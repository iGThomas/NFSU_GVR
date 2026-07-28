// ---------------------------------------------------------------------------
// GvrCardKey.exe - out-of-process key watcher for the virtual smart card.
//
// WHY A SEPARATE PROCESS
// ---------------------
// Detecting the player's START key from inside UniverShell2 does not work. Verified, in
// order, all inside the shell process:
//
//   * GetAsyncKeyState polling  - useless: the attract demo drives itself, so S / Numpad4 /
//                                 even F9 read as pressed with nobody at the keyboard.
//   * RegisterRawInputDevices   - actively harmful: raw input registration is per-process
//                                 per-device, so ours DISPLACED the game's own GVRInputRaw
//                                 registration and the shell stopped receiving keys at all
//                                 (that was the "buttons dead until I alt-tab" bug).
//   * WH_KEYBOARD_LL in-process - receives NOTHING. Not one event, not even a deliberately
//                                 injected test key, with the hook confirmed installed and
//                                 the pumping thread confirmed alive via heartbeat.
//   * subclassing the shell window and watching its WM_INPUT - also nothing.
//
// A low-level hook in an ordinary process does work, so the watcher lives here instead. It
// signals the card state through the same named event the DLLs already use as their single
// source of truth, so the shell and the game both see the slot change.
//
//   S   -> insert the card (also what skips attract, so it is the natural moment)
//   F9  -> toggle insert / remove
//
// Injected keystrokes are ignored via LLKHF_INJECTED, which is what keeps the attract demo's
// synthetic START from inserting the card by itself.
//
// Started automatically by GvrCardEmu.dll; exits once the game is gone.
// ---------------------------------------------------------------------------

#include <windows.h>
#include <stdio.h>
#include <tlhelp32.h>
#include <hidsdi.h>
#include <hidpi.h>      // HidP_GetCaps - report length + collection usage (USB vs Bluetooth DS4)
#include <setupapi.h>

#pragma comment(lib, "hid.lib")
#pragma comment(lib, "setupapi.lib")

#define EVENT_NAME  "Local\\GvrCardEmuInserted"
#define MUTEX_NAME  "Local\\GvrCardKeyOnce"

// ---------------------------------------------------------------------------
// Gamepad support: Cross (PS4) / A (Xbox) inserts the card, exactly like the S key.
// The pad has no attract-demo problem (the demo never touches the controller), so a plain
// rising-edge on the button is enough - the same GameIsForeground()/!CardIn() guards in the
// message loop still gate whether the insert actually happens.
// ---------------------------------------------------------------------------
struct XPAD { WORD wButtons; BYTE bLT, bRT; SHORT lx, ly, rx, ry; };
struct XST  { DWORD packet; XPAD g; };
typedef DWORD (WINAPI *PFN_XGet)(DWORD, XST*);
static PFN_XGet pXGet = NULL;
static void LoadXInput()
{
    const char* names[] = { "xinput1_4.dll", "xinput1_3.dll", "xinput9_1_0.dll" };
    for (int i = 0; i < 3; ++i) { HMODULE h = LoadLibraryA(names[i]);
        if (h) { pXGet = (PFN_XGet)GetProcAddress(h, "XInputGetState"); if (pXGet) return; } }
}

static HANDLE     g_ds4 = INVALID_HANDLE_VALUE, g_ds4ev = NULL;
static OVERLAPPED g_ds4ov = {};
static bool       g_ds4pending = false;
// Buffer must cover the collection's InputReportByteLength: USB DS4 = 64, but a BLUETOOTH DS4
// reports a much larger length (seen: 547). A fixed 78-byte read simply FAILS over Bluetooth, which
// is why Cross stopped inserting the card once the pad was paired wirelessly. Same fix as
// GvrInputEmu: size the read from the device caps, prefer the GAMEPAD collection, and kick the pad
// into full-report mode.
static BYTE       g_ds4rpt[1024] = {};
static DWORD      g_ds4rptlen = 78;
static volatile bool g_ds4cross = false;
static void Log(const char* fmt, ...);      // defined below

// ---- which pad button inserts/ejects the card -------------------------------------------------
// Configurable, like every other pad button: gvr_settings.ini [Frontend] `<button> = card`.
// Default R3 (right stick click) - chosen because Cross is already menu "select" / in-race e-brake,
// and R3 is unused by the game. This exe reads the pad itself (it is not the input DLL), so it
// needs its own button table: DS4 raw-HID byte+mask, and the XInput wButtons mask.
//   DS4 report (o = base): byte[o+5] = face buttons + hat, byte[o+6] = shoulders/sticks, [o+7] = PS
struct PadBtnDef { const char* name; int byteOff; BYTE mask; int hat; WORD xi; };
static const PadBtnDef PAD_BTNS[] = {
    {"square",  5,0x10,-1,0x4000},{"cross",   5,0x20,-1,0x1000},{"circle", 5,0x40,-1,0x2000},
    {"triangle",5,0x80,-1,0x8000},{"l1",      6,0x01,-1,0x0100},{"r1",     6,0x02,-1,0x0200},
    {"l2",      6,0x04,-1,0x0000},{"r2",      6,0x08,-1,0x0000},{"share",  6,0x10,-1,0x0020},
    {"options", 6,0x20,-1,0x0010},{"l3",      6,0x40,-1,0x0040},{"r3",     6,0x80,-1,0x0080},
    {"ps",      7,0x01,-1,0x0000},
    {"dup",     5,0x00, 0,0x0001},{"dright",  5,0x00, 1,0x0008},{"ddown",   5,0x00, 2,0x0002},
    {"dleft",   5,0x00, 3,0x0004},
    // Xbox aliases - alternative spellings of the same positional buttons (A=bottom, B=right,
    // X=left, Y=top), so an Xbox player can write the name printed on their pad.
    {"a",       5,0x20,-1,0x1000},{"b",       5,0x40,-1,0x2000},{"x",      5,0x10,-1,0x4000},
    {"y",       5,0x80,-1,0x8000},{"lb",      6,0x01,-1,0x0100},{"rb",     6,0x02,-1,0x0200},
    {"lt",      6,0x04,-1,0x0000},{"rt",      6,0x08,-1,0x0000},{"start",  6,0x20,-1,0x0010},
    {"menu",    6,0x20,-1,0x0010},{"back",    6,0x10,-1,0x0020},{"view",   6,0x10,-1,0x0020},
    {"ls",      6,0x40,-1,0x0040},{"rs",      6,0x80,-1,0x0080},{"guide",  7,0x01,-1,0x0000},
};
static const PadBtnDef* g_cardBtn = &PAD_BTNS[11];   // r3

// hat (b5 & 0x0F) -> is direction `dir` (0=up 1=right 2=down 3=left) pressed?
static bool HatHas(BYTE b5, int dir) {
    int h = b5 & 0x0F;
    switch (dir) {
        case 0: return h == 0 || h == 1 || h == 7;
        case 1: return h == 1 || h == 2 || h == 3;
        case 2: return h == 3 || h == 4 || h == 5;
        case 3: return h == 5 || h == 6 || h == 7;
    }
    return false;
}
static bool Ds4BtnHeld(const BYTE* rpt, int o) {
    const PadBtnDef* d = g_cardBtn;
    if (d->hat >= 0) return HatHas(rpt[o + 5], d->hat);
    return (rpt[o + d->byteOff] & d->mask) != 0;
}

// Read the card button from the shared gvr_settings.ini: the [Frontend] line whose action is
// `card`, e.g. `R3 = card`. The ini sits at the install root and this exe runs from CardEmu\ or
// the root itself, so walk up. No file / no such line = keep the R3 default.
static void LoadCardButton() {
    char dir[MAX_PATH] = {0};
    GetModuleFileNameA(NULL, dir, MAX_PATH);
    char* s = strrchr(dir, '\\'); if (s) *s = 0;
    char probe[MAX_PATH]; lstrcpynA(probe, dir, MAX_PATH);
    for (int up = 0; up <= 4; ++up) {
        char cand[MAX_PATH]; wsprintfA(cand, "%s\\gvr_settings.ini", probe);
        FILE* f = fopen(cand, "r");
        if (f) {
            char line[256], section[64] = {0};
            while (fgets(line, sizeof(line), f)) {
                char* p = line; while (*p == ' ' || *p == '\t') ++p;
                if (*p == ';' || *p == '#' || *p == '\r' || *p == '\n' || !*p) continue;
                if (*p == '[') { char* e = strchr(p, ']'); if (e) { *e = 0; lstrcpynA(section, p + 1, sizeof(section)); } continue; }
                if (_stricmp(section, "Frontend") != 0) continue;
                char* eq = strchr(p, '='); if (!eq) continue;
                *eq = 0; char* btn = p; char* act = eq + 1;
                char* e = btn + strlen(btn); while (e > btn && (e[-1]==' '||e[-1]=='\t')) *--e = 0;
                while (*act == ' ' || *act == '\t') ++act;
                char* cmt = strpbrk(act, ";#"); if (cmt) *cmt = 0;
                e = act + strlen(act); while (e > act && (e[-1]==' '||e[-1]=='\t'||e[-1]=='\r'||e[-1]=='\n')) *--e = 0;
                if (_stricmp(act, "card") != 0) continue;
                for (const PadBtnDef& d : PAD_BTNS) if (_stricmp(d.name, btn) == 0) { g_cardBtn = &d; break; }
            }
            fclose(f);
            Log("card button: %s (from %s)", g_cardBtn->name, cand);
            return;
        }
        char* q = strrchr(probe, '\\'); if (!q) break; *q = 0;
    }
    Log("card button: %s (no gvr_settings.ini found)", g_cardBtn->name);
}

static void OpenDs4()
{
    GUID hg; HidD_GetHidGuid(&hg);
    HDEVINFO di = SetupDiGetClassDevs(&hg, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
    if (di == INVALID_HANDLE_VALUE) return;
    HANDLE fallback = INVALID_HANDLE_VALUE; DWORD fallbackLen = 78;
    SP_DEVICE_INTERFACE_DATA ifd; ifd.cbSize = sizeof(ifd);
    for (DWORD i = 0; SetupDiEnumDeviceInterfaces(di, NULL, &hg, i, &ifd); ++i) {
        DWORD need = 0; SetupDiGetDeviceInterfaceDetailA(di, &ifd, NULL, 0, &need, NULL);
        if (!need) continue;
        SP_DEVICE_INTERFACE_DETAIL_DATA_A* det = (SP_DEVICE_INTERFACE_DETAIL_DATA_A*)malloc(need);
        det->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_A);
        if (SetupDiGetDeviceInterfaceDetailA(di, &ifd, det, need, NULL, NULL)) {
            HANDLE h = CreateFileA(det->DevicePath, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE,
                                   NULL, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL);
            if (h != INVALID_HANDLE_VALUE) {
                HIDD_ATTRIBUTES at; at.Size = sizeof(at);
                if (HidD_GetAttributes(h, &at) && at.VendorID == 0x054C) {
                    // A DS4 exposes several HID collections; take the GAMEPAD one (usage 01:05),
                    // otherwise the button bytes we decode belong to a different collection.
                    unsigned inLen = 0, usagePage = 0, usage = 0;
                    PHIDP_PREPARSED_DATA pp = NULL;
                    if (HidD_GetPreparsedData(h, &pp)) {
                        HIDP_CAPS caps;
                        if (HidP_GetCaps(pp, &caps) == HIDP_STATUS_SUCCESS) {
                            inLen = caps.InputReportByteLength;
                            usagePage = caps.UsagePage; usage = caps.Usage;
                        }
                        HidD_FreePreparsedData(pp);
                    }
                    DWORD rlen = (inLen > 0 && inLen <= sizeof(g_ds4rpt)) ? inLen : 78;
                    if (usagePage == 0x01 && (usage == 0x05 || usage == 0x04)) {
                        g_ds4 = h; g_ds4rptlen = rlen;
                        // Bluetooth DS4 only sends the basic report until feature 0x02 is read.
                        BYTE feat[64]; ZeroMemory(feat, sizeof(feat)); feat[0] = 0x02;
                        HidD_GetFeature(g_ds4, feat, sizeof(feat));
                        Log("gamepad: opened GAMEPAD collection, readLen=%lu", g_ds4rptlen);
                        if (fallback != INVALID_HANDLE_VALUE) CloseHandle(fallback);
                        free(det); SetupDiDestroyDeviceInfoList(di); return;
                    }
                    if (fallback == INVALID_HANDLE_VALUE) { fallback = h; fallbackLen = rlen; h = INVALID_HANDLE_VALUE; }
                }
                if (h != INVALID_HANDLE_VALUE) CloseHandle(h);
            }
        }
        free(det);
    }
    SetupDiDestroyDeviceInfoList(di);
    if (fallback != INVALID_HANDLE_VALUE) {
        g_ds4 = fallback; g_ds4rptlen = fallbackLen;
        BYTE feat[64]; ZeroMemory(feat, sizeof(feat)); feat[0] = 0x02;
        HidD_GetFeature(g_ds4, feat, sizeof(feat));
        Log("gamepad: no gamepad-usage collection; using first 054C, readLen=%lu", g_ds4rptlen);
    }
}
static void PumpDs4()
{
    if (g_ds4 == INVALID_HANDLE_VALUE) return;
    for (int guard = 0; guard < 16; ++guard) {
        if (g_ds4pending) {
            DWORD rd = 0;
            if (!GetOverlappedResult(g_ds4, &g_ds4ov, &rd, FALSE)) {
                if (GetLastError() == ERROR_IO_INCOMPLETE) return;
                g_ds4pending = false;
            } else {
                g_ds4pending = false;
                int o = (g_ds4rpt[0] == 0x11) ? 2 : (g_ds4rpt[0] == 0x01 ? 0 : -1);
                if (o >= 0 && (DWORD)(o + 8) <= rd) g_ds4cross = Ds4BtnHeld(g_ds4rpt, o);
            }
        }
        ResetEvent(g_ds4ev); memset(g_ds4rpt, 0, g_ds4rptlen);
        DWORD rd = 0;
        if (ReadFile(g_ds4, g_ds4rpt, g_ds4rptlen, &rd, &g_ds4ov)) {   // BT needs the FULL length
            int o = (g_ds4rpt[0] == 0x11) ? 2 : (g_ds4rpt[0] == 0x01 ? 0 : -1);
            if (o >= 0 && (DWORD)(o + 8) <= rd) g_ds4cross = Ds4BtnHeld(g_ds4rpt, o);
        } else if (GetLastError() == ERROR_IO_PENDING) { g_ds4pending = true; return; }
        else return;
    }
}
// True while Cross/A is held (either controller type).
// R3 (right stick click) = insert the card, or eject it if one is already in.
// Chosen over Cross deliberately: Cross is already the menu "select" / in-race e-brake, so it was
// doing double duty. R3 is unused by the game.
//   DS4 raw HID: byte[o+6] bit 0x80 = R3.   XInput: XINPUT_GAMEPAD_RIGHT_THUMB = 0x0080.
static bool PadInsertHeld()
{
    // Do NOT poll XInput every tick when no XInput pad is present: XInputGetState on an empty slot
    // re-enumerates devices via DEVOBJ/cfgmgr32 on every call (very expensive). Back off to a 3s
    // retry when the slot is empty. (Same defect caused the shell's race-end hang in GVRInputRaw.)
    static DWORD nextTry = 0;
    if (pXGet && (DWORD)(GetTickCount() - nextTry) < 0x80000000u) {
        XST xs;
        DWORD r = pXGet(0, &xs);
        if (r == 0) { if (g_cardBtn->xi && (xs.g.wButtons & g_cardBtn->xi)) return true; }
        else nextTry = GetTickCount() + 3000;
    }
    PumpDs4();
    return g_ds4cross;
}

static HANDLE g_ev = NULL;
static HHOOK  g_hook = NULL;
static char   g_log[MAX_PATH];

static void Log(const char* fmt, ...)
{
    char line[512];
    SYSTEMTIME st;
    GetLocalTime(&st);
    int n = wsprintfA(line, "%02d:%02d:%02d.%03d  [keywatch] ",
                      st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
    va_list ap;
    va_start(ap, fmt);
    n += wvsprintfA(line + n, fmt, ap);
    va_end(ap);
    line[n++] = '\r'; line[n++] = '\n';

    HANDLE h = CreateFileA(g_log, FILE_APPEND_DATA, FILE_SHARE_READ | FILE_SHARE_WRITE,
                           NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h != INVALID_HANDLE_VALUE) {
        DWORD w = 0;
        SetFilePointer(h, 0, NULL, FILE_END);
        WriteFile(h, line, n, &w, NULL);
        CloseHandle(h);
    }
}

static bool CardIn()
{
    return g_ev && WaitForSingleObject(g_ev, 0) == WAIT_OBJECT_0;
}

static volatile LONG g_wantInsert = 0;
static volatile LONG g_wantToggle = 0;      // from the F9 key  (needs the game focused)
static volatile LONG g_wantPadToggle = 0;   // from the pad R3   (game only needs to be running)
static HWND g_wnd = NULL;
static bool g_rawOk = false;   // raw input active -> it decides, the hook stands down

// Raw-input handler: records WHICH DEVICE produced the key, so the attract demo's synthetic
// START (which does NOT carry LLKHF_INJECTED) can be told from the player's keyboard.
static LRESULT CALLBACK RawProc(HWND h, UINT m, WPARAM w, LPARAM l)
{
    if (m != WM_INPUT) return DefWindowProcA(h, m, w, l);

    UINT sz = 0;
    if (GetRawInputData((HRAWINPUT)l, RID_INPUT, NULL, &sz, sizeof(RAWINPUTHEADER)) == 0 &&
        sz && sz <= 256) {
        BYTE buf[256];
        if (GetRawInputData((HRAWINPUT)l, RID_INPUT, buf, &sz, sizeof(RAWINPUTHEADER)) == sz) {
            const RAWINPUT* ri = (const RAWINPUT*)buf;
            if (ri->header.dwType == RIM_TYPEKEYBOARD) {
                const RAWKEYBOARD& kb = ri->data.keyboard;
                if ((kb.Message == WM_KEYDOWN || kb.Message == WM_SYSKEYDOWN) &&
                    (kb.VKey == 'S' || kb.VKey == VK_F9)) {
                    char name[256] = "";
                    UINT n = sizeof(name);
                    GetRawInputDeviceInfoA(ri->header.hDevice, RIDI_DEVICENAME, name, &n);
                    Log("rawkey vk=%u hDevice=%p dev='%s'", kb.VKey, ri->header.hDevice, name);
                    if (ri->header.hDevice != NULL) {
                        if (kb.VKey == 'S') g_wantInsert = 1;
                        else                g_wantToggle = 1;
                    }
                }
            }
        }
    }
    return DefWindowProcA(h, m, w, l);
}

// THIS CALLBACK MUST DO ALMOST NOTHING.
// A low-level keyboard hook sits in the path of EVERY keystroke on the machine, so any slow
// work here delays the user's own typing - which is what made the controls feel sticky while
// racing (S is "reset car", and each press was doing a file write from in here). Windows will
// also silently unhook a callback that overruns LowLevelHooksTimeout. So: just record the
// request and let the message loop do the event signalling and the logging.
static LRESULT CALLBACK Proc(int code, WPARAM wp, LPARAM lp)
{
    if (code == HC_ACTION && (wp == WM_KEYDOWN || wp == WM_SYSKEYDOWN)) {
        const KBDLLHOOKSTRUCT* k = (const KBDLLHOOKSTRUCT*)lp;
        // Only a fallback. When raw input is available it decides, because it can identify
        // the device and this cannot: the attract demo's START arrives without the injected
        // flag, so acting on it here would insert the card by itself.
        if (!g_rawOk && !(k->flags & (LLKHF_INJECTED | LLKHF_LOWER_IL_INJECTED))) {
            if (k->vkCode == 'S')        g_wantInsert = 1;
            else if (k->vkCode == VK_F9) g_wantToggle = 1;
        }
    }
    return CallNextHookEx(g_hook, code, wp, lp);
}

// Only react while the game is actually the foreground application, so typing "s" in a
// browser cannot insert the card. Checked out here, never in the hook callback.
static bool GameIsForeground()
{
    HWND fg = GetForegroundWindow();
    if (!fg) return false;
    DWORD pid = 0;
    GetWindowThreadProcessId(fg, &pid);
    if (!pid) return false;
    HANDLE h = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!h) return false;
    char path[MAX_PATH] = "";
    DWORD n = MAX_PATH;
    bool ok = QueryFullProcessImageNameA(h, 0, path, &n) != 0;
    CloseHandle(h);
    if (!ok) return false;
    const char* base = path;
    for (const char* p = path; *p; ++p) if (*p == '\\' || *p == '/') base = p + 1;
    bool ours = lstrcmpiA(base, "UniverShell2.exe")   == 0 ||
                lstrcmpiA(base, "UndergroundGVR.exe") == 0 ||
                lstrcmpiA(base, "GvrLaunch.exe")      == 0;   // our launcher/backdrop counts too
    if (!ours) {   // say WHICH window blocked it - this guard silently ate every pad insert once
        static char lastBlocked[64] = "";
        if (lstrcmpiA(lastBlocked, base) != 0) {
            lstrcpynA(lastBlocked, base, sizeof(lastBlocked));
            Log("insert ignored: foreground is '%s', not the game", base);
        }
    }
    return ours;
}

static bool GameRunning()
{
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return true;
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(pe);
    bool found = false;
    if (Process32First(snap, &pe)) {
        do {
            if (lstrcmpiA(pe.szExeFile, "UniverShell2.exe") == 0 ||
                lstrcmpiA(pe.szExeFile, "UndergroundGVR.exe") == 0) { found = true; break; }
        } while (Process32Next(snap, &pe));
    }
    CloseHandle(snap);
    return found;
}

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE, LPSTR cmdline, int)
{
    // one watcher only
    HANDLE once = CreateMutexA(NULL, TRUE, MUTEX_NAME);
    if (!once || GetLastError() == ERROR_ALREADY_EXISTS) return 0;

    // log next to the card image; the DLL passes that folder on the command line
    if (cmdline && *cmdline) wsprintfA(g_log, "%s\\GvrCardEmu.log", cmdline);
    else                     lstrcpynA(g_log, "GvrCardEmu.log", MAX_PATH);

    g_ev = CreateEventA(NULL, TRUE, FALSE, EVENT_NAME);   // manual-reset, shared

    // gamepad: the configured button (default R3) toggles the card, like the S key inserts it
    LoadCardButton();
    LoadXInput();
    g_ds4ev = CreateEventA(NULL, TRUE, FALSE, NULL);
    g_ds4ov.hEvent = g_ds4ev;
    OpenDs4();
    Log("gamepad: xinput=%s ds4=%s (%s toggles the card)",
        pXGet ? "yes" : "no", g_ds4 != INVALID_HANDLE_VALUE ? "opened" : "none", g_cardBtn->name);

    // Raw Input, for the ORIGINATING DEVICE of each keystroke.
    // LLKHF_INJECTED is not enough: the attract demo's synthetic START arrives WITHOUT the
    // injected flag (it comes from a driver-level layer, not SendInput), so the low-level
    // hook alone cannot tell it from the player pressing S. Raw input identifies the device,
    // which can. Registering it here is safe - this is a separate process, so it does not
    // disturb the game's own GVRInputRaw registration the way doing it in-process did.
    WNDCLASSA wc;
    ZeroMemory(&wc, sizeof(wc));
    wc.lpfnWndProc = RawProc;
    wc.hInstance = hInst;
    wc.lpszClassName = "GvrCardKeyWnd";
    RegisterClassA(&wc);
    g_wnd = CreateWindowExA(0, "GvrCardKeyWnd", "", 0, 0, 0, 0, 0,
                            HWND_MESSAGE, NULL, hInst, NULL);
    RAWINPUTDEVICE rid;
    rid.usUsagePage = 0x01;
    rid.usUsage     = 0x06;             // keyboard
    rid.dwFlags     = RIDEV_INPUTSINK;
    rid.hwndTarget  = g_wnd;
    if (g_wnd && RegisterRawInputDevices(&rid, 1, sizeof(rid)))
        { g_rawOk = true; Log("raw input registered (device-level filtering active)"); }
    else
        Log("!! raw input registration failed (err %lu) - falling back to the hook", GetLastError());

    g_hook = SetWindowsHookExA(WH_KEYBOARD_LL, Proc, hInst, 0);
    if (!g_hook) {
        Log("!! SetWindowsHookEx failed (err %lu)", GetLastError());
        return 1;
    }
    Log("started - S inserts, F9 or pad %s toggles (out-of-process hook)", g_cardBtn->name);

    // Pump messages; exit shortly after the game closes so we never linger.
    MSG msg;
    DWORD lastSeen = GetTickCount();
    for (;;) {
        while (PeekMessageA(&msg, NULL, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            DispatchMessageA(&msg);
        }
        // gamepad R3 -> TOGGLE the card (insert if the slot is empty, eject if one is in),
        // i.e. the same action as F9 rather than the insert-only S key.
        {
            // Debounced edge: HID reads arrive in bursts, so a raw edge test fired many times per
            // press (the log showed ~10 "requests" for one click, toggling the card in and out
            // again). Require the button to read released for a moment before the next press counts.
            static bool prevR3 = false;
            static DWORD lastFire = 0;
            bool r3 = PadInsertHeld();
            DWORD now = GetTickCount();
            if (r3 && !prevR3 && (now - lastFire) > 400) {
                lastFire = now;
                g_wantPadToggle = 1;          // pad path: no foreground requirement (see below)
                Log("pad R3 -> card toggle request");
            }
            prevR3 = r3;
        }

        // perform whatever the hook recorded (event signalling + logging happen HERE)
        if (InterlockedExchange(&g_wantInsert, 0)) {
            if (GameIsForeground() && !CardIn()) {
                SetEvent(g_ev);
                Log("insert (S or pad Cross) -> card INSERTED");
            }
        }
        // KEYBOARD F9: keep the strict foreground check - a stray keypress in another app must not
        // touch the card slot.
        if (InterlockedExchange(&g_wantToggle, 0)) {
            if (GameIsForeground()) {
                if (CardIn()) { ResetEvent(g_ev); Log("F9 -> card REMOVED"); }
                else          { SetEvent(g_ev);   Log("F9 -> card INSERTED"); }
            }
        }
        // GAMEPAD R3: only require the game to be RUNNING, not focused. A pad button cannot be
        // "typed into a browser" by accident, so the foreground rule buys nothing here - and it
        // silently ate every pad press, because the borderless shell often leaves explorer.exe as
        // the foreground window (it is no longer always-on-top).
        if (InterlockedExchange(&g_wantPadToggle, 0)) {
            if (GameRunning()) {
                if (CardIn()) { ResetEvent(g_ev); Log("pad R3 -> card REMOVED"); }
                else          { SetEvent(g_ev);   Log("pad R3 -> card INSERTED"); }
            } else {
                Log("pad R3 ignored: neither the shell nor the game is running");
            }
        }

        if (GameRunning()) lastSeen = GetTickCount();
        else if (GetTickCount() - lastSeen > 8000) break;
        Sleep(20);
    }
    UnhookWindowsHookEx(g_hook);
    Log("game gone - exiting");
    return 0;
}
