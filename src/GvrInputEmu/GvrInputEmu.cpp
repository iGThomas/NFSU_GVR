// GvrInputEmu.cpp  ->  GVRInputRaw.dll  (32-bit, static CRT)
//
// Drop-in replacement for the OEM GVRInputRaw.dll that let UndergroundGVR.exe read the
// arcade cabinet's Immersion force-feedback steering wheel + CUSBIO pedal/button board.
// That hardware is gone, so the original DLL's device enumeration rejects an ordinary
// game controller and the game falls back to digital (full-lock) keyboard steering.
//
// This replacement instead reads a normal Xbox (XInput) or PS4/DS4 (raw HID) controller
// and hands the game analog values through the exact same ABI, so steering is progressive
// (proportional to stick deflection, like the wheel) and the triggers drive throttle/brake.
//
// ---- ABI recovered from the exe (Ghidra) + the real DLL (capstone) ----
// Only UndergroundGVR.exe imports GVRInputRaw; it calls exactly 15 exports, all *cdecl*,
// undecorated names. The game hands Init/Update a pointer to a static state buffer and
// reads these fields out of it:
//     buf+0x00  u8   STEERING   0..255, center 0x80   (game: steer = (char)(buf[0]-0x80))
//     buf+0x02  u8   BRAKE      0..255
//     buf+0x0c  u32  BUTTON BITMASK
//     buf+0x30  u32  INTERFACE-TYPE GATE - MUST be 6, or the game never selects this path
//     buf+0x34  u8   GAS        0..255
// Init(hwnd, buf, "NFSUNDERGROUND") must return 0 AND set buf+0x30 == 6 for the game to
// flip its internal DAT_00c2b42c flag and start using GVRInputRawUpdate(). All the
// Get*Fault / GetUncalibratedAxis / GetStuckAxis calls are cabinet health probes: 0 = OK.
//
// Phase 1 (this build): analog steering + gas + brake only. Buttons (buf+0x0c) are left 0
// and will be mapped in phase 2 once each bit's in-game effect is confirmed empirically.

#include <windows.h>
#include <tlhelp32.h>   // process snapshot: is the race running? (frontend yields z-order to it)
#include <hidsdi.h>
#include <hidpi.h>    // HidP_GetCaps / HIDP_CAPS (input-report length, USB vs BT)
#include <setupapi.h>
#include <cstdint>
#include <cstdio>
#include <intrin.h>   // _ReturnAddress (identify who reads the wheel buffer)

#pragma comment(lib, "hid.lib")
#pragma comment(lib, "setupapi.lib")

// ------------------------------------------------------------------ logging (opt-in)
static FILE* g_log = nullptr;
static void logf(const char* fmt, ...) {
    if (!g_log) return;
    va_list ap; va_start(ap, fmt);
    vfprintf(g_log, fmt, ap);
    va_end(ap);
    fputc('\n', g_log);
    fflush(g_log);
}

// ------------------------------------------------------------------ host detection
// This one DLL is dropped into TWO processes that both use the arcade input ABI:
//   UndergroundGVR.exe  -> the race game (analog wheel + pedals + buttons + gear/camera hooks)
//   UniverShell2.exe    -> the front-end menu shell (reads the wheel axis to pick menu items)
// The game-only code (gear-selector / SetGear / camera-cycle patches at fixed 0x40xxxx addresses)
// must NEVER run in the shell, whose memory map is different. We gate it on the host exe name.
// (The patches are also byte-verified before applying, so this is belt-and-suspenders.)
static bool g_is_game  = false;   // host == UndergroundGVR.exe
static bool g_is_shell = false;   // host == UniverShell2.exe

// ---- diagnostic bisect toggles (env) for the shell race-end hang -------------------------
static bool g_shell_nods4 = false;   // GVR_SHELL_NODS4 : shell doesn't open/read the DS4 (XInput only)
static bool g_shell_nobuf = false;   // GVR_SHELL_NOBUF : shell_update writes nothing (acts absent)
static bool g_shell_nogate = false;  // GVR_SHELL_NOGATE: shell doesn't force buf+0x30=6

static void detect_host() {
    char path[MAX_PATH] = {0};
    GetModuleFileNameA(nullptr, path, MAX_PATH);
    const char* base = strrchr(path, '\\'); base = base ? base + 1 : path;
    g_is_game  = _stricmp(base, "UndergroundGVR.exe") == 0;
    g_is_shell = _stricmp(base, "UniverShell2.exe")   == 0;
    g_shell_nods4  = getenv("GVR_SHELL_NODS4")  != nullptr;
    g_shell_nobuf  = getenv("GVR_SHELL_NOBUF")  != nullptr;
    g_shell_nogate = getenv("GVR_SHELL_NOGATE") != nullptr;
    logf("host exe = %s  (game=%d shell=%d)  toggles: nods4=%d nobuf=%d nogate=%d",
         base, g_is_game, g_is_shell, g_shell_nods4, g_shell_nobuf, g_shell_nogate);
}

// ================== SHELL: proxy the OEM DLL, then overlay the pad ==========================
// The shell hangs at race-end only when WE drive its input buffer; with the OEM DLL it never
// hangs (and its keyboard support works). Rather than keep guessing which of our many
// differences trips the managed loop, we make the shell path OEM-identical BY CONSTRUCTION:
// load the real OEM GVRInputRaw next to us and let IT do Init/Update every frame, then merely
// OVERLAY the gamepad's contribution on top of the buffer it produced. Keyboard therefore keeps
// working exactly as the OEM does it (no manual folding), and the pad is additive.
//   File: "GVRInputRaw_oem.dll" placed beside our DLL (a copy of the OEM 53,248-byte binary).
//   Env GVR_NOOEM=1 forces our own implementation (the previous behaviour) for comparison.
static HINSTANCE g_hinst = nullptr;    // our module handle (locate files next to the DLL)
typedef int (__cdecl *PFN_OemInit)(void*, void*, const char*);
typedef int (__cdecl *PFN_OemUpd)(void*);
static HMODULE     g_oem = nullptr;
static PFN_OemInit g_oemInit = nullptr;
static PFN_OemUpd  g_oemUpdate = nullptr;
static bool        g_oemTried = false, g_oemInited = false;

// Forward ANY export to the OEM DLL by name. The shell's NFSControl polls the health/card probes
// (GetUncalibratedAxis, GetCardStatus, GetAxisFault, ...) every frame and BRANCHES on the answers;
// our hardcoded "0 = healthy" stubs are not what a stock install returns, which sent the idle
// script into a retry/exception loop (the ~100s idle hang). In the shell we therefore forward the
// whole ABI to the OEM and only overlay the gamepad in Update().
static FARPROC oem_proc(const char* name) {
    if (!g_oem) return nullptr;
    return GetProcAddress(g_oem, name);
}
#define OEM_FWD_I0(fn)      do { if (g_is_shell && g_oem) { typedef int (__cdecl *F)(void); \
        static F p = (F)oem_proc(fn); if (p) return p(); } } while (0)
#define OEM_FWD_I1(fn, a)   do { if (g_is_shell && g_oem) { typedef int (__cdecl *F)(int); \
        static F p = (F)oem_proc(fn); if (p) return p(a); } } while (0)
#define OEM_FWD_V0(fn)      do { if (g_is_shell && g_oem) { typedef void (__cdecl *F)(void); \
        static F p = (F)oem_proc(fn); if (p) { p(); return; } } } while (0)
#define OEM_FWD_V1(fn, a)   do { if (g_is_shell && g_oem) { typedef void (__cdecl *F)(int); \
        static F p = (F)oem_proc(fn); if (p) { p(a); return; } } } while (0)
#define OEM_FWD_IP(fn, a)   do { if (g_is_shell && g_oem) { typedef int (__cdecl *F)(void*); \
        static F p = (F)oem_proc(fn); if (p) return p(a); } } while (0)

static void load_oem() {
    if (g_oemTried) return;
    g_oemTried = true;
    if (getenv("GVR_NOOEM")) { logf("oem: disabled by GVR_NOOEM"); return; }
    char path[MAX_PATH] = {0};
    GetModuleFileNameA(g_hinst, path, MAX_PATH);
    char* s = strrchr(path, '\\');
    if (s) strcpy(s + 1, "GVRInputRaw_oem.dll"); else strcpy(path, "GVRInputRaw_oem.dll");
    g_oem = LoadLibraryA(path);
    if (!g_oem) { logf("oem: NOT loaded (%s) err=%lu - using our own shell path", path, GetLastError()); return; }
    g_oemInit   = (PFN_OemInit)GetProcAddress(g_oem, "GVRInputRawInit");
    g_oemUpdate = (PFN_OemUpd)GetProcAddress(g_oem, "GVRInputRawUpdate");
    logf("oem: loaded %s (Init=%p Update=%p)", path, g_oemInit, g_oemUpdate);
}

static void maybe_open_log() {
    if (g_log || !getenv("GVRINPUT_LOG")) return;
    // PER-PROCESS log file. Both the shell and the game load this DLL; with one shared filename
    // each fopen(...,"w") TRUNCATED the file while the other process still held it open at a large
    // offset, so the survivor kept writing past EOF into a sparse gap (heavy, pointless I/O on the
    // input thread). Name the file after the host exe + pid so they can never collide.
    char exe[MAX_PATH] = {0};
    GetModuleFileNameA(nullptr, exe, MAX_PATH);
    const char* base = strrchr(exe, '\\'); base = base ? base + 1 : exe;
    char stem[64]; lstrcpynA(stem, base, sizeof(stem));
    char* dot = strrchr(stem, '.'); if (dot) *dot = 0;
    char path[MAX_PATH]; DWORD n = GetTempPathA(MAX_PATH, path);
    wsprintfA(path + n, "gvrinput_%s_%lu.log", stem, GetCurrentProcessId());
    g_log = fopen(path, "w");
}

// ------------------------------------------------------------------ XInput (Xbox)
// Loaded dynamically so the DLL still loads on systems without XInput (e.g. XP); there we
// simply fall back to the DS4 HID path.
struct XINPUT_GAMEPAD_ { WORD wButtons; BYTE bLeftTrigger, bRightTrigger;
                         SHORT sThumbLX, sThumbLY, sThumbRX, sThumbRY; };
struct XINPUT_STATE_   { DWORD dwPacketNumber; XINPUT_GAMEPAD_ Gamepad; };
typedef DWORD (WINAPI *PFN_XInputGetState)(DWORD, XINPUT_STATE_*);
static PFN_XInputGetState pXInputGetState = nullptr;

static void load_xinput() {
    if (pXInputGetState) return;
    const char* names[] = { "xinput1_4.dll", "xinput1_3.dll", "xinput9_1_0.dll" };
    for (const char* n : names) {
        HMODULE h = LoadLibraryA(n);
        if (h) {
            pXInputGetState = (PFN_XInputGetState)GetProcAddress(h, "XInputGetState");
            if (pXInputGetState) { logf("xinput: using %s", n); return; }
        }
    }
    logf("xinput: not available");
}

// ------------------------------------------------------------------ DS4 (raw HID)
static HANDLE   g_ds4  = INVALID_HANDLE_VALUE;
static OVERLAPPED g_ov = {};
static HANDLE   g_ev   = nullptr;
static bool     g_read_pending = false;
// HID ReadFile must be given a buffer >= the collection's InputReportByteLength and read that
// many bytes. USB DS4 = 64, but a Bluetooth DS4 reports a MUCH larger length (seen: 547) - a
// fixed 78-byte buffer makes the BT read fail, which is why the pad was dead over Bluetooth.
// Use a generous fixed buffer and read exactly g_rptlen (set from the device caps).
static uint8_t  g_rpt[1024]    = {};
static DWORD    g_rptlen       = 78;    // InputReportByteLength of the chosen collection

// latched analog state (defaults = centered/released)
static volatile int g_ds4_steer = 128, g_ds4_gas = 0, g_ds4_brake = 0;
static volatile bool g_ds4_fresh = false;

// ------------------------------------------------------------------ buttons (unified)
// Source-agnostic button flags; both the DS4 HID decoder and the XInput reader fill these.
enum {
    UB_CROSS = 1u<<0, UB_CIRCLE = 1u<<1, UB_SQUARE = 1u<<2, UB_TRIANGLE = 1u<<3,
    UB_L1 = 1u<<4, UB_R1 = 1u<<5, UB_L2 = 1u<<6, UB_R2 = 1u<<7,
    UB_SHARE = 1u<<8, UB_OPTIONS = 1u<<9, UB_L3 = 1u<<10, UB_R3 = 1u<<11,
    UB_PS = 1u<<12, UB_DUP = 1u<<13, UB_DDOWN = 1u<<14, UB_DLEFT = 1u<<15, UB_DRIGHT = 1u<<16,
};
static volatile unsigned g_ds4_btn = 0;

// A pad button -> game bitmask (buf+0x0c) entry.
struct BtnMap { unsigned ub; uint32_t gbit; const char* name; };

// DISCOVERY table: each pad button on a DISTINCT candidate game bit (the bits the engine tests).
// Press each in-game and note what it does; then fill FINAL_MAP below.
static const BtnMap DISCOVERY_MAP[] = {
    { UB_CROSS,    0x00000001, "Cross"    },
    { UB_CIRCLE,   0x00000002, "Circle"   },
    { UB_SQUARE,   0x00000010, "Square"   },
    { UB_TRIANGLE, 0x00000100, "Triangle" },
    { UB_L1,       0x00000200, "L1"       },
    { UB_R1,       0x00000400, "R1"       },
    { UB_DUP,      0x00010000, "DpadUp"   },
    { UB_DDOWN,    0x00020000, "DpadDown" },
    { UB_DLEFT,    0x00040000, "DpadLeft" },
    { UB_DRIGHT,   0x00080000, "DpadRight"},
};

// FINAL table (user layout). Game bits discovered empirically:
//   0x200=look-back, 0x400=nitrous(NOS), 0x20000=e-brake, 0x10=start/reset, 0x100=music.
//   Gears (0x1/0x2/0x80000 combos) + camera(V) are handled separately (see PHASE 2b).
static const BtnMap FINAL_MAP[] = {
    { UB_L1,      0x00000200, "LookBack" },   // Look back  -> L1
    { UB_CIRCLE,  0x00000400, "Nitrous"  },   // Nitrous    -> Circle
    { UB_CROSS,   0x00020000, "Ebrake"   },   // E-brake    -> Cross
    { UB_OPTIONS, 0x00000010, "Start"    },   // Start/reset-> Options (bonus; free button)
    { UB_DRIGHT,  0x00000100, "Music"    },   // Music/volume ('M') -> D-pad right (free in-race)
};

// ---- sequential shifter (manual transmission, launch arg -trans 1) ----
// The arcade 6-speed encodes gear via raw bits 0x1/0x2/0x80000 -> gear value table [2,4,6,3,5,7]
// (none->4). We emit the combo for the current gear; Square = up, Triangle = down. These gear bits
// are ignored by the game in automatic mode (user-confirmed in discovery), so emitting is harmless.
// Order is by ascending gear value (2..7); refine after the in-game test if the sequence is wrong.
static const uint32_t GEAR_COMBO[7] = {
    0,                 // [0] unused
    0x00000001,        // gear 1  (value 2)          = 0x1
    0x00080001,        // gear 2  (value 3)          = 0x1 | 0x80000
    0x00000000,        // gear 3  (value 4, default) = none
    0x00080000,        // gear 4  (value 5)          = 0x80000
    0x00000002,        // gear 5  (value 6)          = 0x2
    0x00080002,        // gear 6  (value 7)          = 0x2 | 0x80000
};
static int g_gear = 1;
static bool g_cam_ok = false;   // set in Init: the camera-cycle fn @0x58f740 is present (right exe)

// ---- gear-selector hook (to read/override the game's transmission clamp) ----
// The game's FUN_004276c0 @ 0x004276c0 turns the gear-bit flags into a gear value, then clamps it
// DOWN by  [[[car+0x26c]+0x20]+0x1c8]+1  which squashes the top-row H-pattern positions. We replace
// the function with our own copy (exe base fixed at 0x400000, no ASLR) so we can log the clamp and,
// if desired, drop it so all 6 gears are selectable.
static volatile uint32_t g_car = 0;
static volatile int g_capsrc = -1, g_selval = -1;
static bool g_drop_clamp = false;   // set via env GVR_NOCLAMP

extern "C" int __cdecl my_gear_selector(int car) {
    // SEQUENTIAL shifter: return our clean g_gear (1..6) as a gear-position value (2..7),
    // bypassing the noisy H-pattern bit flags. Mimics the game's keyboard incrementer, which
    // works reliably (car+0x1d4 = 2..7 all engage). g_gear is edge-stepped in Update by Square/Triangle.
    *(volatile uint8_t*)0x007d3b10 = 1;                        // signal "gear input active"
    int val = g_gear + 1;                                      // g_gear 1..6 -> 2..7
    int cap;
    __try {
        cap = *(volatile int*)(*(volatile uint32_t*)(*(volatile uint32_t*)(car + 0x26c) + 0x20) + 0x1c8) + 1;
    } __except (EXCEPTION_EXECUTE_HANDLER) {
        g_car = (uint32_t)car; g_selval = val; return val;     // can't read clamp -> pass through
    }
    g_car = (uint32_t)car; g_capsrc = cap; g_selval = val;
    if (!g_drop_clamp && cap < val) val = cap;                 // keep original safety clamp (cap=8)
    return val;
}

static void* g_hookptr = (void*)&my_gear_selector;

// The engaged-gear value we want on the player car. The physics loop's SetGear (0x422910,
// `SetGear(this, gear){ this->[0x1d4] = gear; }`) writes the FSM result over car+0x1d4 every
// frame, which rounds our request. We replace SetGear so the PLAYER car takes our value instead,
// bypassing the transmission FSM. Non-player (AI) cars keep the stock behavior.
static volatile int g_engaged = 2;

__declspec(naked) void my_setgear_stub() {
    __asm {
        mov eax, dword ptr [g_car]      ; player car ptr
        test eax, eax
        je   use_arg
        cmp  ecx, eax                   ; this == player car?
        jne  use_arg
        mov  eax, dword ptr [g_engaged]
        mov  dword ptr [ecx + 0x1d4], eax
        ret  4
    use_arg:
        mov  eax, dword ptr [esp + 4]   ; stock: this->[0x1d4] = arg
        mov  dword ptr [ecx + 0x1d4], eax
        ret  4
    }
}
static void* g_setgearptr = (void*)&my_setgear_stub;

static bool g_hook_installed = false;
static bool patch_jmp(uint32_t at, void** targetPtr) {   // patch `jmp dword ptr [targetPtr]` (6B)
    uint8_t patch[6] = { 0xFF, 0x25, 0,0,0,0 };
    uint32_t pa = (uint32_t)targetPtr; memcpy(patch + 2, &pa, 4);
    DWORD old;
    if (!VirtualProtect((void*)at, 6, PAGE_EXECUTE_READWRITE, &old)) return false;
    memcpy((void*)at, patch, 6);
    VirtualProtect((void*)at, 6, old, &old);
    FlushInstructionCache(GetCurrentProcess(), (void*)at, 6);
    return true;
}
static void install_gear_hook() {
    if (g_hook_installed) return;
    if (!g_is_game) return;                   // game-only: never patch fixed addrs in the shell
    if (getenv("GVR_NOGEARHOOK")) return;     // ON by default (the sequential-shifter fix); opt-out
    g_drop_clamp = getenv("GVR_NOCLAMP") != nullptr;
    // Verify the expected original bytes first, so we never patch a different exe build (would crash).
    if (*(volatile uint8_t*)0x004276c0 != 0x53) return;   // GearSelector: push ebx
    if (*(volatile uint8_t*)0x00422910 != 0x8B) return;   // SetGear: mov eax,[esp+4]
    patch_jmp(0x004276c0, &g_hookptr);        // GearSelector -> our sequential value
    patch_jmp(0x00422910, &g_setgearptr);     // SetGear -> force our engaged gear on the player car
    g_hook_installed = true;
}

// R1 -> tap the "change view" key (V). The arcade input has no view-change bit, so we synthesize
// the keyboard key the game reads via DirectInput (DIK_V scancode 0x2F).
static void tap_view_key() {
    INPUT in[2] = {};
    in[0].type = INPUT_KEYBOARD;
    in[0].ki.wScan = 0x2F;                              // DIK_V scancode
    in[0].ki.dwFlags = KEYEVENTF_SCANCODE;
    in[1] = in[0];
    in[1].ki.dwFlags = KEYEVENTF_SCANCODE | KEYEVENTF_KEYUP;
    SendInput(2, in, sizeof(INPUT));
}

// ---- configurable button map (optional GvrInput.ini next to the DLL) -----------------------
// Any pad can be corrected without a rebuild. Lines are `<button>=<action>`, e.g.
//   Cross=ebrake   Circle=nitrous   L1=lookback   Options=start
//   Square=shiftup Triangle=shiftdown  R1=camera   Share=none
// A button not listed keeps its default; a MISSING file reproduces the exact previous behaviour.
static const struct { const char* name; unsigned ub; } PAD_BUTTONS[] = {
    {"cross",UB_CROSS},{"circle",UB_CIRCLE},{"square",UB_SQUARE},{"triangle",UB_TRIANGLE},
    {"l1",UB_L1},{"r1",UB_R1},{"l2",UB_L2},{"r2",UB_R2},{"options",UB_OPTIONS},{"share",UB_SHARE},
    {"l3",UB_L3},{"r3",UB_R3},{"dup",UB_DUP},{"ddown",UB_DDOWN},{"dleft",UB_DLEFT},
    {"dright",UB_DRIGHT},{"ps",UB_PS},
    // Xbox aliases. The map is POSITIONAL - an Xbox pad is normalised onto the same internal
    // buttons - so these are alternative SPELLINGS of the entries above, not extra buttons:
    //   A=bottom  B=right  X=left  Y=top   (both layouts agree on those positions)
    {"a",UB_CROSS},{"b",UB_CIRCLE},{"x",UB_SQUARE},{"y",UB_TRIANGLE},
    {"lb",UB_L1},{"rb",UB_R1},{"lt",UB_L2},{"rt",UB_R2},
    {"start",UB_OPTIONS},{"menu",UB_OPTIONS},          // "Menu" on an Xbox One pad
    {"back",UB_SHARE},{"view",UB_SHARE},               // "View" on an Xbox One pad
    {"ls",UB_L3},{"rs",UB_R3},{"guide",UB_PS},         // Guide is DS4-only: XInput does not report it
};
// Actions that are NOT a plain buffer bit. camera/shift synthesise a keystroke; quit/skipintro/
// confirm gate a piece of logic further down. Each is a single global, so assigning it to another
// button simply moves it - and a button keeps them even when its bit-action is reassigned, so an
// ini written before these existed still behaves exactly as it did.
enum { SPEC_NONE=0, SPEC_CAMERA=1, SPEC_SHIFTUP=2, SPEC_SHIFTDOWN=3,
       SPEC_QUIT=4, SPEC_SKIPINTRO=5, SPEC_CONFIRM=6 };
static const struct { const char* name; uint32_t gbit; int spec; } PAD_ACTIONS[] = {
    {"ebrake",0x20000,0},{"nitrous",0x400,0},{"lookback",0x200,0},{"start",0x10,0},
    {"reset",0x10,0},{"music",0x100,0},{"camera",0,SPEC_CAMERA},{"shiftup",0,SPEC_SHIFTUP},
    {"shiftdown",0,SPEC_SHIFTDOWN},{"quit",0,SPEC_QUIT},{"skipintro",0,SPEC_SKIPINTRO},
    {"confirm",0,SPEC_CONFIRM},{"none",0,SPEC_NONE},
};
static BtnMap   g_map[24];
static int      g_map_n = 0;
static unsigned g_ub_camera = UB_R1, g_ub_shiftup = UB_SQUARE, g_ub_shiftdown = UB_TRIANGLE;
static unsigned g_ub_quit = UB_DDOWN;        // opens the game's own QUIT GAME? prompt
static unsigned g_ub_skipintro = UB_CROSS;   // skips the race-start fly-by
static unsigned g_ub_confirm = UB_CROSS;     // answers the quit prompt (the pad's 'S')

// ---- frontend (UniverShell2) map ---------------------------------------------------------------
// A separate map because the SAME button means different things in the two programs (Cross is the
// e-brake in a race but "select" in the menus), so one button->action table cannot express both.
// Values are the buffer bits at buf+0x0c that the OEM driver folded from its DirectInput keyboard.
struct FrontMap { unsigned ub; uint32_t bit; const char* name; };
static const FrontMap FRONT_DEFAULT[] = {
    { UB_CROSS,   0x10,    "select"    },   // 'S' - select / start / swipe card
    { UB_OPTIONS, 0x20,    "operator"  },   // 'O' - operator menu
    { UB_DUP,     0x10000, "navup"     },   // arrow keys - operator-menu navigation
    { UB_DDOWN,   0x200,   "navdown"   },
    { UB_DLEFT,   0x400,   "navleft"   },
    { UB_DRIGHT,  0x100,   "navright"  },
    { UB_CIRCLE,  0x20000, "exit"      },   // 'E' - back / exit to main
    { UB_R2,      0x100,   "accept"    },   // career screens: accept a letter (same bit as right)
    { UB_L2,      0x400,   "backspace" },   // career screens: backspace     (same bit as left)
};
static const struct { const char* name; uint32_t bit; } FRONT_ACTIONS[] = {
    {"select",0x10},{"operator",0x20},{"navup",0x10000},{"navdown",0x200},{"navleft",0x400},
    {"navright",0x100},{"exit",0x20000},{"accept",0x100},{"backspace",0x400},{"none",0},
    {"card",0},   // owned by CardEmu\GvrCardKey.exe, which reads the same line; accepted here
};                // (bit 0) purely so it is not reported as an unknown action
static FrontMap g_fmap[24];
static int      g_fmap_n = 0;

static void map_defaults() {
    g_map_n = (int)(sizeof(FINAL_MAP)/sizeof(BtnMap));
    for (int i = 0; i < g_map_n; ++i) g_map[i] = FINAL_MAP[i];
    g_ub_camera = UB_R1; g_ub_shiftup = UB_SQUARE; g_ub_shiftdown = UB_TRIANGLE;
    g_ub_quit = UB_DDOWN; g_ub_skipintro = UB_CROSS; g_ub_confirm = UB_CROSS;
    g_fmap_n = (int)(sizeof(FRONT_DEFAULT)/sizeof(FrontMap));
    for (int i = 0; i < g_fmap_n; ++i) g_fmap[i] = FRONT_DEFAULT[i];
}
static void map_clear_ub(unsigned ub) {                    // drop any prior assignment of this button
    for (int i = 0; i < g_map_n; ) {
        if (g_map[i].ub == ub) { for (int j = i; j < g_map_n-1; ++j) g_map[j] = g_map[j+1]; --g_map_n; }
        else ++i;
    }
    if (g_ub_camera == ub) g_ub_camera = 0;
    if (g_ub_shiftup == ub) g_ub_shiftup = 0;
    if (g_ub_shiftdown == ub) g_ub_shiftdown = 0;
}
// One button may carry several actions (`Cross = ebrake, skipintro, confirm`), because the same
// button legitimately means different things in different states of the game.
static void map_set_one(unsigned ub, const char* action, bool& clearedBits) {
    for (auto& a : PAD_ACTIONS) if (_stricmp(a.name, action) == 0) {
        if      (a.spec == SPEC_CAMERA)    g_ub_camera = ub;
        else if (a.spec == SPEC_SHIFTUP)   g_ub_shiftup = ub;
        else if (a.spec == SPEC_SHIFTDOWN) g_ub_shiftdown = ub;
        else if (a.spec == SPEC_QUIT)      g_ub_quit = ub;
        else if (a.spec == SPEC_SKIPINTRO) g_ub_skipintro = ub;
        else if (a.spec == SPEC_CONFIRM)   g_ub_confirm = ub;
        else if (a.gbit) {
            // the first bit-action listed replaces whatever this button had; further ones add to it
            if (!clearedBits) { map_clear_ub(ub); clearedBits = true; }
            if (g_map_n < 24) { g_map[g_map_n].ub = ub; g_map[g_map_n].gbit = a.gbit; g_map[g_map_n].name = a.name; ++g_map_n; }
        } else if (a.spec == SPEC_NONE && !clearedBits) { map_clear_ub(ub); clearedBits = true; }  // `= none`
        return;
    }
    logf("cfg: unknown action '%s'", action);
}
static void map_set(unsigned ub, const char* actions) {
    char buf[128]; lstrcpynA(buf, actions, sizeof(buf));
    bool cleared = false;
    for (char* tok = strtok(buf, ","); tok; tok = strtok(nullptr, ",")) {
        while (*tok == ' ' || *tok == '\t') ++tok;
        char* e = tok + strlen(tok); while (e > tok && (e[-1]==' '||e[-1]=='\t')) *--e = 0;
        if (*tok) map_set_one(ub, tok, cleared);
    }
}

// ---- the same, for the frontend map ------------------------------------------------------------
static void front_clear_ub(unsigned ub) {
    for (int i = 0; i < g_fmap_n; ) {
        if (g_fmap[i].ub == ub) { for (int j = i; j < g_fmap_n-1; ++j) g_fmap[j] = g_fmap[j+1]; --g_fmap_n; }
        else ++i;
    }
}
static void front_set(unsigned ub, const char* actions) {
    char buf[128]; lstrcpynA(buf, actions, sizeof(buf));
    front_clear_ub(ub);
    for (char* tok = strtok(buf, ","); tok; tok = strtok(nullptr, ",")) {
        while (*tok == ' ' || *tok == '\t') ++tok;
        char* e = tok + strlen(tok); while (e > tok && (e[-1]==' '||e[-1]=='\t')) *--e = 0;
        if (!*tok) continue;
        bool known = false;
        for (auto& a : FRONT_ACTIONS) if (_stricmp(a.name, tok) == 0) {
            known = true;
            if (a.bit && g_fmap_n < 24) { g_fmap[g_fmap_n].ub = ub; g_fmap[g_fmap_n].bit = a.bit; g_fmap[g_fmap_n].name = a.name; ++g_fmap_n; }
            break;
        }
        if (!known) logf("cfg: unknown frontend action '%s'", tok);
    }
}
// pad state -> the frontend's buf+0x0c button bits
static uint32_t front_bits(unsigned ub) {
    if (g_fmap_n == 0) map_defaults();
    uint32_t g = 0;
    for (int i = 0; i < g_fmap_n; ++i) if (g_fmap[i].ub && (ub & g_fmap[i].ub)) g |= g_fmap[i].bit;
    return g;
}
// Locate the shared gvr_settings.ini: it sits at the INSTALL ROOT while this DLL sits 1-3 levels
// below it, so walk up from our own directory. Returns true and fills `out` when found.
static bool find_settings_ini(char* out, size_t n) {
    char probe[MAX_PATH] = {0};
    GetModuleFileNameA(g_hinst, probe, MAX_PATH);
    char* s = strrchr(probe, '\\'); if (s) *s = 0;
    for (int up = 0; up <= 4; ++up) {
        char cand[MAX_PATH];
        wsprintfA(cand, "%s\\gvr_settings.ini", probe);
        if (GetFileAttributesA(cand) != INVALID_FILE_ATTRIBUTES) { lstrcpynA(out, cand, (int)n); return true; }
        char* q = strrchr(probe, '\\'); if (!q) break; *q = 0;
    }
    return false;
}

// ---- automatic RACE resolution ---------------------------------------------------------------
// UndergroundGVR.exe STATICALLY imports this DLL, so our DllMain runs BEFORE the exe's entry
// point - early enough to patch the hardcoded device resolution in memory, before D3D is created.
// That means gvr_settings.ini [Race] applies on the next launch with NO tool run and, crucially,
// WITHOUT modifying UndergroundGVR.exe on disk at all.
//   device init FUN_005c40e0 -> call FUN_005c3d30(width,height); the two `push imm32` operands
//   live at VA 0x005c431e (height) and 0x005c4323 (width) - each preceded by the 0x68 opcode,
//   which we verify before writing so a different build is never corrupted.
static bool g_want_center = false;      // centre our window once it appears
static bool g_center_resize = true;     // game: also resize the client; shell: position only
static bool g_borderless = true;        // windowed race: strip the title bar / frame
static bool g_race_windowed = false;    // race is running windowed (so z-order is ours to manage)
static int  g_win_w = 0, g_win_h = 0;
static void center_window_once();       // defined below; called from both update paths

// true when a window of OUR process owns the foreground
static bool our_process_is_foreground() {
    HWND fg = GetForegroundWindow(); if (!fg) return false;
    DWORD pid = 0; GetWindowThreadProcessId(fg, &pid);
    return pid == GetCurrentProcessId();
}

// true when the foreground belongs to ANY part of this game (frontend, race, or our launcher).
// The z-order rules must use THIS, not "is it my own process": the shell launches the race and
// keeps the foreground for a moment, so a strict same-process test made the race demote itself
// below the taskbar until the player alt-tabbed to it.
static bool foreground_is_our_app(char* outName = nullptr, size_t outN = 0) {
    if (outName && outN) outName[0] = 0;
    HWND fg = GetForegroundWindow(); if (!fg) return false;
    DWORD pid = 0; GetWindowThreadProcessId(fg, &pid);
    if (!pid) return false;
    if (pid == GetCurrentProcessId()) { if (outName && outN) lstrcpynA(outName, "(self)", (int)outN); return true; }
    HANDLE p = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!p) return false;
    char path[MAX_PATH] = ""; DWORD n = MAX_PATH;
    bool ok = QueryFullProcessImageNameA(p, 0, path, &n) != 0;
    CloseHandle(p);
    if (!ok) return false;
    const char* b = strrchr(path, '\\'); b = b ? b + 1 : path;
    if (outName && outN) lstrcpynA(outName, b, (int)outN);
    return _stricmp(b, "UniverShell2.exe")   == 0 ||
           _stricmp(b, "UndergroundGVR.exe") == 0 ||
           _stricmp(b, "GvrLaunch.exe")      == 0;
}

// Is (w,h) a real display mode this adapter enumerates? The game makes a FULLSCREEN D3D device,
// so an invented size (e.g. 1440x1080 on a 1080p panel) makes CreateDevice fail and the race
// crashes on launch. Windowed mode has no such constraint.
static bool display_mode_available(int w, int h) {
    DEVMODEA dm; ZeroMemory(&dm, sizeof(dm)); dm.dmSize = sizeof(dm);
    for (int i = 0; EnumDisplaySettingsA(nullptr, i, &dm); ++i)
        if ((int)dm.dmPelsWidth == w && (int)dm.dmPelsHeight == h && dm.dmBitsPerPel >= 32) return true;
    return false;
}
// Closest usable mode: prefer the same aspect ratio, then the largest that still fits.
static bool nearest_display_mode(int wantW, int wantH, int* outW, int* outH) {
    DEVMODEA dm; ZeroMemory(&dm, sizeof(dm)); dm.dmSize = sizeof(dm);
    double wantAspect = (double)wantW / (double)wantH;
    int bestW = 0, bestH = 0; double bestScore = 1e18;
    for (int i = 0; EnumDisplaySettingsA(nullptr, i, &dm); ++i) {
        if (dm.dmBitsPerPel < 32) continue;
        int mw = (int)dm.dmPelsWidth, mh = (int)dm.dmPelsHeight;
        if (mw < 640 || mh < 480) continue;
        double aspectErr = (double)mw / (double)mh - wantAspect; if (aspectErr < 0) aspectErr = -aspectErr;
        double areaErr = (double)(mw * mh - wantW * wantH) / (double)(wantW * wantH);
        if (areaErr < 0) areaErr = -areaErr;
        double score = aspectErr * 10.0 + areaErr;        // aspect matters most (avoids stretching)
        if (score < bestScore) { bestScore = score; bestW = mw; bestH = mh; }
    }
    if (!bestW) return false;
    *outW = bestW; *outH = bestH; return true;
}

// One shared [Display] section drives both programs. [Race]/[Shell] are still honoured as a
// fallback so installs made before the merge keep working.
static int ini_int(const char* ini, const char* key, int def) {
    int v = GetPrivateProfileIntA("Display", key, -1, ini);
    if (v < 0) v = GetPrivateProfileIntA("Race", key, -1, ini);
    if (v < 0) v = GetPrivateProfileIntA("Shell", key, -1, ini);
    return v < 0 ? def : v;
}
static bool ini_bool(const char* ini, const char* key, bool def) {
    char buf[32] = {0};
    GetPrivateProfileStringA("Display", key, "", buf, sizeof(buf), ini);
    if (!buf[0]) GetPrivateProfileStringA("Race", key, "", buf, sizeof(buf), ini);
    if (!buf[0]) return def;
    return !(_stricmp(buf, "false") == 0 || _stricmp(buf, "0") == 0 || _stricmp(buf, "no") == 0);
}

static void apply_race_resolution() {
    char ini[MAX_PATH];
    if (!find_settings_ini(ini, sizeof(ini))) { logf("res: no gvr_settings.ini found - leaving stock resolution"); return; }
    int w = ini_int(ini, "Width",  0);
    int h = ini_int(ini, "Height", 0);
    if (w <= 0 || h <= 0) { logf("res: [Display] Width/Height not set in %s", ini); return; }

    // Validate against real display modes unless the game was told to run windowed.
    const char* cl = GetCommandLineA();
    bool windowed = cl && (strstr(cl, "-forcewindowed") != nullptr);
    if (!windowed && !display_mode_available(w, h)) {
        int nw = 0, nh = 0;
        if (nearest_display_mode(w, h, &nw, &nh)) {
            logf("res: %dx%d is NOT a display mode this adapter supports - fullscreen CreateDevice "
                 "would fail (black screen / crash on race start). Using nearest supported %dx%d instead.", w, h, nw, nh);
            w = nw; h = nh;
        } else {
            logf("res: %dx%d unsupported and no alternative found - leaving stock resolution", w, h);
            return;
        }
    }

    // TWO call sites feed the device-size setup FUN_005c3d30(width,height), and BOTH must be
    // patched. The second one is the reason windowed mode still came up 800x600:
    //   0x5c431d: push <height> / 0x5c4322: push <width>   -> main device init
    //   0x5c50d9: push <height> / 0x5c50de: push <width>   -> the resolution-switch path
    //             (guarded by `cmp [g_RacingResolution],1`)
    struct Site { uint32_t opH, opW; const char* what; };
    const Site sites[] = {
        { 0x005c431d, 0x005c4322, "device-init" },
        { 0x005c50d9, 0x005c50de, "resolution-switch" },
    };
    int done = 0;
    for (const Site& s : sites) {
        bool ok = false;
        __try { ok = (*(volatile uint8_t*)s.opH == 0x68 && *(volatile uint8_t*)s.opW == 0x68); }
        __except (EXCEPTION_EXECUTE_HANDLER) { ok = false; }
        if (!ok) { logf("res: %s site is not push imm32 - skipped", s.what); continue; }
        DWORD old;
        if (VirtualProtect((void*)(s.opH + 1), 4, PAGE_EXECUTE_READWRITE, &old)) {
            *(volatile uint32_t*)(s.opH + 1) = (uint32_t)h; VirtualProtect((void*)(s.opH + 1), 4, old, &old);
        }
        if (VirtualProtect((void*)(s.opW + 1), 4, PAGE_EXECUTE_READWRITE, &old)) {
            *(volatile uint32_t*)(s.opW + 1) = (uint32_t)w; VirtualProtect((void*)(s.opW + 1), 4, old, &old);
        }
        FlushInstructionCache(GetCurrentProcess(), (void*)s.opH, 16);
        ++done;
    }
    g_want_center = windowed;                    // windowed: also centre the window once it exists
    g_race_windowed = windowed;                  // and keep its z-order in step with focus
    g_win_w = w; g_win_h = h;
    // [Display] Borderless=true|false - drop the title bar in windowed mode (default true)
    g_borderless = ini_bool(ini, "Borderless", true);
    logf("res: race resolution set to %dx%d from %s (%d/%d sites, %s; exe untouched)",
         w, h, ini, done, 2, windowed ? "windowed" : "fullscreen");
}

// Windows refuses SetForegroundWindow() from a process that does not already own the foreground
// (here the shell still does when the race launches), so temporarily attach our input queue to the
// current foreground thread - the standard way to make the activation actually stick.
static void force_foreground(HWND h) {
    HWND fg = GetForegroundWindow();
    DWORD fgThread  = fg ? GetWindowThreadProcessId(fg, nullptr) : 0;
    DWORD ourThread = GetWindowThreadProcessId(h, nullptr);
    if (fgThread && fgThread != ourThread) AttachThreadInput(ourThread, fgThread, TRUE);
    ShowWindow(h, SW_SHOW);
    BringWindowToTop(h);
    SetForegroundWindow(h);
    SetActiveWindow(h);
    SetFocus(h);
    if (fgThread && fgThread != ourThread) AttachThreadInput(ourThread, fgThread, FALSE);
    logf("res: race window brought to front and focused");
}

// ---- centre the windowed race on screen ------------------------------------------------------
// With -forcewindowed the game creates its window at a fixed (100,10). Once it exists we move it
// to the middle of the primary monitor (and never touch it in fullscreen).
static BOOL CALLBACK center_enum(HWND h, LPARAM) {
    DWORD pid = 0; GetWindowThreadProcessId(h, &pid);
    if (pid != GetCurrentProcessId() || !IsWindowVisible(h) || GetWindow(h, GW_OWNER)) return TRUE;
    RECT rc; GetClientRect(h, &rc);
    if (rc.right < 320 || rc.bottom < 240) return TRUE;          // skip helper windows

    int sw = GetSystemMetrics(SM_CXSCREEN), sh = GetSystemMetrics(SM_CYSCREEN);

    // SHELL: GvrLaunch patches the size constants before the process runs, but the .NET form
    // settles a few pixels short of what we asked for (seen: 1440x1067 for a requested 1440x1080),
    // which makes the frontend look inset compared to the race. Snap it to the exact requested
    // size (it is borderless, so window rect == client rect) and centre it.
    if (!g_center_resize) {
        RECT wr; GetWindowRect(h, &wr);
        int ww0 = wr.right - wr.left, wh0 = wr.bottom - wr.top;
        if (g_win_w > 0 && g_win_h > 0 && g_win_w <= sw && g_win_h <= sh) { ww0 = g_win_w; wh0 = g_win_h; }
        int x0 = (sw - ww0) / 2, y0 = (sh - wh0) / 2;
        if (x0 < 0) x0 = 0; if (y0 < 0) y0 = 0;
        // HWND_NOTOPMOST: the frontend makes itself always-on-top, which covers the taskbar and
        // makes alt-tabbing away awkward - it behaves like a fullscreen takeover. Drop that so it
        // is a normal borderless window you can switch away from.
        SetWindowPos(h, HWND_NOTOPMOST, x0, y0, ww0, wh0, SWP_NOACTIVATE);
        RECT after; GetClientRect(h, &after);
        logf("res: shell window -> %dx%d at (%d,%d) (client %dx%d) on %dx%d screen",
             ww0, wh0, x0, y0, after.right, after.bottom, sw, sh);
        g_want_center = false;
        return FALSE;
    }

    // GAME: the window is created at a fixed 800x600 client, INDEPENDENT of the D3D backbuffer
    // (patching the device size alone left an 800x600 window showing a downscaled image). In
    // windowed mode Present() stretches the backbuffer to the client area, so sizing the client to
    // the requested resolution gives a 1:1, correctly-sized picture.
    int cw = g_win_w, ch = g_win_h;
    if (cw <= 0 || ch <= 0) { cw = rc.right; ch = rc.bottom; }
    // never larger than the desktop work area
    if (cw > sw) { ch = (int)((double)ch * sw / cw); cw = sw; }
    if (ch > sh) { cw = (int)((double)cw * sh / ch); ch = sh; }

    LONG style   = GetWindowLong(h, GWL_STYLE);
    LONG exStyle = GetWindowLong(h, GWL_EXSTYLE);
    int ww, wh;
    if (g_borderless) {
        // Strip the caption/frame so the picture fills the whole window: the client area then
        // equals the window rect, giving a clean "borderless windowed" look at the exact
        // resolution. SWP_FRAMECHANGED makes Windows re-evaluate the new style.
        style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX |
                   WS_SYSMENU | WS_BORDER | WS_DLGFRAME);
        style |= WS_POPUP;
        SetWindowLong(h, GWL_STYLE, style);
        ww = cw; wh = ch;                       // no frame -> window size == client size
    } else {
        RECT want = { 0, 0, cw, ch };
        AdjustWindowRectEx(&want, style & ~WS_OVERLAPPED, GetMenu(h) != nullptr, exStyle);
        ww = want.right - want.left; wh = want.bottom - want.top;
    }
    int x = (sw - ww) / 2, y = (sh - wh) / 2;
    if (x < 0) x = 0; if (y < 0) y = 0;
    // Bring it to the top AND activate it. Restyling to WS_POPUP re-orders the window, and the
    // shell is still the foreground app when the race starts, so without this the race window
    // ends up behind everything and the player has to click it to get input.
    // NOT topmost on purpose: a topmost borderless window behaves like an exclusive fullscreen
    // app - it covers the taskbar and makes alt-tabbing to another program painful. We just bring
    // it to the top of the normal z-order and focus it.
    SetWindowPos(h, HWND_TOP, x, y, ww, wh, SWP_SHOWWINDOW | (g_borderless ? SWP_FRAMECHANGED : 0));
    force_foreground(h);

    RECT after; GetClientRect(h, &after);
    logf("res: window -> client %dx%d (asked %dx%d), frame %dx%d at (%d,%d) on %dx%d screen",
         after.right, after.bottom, cw, ch, ww, wh, x, y, sw, sh);
    g_want_center = false;                                        // once is enough
    return FALSE;
}
static void center_window_once() {
    if (!g_want_center) return;
    static DWORD firstSeen = 0;
    if (!firstSeen) firstSeen = GetTickCount();
    if (GetTickCount() - firstSeen > 20000) { g_want_center = false; return; }   // give up after 20s
    EnumWindows(center_enum, 0);
}

// Parse an ini and apply `<button>=<action>` pairs. When `wantSection` is non-null only lines
// inside that [Section] are applied (so the shared gvr_settings.ini's [Race]/[Shell] resolution
// keys are ignored); when null, every key=value line is applied (legacy GvrInput.ini).
// Returns the number of mappings applied.
static int parse_button_ini(const char* path, const char* wantSection, bool frontend = false) {
    FILE* f = fopen(path, "r");
    if (!f) return 0;
    char line[256], section[64] = {0};
    int applied = 0;
    while (fgets(line, sizeof(line), f)) {
        char* p = line; while (*p == ' ' || *p == '\t') ++p;
        if (*p == '#' || *p == ';' || *p == '\r' || *p == '\n' || !*p) continue;
        if (*p == '[') {                                    // [Section]
            char* end = strchr(p, ']');
            if (end) { *end = 0; lstrcpynA(section, p + 1, sizeof(section)); }
            continue;
        }
        if (wantSection && _stricmp(section, wantSection) != 0) continue;   // wrong section
        char* eq = strchr(p, '='); if (!eq) continue;
        *eq = 0; char* btn = p; char* act = eq + 1;
        char* e = btn + strlen(btn); while (e > btn && (e[-1] == ' ' || e[-1] == '\t')) *--e = 0;
        while (*act == ' ' || *act == '\t') ++act;
        e = act + strlen(act); while (e > act && (e[-1]==' '||e[-1]=='\t'||e[-1]=='\r'||e[-1]=='\n')) *--e = 0;
        char* cmt = strpbrk(act, ";#");                     // allow trailing comments
        if (cmt) { *cmt = 0; e = cmt; while (e > act && (e[-1]==' '||e[-1]=='\t')) *--e = 0; }
        unsigned ub = 0;
        for (auto& b : PAD_BUTTONS) if (_stricmp(b.name, btn) == 0) { ub = b.ub; break; }
        if (ub) {
            if (frontend) front_set(ub, act); else map_set(ub, act);
            logf("cfg: %s%s -> %s", frontend ? "[frontend] " : "", btn, act);
            ++applied;
        }
        else logf("cfg: unknown button '%s'", btn);
    }
    fclose(f);
    return applied;
}

// Controller settings live in the SAME gvr_settings.ini as the resolution options, under a
// [Controller] section. That file sits at the INSTALL ROOT while this DLL sits 1-3 levels below
// it (Underground\ for the game, Underground\GVR\GvrRoot\ for the shell), so walk up from our own
// directory to find it. GvrInput.ini beside the DLL is still honoured as a legacy override.
static void load_button_config() {
    map_defaults();
    char dir[MAX_PATH] = {0};
    GetModuleFileNameA(g_hinst, dir, MAX_PATH);
    char* s = strrchr(dir, '\\'); if (s) *s = 0;            // dir = folder holding the DLL

    char cand[MAX_PATH];
    char probe[MAX_PATH];
    lstrcpynA(probe, dir, MAX_PATH);
    for (int up = 0; up <= 4; ++up) {                       // our dir, then parents
        wsprintfA(cand, "%s\\gvr_settings.ini", probe);
        if (GetFileAttributesA(cand) != INVALID_FILE_ATTRIBUTES) {
            int n  = parse_button_ini(cand, "Controller");           // in-race map
            int nf = parse_button_ini(cand, "Frontend", true);       // menu map
            logf("cfg: %s -> %d [Controller] + %d [Frontend] mapping(s)", cand, n, nf);
            if (n > 0 || nf > 0) return;                    // configured here; done
            break;                                          // found the file but neither section
        }
        char* q = strrchr(probe, '\\'); if (!q) break; *q = 0;   // go up one level
    }
    wsprintfA(cand, "%s\\GvrInput.ini", dir);                // legacy per-DLL file
    if (GetFileAttributesA(cand) != INVALID_FILE_ATTRIBUTES) {
        int n = parse_button_ini(cand, nullptr);
        logf("cfg: legacy %s -> %d mapping(s)", cand, n);
    }
}

static uint32_t map_buttons(unsigned ub) {
    if (getenv("GVR_BTN_DISCOVERY")) {   // discovery mode: each pad button on a distinct test bit
        uint32_t g = 0;
        int n = (int)(sizeof(DISCOVERY_MAP)/sizeof(BtnMap));
        for (int i = 0; i < n; ++i) if (DISCOVERY_MAP[i].ub && (ub & DISCOVERY_MAP[i].ub)) g |= DISCOVERY_MAP[i].gbit;
        return g;
    }
    if (g_map_n == 0) map_defaults();    // safety: never leave the map empty
    uint32_t g = 0;
    for (int i = 0; i < g_map_n; ++i)
        if (g_map[i].ub && (ub & g_map[i].ub)) g |= g_map[i].gbit;
    if (g_log) {
        static unsigned prev = 0xFFFFFFFFu;
        if (ub != prev) {   // log only on change
            char names[256]; names[0] = 0;
            for (int i = 0; i < g_map_n; ++i)
                if (g_map[i].ub && (ub & g_map[i].ub)) { strcat(names, g_map[i].name); strcat(names, " "); }
            logf("btn ub=0x%X -> gamebits=0x%08X [%s]", ub, g, names);
            prev = ub;
        }
    }
    return g;
}

static void open_ds4() {
    GUID hidGuid; HidD_GetHidGuid(&hidGuid);
    HDEVINFO di = SetupDiGetClassDevs(&hidGuid, nullptr, nullptr,
                                      DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
    if (di == INVALID_HANDLE_VALUE) return;

    // A DS4 exposes SEVERAL HID top-level collections (more so over Bluetooth, and doubly so when
    // it is connected via USB *and* BT at once). We must open the GAMEPAD collection
    // (UsagePage 0x01 Generic-Desktop, Usage 0x05 Gamepad / 0x04 Joystick) - NOT just the first
    // VID_054C interface the enumerator returns. Grabbing a non-gamepad collection and decoding it
    // with gamepad byte-offsets is what scrambled the buttons on another player's machine (whose
    // enumeration order differs). If no gamepad-usage collection is found we fall back to the first
    // 054C interface (old behaviour) so nothing regresses.
    HANDLE fallback = INVALID_HANDLE_VALUE; DWORD fallbackLen = 78;

    SP_DEVICE_INTERFACE_DATA ifd; ifd.cbSize = sizeof(ifd);
    for (DWORD i = 0; SetupDiEnumDeviceInterfaces(di, nullptr, &hidGuid, i, &ifd); ++i) {
        DWORD need = 0;
        SetupDiGetDeviceInterfaceDetailA(di, &ifd, nullptr, 0, &need, nullptr);
        if (!need) continue;
        auto* det = (SP_DEVICE_INTERFACE_DETAIL_DATA_A*)malloc(need);
        det->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_A);
        if (SetupDiGetDeviceInterfaceDetailA(di, &ifd, det, need, nullptr, nullptr)) {
            HANDLE h = CreateFileA(det->DevicePath, GENERIC_READ,
                                   FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
                                   OPEN_EXISTING, FILE_FLAG_OVERLAPPED, nullptr);
            if (h != INVALID_HANDLE_VALUE) {
                HIDD_ATTRIBUTES at; at.Size = sizeof(at);
                if (HidD_GetAttributes(h, &at) && at.VendorID == 0x054C) {
                    // Sony: DS4 v1 = 0x05C4, DS4 v2 = 0x09CC, DS4 USB adapter = 0x0BA0.
                    // Read caps: usage identifies the collection; InputReportByteLength sizes the
                    // read (USB=64; Bluetooth is large, e.g. 547 - ReadFile must be given exactly
                    // that many bytes or the read fails).
                    unsigned inLen = 0, usagePage = 0, usage = 0;
                    PHIDP_PREPARSED_DATA pp = nullptr;
                    if (HidD_GetPreparsedData(h, &pp)) {
                        HIDP_CAPS caps;
                        if (HidP_GetCaps(pp, &caps) == HIDP_STATUS_SUCCESS) {
                            inLen = caps.InputReportByteLength;
                            usagePage = caps.UsagePage; usage = caps.Usage;
                        }
                        HidD_FreePreparsedData(pp);
                    }
                    bool isGamepad = (usagePage == 0x01 && (usage == 0x05 || usage == 0x04));
                    DWORD rlen = (inLen > 0 && inLen <= sizeof(g_rpt)) ? inLen : 78;
                    logf("ds4: candidate VID=%04X PID=%04X usage=%02X:%02X inRptLen=%u gamepad=%d %s",
                         at.VendorID, at.ProductID, usagePage, usage, inLen, isGamepad, det->DevicePath);
                    if (isGamepad) {
                        g_ds4 = h; g_rptlen = rlen;
                        // Bluetooth DS4 only sends the BASIC report (id 0x01) until the host reads
                        // feature report 0x02; that read switches it to the FULL report (id 0x11)
                        // our decoder needs. Harmless over USB.
                        uint8_t feat[64] = { 0x02 };
                        if (HidD_GetFeature(g_ds4, feat, sizeof(feat))) logf("ds4: feature 0x02 -> full report mode enabled");
                        else                                            logf("ds4: feature 0x02 read failed err=%lu (USB, or already full)", GetLastError());
                        logf("ds4: opened GAMEPAD collection, readLen=%lu", g_rptlen);
                        if (fallback != INVALID_HANDLE_VALUE) CloseHandle(fallback);
                        free(det); SetupDiDestroyDeviceInfoList(di);
                        return;
                    }
                    // not the gamepad collection: remember the first 054C as a last-resort fallback
                    if (fallback == INVALID_HANDLE_VALUE) { fallback = h; fallbackLen = rlen; h = INVALID_HANDLE_VALUE; }
                }
                if (h != INVALID_HANDLE_VALUE) CloseHandle(h);
            }
        }
        free(det);
    }
    SetupDiDestroyDeviceInfoList(di);

    if (fallback != INVALID_HANDLE_VALUE) {
        g_ds4 = fallback; g_rptlen = fallbackLen;
        uint8_t feat[64] = { 0x02 };
        HidD_GetFeature(g_ds4, feat, sizeof(feat));
        logf("ds4: no gamepad-usage collection found; using first 054C fallback, readLen=%lu", g_rptlen);
        return;
    }
    logf("ds4: no Sony controller found");
}

// Decode one DS4 input report into the latched analog globals.
//   USB:  report id 0x01, payload at +1
//   BT :  report id 0x11, payload at +3 (2-byte BT header before the 0x01-style block)
static void latch_ds4(DWORD len) {
    int o;
    if (g_rpt[0] == 0x11)      o = 2;   // Bluetooth
    else if (g_rpt[0] == 0x01) o = 0;   // USB
    else                        return; // unknown report
    if ((DWORD)(o + 10) > len) return;

    if (g_log) {
        static int hc = 0;
        if ((hc++ % 30) == 0)
            logf("raw[%lu] %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X",
                 len, g_rpt[0],g_rpt[1],g_rpt[2],g_rpt[3],g_rpt[4],g_rpt[5],g_rpt[6],
                 g_rpt[7],g_rpt[8],g_rpt[9],g_rpt[10],g_rpt[11],g_rpt[12],g_rpt[13]);
    }

    int lx = g_rpt[o + 1];              // left stick X, 0..255 center 128
    int l2 = g_rpt[o + 8];              // L2 trigger analog, 0..255
    int r2 = g_rpt[o + 9];              // R2 trigger analog, 0..255

    int d = lx - 128;                   // small deadzone
    if (d > -8 && d < 8) d = 0;
    int steer = 128 + d;
    if (steer < 0) steer = 0; if (steer > 255) steer = 255;

    g_ds4_steer = steer;
    g_ds4_brake = l2;
    g_ds4_gas   = r2;
    g_ds4_fresh = true;

    // buttons: byte5 = hat(lo nibble) + face(hi nibble); byte6 = shoulders/sticks; byte7 = PS/TPad
    int b5 = g_rpt[o + 5], b6 = g_rpt[o + 6], b7 = g_rpt[o + 7];
    int hat = b5 & 0x0F;
    unsigned ub = 0;
    if (b5 & 0x10) ub |= UB_SQUARE;
    if (b5 & 0x20) ub |= UB_CROSS;
    if (b5 & 0x40) ub |= UB_CIRCLE;
    if (b5 & 0x80) ub |= UB_TRIANGLE;
    if (b6 & 0x01) ub |= UB_L1;
    if (b6 & 0x02) ub |= UB_R1;
    if (b6 & 0x04) ub |= UB_L2;
    if (b6 & 0x08) ub |= UB_R2;
    if (b6 & 0x10) ub |= UB_SHARE;
    if (b6 & 0x20) ub |= UB_OPTIONS;
    if (b6 & 0x40) ub |= UB_L3;
    if (b6 & 0x80) ub |= UB_R3;
    if (b7 & 0x01) ub |= UB_PS;
    if (hat == 0 || hat == 1 || hat == 7) ub |= UB_DUP;
    if (hat == 1 || hat == 2 || hat == 3) ub |= UB_DRIGHT;
    if (hat == 3 || hat == 4 || hat == 5) ub |= UB_DDOWN;
    if (hat == 5 || hat == 6 || hat == 7) ub |= UB_DLEFT;
    g_ds4_btn = ub;
}

// Non-blocking overlapped pump: drain any completed reports, leave one read outstanding.
static void pump_ds4() {
    if (g_ds4 == INVALID_HANDLE_VALUE) return;
    for (int guard = 0; guard < 16; ++guard) {
        if (g_read_pending) {
            DWORD rd = 0;
            if (!GetOverlappedResult(g_ds4, &g_ov, &rd, FALSE)) {
                if (GetLastError() == ERROR_IO_INCOMPLETE) return;  // still waiting
                g_read_pending = false;                            // error -> re-issue
            } else {
                g_read_pending = false;
                if (rd >= 10) latch_ds4(rd);
            }
        }
        ResetEvent(g_ev);
        memset(g_rpt, 0, g_rptlen);
        DWORD rd = 0;
        BOOL ok = ReadFile(g_ds4, g_rpt, g_rptlen, &rd, &g_ov);   // read the FULL report (BT needs 547, not 78)
        if (ok) {
            if (rd >= 10) latch_ds4(rd);      // completed synchronously; loop for a fresher one
        } else if (GetLastError() == ERROR_IO_PENDING) {
            g_read_pending = true; return;
        } else {
            return;                            // device gone
        }
    }
}

// ================================================================== exported ABI
extern "C" {

// Init(hwnd, buf, name). Returns 0 on success; must set buf+0x30 = 6.
int GVRInputRawInit(void* hwnd, void* buf, const char* name) {
    maybe_open_log();
    logf("GVRInputRawInit buf=%p  (game=%d shell=%d)", buf, g_is_game, g_is_shell);
    g_gear = 1;                        // start each race in 1st
    // camera-cycle fn only exists in the race exe; verify + gate on host so we never call it in the shell
    if (g_is_game) {
        __try { g_cam_ok = (*(volatile uint8_t*)0x0058f740 == 0x56); }
        __except (EXCEPTION_EXECUTE_HANDLER) { g_cam_ok = false; }
    } else {
        g_cam_ok = false;
    }
    install_gear_hook();               // replace the game's gear-selector so we control the clamp
    load_button_config();              // apply optional GvrInput.ini remap (else defaults)
    load_xinput();
    if (g_ds4 == INVALID_HANDLE_VALUE && !(g_is_shell && g_shell_nods4)) {
        g_ev = CreateEventA(nullptr, TRUE, FALSE, nullptr);
        g_ov = {}; g_ov.hEvent = g_ev; g_read_pending = false;
        open_ds4();
    }
    // SHELL: hand initialisation to the real OEM DLL when present, so the shell is initialised
    // byte-identically to a stock install (this is what avoids the race-end managed hang, and it
    // gives us the OEM's keyboard handling for free). We only overlay the pad in Update().
    if (g_is_shell) {
        g_want_center = true;          // centre the frontend window (and snap it to [Shell] size)
        g_center_resize = false;
        {   char sini[MAX_PATH];
            if (find_settings_ini(sini, sizeof(sini))) {
                g_win_w = ini_int(sini, "Width",  0);   // one shared [Display] size for both
                g_win_h = ini_int(sini, "Height", 0);
                logf("res: frontend target %dx%d", g_win_w, g_win_h);
            }
        }
        load_oem();
        if (g_oemInit && !g_oemInited) {
            int r = g_oemInit(hwnd, buf, name);
            g_oemInited = true;
            logf("oem: Init returned %d (buf+0x30=%u)", r, buf ? *(uint32_t*)((uint8_t*)buf + 0x30) : 0);
            return r;                  // pass the OEM's own result through unchanged
        }
    }
    if (buf) {
        uint8_t* b = (uint8_t*)buf;
        if (!(g_is_shell && g_shell_nogate)) *(uint32_t*)(b + 0x30) = 6;  // interface-type gate
        b[0x00] = 0x80;                // steering centered
        b[0x02] = 0;                   // brake released
        b[0x34] = 0;                   // gas released
        *(uint32_t*)(b + 0x0c) = 0;    // no buttons
    }
    return 0;
}

// Read the live controller into (steer, gas, brake, ub). Shared by game + shell paths.
static const char* read_pad(int& steer, int& gas, int& brake, unsigned& ub) {
    steer = 128; gas = 0; brake = 0; ub = 0;
    const char* src = "none";

    // 1) XInput (Xbox controllers; also DS4 when Steam Input presents it as XInput)
    //
    // *** DO NOT poll XInput every frame when no XInput pad is connected. ***
    // XInputGetState on an EMPTY user slot takes the slow path: it re-enumerates devices through
    // DEVOBJ/cfgmgr32 on every single call. With a raw-HID DS4 (no XInput device present) that ran
    // once per frame from CONTROLUPDATE and burned ~100% CPU inside the device enumerator - the
    // captured hang stack was exactly
    //     cfgmgr32 <- DEVOBJ <- xinput1_4 <- GVRInputRaw <- NFSControl(CONTROLUPDATE)
    // with 164s of CPU. That is the race-end "hang": the shell's UI thread stalls in our Update.
    // (It bites hardest right after a race, when the game exiting invalidates XInput's device
    // cache.) Standard fix: back off - retry a disconnected slot only every few seconds.
    static DWORD s_xiNextTry = 0;      // GetTickCount() before which we skip XInput entirely
    if (pXInputGetState && (DWORD)(GetTickCount() - s_xiNextTry) < 0x80000000u) {
        XINPUT_STATE_ xs;
        DWORD xr = pXInputGetState(0, &xs);
        if (xr != ERROR_SUCCESS) {
            s_xiNextTry = GetTickCount() + 3000;   // not connected -> don't ask again for 3s
            if (g_log) { static bool once=false; if(!once){once=true; logf("xinput: user0 not connected (err=%lu) -> backing off to 3s polls", xr);} }
        }
        if (xr == ERROR_SUCCESS) {
            int lx = xs.Gamepad.sThumbLX;
            if (lx > -6000 && lx < 6000) lx = 0;         // deadzone
            steer = 128 + (lx * 127) / 32768;
            if (steer < 0) steer = 0; if (steer > 255) steer = 255;
            gas   = xs.Gamepad.bRightTrigger;            // 0..255
            brake = xs.Gamepad.bLeftTrigger;             // 0..255
            WORD wb = xs.Gamepad.wButtons;
            if (wb & 0x1000) ub |= UB_CROSS;    if (wb & 0x2000) ub |= UB_CIRCLE;
            if (wb & 0x4000) ub |= UB_SQUARE;   if (wb & 0x8000) ub |= UB_TRIANGLE;
            if (wb & 0x0100) ub |= UB_L1;       if (wb & 0x0200) ub |= UB_R1;
            if (wb & 0x0020) ub |= UB_SHARE;    if (wb & 0x0010) ub |= UB_OPTIONS;
            if (wb & 0x0040) ub |= UB_L3;       if (wb & 0x0080) ub |= UB_R3;
            if (wb & 0x0001) ub |= UB_DUP;      if (wb & 0x0002) ub |= UB_DDOWN;
            if (wb & 0x0004) ub |= UB_DLEFT;    if (wb & 0x0008) ub |= UB_DRIGHT;
            if (xs.Gamepad.bLeftTrigger  > 30) ub |= UB_L2;
            if (xs.Gamepad.bRightTrigger > 30) ub |= UB_R2;
            src = "xinput";
        }
    }

    // 2) DS4 over raw HID (native PS4 controller, no Steam Input)
    if (src[0] == 'n') {
        pump_ds4();
        if (g_ds4 != INVALID_HANDLE_VALUE) {
            steer = g_ds4_steer; gas = g_ds4_gas; brake = g_ds4_brake;
            ub = g_ds4_btn;
            src = "ds4";
        }
    }
    return src;
}

// ---- SHELL keyboard injection (menu buttons) ----------------------------------------------
// UniverShell2 reads the analog wheel (b+0x00) for game-menu SELECTION, but the action buttons
// (select / enter-operator / operator-menu arrows) are plain keyboard keys. We inject them with
// hold-based scan-code SendInput (a DirectInput poll reads current key state each frame, so the
// key must stay physically down while the pad button is held). Only while the shell is foreground,
// so this never leaks into the running race game.
static const struct { WORD vk; WORD scan; } SH_SCANS[] = {
    {VK_LEFT,0xCB},{VK_RIGHT,0xCD},{VK_UP,0xC8},{VK_DOWN,0xD0},{'S',0x1F},{'O',0x18},
};
static WORD sh_scan_of(WORD vk){ for (auto& s : SH_SCANS) if (s.vk == vk) return s.scan; return 0; }
static void sh_keyevent(WORD vk, bool down) {
    WORD scan = sh_scan_of(vk);
    INPUT in = {}; in.type = INPUT_KEYBOARD;
    in.ki.wVk = vk; in.ki.wScan = (WORD)(scan & 0x7F);
    in.ki.dwFlags = KEYEVENTF_SCANCODE | ((scan & 0x80) ? KEYEVENTF_EXTENDEDKEY : 0) | (down ? 0 : KEYEVENTF_KEYUP);
    INPUT in2 = {}; in2.type = INPUT_KEYBOARD; in2.ki.wVk = vk; in2.ki.dwFlags = down ? 0 : KEYEVENTF_KEYUP;
    INPUT arr[2] = { in2, in };
    UINT sent = SendInput(2, arr, sizeof(INPUT));
    logf("  inject vk=0x%X %s scan=0x%X sent=%u/2 err=%lu", vk, down ? "DOWN" : "up", scan, sent, GetLastError());
}
struct ShHeld { WORD vk; bool down; };
static ShHeld g_sh_held[] = { {VK_LEFT},{VK_RIGHT},{VK_UP},{VK_DOWN},{'S'},{'O'} };
static void sh_hold(WORD vk, bool want) {
    for (auto& h : g_sh_held) if (h.vk == vk) {
        if (want && !h.down)      { sh_keyevent(vk, true);  h.down = true; }
        else if (!want && h.down) { sh_keyevent(vk, false); h.down = false; }
        return;
    }
}
static void sh_release_all() { for (auto& h : g_sh_held) if (h.down) { sh_keyevent(h.vk, false); h.down = false; } }

static bool shell_is_foreground() {
    HWND h = GetForegroundWindow(); if (!h) return false;
    DWORD pid = 0; GetWindowThreadProcessId(h, &pid);
    bool same = (pid == GetCurrentProcessId());
    if (g_log) {
        static DWORD prevpid = 0;
        if (pid != prevpid) {   // log the foreground process only when it changes
            char nm[MAX_PATH] = "?";
            HANDLE p = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
            if (p) { DWORD n = MAX_PATH; QueryFullProcessImageNameA(p, 0, nm, &n); CloseHandle(p); }
            const char* bn = strrchr(nm, '\\'); bn = bn ? bn + 1 : nm;
            logf("FG changed: pid=%lu name=%s  same-as-shell=%d", pid, bn, same);
            prevpid = pid;
        }
    }
    return same;
}

// ---- SHELL menu path: UniverShell2's NFSControl.dll picks menu items from the wheel axis by ANGLE.
// Verified from NFSControl.dll @0x231F: it reads buf+0x00 as a SIGNED 16-bit WORD and computes
//   index = round( ((steer_word + 128) / 256) * itemCount )   (C_e8=128, C_e4=1/256).
// So the wheel must be a signed word -128 (full left) .. +128 (full right), center 0. We were only
// writing the low byte, leaving buf+0x01 garbage -> movsx read a huge/negative value (the inverted,
// hyper-sensitive behavior). Write the full signed word.
// ---- Q = quit -------------------------------------------------------------------------------
// Documented cabinet key (see PreviousNotes "Game Controls"), but in GVRInputRaw input mode the
// game stops reading the keyboard for these functions - the same reason the camera key V had to be
// wired up by hand. Q is not one of the buffer bits either, so we implement it ourselves:
//   game  -> set the engine's "quit requested" flag (DWORD at 0x0081b300, written =1 by every
//            in-game shutdown path and polled at 0x0052041c), so it exits through its own code.
//   shell -> post WM_CLOSE to its window, which is the clean way to end a WinForms app.
// Only acts while OUR process owns the foreground, so pressing Q in another app does nothing.
static int g_quit_combo_frames = 0;     // >0 = inject the cabinet quit combo this many frames
static unsigned g_last_ub = 0;          // most recent pad buttons (so the quit key can see them)
static void handle_quit_key() {
    static bool prev = false;
    // Q on the keyboard, or D-PAD DOWN on the pad (unused in-race, so no conflict).
    bool down = ((GetAsyncKeyState('Q') & 0x8000) != 0) ||
                (g_ub_quit && (g_last_ub & g_ub_quit) != 0);   // [Controller] ... = quit
    bool edge = down && !prev;
    prev = down;
    if (!edge || !our_process_is_foreground()) return;
    if (g_is_game) {
        // Raise the engine's own "QUIT GAME?" prompt rather than writing its exit flag (which would
        // kill the race instantly, skipping the confirmation).
        // The handler accepts EITHER trigger:
        //     DAT_00c2b1c4 == 0x10           <- buf+0xEC, a dedicated command byte
        //     (buf+0x0c & 0x10610) == 0x10610 <- the operator button combo
        // We use the command byte: the button combo shares bit 0x400 with NITROUS (and 0x200 with
        // look-back, 0x10 with start), so triggering the prompt that way also fired the NOS.
        g_quit_combo_frames = 6;                 // hold it briefly so the handler samples it
        logf("Q pressed -> raising the quit prompt via buf+0xEC (no button side effects)");
    } else {
        logf("Q pressed -> closing the frontend");
        struct E { HWND found; } e = { nullptr };
        EnumWindows([](HWND w, LPARAM lp) -> BOOL {
            DWORD pid = 0; GetWindowThreadProcessId(w, &pid);
            if (pid != GetCurrentProcessId() || !IsWindowVisible(w) || GetWindow(w, GW_OWNER)) return TRUE;
            RECT rc; GetClientRect(w, &rc);
            if (rc.right < 320 || rc.bottom < 240) return TRUE;
            ((E*)lp)->found = w; return FALSE;
        }, (LPARAM)&e);
        if (e.found) PostMessageA(e.found, WM_CLOSE, 0, 0);
    }
}

// TOPMOST FOLLOWS FOCUS.
// The frontend natively forces itself ALWAYS-ON-TOP (cabinet behaviour), which covers the taskbar
// permanently and makes it impossible to click another window. Simply clearing that left it *under*
// the taskbar while playing. So we track focus instead:
//   focused     -> HWND_TOPMOST    (draws over the taskbar - looks like a proper fullscreen game)
//   not focused -> HWND_NOTOPMOST  (an ordinary window; alt-tab and the taskbar work normally)
// Polled ~1/s and only applied on a CHANGE. Done by polling rather than by hooking SetWindowPos -
// an inline detour of that API crashed the shell.
static void keep_not_topmost() {
    // Poll FAST (not once a second). The frontend re-asserts always-on-top itself, constantly, so a
    // slow correction left it effectively pinned on top: it popped back within the gap and the
    // player could not alt-tab away. 120 ms keeps it genuinely behind other windows.
    static DWORD next = 0;
    DWORD now = GetTickCount();
    if (now < next) return;
    next = now + 120;
    HWND h = nullptr;
    struct E { HWND found; } e = { nullptr };
    EnumWindows([](HWND w, LPARAM lp) -> BOOL {
        DWORD pid = 0; GetWindowThreadProcessId(w, &pid);
        if (pid != GetCurrentProcessId() || !IsWindowVisible(w) || GetWindow(w, GW_OWNER)) return TRUE;
        RECT rc; GetClientRect(w, &rc);
        if (rc.right < 320 || rc.bottom < 240) return TRUE;
        ((E*)lp)->found = w; return FALSE;
    }, (LPARAM)&e);
    h = e.found;
    if (!h) return;
    char fgName[64] = "";
    bool focused = foreground_is_our_app(fgName, sizeof(fgName));

    // "Nobody owns the foreground" happens right after the race finishes loading: the frontend has
    // dropped focus and the race never took it, so the desktop is in front and the race would sink
    // below the taskbar. We claim it back - but ONLY in the race, and ONLY for a short grace period
    // after start-up.
    // Do NOT do this open-endedly, and never in the frontend: the ALT-TAB SWITCHER ITSELF is
    // explorer.exe, so treating explorer as "ours" made the shell instantly grab the top again and
    // alt-tab became impossible.
    bool nobodyHasIt = false;
    if (!focused && g_is_game) {
        static DWORD firstSeen = 0;
        DWORD now = GetTickCount();
        if (!firstSeen) firstSeen = now;
        bool grace = (now - firstSeen) < 20000;          // covers load -> countdown only
        if (grace && (fgName[0] == 0 || _stricmp(fgName, "explorer.exe") == 0)) {
            nobodyHasIt = true;
            focused = true;
            static DWORD lastGrab = 0;
            if (now - lastGrab > 1500) { lastGrab = now; force_foreground(h); }
        }
    }

    // The frontend stays running while a race is on, so without this BOTH processes claim topmost
    // and fight: the race would flash above the taskbar and then drop behind it again. While the
    // race exists the frontend never takes the topmost band.
    if (g_is_shell) {
        // Cached: a process snapshot every 120 ms would be wasteful, once a second is plenty.
        static DWORD nextScan = 0;
        static bool  raceUp = false;
        if (now >= nextScan) {
            nextScan = now + 1000;
            raceUp = false;
            HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (snap != INVALID_HANDLE_VALUE) {
                PROCESSENTRY32 pe; pe.dwSize = sizeof(pe);
                if (Process32First(snap, &pe)) do {
                    if (lstrcmpiA(pe.szExeFile, "UndergroundGVR.exe") == 0) { raceUp = true; break; }
                } while (Process32Next(snap, &pe));
                CloseHandle(snap);
            }
        }
        if (raceUp) focused = false;              // yield the z-order to the race
    }
    bool isTopmost = (GetWindowLong(h, GWL_EXSTYLE) & WS_EX_TOPMOST) != 0;
    if (g_log) {
        static DWORD nextLog = 0;
        DWORD now2 = GetTickCount();
        if (now2 >= nextLog) {
            nextLog = now2 + 2000;
            logf("z: hwnd=%p fg='%s' wantTop=%d isTop=%d nobody=%d", h, fgName, (int)focused, (int)isTopmost, (int)nobodyHasIt);
        }
    }
    // RE-ASSERT every poll while we should be on top - do NOT skip when WS_EX_TOPMOST is already
    // set. The taskbar is topmost too, so being *in* the topmost band is not enough: whatever was
    // raised last sits highest. The window logged isTop=1 and still lost to the taskbar, because a
    // change-only update never re-raises us. Dropping back to non-topmost still only happens on a
    // real change, so we do not thrash when the player alt-tabs away.
    if (focused) SetWindowPos(h, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    else if (isTopmost) SetWindowPos(h, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
}

static int shell_update(uint8_t* b) {
    if (g_shell_nobuf) return 0;             // diagnostic: write nothing (behave as if absent)
    center_window_once();                    // centre the frontend window once it exists
    keep_not_topmost();                      // stop it forcing itself always-on-top
    handle_quit_key();                       // Q = quit (documented cabinet key)

    // ---- OEM-driven mode: let the real OEM DLL fill the buffer (identical to a stock install -
    // including its keyboard handling), then overlay ONLY the pad on top. -------------------
    if (g_oemUpdate) {
        g_oemUpdate(b);                       // OEM produces the whole frame (keyboard included)
        int st, gs, bk; unsigned pub;
        read_pad(st, gs, bk, pub);            // our gamepad state

        // steering: only override while the stick is actually deflected, using the same stable
        // quantise+hysteresis rule (idle stick => leave the OEM value untouched, so an idle pad is
        // byte-for-byte a stock install and cannot perturb the shell).
        static int owheel = 0;
        const int DEAD = 24, QUANT = 8;
        int sw = st - 128;
        if (sw > DEAD || sw < -DEAD) {
            int q = (sw / QUANT) * QUANT;
            if (q >  120) q =  120;
            if (q < -120) q = -120;
            if (q - owheel >= QUANT || owheel - q >= QUANT) owheel = q;
            *(int16_t*)(b + 0x00) = (int16_t)owheel;
        } else {
            owheel = 0;                        // released -> hand the axis back to the OEM/keyboard
        }
        // buttons: OR our mapped bits into whatever the OEM already reported
        // every menu button comes from the [Frontend] map (defaults reproduce the old hardcoding)

        // ---- career-mode triggers (FRONTEND ONLY) ----------------------------------------------
        // In the career screens (e.g. name entry) accept/backspace are BUTTON BITS, not the pedals:
        //   0x100 = accept / select a letter   (same bit as RIGHT arrow, and as our D-pad right)
        //   0x400 = backspace / go back        (same bit as LEFT arrow, and as NOS - hence
        //                                       "NOS is backspace")
        // Driving the gas AXIS (buf+0x02) does not work here - that was the wrong lever.
        // Same trigger sides as in-race so the muscle memory carries over:
        //   R2 -> accept        L2 -> back
        // Shell path only; the race keeps R2 = throttle / L2 = brake.
        if (gs > 40) pub |= UB_R2;                  // analog trigger -> its button, so the
        if (bk > 40) pub |= UB_L2;                  // [Frontend] map decides what it does
        uint32_t add = front_bits(pub);

        if (add) *(uint32_t*)(b + 0x0c) |= add;
        if (g_log) {
            static unsigned prev = 0xFFFFFFFFu;
            if (pub != prev) { logf("shell(oem) pad ub=0x%X add=0x%X wheel=%d", pub, add, owheel); prev = pub; }
        }
        return 0;
    }

    int steer, gas, brake; unsigned ub;
    const char* src = read_pad(steer, gas, brake, ub);

    // ---- menu wheel (buf+0x00, signed word). TWO input styles, matching the OEM behaviour:
    //   * analog stick -> ABSOLUTE: the wheel tracks the stick ANGLE directly, so holding the
    //     stick part-way sits on center±1/±2 (what the user asked for and confirmed liking).
    //   * Numpad 4/6   -> GRADUAL RAMP + spring-to-center, like the OEM's digital wheel step, so
    //     a brief tap nudges one item instead of slamming to full lock. (Restoring the original
    //     feel: my first pass slammed steer to 0/255 on keypress, which made selection "super
    //     quick" / jump to the far end.)
    // *** THE VALUE MUST BE STABLE FRAME-TO-FRAME ***
    // NFSControl @0x23A4 compares the index it derives from this wheel value against the previous
    // index; when it CHANGES it fires a "selection changed" event into the MANAGED engine (sets the
    // trigger bytes at 0x10005c20/0x10005c2c => sound + animation objects). Feeding the RAW analog
    // stick meant stick noise/drift changed the index almost every frame, so that managed event
    // fired continuously, the CLR churned (the ~400s of mscorwks CPU we captured) and the UI thread
    // stopped pumping => the race-end AppHang. The OEM DLL has no wheel hardware, so its value is
    // constant and the index never churns - which is exactly why OEM never hung.
    // Fix: real deadzone + quantisation + hysteresis so the wheel only moves on deliberate input.
    static int wheel = 0;                     // persists across frames, -127..+127
    const int STEP = 4;                       // ramp / re-center speed per Update (tuned for feel)
    const int DEAD = 24;                      // stick deadzone (was 12; covers resting drift)
    const int QUANT = 8;                      // quantisation bucket - noise below this cannot move the index
    int stickSw = steer - 128;                // -128..+127 from the pad
    bool stickActive = (stickSw > DEAD || stickSw < -DEAD);
    bool kL = (GetAsyncKeyState(VK_NUMPAD4) & 0x8000) != 0;
    bool kR = (GetAsyncKeyState(VK_NUMPAD6) & 0x8000) != 0;
    if (stickActive) {
        // quantise, then only accept a new value when it moved a FULL bucket (hysteresis)
        int q = (stickSw / QUANT) * QUANT;
        if (q >  120) q =  120;
        if (q < -120) q = -120;
        if (q - wheel >= QUANT || wheel - q >= QUANT) wheel = q;   // stable otherwise
    }
    else if (kR && !kL) { wheel += STEP; if (wheel >  127) wheel =  127; }   // ramp right
    else if (kL && !kR) { wheel -= STEP; if (wheel < -127) wheel = -127; }   // ramp left
    else {                                                        // spring back to center on release
        if      (wheel > 0) { wheel -= STEP; if (wheel < 0) wheel = 0; }
        else if (wheel < 0) { wheel += STEP; if (wheel > 0) wheel = 0; }
    }
    // Clear the WHOLE driving-buffer region first. The OEM DLL's joystick read fills many fields
    // (buf+0x04/06/08/0a/0x36/0x38/0x42 ...); we only set a handful, so the rest were left STALE.
    // NFSControl reads buf+0x42 (a second steer axis) among others, so garbage there fed the managed
    // shell a bad value and spun it in a busy loop at race-end (the AppHang). Zeroing = clean "no
    // extra input" state, then we write our meaningful fields on top.
    memset(b, 0, 0x48);
    *(int16_t*)(b + 0x00) = (int16_t)wheel;  // menu selection by wheel position
    // buf+0x02 (throttle) and buf+0x34 (brake) stay 0 from the memset

    // ---- menu buttons as BUFFER BITS in buf+0x0c. These bit values are the EXACT ones the OEM
    // GVRInputRaw folded from its DirectInput keyboard (reverse-engineered from the OEM DLL):
    //   S=0x10(select/card)  O=0x20(operator)  Up=0x10000 Down=0x200 Left=0x400 Right=0x100  E=0x20000
    // The consumer edge-detects via (buf+0x0c AND NOT buf+0x10), so we publish the previous frame's
    // mask in buf+0x10.  Keyboard injection was the wrong layer - nothing here reads window keys. ----
    unsigned mub = ub;
    if (gas   > 40) mub |= UB_R2;           // analog triggers count as their buttons here too
    if (brake > 40) mub |= UB_L2;
    uint32_t cur = front_bits(mub);         // gamepad -> buffer bits, per the [Frontend] map
    // keyboard -> the SAME buffer bits, exactly as the OEM GVRInputRaw folded its DirectInput
    // keyboard (so the physical keys keep working alongside the pad; nothing else reads them).
    if (GetAsyncKeyState('S')     & 0x8000) cur |= 0x10;      // S     -> select / start
    if (GetAsyncKeyState('O')     & 0x8000) cur |= 0x20;      // O     -> operator menu
    if (GetAsyncKeyState(VK_UP)   & 0x8000) cur |= 0x10000;   // arrows-> operator-menu nav
    if (GetAsyncKeyState(VK_DOWN) & 0x8000) cur |= 0x200;
    if (GetAsyncKeyState(VK_LEFT) & 0x8000) cur |= 0x400;
    if (GetAsyncKeyState(VK_RIGHT)& 0x8000) cur |= 0x100;
    if (GetAsyncKeyState('E')     & 0x8000) cur |= 0x20000;   // E     -> e-brake / exit-to-main
    static uint32_t prev0c = 0;
    *(uint32_t*)(b + 0x0c) = cur;           // current button mask
    *(uint32_t*)(b + 0x10) = prev0c;        // previous mask -> engine edge-detects new presses
    prev0c = cur;
    if (!g_shell_nogate) *(uint32_t*)(b + 0x30) = 6;   // keep the interface gate asserted

    if (g_log) {
        // DIAGNOSTIC: log the buffer bits we feed + the raw key states every 30 frames. If the
        // shell hangs at race-end because we feed a STUCK bit (e.g. phantom GetAsyncKeyState('S')
        // during attract), the tail of this log shows cur pinned at 0x10 with kbS=1.
        static int fc = 0;
        if ((fc++ % 30) == 0)
            logf("SHELL cur=0x%X wheel=%d ub=0x%X | kbS=%d kbO=%d kbNum4=%d kbNum6=%d kbUp=%d",
                 cur, wheel, ub,
                 (GetAsyncKeyState('S')&0x8000)!=0, (GetAsyncKeyState('O')&0x8000)!=0,
                 (GetAsyncKeyState(VK_NUMPAD4)&0x8000)!=0, (GetAsyncKeyState(VK_NUMPAD6)&0x8000)!=0,
                 (GetAsyncKeyState(VK_UP)&0x8000)!=0);
    }
    return 0;
}

// Identify (once) the module + offset that calls us, so we know who consumes the wheel byte.
static void log_caller_once(void* ra) {
    if (!g_log) return;
    static bool done = false; if (done) return; done = true;
    HMODULE m = nullptr;
    GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                       (LPCSTR)ra, &m);
    char name[MAX_PATH] = "?"; if (m) GetModuleFileNameA(m, name, MAX_PATH);
    const char* bn = strrchr(name, '\\'); bn = bn ? bn + 1 : name;
    logf("Update caller: %s + 0x%X   (ra=%p base=%p)", bn, m ? (unsigned)((uintptr_t)ra - (uintptr_t)m) : 0, ra, m);
}

// Update(buf): fill the game's input buffer from the live controller.
int GVRInputRawUpdate(void* buf) {
    void* ra = _ReturnAddress();
    if (!buf) return 0;
    uint8_t* b = (uint8_t*)buf;

    if (g_is_shell) { log_caller_once(ra); return shell_update(b); }   // front-end menu: analog wheel only

    center_window_once();              // windowed race: nudge the window to screen centre (no-op otherwise)
    // Windowed race: draw over the taskbar while it is the active window, and drop back to a
    // normal window when it is not - same focus-following rule as the frontend, so it looks
    // fullscreen while playing but you can still alt-tab away.
    if (g_race_windowed) keep_not_topmost();
    handle_quit_key();                 // Q = quit (documented cabinet key)

    int steer = 128, gas = 0, brake = 0;
    unsigned ub = 0;                  // unified button flags
    const char* src = read_pad(steer, gas, brake, ub);
    g_last_ub = ub;                    // let handle_quit_key() see the pad (D-pad down = quit)
    uint32_t buttons = map_buttons(ub);

    // ---- keyboard passthrough: the original driving keys work alongside the pad ----
    // (In GVRInputRaw mode the game reads driving from this buffer, not the keyboard, so we merge
    //  the keys back in here.) See [[game-key-bindings]].
    if (GetAsyncKeyState(VK_NUMPAD8) & 0x8000) gas   = 255;    // accelerate
    if (GetAsyncKeyState(VK_NUMPAD2) & 0x8000) brake = 255;    // brake / reverse
    if (GetAsyncKeyState(VK_NUMPAD4) & 0x8000) steer = 0;      // steer left
    if (GetAsyncKeyState(VK_NUMPAD6) & 0x8000) steer = 255;    // steer right
    if (GetAsyncKeyState('N') & 0x8000) buttons |= 0x00000400; // nitrous
    if (GetAsyncKeyState('E') & 0x8000) buttons |= 0x00020000; // e-brake
    if (GetAsyncKeyState('S') & 0x8000) buttons |= 0x00000010; // start / reset
    if (GetAsyncKeyState('M') & 0x8000) buttons |= 0x00000100; // music / change song

    // ---- camera: R1 (rising edge) cycles the drive-camera POV ----
    // Calls the game's own no-arg "cycle player camera" FUN_0058f740 (uses global player object,
    // self-null-checks). Direct call because keyboard V is suppressed in GVRInputRaw input mode.
    {
        static bool prevR1 = false, prevV = false;
        bool r1 = g_ub_camera && (ub & g_ub_camera) != 0;            // camera button (configurable; default R1)
        bool vk = (GetAsyncKeyState('V') & 0x8000) != 0;             // keyboard V also cycles view
        if (((r1 && !prevR1) || (vk && !prevV)) && g_cam_ok) ((void(__cdecl*)())0x0058f740)();
        prevR1 = r1; prevV = vk;
    }

    // ---- sequential shifter: Square = up, Triangle = down (manual only; ignored in auto) ----
    {
        static bool prevUp = false, prevDn = false;
        bool up = g_ub_shiftup   && (ub & g_ub_shiftup)   != 0;      // shift-up button (configurable; default Square)
        bool dn = g_ub_shiftdown && (ub & g_ub_shiftdown) != 0;      // shift-down button (configurable; default Triangle)
        if (up && !prevUp && g_gear < 6) { ++g_gear; if (g_log) logf(">> SHIFT UP  -> g_gear=%d", g_gear); }
        if (dn && !prevDn && g_gear > 1) { --g_gear; if (g_log) logf(">> SHIFT DN  -> g_gear=%d", g_gear); }
        prevUp = up; prevDn = dn;
    }
    g_engaged = g_gear + 1;   // desired car+0x1d4 for the player (SetGear override forces this)
    buttons |= GEAR_COMBO[g_gear];

    if (g_log) {
        static int gc = 0;
        if ((gc++ % 20) == 0 && g_car) {
            int actual = -1;
            __try { actual = *(volatile int*)(g_car + 0x1d4); } __except (EXCEPTION_EXECUTE_HANDLER) {}
            logf("gear g=%d engaged=%d | car+1d4(display)=%d", g_gear, g_engaged, actual);
        }
    }

    // The game reads throttle from buf+0x02 (engine axis 1) and brake from buf+0x34
    // (engine axis 2) - confirmed by live in-game test. R2 = throttle, L2 = brake.
    // Steering: buf+0x00 must be SIGNED, centered at 0 (the game forms its internal steer as
    // (buf[0] + 0x80) & 0xFF, i.e. it re-centers to 0x80). Our `steer` is 0..255 centered at
    // 128, so shift it down by 128: center->0, full-right->+127 (0x7F), full-left->-128 (0x80).
    // (Confirmed live: without this, a centered stick drove full-left and full-right drove straight.)
    // ---- Cross also skips the race-start animation ------------------------------------------
    // 'S' (bit 0x10) skips the intro fly-by and jumps to the countdown. We want Cross to do that
    // too - but 0x10 is ALSO "start / reset car", so wiring it to Cross permanently would respawn
    // the car every time you tap the e-brake mid-race. So it is only added during the opening
    // seconds of the run, which is exactly when the intro/countdown plays.
    {
        static DWORD started = 0;
        if (!started) started = GetTickCount();
        bool introWindow = (GetTickCount() - started) < 30000;   // intro + countdown
        if (introWindow && g_ub_skipintro && (ub & g_ub_skipintro)) {
            buttons |= 0x10;
            if (g_log) { static bool once = false; if (!once) { once = true; logf("Cross -> skip intro (0x10) during the opening window"); } }
        }
    }

    // Q -> raise the engine's own "QUIT GAME?" prompt via the command byte (buf+0xEC == 0x10).
    // Deliberately NOT the 0x10610 button combo: those bits are also nitrous/look-back/start.
    b[0xEC] = (g_quit_combo_frames > 0) ? 0x10 : 0x00;
    if (g_quit_combo_frames > 0) --g_quit_combo_frames;

    // ---- answering the prompt --------------------------------------------------------------
    // While it is up (engine flag 0x00c228a2), S / Cross answers YES by setting the engine's own
    // "confirmed" flag (0x00c228a3) - the game then quits through its normal path
    // (sets the exit flag AND runs its cleanup), exactly as if the cabinet operator confirmed.
    // NO needs nothing from us: pressing the accelerator, or just letting the countdown run out,
    // is the engine's own cancel and resumes the race.
    {
        bool dialogUp = false;
        __try { dialogUp = (*(volatile uint8_t*)0x00c228a2 != 0); }
        __except (EXCEPTION_EXECUTE_HANDLER) { dialogUp = false; }
        if (dialogUp) {
            // Steering selects YES/NO natively once buf+0x00 carries a valid signed WORD (see the
            // int16 write below) - the prompt reads the wheel, so numpad 4/6 and the stick both
            // move the highlight without any translation from us.
            // S / Cross answers YES through the engine's own confirm flag, so it quits via its
            // normal path (exit flag + cleanup) instead of being forced.
            static bool prevYes = false;
            bool yes = ((GetAsyncKeyState('S') & 0x8000) != 0) ||
                       (g_ub_confirm && (ub & g_ub_confirm) != 0);
            if (yes && !prevYes) {
                logf("quit prompt: YES confirmed (S / Cross)");
                __try { *(volatile uint8_t*)0x00c228a3 = 1; }
                __except (EXCEPTION_EXECUTE_HANDLER) {}
            }
            prevYes = yes;
        }
    }

    // Write steering as a proper SIGNED WORD, not just the low byte. The driving code reads only
    // the low byte ((char)buf[0] - 0x80), so behaviour there is unchanged - but other consumers
    // read buf+0x00 as an int16 (the shell's NFSControl does, and so does the in-race QUIT prompt).
    // Writing only the byte left buf+0x01 as stale garbage, which is why the prompt's YES/NO
    // highlight never responded to the wheel.
    *(int16_t*)(b + 0x00) = (int16_t)(int8_t)(steer - 128);
    *(int16_t*)(b + 0x02) = (int16_t)gas;    // throttle -> buf+0x02  (R2)
    *(int16_t*)(b + 0x34) = (int16_t)brake;  // brake    -> buf+0x34  (L2)
    *(uint32_t*)(b + 0x0c) = buttons;
    *(uint32_t*)(b + 0x30) = 6;        // keep the gate asserted

    if (g_log) {
        static int fc = 0;
        if ((fc++ % 30) == 0)
            logf("upd src=%s steer=%d gas=%d brake=%d", src, steer, gas, brake);
    }
    return 0;
}

void GVRInputRawCleanup(void) {
    if (g_ds4 != INVALID_HANDLE_VALUE) {
        // CANCEL the outstanding overlapped read BEFORE closing. Closing a handle that still has a
        // pending async HID read can block the game's shutdown at race-end (over Bluetooth the read
        // is a slow 547-byte transfer) - and the shell, waiting on the game to exit, then hangs too
        // (the AppHang we saw). CancelIoEx is Vista+; load it dynamically so the DLL still loads on
        // XP, where we simply skip the cancel.
        typedef BOOL (WINAPI *PFN_CancelIoEx)(HANDLE, LPOVERLAPPED);
        static PFN_CancelIoEx pCancelIoEx =
            (PFN_CancelIoEx)GetProcAddress(GetModuleHandleA("kernel32.dll"), "CancelIoEx");
        if (pCancelIoEx && g_read_pending) pCancelIoEx(g_ds4, nullptr);   // fire-and-forget cancel
        g_read_pending = false;
        CloseHandle(g_ds4); g_ds4 = INVALID_HANDLE_VALUE;
    }
    if (g_ev)  { CloseHandle(g_ev); g_ev = nullptr; }
    if (g_log) { fclose(g_log); g_log = nullptr; }
}

// ---- cabinet health probes -----------------------------------------------------------------
// IN THE SHELL these are FORWARDED to the OEM DLL: NFSControl polls them every frame and branches
// on the answers, and our fixed "0 = healthy" replies are not what a stock install returns - which
// is what drove the shell's idle script into its retry/exception loop. In the GAME we keep the
// "healthy" stubs (that path is proven and has no OEM DLL beside it).
int  GVRInputRawGetUncalibratedAxis(int a)    { OEM_FWD_I1("GVRInputRawGetUncalibratedAxis", a); return 0; }
int  GVRInputRawGetStuckAxis(int a)           { OEM_FWD_I1("GVRInputRawGetStuckAxis", a);        return 0; }
int  GVRInputRawGetAxisFault(int a)           { OEM_FWD_I1("GVRInputRawGetAxisFault", a);        return 0; }
int  GVRInputRawGetFFFault(void)              { OEM_FWD_I0("GVRInputRawGetFFFault");             return 0; }
int  GVRInputRawGetButtonFault(int a)         { OEM_FWD_I1("GVRInputRawGetButtonFault", a);      return 0; }
int  GVRInputRawGetStuckButtonFault(int a)    { OEM_FWD_I1("GVRInputRawGetStuckButtonFault", a); return 0; }
void GVRInputRawIncAxisFault(int)             {}
void GVRInputRawClearAxisFault(int a)         { OEM_FWD_V1("GVRInputRawClearAxisFault", a); }
void GVRInputRawClearStuckAxis(int a)         { OEM_FWD_V1("GVRInputRawClearStuckAxis", a); }
void GVRInputRawClearButtonFault(int a)       { OEM_FWD_V1("GVRInputRawClearButtonFault", a); }
void GVRInputRawClearStuckButtonFault(int a)  { OEM_FWD_V1("GVRInputRawClearStuckButtonFault", a); }
void GVRInputRawIncButtonFault(int a)         { OEM_FWD_V1("GVRInputRawIncButtonFault", a); }

// log the first call to an export (to learn the shell's call pattern; game path stays silent-fast)
#define LOG_FIRST(nm) do { static bool once=false; if(!once){ once=true; logf("EXPORT first call: " nm); } } while(0)

// ---- exports the game never calls; the SHELL uses several - all forwarded to the OEM there ----
int  GVRInputRawGetCUSBIO(void)               { OEM_FWD_I0("GVRInputRawGetCUSBIO");            return 0; }
void GVRInputRawSleep(void)                   { OEM_FWD_V0("GVRInputRawSleep"); }
void GVRInputRawWake(void)                    { OEM_FWD_V0("GVRInputRawWake"); }
int  GVRInputRawClearFFFault(void)            { OEM_FWD_I0("GVRInputRawClearFFFault");         return 0; }
int  GVRInputRawIncFFFault(void)              { OEM_FWD_I0("GVRInputRawIncFFFault");           return 0; }
int  GVRInputRawIncStuckAxis(int a)           { OEM_FWD_I1("GVRInputRawIncStuckAxis", a);      return 0; }
int  GVRInputRawIncUncalibratedAxis(int a)    { OEM_FWD_I1("GVRInputRawIncUncalibratedAxis", a); return 0; }
int  GVRInputRawClearUncalibratedAxis(int a)  { OEM_FWD_I1("GVRInputRawClearUncalibratedAxis", a); return 0; }
int  GVRInputRawGetCardStatus(void)           { OEM_FWD_I0("GVRInputRawGetCardStatus");        return 0; }
int  GVRInputRawGetCardShutdown(void)         { OEM_FWD_I0("GVRInputRawGetCardShutdown");      return 0; }
int  GVRInputRawDispenseCard(void)            { OEM_FWD_I0("GVRInputRawDispenseCard");         return 0; }
int  GVRInputRawSetInterfaceType(int t)       { OEM_FWD_I1("GVRInputRawSetInterfaceType", t);  return 0; }
int  GVRInputRawSetMode(int m)                { OEM_FWD_I1("GVRInputRawSetMode", m);           return 0; }
int  GVRInputRawResetCalibration(void)        { OEM_FWD_I0("GVRInputRawResetCalibration");     return 0; }
int  GVRInputRawResetImmersion(void)          { OEM_FWD_I0("GVRInputRawResetImmersion");       return 0; }
int  GVRInputRawReadDrivingValues(void* buf)  { OEM_FWD_IP("GVRInputRawReadDrivingValues", buf);
                                                if (buf) GVRInputRawUpdate(buf); return 0; }
int  GVRInputRawWriteDrivingValues(void* buf) { OEM_FWD_IP("GVRInputRawWriteDrivingValues", buf); return 0; }

} // extern "C"

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD reason, LPVOID reserved) {
    if (reason == DLL_PROCESS_ATTACH) {
        g_hinst = hinst;               // for locating gvr_settings.ini from our own folder
        maybe_open_log();
        detect_host();
        // The game statically imports us, so this runs BEFORE its entry point - early enough to
        // set the render resolution from the ini without ever touching the exe on disk.
        if (g_is_game) apply_race_resolution();
    } else if (reason == DLL_PROCESS_DETACH) {
        // reserved != NULL => the process is terminating: the OS reclaims every handle, and doing
        // cleanup (CloseHandle on a device with pending async I/O) under the loader lock can
        // deadlock. Only clean up on an explicit FreeLibrary (reserved == NULL).
        if (reserved == nullptr) GVRInputRawCleanup();
    }
    return TRUE;
}
