// GvrLaunch.exe - the one-click launcher for NFS Underground GlobalVR.
//
// WHY THIS EXISTS
// ---------------
// Neither executable has a resolution setting, so resolution used to be applied by REWRITING
// constants inside the exes (Tools\Apply-GvrSettings.ps1, with .orig backups). That means editing
// gvr_settings.ini did nothing until you remembered to re-run the tool.
//
// This launcher removes that step. It starts UniverShell2.exe SUSPENDED, writes the resolution
// from gvr_settings.ini [Display] straight into the process image, then resumes it - so the setting
// takes effect on every launch and **UniverShell2.exe on disk is never modified**.
//
// The race half needs no wrapper: UndergroundGVR.exe statically imports GVRInputRaw.dll, so that
// DLL's DllMain runs before the exe's entry point and applies the same [Display] size the same
// in-memory way - one shared section, so the frontend and the race always line up.
//
// Patch sites (verified for this build, and each is byte-checked before writing):
//   UniverShell2.exe is a managed image; the sizes are CIL `ldc.i4` operands.
//     file 0x928C: 20 <width> 20 <height>   <- the Form's ClientSize (window size)
//     file 0x9450: 20 <width> 20 <height>   <- the DXPanel Size  (THE RENDER SURFACE)
//   BOTH must be patched: patching only the form gives a big window still rendering at 800x600,
//   because Render_Initialize() takes the backbuffer size from the DXPanel's rect.

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <tlhelp32.h>   // process snapshot - is the race still running?
#include <olectl.h>     // OleLoadPicture / IPicture - decodes the boot screen JPG
#include <ocidl.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>

// ---- CIL ldc.i4 operand sites (file offsets) --------------------------------------------------
static const DWORD SITE_FORM_W  = 0x928D, SITE_FORM_H  = 0x9292;
static const DWORD SITE_PANEL_W = 0x9451, SITE_PANEL_H = 0x9456;

static void die(const char* fmt, ...) {
    char msg[1024];
    va_list ap; va_start(ap, fmt); vsprintf(msg, fmt, ap); va_end(ap);
    MessageBoxA(nullptr, msg, "GvrLaunch", MB_ICONERROR | MB_OK);
    ExitProcess(1);
}

// walk up from `start` looking for gvr_settings.ini
static bool find_ini(const char* start, char* out) {
    char probe[MAX_PATH]; lstrcpynA(probe, start, MAX_PATH);
    for (int up = 0; up <= 5; ++up) {
        char cand[MAX_PATH]; wsprintfA(cand, "%s\\gvr_settings.ini", probe);
        if (GetFileAttributesA(cand) != INVALID_FILE_ATTRIBUTES) { lstrcpyA(out, cand); return true; }
        char* q = strrchr(probe, '\\'); if (!q) break; *q = 0;
    }
    return false;
}

// file offset -> RVA using the section table of the on-disk image
static DWORD file_off_to_rva(const char* exePath, DWORD fileOff) {
    FILE* f = fopen(exePath, "rb");
    if (!f) return 0;
    static BYTE hdr[4096];
    size_t n = fread(hdr, 1, sizeof(hdr), f);
    fclose(f);
    if (n < 0x200 || hdr[0] != 'M' || hdr[1] != 'Z') return 0;
    DWORD e_lfanew = *(DWORD*)(hdr + 0x3C);
    if (e_lfanew + 0xF8 > n) return 0;
    BYTE* nt = hdr + e_lfanew;
    WORD  nSec = *(WORD*)(nt + 6);
    WORD  optSize = *(WORD*)(nt + 20);
    BYTE* sec = nt + 24 + optSize;
    for (int i = 0; i < nSec; ++i, sec += 40) {
        DWORD va = *(DWORD*)(sec + 12), rawSz = *(DWORD*)(sec + 16), rawPtr = *(DWORD*)(sec + 20);
        if (fileOff >= rawPtr && fileOff < rawPtr + rawSz) return va + (fileOff - rawPtr);
    }
    return 0;
}

// the actual load address of the target's main image (read from its PEB; works while suspended)
typedef LONG (WINAPI *PFN_NtQIP)(HANDLE, ULONG, PVOID, ULONG, PULONG);
static BYTE* remote_image_base(HANDLE proc) {
    PFN_NtQIP q = (PFN_NtQIP)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtQueryInformationProcess");
    if (!q) return nullptr;
    struct { PVOID a; PVOID PebBaseAddress; PVOID b[4]; } pbi = {};
    ULONG got = 0;
    if (q(proc, 0 /*ProcessBasicInformation*/, &pbi, sizeof(pbi), &got) < 0 || !pbi.PebBaseAddress) return nullptr;
    BYTE* base = nullptr; SIZE_T rd = 0;
    // x86 PEB: ImageBaseAddress at +0x08
    if (!ReadProcessMemory(proc, (BYTE*)pbi.PebBaseAddress + 0x08, &base, sizeof(base), &rd)) return nullptr;
    return base;
}

static bool patch_dword(HANDLE proc, BYTE* addr, DWORD value, const char* what, char* log, size_t logn) {
    BYTE opcode = 0; SIZE_T rw = 0;
    if (!ReadProcessMemory(proc, addr - 1, &opcode, 1, &rw) || opcode != 0x20) {   // CIL ldc.i4
        _snprintf(log + strlen(log), logn - strlen(log), "  %s: site does not look like ldc.i4 (0x%02X) - skipped\r\n", what, opcode);
        return false;
    }
    DWORD old = 0;
    VirtualProtectEx(proc, addr, 4, PAGE_EXECUTE_READWRITE, &old);
    BOOL ok = WriteProcessMemory(proc, addr, &value, 4, &rw);
    VirtualProtectEx(proc, addr, 4, old, &old);
    _snprintf(log + strlen(log), logn - strlen(log), "  %s = %lu %s\r\n", what, value, ok ? "OK" : "FAILED");
    return ok != FALSE;
}

// ---- [Race] Fullscreen=true|false --------------------------------------------------------------
// The shell launches the race with a base argument string stored in a GVRD container
// (GvrRoot\gvr\CommandlineArgs_data.gvr). Whether the race runs fullscreen or in a window is just
// the "-forcefullscreen" / "-forcewindowed" token in that string, so we sync it from the ini here,
// before the shell starts. Both tokens are exactly 16 bytes:
//     "-forcefullscreen"  <->  "-forcewindowed  "
// so the swap is length-preserving: the GVRD record length and every offset stay valid.
static const char* TOK_FULL = "-forcefullscreen";
static const char* TOK_WIND = "-forcewindowed  ";

static bool sync_race_fullscreen(const char* shellDir, bool wantFullscreen, char* log, size_t logn) {
    char path[MAX_PATH];
    wsprintfA(path, "%s\\gvr\\CommandlineArgs_data.gvr", shellDir);
    HANDLE h = CreateFileA(path, GENERIC_READ | GENERIC_WRITE, 0, nullptr, OPEN_EXISTING, 0, nullptr);
    if (h == INVALID_HANDLE_VALUE) {
        _snprintf(log + strlen(log), logn - strlen(log), "  launch args: %s not found (%lu)\r\n", path, GetLastError());
        return false;
    }
    DWORD size = GetFileSize(h, nullptr), got = 0;
    if (size == INVALID_FILE_SIZE || size > 4 * 1024 * 1024) { CloseHandle(h); return false; }
    BYTE* buf = (BYTE*)malloc(size);
    if (!buf) { CloseHandle(h); return false; }
    ReadFile(h, buf, size, &got, nullptr);

    const char* have = wantFullscreen ? TOK_WIND : TOK_FULL;   // what we must replace
    const char* want = wantFullscreen ? TOK_FULL : TOK_WIND;
    bool changed = false;
    for (DWORD i = 0; i + 16 <= got; ++i) {
        if (memcmp(buf + i, have, 16) == 0) {
            SetFilePointer(h, i, nullptr, FILE_BEGIN);
            DWORD wr = 0; WriteFile(h, want, 16, &wr, nullptr);
            changed = true;
            break;
        }
    }
    free(buf);
    CloseHandle(h);
    _snprintf(log + strlen(log), logn - strlen(log), "  race window mode: %s%s\r\n",
              wantFullscreen ? "fullscreen" : "windowed", changed ? " (updated)" : " (already set)");
    return changed;
}

// ================== backdrop: never show the desktop between the two exes ======================
// The shell and the race are two separate programs, so when one exits and the other starts you
// briefly see the Windows desktop. This puts a full-screen window BEHIND whichever one is running
// and paints the last frame we captured, so the swap looks like one continuous application.
//
// It deliberately does NOT re-parent the game/shell windows (an earlier experiment did, and being
// a child window made both apps mute their audio and lose input focus). They stay ordinary
// top-level windows; we only sit behind them in the z-order.
static HWND    g_backdrop = nullptr;
static bool    g_merge = false;          // [Launcher] Merge=true -> adopt both windows as children
static int     g_missing = 0;            // consecutive ticks with no game/frontend window visible
static HBITMAP g_boot = nullptr;         // the game's own boot screen, shown between the two exes
static int     g_bootW = 0, g_bootH = 0;
static HBITMAP g_shot = nullptr;
static int     g_shotW = 0, g_shotH = 0;
static DWORD   g_lastShot = 0;
static DWORD   g_lastSeen = 0;

// tiny log helper (only when GVRLAUNCH_VERBOSE is set, shown at exit)
static char g_diag[2048];
static void logf2(const char* f, ...) {
    size_t used = strlen(g_diag);
    if (used > sizeof(g_diag) - 200) return;
    va_list a; va_start(a, f);
    _vsnprintf(g_diag + used, sizeof(g_diag) - used - 3, f, a);
    va_end(a);
    strcat(g_diag, "\r\n");
}

static bool pid_is(DWORD pid, const char* exe) {
    HANDLE p = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!p) return false;
    char path[MAX_PATH] = ""; DWORD n = MAX_PATH;
    bool ok = QueryFullProcessImageNameA(p, 0, path, &n) != 0;
    CloseHandle(p);
    if (!ok) return false;
    const char* b = strrchr(path, '\\'); b = b ? b + 1 : path;
    return lstrcmpiA(b, exe) == 0;
}
struct Find { HWND hit; };
static BOOL CALLBACK find_cb(HWND h, LPARAM lp) {
    Find* f = (Find*)lp;
    if (h == g_backdrop || !IsWindowVisible(h) || GetWindow(h, GW_OWNER)) return TRUE;
    RECT rc; GetClientRect(h, &rc);
    if (rc.right < 320 || rc.bottom < 240) return TRUE;
    DWORD pid = 0; GetWindowThreadProcessId(h, &pid);
    if (pid_is(pid, "UniverShell2.exe") || pid_is(pid, "UndergroundGVR.exe")) { f->hit = h; return FALSE; }
    return TRUE;
}
static HWND find_app_window() { Find f = { nullptr }; EnumWindows(find_cb, (LPARAM)&f); return f.hit; }

// Find the window of one specific exe (used to hand focus back to the frontend after a race).
struct FindExe { const char* exe; HWND hit; };
static BOOL CALLBACK find_exe_cb(HWND h, LPARAM lp) {
    FindExe* f = (FindExe*)lp;
    if (h == g_backdrop || !IsWindowVisible(h) || GetWindow(h, GW_OWNER)) return TRUE;
    RECT rc; GetClientRect(h, &rc);
    if (rc.right < 320 || rc.bottom < 240) return TRUE;
    DWORD pid = 0; GetWindowThreadProcessId(h, &pid);
    if (pid_is(pid, f->exe)) { f->hit = h; return FALSE; }
    return TRUE;
}
static HWND find_window_of(const char* exe) { FindExe f = { exe, nullptr }; EnumWindows(find_exe_cb, (LPARAM)&f); return f.hit; }

static bool exe_running(const char* exe) {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return false;
    PROCESSENTRY32 pe; pe.dwSize = sizeof(pe);
    bool found = false;
    if (Process32First(snap, &pe)) do {
        if (lstrcmpiA(pe.szExeFile, exe) == 0) { found = true; break; }
    } while (Process32Next(snap, &pe));
    CloseHandle(snap);
    return found;
}

// Windows refuses SetForegroundWindow from a process that does not own the foreground, so attach
// our input queue to the current foreground thread first - the standard way to make it stick.
static void give_focus(HWND h) {
    if (!h || !IsWindow(h)) return;
    HWND fg = GetForegroundWindow();
    DWORD fgT = fg ? GetWindowThreadProcessId(fg, nullptr) : 0;
    DWORD meT = GetCurrentThreadId();
    if (fgT && fgT != meT) AttachThreadInput(meT, fgT, TRUE);
    ShowWindow(h, SW_SHOW);
    BringWindowToTop(h);
    SetForegroundWindow(h);
    if (fgT && fgT != meT) AttachThreadInput(meT, fgT, FALSE);
}

// Capture just the backdrop's own area (that is where the two programs render), so the frame we
// show during a swap matches the region exactly - no desktop around it, no scaling.
static void capture_screen() {
    RECT rc; GetWindowRect(g_backdrop, &rc);
    int w = rc.right - rc.left, h = rc.bottom - rc.top;
    if (w < 16 || h < 16) return;
    HDC screen = GetDC(nullptr);
    HDC mem = CreateCompatibleDC(screen);
    HBITMAP bmp = CreateCompatibleBitmap(screen, w, h);
    HGDIOBJ old = SelectObject(mem, bmp);
    BitBlt(mem, 0, 0, w, h, screen, rc.left, rc.top, SRCCOPY);
    SelectObject(mem, old);
    DeleteDC(mem);
    ReleaseDC(nullptr, screen);
    if (g_shot) DeleteObject(g_shot);
    g_shot = bmp; g_shotW = w; g_shotH = h;
}

// Load the game's own boot screen (Gvr\gvr_data\NFSBOOT.jpg) so the hand-over between the
// frontend and the race shows THAT instead of the desktop - it reads as one continuous program.
// Uses OleLoadPicture, which decodes JPG/BMP/GIF with no extra libraries.
static void load_boot_image(const char* installRoot) {
    char path[MAX_PATH];
    const char* rel[] = {
        "Underground\\GVR\\Gvr\\gvr_data\\NFSBOOT.jpg",
        "GVR\\Gvr\\gvr_data\\NFSBOOT.jpg",
        "Gvr\\gvr_data\\NFSBOOT.jpg",
    };
    HANDLE f = INVALID_HANDLE_VALUE;
    for (int i = 0; i < 3 && f == INVALID_HANDLE_VALUE; ++i) {
        wsprintfA(path, "%s\\%s", installRoot, rel[i]);
        f = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, 0, nullptr);
    }
    if (f == INVALID_HANDLE_VALUE) { logf2("boot image not found"); return; }
    DWORD size = GetFileSize(f, nullptr), got = 0;
    if (size == INVALID_FILE_SIZE || size > 16u * 1024 * 1024) { CloseHandle(f); return; }
    HGLOBAL hg = GlobalAlloc(GMEM_MOVEABLE, size);
    void* p = GlobalLock(hg);
    ReadFile(f, p, size, &got, nullptr);
    GlobalUnlock(hg);
    CloseHandle(f);

    IStream* stm = nullptr;
    if (CreateStreamOnHGlobal(hg, TRUE, &stm) == S_OK) {
        IPicture* pic = nullptr;
        if (OleLoadPicture(stm, 0, FALSE, IID_IPicture, (void**)&pic) == S_OK && pic) {
            OLE_HANDLE oh = 0;
            if (pic->get_Handle(&oh) == S_OK) {
                g_boot = (HBITMAP)CopyImage((HANDLE)(UINT_PTR)oh, IMAGE_BITMAP, 0, 0, LR_COPYRETURNORG);
                BITMAP bm;
                if (g_boot && GetObject(g_boot, sizeof(bm), &bm)) { g_bootW = bm.bmWidth; g_bootH = bm.bmHeight; }
            }
            pic->Release();
        }
        stm->Release();
    }
    logf2("boot image: %s (%dx%d)", g_boot ? path : "FAILED to load", g_bootW, g_bootH);
}

static LRESULT CALLBACK backdrop_proc(HWND h, UINT m, WPARAM w, LPARAM l) {
    if (m == WM_PAINT) {
        PAINTSTRUCT ps; HDC dc = BeginPaint(h, &ps);
        RECT rc; GetClientRect(h, &rc);
        if (g_boot) {                      // the boot screen, scaled to fill the region
            HDC mem = CreateCompatibleDC(dc);
            HGDIOBJ old = SelectObject(mem, g_boot);
            SetStretchBltMode(dc, HALFTONE);
            StretchBlt(dc, 0, 0, rc.right, rc.bottom, mem, 0, 0, g_bootW, g_bootH, SRCCOPY);
            SelectObject(mem, old); DeleteDC(mem);
            EndPaint(h, &ps);
            return 0;
        }
        if (g_shot) {
            HDC mem = CreateCompatibleDC(dc);
            HGDIOBJ old = SelectObject(mem, g_shot);
            StretchBlt(dc, 0, 0, rc.right, rc.bottom, mem, 0, 0, g_shotW, g_shotH, SRCCOPY);
            SelectObject(mem, old); DeleteDC(mem);
        } else {
            FillRect(dc, &rc, (HBRUSH)GetStockObject(BLACK_BRUSH));
        }
        EndPaint(h, &ps);
        return 0;
    }
    if (m == WM_TIMER) {
        HWND app = find_app_window();
        DWORD now = GetTickCount();

        // ---- hand focus over on TRANSITIONS ONLY (never every tick) ----------------------------
        // Whichever program is live must actually own the foreground, otherwise Windows leaves
        // explorer.exe focused: the frontend then ignores the keyboard and the card watcher's
        // foreground guard rejects presses. We act only when the target CHANGES - at startup, when
        // a race begins, and when a race ends - so alt-tabbing away is never fought.
        {
            static HWND lastTarget = nullptr;
            bool gameUp = exe_running("UndergroundGVR.exe");
            HWND target = gameUp ? find_window_of("UndergroundGVR.exe")
                                 : find_window_of("UniverShell2.exe");
            if (target && target != lastTarget) {
                lastTarget = target;
                give_focus(target);
            }
            if (!target) lastTarget = nullptr;   // window gone; re-focus when the next one appears
        }
        if (app && g_merge) {
            // ---- TRUE MERGE: adopt the app window as a CHILD of the host ----------------------
            // Both programs then live inside one window: one taskbar entry, one alt-tab entry, and
            // no desktop visible when they swap. This only became possible once the dsound proxy
            // added DSBCAPS_GLOBALFOCUS - a child window can never be the OS foreground window, so
            // without that both programs fall silent (which is what sank the first attempt).
            g_lastSeen = now;
            if (GetParent(app) != g_backdrop) {
                LONG st = GetWindowLong(app, GWL_STYLE);
                st &= ~(WS_POPUP | WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX |
                        WS_MAXIMIZEBOX | WS_SYSMENU | WS_BORDER | WS_DLGFRAME);
                st |= WS_CHILD | WS_VISIBLE;
                SetWindowLong(app, GWL_STYLE, st);
                SetParent(app, g_backdrop);
                RECT hr2; GetClientRect(g_backdrop, &hr2);
                RECT ar; GetWindowRect(app, &ar);
                int aw = ar.right - ar.left, ah = ar.bottom - ar.top;
                int ax = (hr2.right - aw) / 2, ay = (hr2.bottom - ah) / 2;
                if (ax < 0) ax = 0; if (ay < 0) ay = 0;
                SetWindowPos(app, HWND_TOP, ax, ay, aw, ah, SWP_FRAMECHANGED | SWP_SHOWWINDOW);
                // give the child the keyboard focus across the process boundary
                DWORD ht = GetWindowThreadProcessId(g_backdrop, nullptr);
                DWORD at = GetWindowThreadProcessId(app, nullptr);
                AttachThreadInput(ht, at, TRUE);
                SetForegroundWindow(g_backdrop);
                SetFocus(app);
                AttachThreadInput(ht, at, FALSE);
            }
            if (now - g_lastShot > 1000) { capture_screen(); g_lastShot = now; }
        } else if (app) {
            g_lastSeen = now;
            // Sink to the BOTTOM rather than inserting ourselves directly behind the app: placing a
            // window after a TOPMOST one promotes it into the topmost band, and the resulting churn
            // made the race flash above the taskbar and then drop behind it. Bottom is enough - the
            // backdrop only has to cover the desktop, and it is never above either program.
            SetWindowPos(g_backdrop, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
            g_missing = 0;
            if (now - g_lastShot > 1000) { capture_screen(); g_lastShot = now; }   // keep a fresh frame
        } else {
            // Between the two programs: show the boot screen in the same region. HWND_TOP (not
            // TOPMOST) keeps this an ordinary window - the taskbar stays reachable and alt-tab
            // still works, it simply hides the desktop patch the programs were occupying.
            SetWindowPos(g_backdrop, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
            InvalidateRect(g_backdrop, nullptr, FALSE);
            // both programs gone for a while -> we are done
            if (g_lastSeen && now - g_lastSeen > 6000) PostQuitMessage(0);
        }
        return 0;
    }
    if (m == WM_DESTROY) { PostQuitMessage(0); return 0; }
    return DefWindowProcA(h, m, w, l);
}

// The backdrop is only as big as the area the two programs actually use (the larger of the shell
// and race sizes), centred - NOT the whole screen. That makes the pair look like ONE borderless
// window on your desktop, instead of a fullscreen takeover that swallows alt-tab.
static void create_backdrop(HINSTANCE hInst, int shellW, int shellH, int raceW, int raceH) {
    WNDCLASSA wc; ZeroMemory(&wc, sizeof(wc));
    wc.lpfnWndProc   = backdrop_proc;
    wc.hInstance     = hInst;
    wc.hCursor       = LoadCursor(nullptr, IDC_ARROW);
    wc.hIcon         = LoadIconA(hInst, MAKEINTRESOURCEA(1));   // embedded NFSU_GVR.ico
    wc.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
    wc.lpszClassName = "GvrBackdrop";
    RegisterClassA(&wc);
    int sw = GetSystemMetrics(SM_CXSCREEN), sh = GetSystemMetrics(SM_CYSCREEN);
    int w = shellW > raceW ? shellW : raceW;
    int h = shellH > raceH ? shellH : raceH;
    if (w <= 0 || w > sw) w = sw;
    if (h <= 0 || h > sh) h = sh;
    int x = (sw - w) / 2, y = (sh - h) / 2;
    // Backdrop-only mode: WS_EX_NOACTIVATE (never steals focus) + WS_EX_TOOLWINDOW (no taskbar
    // button), because the two programs remain the real windows.
    // MERGE mode: this window IS the application - it hosts both programs as children, so it must
    // be activatable and own the single taskbar / alt-tab entry.
    DWORD ex = g_merge ? 0 : (WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW);
    g_backdrop = CreateWindowExA(ex, "GvrBackdrop", g_merge ? "NFS Underground" : "",
                                 WS_POPUP, x, y, w, h, nullptr, nullptr, hInst, nullptr);
    ShowWindow(g_backdrop, g_merge ? SW_SHOW : SW_SHOWNOACTIVATE);
    SetTimer(g_backdrop, 1, 120, nullptr);
}

// One shared [Display] section drives both programs. [Race]/[Shell] are still read as a fallback
// so installs made before the merge keep working.
static int ini_int(const char* ini, const char* key, int def) {
    int v = GetPrivateProfileIntA("Display", key, -1, ini);
    if (v < 0) v = GetPrivateProfileIntA("Shell", key, -1, ini);
    if (v < 0) v = GetPrivateProfileIntA("Race",  key, -1, ini);
    return v < 0 ? def : v;
}
static bool ini_bool(const char* ini, const char* key, bool def) {
    char buf[32] = {0};
    GetPrivateProfileStringA("Display", key, "", buf, sizeof(buf), ini);
    if (!buf[0]) GetPrivateProfileStringA("Race", key, "", buf, sizeof(buf), ini);
    if (!buf[0]) return def;
    return !(_stricmp(buf, "false") == 0 || _stricmp(buf, "0") == 0 || _stricmp(buf, "no") == 0);
}

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE, LPSTR cmdline, int) {
    char self[MAX_PATH]; GetModuleFileNameA(nullptr, self, MAX_PATH);
    char selfDir[MAX_PATH]; lstrcpynA(selfDir, self, MAX_PATH);
    { char* s = strrchr(selfDir, '\\'); if (s) *s = 0; }

    // locate the shell exe: next to us, or at the standard install layout below us
    char shell[MAX_PATH];
    wsprintfA(shell, "%s\\UniverShell2.exe", selfDir);
    if (GetFileAttributesA(shell) == INVALID_FILE_ATTRIBUTES)
        wsprintfA(shell, "%s\\Underground\\GVR\\GvrRoot\\UniverShell2.exe", selfDir);
    if (GetFileAttributesA(shell) == INVALID_FILE_ATTRIBUTES)
        die("UniverShell2.exe not found.\n\nPut GvrLaunch.exe in the install root or next to the shell.");

    char shellDir[MAX_PATH]; lstrcpynA(shellDir, shell, MAX_PATH);
    { char* s = strrchr(shellDir, '\\'); if (s) *s = 0; }

    // resolution from the shared ini (optional - if absent we just launch stock)
    char ini[MAX_PATH] = {0};
    int w = 0, h = 0;
    char logEarly[512] = {0};
    if (find_ini(selfDir, ini) || find_ini(shellDir, ini)) {
        w = ini_int(ini, "Width",  0);      // one shared size for the frontend and the race
        h = ini_int(ini, "Height", 0);
        // [Race] Fullscreen=true|false  (also accepts 1/0, yes/no) - default true
        bool wantFull = ini_bool(ini, "Fullscreen", false);   // [Display] Fullscreen (default: windowed)
        sync_race_fullscreen(shellDir, wantFull, logEarly, sizeof(logEarly));
    }

    STARTUPINFOA si = {}; si.cb = sizeof(si);
    PROCESS_INFORMATION pi = {};
    char cmd[MAX_PATH * 2];
    wsprintfA(cmd, "\"%s\" %s", shell, cmdline ? cmdline : "");
    if (!CreateProcessA(nullptr, cmd, nullptr, nullptr, FALSE, CREATE_SUSPENDED, nullptr, shellDir, &si, &pi))
        die("Could not start:\n%s\n\nerror %lu", shell, GetLastError());

    char log[1024] = {0};
    if (w > 0 && h > 0) {
        BYTE* base = remote_image_base(pi.hProcess);
        DWORD rvaFW = file_off_to_rva(shell, SITE_FORM_W),  rvaFH = file_off_to_rva(shell, SITE_FORM_H);
        DWORD rvaPW = file_off_to_rva(shell, SITE_PANEL_W), rvaPH = file_off_to_rva(shell, SITE_PANEL_H);
        if (base && rvaFW && rvaPW) {
            patch_dword(pi.hProcess, base + rvaFW, (DWORD)w, "form width",   log, sizeof(log));
            patch_dword(pi.hProcess, base + rvaFH, (DWORD)h, "form height",  log, sizeof(log));
            patch_dword(pi.hProcess, base + rvaPW, (DWORD)w, "panel width",  log, sizeof(log));
            patch_dword(pi.hProcess, base + rvaPH, (DWORD)h, "panel height", log, sizeof(log));
        } else {
            _snprintf(log, sizeof(log), "could not resolve the patch sites - launching at stock size\r\n");
        }
    }
    if (getenv("GVRLAUNCH_VERBOSE")) {
        char m[2048]; _snprintf(m, sizeof(m), "ini: %s\r\nshell: %s\r\nshell size %dx%d\r\n%s%s",
                                ini, shell, w, h, logEarly, log);
        MessageBoxA(nullptr, m, "GvrLaunch", MB_OK);
    }

    // Backdrop up FIRST (so the desktop is hidden from the moment we start), then let the shell run.
    // [Launcher] Backdrop=false turns it off and the launcher exits immediately as before.
    char bd[32] = {0};
    if (ini[0]) GetPrivateProfileStringA("Launcher", "Backdrop", "true", bd, sizeof(bd), ini);
    else        lstrcpyA(bd, "true");
    bool useBackdrop = !(_stricmp(bd, "false") == 0 || _stricmp(bd, "0") == 0 || _stricmp(bd, "no") == 0);
    int raceW = ini[0] ? ini_int(ini, "Width",  0) : 0;   // same shared size
    int raceH = ini[0] ? ini_int(ini, "Height", 0) : 0;
    {   // [Launcher] Merge=true -> run BOTH programs inside this one window (one taskbar entry)
        char mg[32] = {0};
        if (ini[0]) GetPrivateProfileStringA("Launcher", "Merge", "false", mg, sizeof(mg), ini);
        g_merge = (_stricmp(mg, "true") == 0 || _stricmp(mg, "1") == 0 || _stricmp(mg, "yes") == 0);
        if (g_merge) useBackdrop = true;                       // the host window IS the backdrop
    }
    if (useBackdrop) {
        OleInitialize(nullptr);                 // needed by OleLoadPicture
        // installRoot = the folder holding gvr_settings.ini (falls back to our own folder)
        char root[MAX_PATH]; lstrcpynA(root, ini[0] ? ini : selfDir, MAX_PATH);
        if (ini[0]) { char* s2 = strrchr(root, '\\'); if (s2) *s2 = 0; }
        load_boot_image(root);
        create_backdrop(hInst, w, h, raceW, raceH);
    }

    ResumeThread(pi.hThread);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);

    if (!useBackdrop) return 0;

    // Stay alive behind the two programs until both are gone.
    g_lastSeen = GetTickCount();
    MSG msg;
    while (GetMessageA(&msg, nullptr, 0, 0)) { TranslateMessage(&msg); DispatchMessageA(&msg); }
    if (g_shot) DeleteObject(g_shot);
    return 0;
}
