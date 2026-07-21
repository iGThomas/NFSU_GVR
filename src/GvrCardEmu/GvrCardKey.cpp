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

#define EVENT_NAME  "Local\\GvrCardEmuInserted"
#define MUTEX_NAME  "Local\\GvrCardKeyOnce"

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
static volatile LONG g_wantToggle = 0;
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
    return lstrcmpiA(base, "UniverShell2.exe") == 0 ||
           lstrcmpiA(base, "UndergroundGVR.exe") == 0;
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
    Log("started - S inserts the card, F9 toggles (out-of-process hook)");

    // Pump messages; exit shortly after the game closes so we never linger.
    MSG msg;
    DWORD lastSeen = GetTickCount();
    for (;;) {
        while (PeekMessageA(&msg, NULL, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            DispatchMessageA(&msg);
        }
        // perform whatever the hook recorded (event signalling + logging happen HERE)
        if (InterlockedExchange(&g_wantInsert, 0)) {
            if (GameIsForeground() && !CardIn()) {
                SetEvent(g_ev);
                Log("S pressed -> card INSERTED");
            }
        }
        if (InterlockedExchange(&g_wantToggle, 0)) {
            if (GameIsForeground()) {
                if (CardIn()) { ResetEvent(g_ev); Log("F9 -> card REMOVED"); }
                else          { SetEvent(g_ev);   Log("F9 -> card INSERTED"); }
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
