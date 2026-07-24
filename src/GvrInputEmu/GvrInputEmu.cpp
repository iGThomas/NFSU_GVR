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
#include <hidsdi.h>
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

static void detect_host() {
    char path[MAX_PATH] = {0};
    GetModuleFileNameA(nullptr, path, MAX_PATH);
    const char* base = strrchr(path, '\\'); base = base ? base + 1 : path;
    g_is_game  = _stricmp(base, "UndergroundGVR.exe") == 0;
    g_is_shell = _stricmp(base, "UniverShell2.exe")   == 0;
    logf("host exe = %s  (game=%d shell=%d)", base, g_is_game, g_is_shell);
}

static void maybe_open_log() {
    if (g_log || !getenv("GVRINPUT_LOG")) return;
    char path[MAX_PATH]; DWORD n = GetTempPathA(MAX_PATH, path);
    strcpy(path + n, "gvrinput_emu.log");
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
static uint8_t  g_rpt[78]      = {};

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

static uint32_t map_buttons(unsigned ub) {
    static bool discovery = getenv("GVR_BTN_DISCOVERY") != nullptr;
    const BtnMap* map = discovery ? DISCOVERY_MAP : FINAL_MAP;
    int n = discovery ? (int)(sizeof(DISCOVERY_MAP)/sizeof(BtnMap))
                      : (int)(sizeof(FINAL_MAP)/sizeof(BtnMap));
    uint32_t g = 0;
    for (int i = 0; i < n; ++i)
        if (map[i].ub && (ub & map[i].ub)) g |= map[i].gbit;
    if (g_log) {
        static unsigned prev = 0xFFFFFFFFu;
        if (ub != prev) {   // log only on change
            char names[256]; names[0] = 0;
            for (int i = 0; i < n; ++i)
                if (map[i].ub && (ub & map[i].ub)) { strcat(names, map[i].name); strcat(names, " "); }
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
                    // Sony: DS4 v1 = 0x05C4, DS4 v2 = 0x09CC, DS4 USB adapter = 0x0BA0
                    g_ds4 = h;
                    logf("ds4: opened VID=%04X PID=%04X %s", at.VendorID, at.ProductID,
                         det->DevicePath);
                    free(det);
                    SetupDiDestroyDeviceInfoList(di);
                    return;
                }
                CloseHandle(h);
            }
        }
        free(det);
    }
    SetupDiDestroyDeviceInfoList(di);
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
        memset(g_rpt, 0, sizeof(g_rpt));
        DWORD rd = 0;
        BOOL ok = ReadFile(g_ds4, g_rpt, sizeof(g_rpt), &rd, &g_ov);
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
int GVRInputRawInit(void* /*hwnd*/, void* buf, const char* /*name*/) {
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
    load_xinput();
    if (g_ds4 == INVALID_HANDLE_VALUE) {
        g_ev = CreateEventA(nullptr, TRUE, FALSE, nullptr);
        g_ov = {}; g_ov.hEvent = g_ev; g_read_pending = false;
        open_ds4();
    }
    if (buf) {
        uint8_t* b = (uint8_t*)buf;
        *(uint32_t*)(b + 0x30) = 6;    // interface-type gate: enables the controller path
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
    if (pXInputGetState) {
        XINPUT_STATE_ xs;
        if (pXInputGetState(0, &xs) == ERROR_SUCCESS) {
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
static int shell_update(uint8_t* b) {
    int steer, gas, brake; unsigned ub;
    const char* src = read_pad(steer, gas, brake, ub);

    // keyboard Numpad4/6 still step the menu (the original nav), alongside the analog stick
    if (GetAsyncKeyState(VK_NUMPAD4) & 0x8000) steer = 0;
    if (GetAsyncKeyState(VK_NUMPAD6) & 0x8000) steer = 255;

    int sw = steer - 128;                // -128 (full left) .. +127 (full right), center 0
    if (sw >  127) sw =  127;
    if (sw < -128) sw = -128;
    *(int16_t*)(b + 0x00) = (int16_t)sw; // analog wheel as a SIGNED WORD -> selection by angle
    *(int16_t*)(b + 0x02) = 0;
    *(int16_t*)(b + 0x34) = 0;

    // ---- menu buttons as BUFFER BITS in buf+0x0c. These bit values are the EXACT ones the OEM
    // GVRInputRaw folded from its DirectInput keyboard (reverse-engineered from the OEM DLL):
    //   S=0x10(select/card)  O=0x20(operator)  Up=0x10000 Down=0x200 Left=0x400 Right=0x100  E=0x20000
    // The consumer edge-detects via (buf+0x0c AND NOT buf+0x10), so we publish the previous frame's
    // mask in buf+0x10.  Keyboard injection was the wrong layer - nothing here reads window keys. ----
    uint32_t cur = 0;
    if (ub & UB_CROSS)   cur |= 0x10;       // Cross   -> select / card-swipe ('S')
    if (ub & UB_OPTIONS) cur |= 0x20;       // Options -> operator menu ('O')
    if (ub & UB_DUP)     cur |= 0x10000;    // D-pad   -> operator-menu nav (arrow keys)
    if (ub & UB_DDOWN)   cur |= 0x200;
    if (ub & UB_DLEFT)   cur |= 0x400;
    if (ub & UB_DRIGHT)  cur |= 0x100;
    if (ub & UB_CIRCLE)  cur |= 0x20000;    // Circle  -> e-brake / exit-to-main ('E')
    static uint32_t prev0c = 0;
    *(uint32_t*)(b + 0x0c) = cur;           // current button mask
    *(uint32_t*)(b + 0x10) = prev0c;        // previous mask -> engine edge-detects new presses
    prev0c = cur;
    *(uint32_t*)(b + 0x30) = 6;             // keep the interface gate asserted

    if (g_log) {
        static unsigned prevub = 0xFFFFFFFF;
        if (ub != prevub) { logf("shell BTN ub=0x%X -> buf+0x0c=0x%X", ub, cur); prevub = ub; }
        static int fc = 0;
        if ((fc++ % 60) == 0) logf("shell src=%s steer=%d sw=%d ub=0x%X", src, steer, sw, ub);
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

    int steer = 128, gas = 0, brake = 0;
    unsigned ub = 0;                  // unified button flags
    const char* src = read_pad(steer, gas, brake, ub);
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
        bool r1 = (ub & UB_R1) != 0;
        bool vk = (GetAsyncKeyState('V') & 0x8000) != 0;             // keyboard V also cycles view
        if (((r1 && !prevR1) || (vk && !prevV)) && g_cam_ok) ((void(__cdecl*)())0x0058f740)();
        prevR1 = r1; prevV = vk;
    }

    // ---- sequential shifter: Square = up, Triangle = down (manual only; ignored in auto) ----
    {
        static bool prevUp = false, prevDn = false;
        bool up = (ub & UB_SQUARE) != 0, dn = (ub & UB_TRIANGLE) != 0;
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
    b[0x00] = (uint8_t)(steer - 128);
    b[0x02] = (uint8_t)gas;            // throttle -> buf+0x02  (R2)
    b[0x34] = (uint8_t)brake;          // brake    -> buf+0x34  (L2)
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
    if (g_ds4 != INVALID_HANDLE_VALUE) { CloseHandle(g_ds4); g_ds4 = INVALID_HANDLE_VALUE; }
    if (g_ev)  { CloseHandle(g_ev); g_ev = nullptr; }
    if (g_log) { fclose(g_log); g_log = nullptr; }
}

// ---- cabinet health probes: report "healthy" so the operator diagnostics stay quiet ----
int  GVRInputRawGetUncalibratedAxis(int)      { return 0; }
int  GVRInputRawGetStuckAxis(int)             { return 0; }
int  GVRInputRawGetAxisFault(int)             { return 0; }
int  GVRInputRawGetFFFault(void)              { return 0; }
int  GVRInputRawGetButtonFault(int)           { return 0; }
int  GVRInputRawGetStuckButtonFault(int)      { return 0; }
void GVRInputRawIncAxisFault(int)             {}
void GVRInputRawClearAxisFault(int)           {}
void GVRInputRawClearStuckAxis(int)           {}
void GVRInputRawClearButtonFault(int)         {}
void GVRInputRawClearStuckButtonFault(int)    {}
void GVRInputRawIncButtonFault(int)           {}

// log the first call to an export (to learn the shell's call pattern; game path stays silent-fast)
#define LOG_FIRST(nm) do { static bool once=false; if(!once){ once=true; logf("EXPORT first call: " nm); } } while(0)

// ---- exports the game never calls; the SHELL may use some of these ----
int  GVRInputRawGetCUSBIO(void)               { LOG_FIRST("GetCUSBIO"); return 0; }
void GVRInputRawSleep(void)                   {}
void GVRInputRawWake(void)                    {}
int  GVRInputRawClearFFFault(void)            { return 0; }
int  GVRInputRawIncFFFault(void)              { return 0; }
int  GVRInputRawIncStuckAxis(int)             { return 0; }
int  GVRInputRawIncUncalibratedAxis(int)      { return 0; }
int  GVRInputRawClearUncalibratedAxis(int)    { return 0; }
int  GVRInputRawGetCardStatus(void)           { LOG_FIRST("GetCardStatus"); return 0; }
int  GVRInputRawGetCardShutdown(void)         { return 0; }
int  GVRInputRawDispenseCard(void)            { return 0; }
int  GVRInputRawSetInterfaceType(int t)       { logf("SetInterfaceType(%d)", t); return 0; }
int  GVRInputRawSetMode(int m)                { logf("SetMode(%d)", m); return 0; }
int  GVRInputRawResetCalibration(void)        { return 0; }
int  GVRInputRawResetImmersion(void)          { return 0; }
// The shell may pull the wheel/pedal state through this instead of Update(). If so, fill the
// same buffer layout Update() uses so menu selection tracks the stick.
int  GVRInputRawReadDrivingValues(void* buf)  { LOG_FIRST("ReadDrivingValues"); if(buf) GVRInputRawUpdate(buf); return 0; }
int  GVRInputRawWriteDrivingValues(void*)     { return 0; }

} // extern "C"

BOOL WINAPI DllMain(HINSTANCE, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) {
        maybe_open_log();
        detect_host();
    } else if (reason == DLL_PROCESS_DETACH) {
        GVRInputRawCleanup();
    }
    return TRUE;
}
