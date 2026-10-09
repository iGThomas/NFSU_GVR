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

// ---- optional session log: LOG\gvrlaunch.log, switched on by [Debug] Log=true -----------------
// A timeline of the whole launch from the orchestrator's side: which exe started, the size and
// window mode applied, the in-memory patch result, and when the shell / race appear and exit.
// Together with the in-process logs (GvrSqlite managed crashes, GVRInputRaw native crashes) this
// is what turns a "hangs then crashes" report into something readable. Off unless the flag is set.
static FILE* g_lf = nullptr;
static void lflog(const char* fmt, ...) {
    if (!g_lf) return;
    SYSTEMTIME st; GetLocalTime(&st);
    fprintf(g_lf, "%02d:%02d:%02d.%03d  ", st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
    va_list ap; va_start(ap, fmt); vfprintf(g_lf, fmt, ap); va_end(ap);
    fputc('\n', g_lf); fflush(g_lf);
}
static bool ini_debug_log(const char* ini) {
    char buf[32] = {0};
    GetPrivateProfileStringA("Debug", "Log", "", buf, sizeof(buf), ini);
    if (!buf[0]) return false;
    return !(_stricmp(buf, "false") == 0 || _stricmp(buf, "0") == 0 ||
             _stricmp(buf, "no") == 0 || _stricmp(buf, "off") == 0);
}
static void open_session_log(const char* ini) {
    if (g_lf || !ini || !ini[0]) return;
    if (!ini_debug_log(ini) && !getenv("GVRLAUNCH_VERBOSE")) return;   // env still forces it on
    char root[MAX_PATH]; lstrcpynA(root, ini, MAX_PATH);
    char* s = strrchr(root, '\\'); if (s) *s = 0;                      // install root = dir of the ini
    char logdir[MAX_PATH]; wsprintfA(logdir, "%s\\LOG", root);
    CreateDirectoryA(logdir, nullptr);
    char path[MAX_PATH]; wsprintfA(path, "%s\\gvrlaunch.log", logdir);
    g_lf = fopen(path, "w");
    if (g_lf) {
        SYSTEMTIME st; GetLocalTime(&st);
        fprintf(g_lf, "==== GvrLaunch  %04d-%02d-%02d %02d:%02d:%02d  pid=%lu ====\n",
                st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, GetCurrentProcessId());
        fflush(g_lf);
    }
}

// ---- PC configuration dump (diagnostic) --------------------------------------------------------
// Pure registry + Win32 so it works on everything from XP to Win11 and needs no WMI/COM. This is
// the single most useful thing in a "works on my machine, not theirs" report - the GPU driver in
// particular. Only called when the session log is open.
static bool reg_read_sz(HKEY root, const char* sub, const char* val, char* out, DWORD n) {
    out[0] = 0;
    HKEY k;
    if (RegOpenKeyExA(root, sub, 0, KEY_READ | KEY_WOW64_64KEY, &k) != ERROR_SUCCESS) return false;
    DWORD type = 0, cb = n - 1;
    LONG r = RegQueryValueExA(k, val, nullptr, &type, (BYTE*)out, &cb);
    RegCloseKey(k);
    if (r != ERROR_SUCCESS) { out[0] = 0; return false; }
    if (type == REG_DWORD && cb == 4) { DWORD d = *(DWORD*)out; wsprintfA(out, "%lu", d); return true; }
    out[(cb < n) ? cb : n - 1] = 0;   // REG_SZ may omit the terminator
    return true;
}

// .NET Framework 1.1 presence. DETECT THE FILE, not the registry: 1.1 predates the NDP\vX layout
// that 2.0+ use, so a machine can have a perfectly working 1.1 (the game runs) with no
// NDP\v1.1.4322 key at all - confirmed on the dev box. This is exactly the check the installer's
// Ensure-DotNet uses, so the guard and the installer agree. It is the one hard per-machine
// prerequisite that cannot travel inside a copied install folder.
static bool dotnet11_installed() {
    char p[MAX_PATH];
    UINT n = GetWindowsDirectoryA(p, MAX_PATH);
    if (!n || n > MAX_PATH - 48) return true;   // can't tell -> don't block
    lstrcatA(p, "\\Microsoft.NET\\Framework\\v1.1.4322\\mscorlib.dll");
    return GetFileAttributesA(p) != INVALID_FILE_ATTRIBUTES;
}
// NDP registry check, reliable for 2.0+ only (informational logging).
static bool net_ndp_installed(const char* ndpSubkey) {
    HKEY k;
    char path[160]; wsprintfA(path, "SOFTWARE\\Microsoft\\NET Framework Setup\\NDP\\%s", ndpSubkey);
    REGSAM views[2] = { KEY_WOW64_64KEY, KEY_WOW64_32KEY };
    for (int i = 0; i < 2; ++i) {
        if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, path, 0, KEY_READ | views[i], &k) != ERROR_SUCCESS) continue;
        DWORD val = 0, cb = sizeof(val), type = 0;
        LONG r = RegQueryValueExA(k, "Install", nullptr, &type, (BYTE*)&val, &cb);
        RegCloseKey(k);
        if (r == ERROR_SUCCESS && type == REG_DWORD && val == 1) return true;
    }
    return false;
}

static void log_pc_config() {
    if (!g_lf) return;
    lflog("---- PC configuration (diagnostic) ----");

    char prod[256], disp[64], build[32], ubr[32];
    reg_read_sz(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "ProductName", prod, sizeof(prod));
    reg_read_sz(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "DisplayVersion", disp, sizeof(disp));
    reg_read_sz(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "CurrentBuildNumber", build, sizeof(build));
    reg_read_sz(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "UBR", ubr, sizeof(ubr));
    lflog("os      : %s %s (build %s.%s)", prod, disp, build, ubr[0] ? ubr : "0");

    SYSTEM_INFO si; GetNativeSystemInfo(&si);
    const char* arch = si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64 ? "x64" :
                       si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_INTEL ? "x86" :
                       si.wProcessorArchitecture == 12 /*ARM64*/ ? "ARM64" : "?";
    lflog("arch    : %s, %lu logical CPUs", arch, si.dwNumberOfProcessors);

    char cpu[256], vendor[64];
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", "ProcessorNameString", cpu, sizeof(cpu));
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", "VendorIdentifier", vendor, sizeof(vendor));
    lflog("cpu     : %s (%s)", cpu[0] ? cpu : "?", vendor);

    MEMORYSTATUSEX ms; ms.dwLength = sizeof(ms);
    if (GlobalMemoryStatusEx(&ms))
        lflog("ram     : %.1f GB total, %.1f GB free",
              ms.ullTotalPhys / 1073741824.0, ms.ullAvailPhys / 1073741824.0);

    char sysman[128], sysprod[128], bbman[128], bbprod[128], bios[128], biosdate[64];
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\BIOS", "SystemManufacturer", sysman, sizeof(sysman));
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\BIOS", "SystemProductName", sysprod, sizeof(sysprod));
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\BIOS", "BaseBoardManufacturer", bbman, sizeof(bbman));
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\BIOS", "BaseBoardProduct", bbprod, sizeof(bbprod));
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\BIOS", "BIOSVersion", bios, sizeof(bios));
    reg_read_sz(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\BIOS", "BIOSReleaseDate", biosdate, sizeof(biosdate));
    lflog("system  : %s %s", sysman, sysprod);
    lflog("mainboard: %s %s", bbman, bbprod);
    lflog("bios    : %s (%s)", bios, biosdate);

    // every display adapter + its driver, from the display device-class key
    static const char* CLS = "SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}";
    for (int i = 0; i < 16; ++i) {
        char keypath[320]; wsprintfA(keypath, "%s\\%04d", CLS, i);
        char desc[256];
        if (!reg_read_sz(HKEY_LOCAL_MACHINE, keypath, "DriverDesc", desc, sizeof(desc)) || !desc[0]) continue;
        char dver[64], ddate[64], prov[128];
        reg_read_sz(HKEY_LOCAL_MACHINE, keypath, "DriverVersion", dver, sizeof(dver));
        reg_read_sz(HKEY_LOCAL_MACHINE, keypath, "DriverDate", ddate, sizeof(ddate));
        reg_read_sz(HKEY_LOCAL_MACHINE, keypath, "ProviderName", prov, sizeof(prov));
        lflog("gpu[%d]  : %s  drv %s (%s, %s)", i, desc,
              dver[0] ? dver : "?", ddate[0] ? ddate : "?", prov[0] ? prov : "?");
    }

    DEVMODEA dm; dm.dmSize = sizeof(dm); dm.dmDriverExtra = 0;
    if (EnumDisplaySettingsA(nullptr, ENUM_CURRENT_SETTINGS, &dm))
        lflog("display : %lux%lu %lubpp @ %luHz (desktop)",
              dm.dmPelsWidth, dm.dmPelsHeight, dm.dmBitsPerPel, dm.dmDisplayFrequency);

    // .NET — the game REQUIRES 1.1 (detected by its files; the NDP registry key is unreliable for
    // 1.1). This is the first line to read on a "won't start" report: 1.1(files)=NO means the
    // install step was skipped. The 2.0/3.5/4 flags are informational (NDP registry).
    lflog(".net    : 1.1(files)=%s  2.0=%s  3.5=%s  v4=%s",
          dotnet11_installed() ? "yes" : "NO",
          net_ndp_installed("v2.0.50727") ? "yes" : "no",
          net_ndp_installed("v3.5") ? "yes" : "no",
          net_ndp_installed("v4\\Full") ? "yes" : "no");

    lflog("---- end PC configuration ----");
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

// ---- [Launcher] KeepShell=true : the frontend stays up behind the race --------------------------
// UniverShell2's script opcode RUN (Interpreter_OpCode_RUN) normally tears its renderer, sound and
// scene down, hides its window, starts the race and rebuilds everything after it. The OEM keeps a
// "keep running" mode for tools: three tests on the launch entry's flag (`id && id->+8 && !golf`).
// Each test starts with `ldloca.s V_43` (12 2B); a 2-byte `br.s` in its place takes the keep branch:
//   IL_02BE  before the launch -> no teardown         (br.s IL_02D2)
//   IL_039F  after CreateProcess -> window not hidden  (br.s IL_03D9)
//   IL_04DD  after the race -> no rebuild              (br.s IL_0513)
struct IlPatch { DWORD fileOff; BYTE want[2]; BYTE put[2]; const char* what; };
static const IlPatch KEEP_SHELL[] = {
    { 0x175C2, { 0x12, 0x2B }, { 0x2B, 0x12 }, "keep renderer" },
    { 0x176A3, { 0x12, 0x2B }, { 0x2B, 0x38 }, "keep window"   },
    { 0x177E1, { 0x12, 0x2B }, { 0x2B, 0x34 }, "skip rebuild"  },
};
static bool patch_keep_shell(HANDLE proc, BYTE* base, const char* exe, char* log, size_t logn) {
    // all-or-nothing: verify every site first, so a different build is never half-patched
    BYTE* at[3];
    for (int i = 0; i < 3; ++i) {
        DWORD rva = file_off_to_rva(exe, KEEP_SHELL[i].fileOff);
        BYTE cur[2] = {0}; SIZE_T rw = 0;
        at[i] = base + rva;
        if (!rva || !ReadProcessMemory(proc, at[i], cur, 2, &rw) || memcmp(cur, KEEP_SHELL[i].want, 2) != 0) {
            _snprintf(log + strlen(log), logn - strlen(log), "  KeepShell: %s site differs - not applied\r\n", KEEP_SHELL[i].what);
            return false;
        }
    }
    for (int i = 0; i < 3; ++i) {
        DWORD old = 0; SIZE_T rw = 0;
        VirtualProtectEx(proc, at[i], 2, PAGE_EXECUTE_READWRITE, &old);
        WriteProcessMemory(proc, at[i], KEEP_SHELL[i].put, 2, &rw);
        VirtualProtectEx(proc, at[i], 2, old, &old);
    }
    _snprintf(log + strlen(log), logn - strlen(log), "  KeepShell: frontend stays up during the race\r\n");
    return true;
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
static bool    g_keepShell = false;      // KeepShell applied: no swap to cover, only the focus watcher
static bool    g_splash = true;          // [Launcher] Backdrop: boot screen while the shell loads
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
            // session-log the race starting / ending (only when the state flips)
            static int lastGameUp = -1;
            if (g_lf && (int)gameUp != lastGameUp) {
                if (lastGameUp != -1) lflog(gameUp ? "race started (UndergroundGVR.exe up)"
                                                   : "race ended (UndergroundGVR.exe gone)");
                lastGameUp = (int)gameUp;
            }
            HWND target = gameUp ? find_window_of("UndergroundGVR.exe")
                                 : find_window_of("UniverShell2.exe");
            if (target && target != lastTarget) {
                lastTarget = target;
                if (g_lf) lflog("foreground -> %s window %p", gameUp ? "race" : "frontend", (void*)target);
                give_focus(target);
            }
            if (!target) lastTarget = nullptr;   // window gone; re-focus when the next one appears
        }
        // ---- KeepShell: the frontend never leaves the screen, so there is no swap to cover. The
        // boot screen shows only until the shell's window first appears; after that this window
        // stays hidden and the timer just runs the focus hand-off above. Exit once neither
        // program has been running for 6 s (a minimised window must not end the watcher).
        if (g_keepShell && !g_merge) {
            if (app && IsWindowVisible(h)) ShowWindow(h, SW_HIDE);
            if (exe_running("UniverShell2.exe") || exe_running("UndergroundGVR.exe")) g_lastSeen = now;
            else if (g_lastSeen && now - g_lastSeen > 6000) PostQuitMessage(0);
            return 0;
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
    if (g_splash || g_merge) ShowWindow(g_backdrop, g_merge ? SW_SHOW : SW_SHOWNOACTIVATE);
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
        die("NFS Underground GVR is not installed here.\n\n"
            "UniverShell2.exe was not found next to GvrLaunch.exe or under\n"
            "Underground\\GVR\\GvrRoot. Run Install.bat first, then start the game\n"
            "from the desktop shortcut it creates.");

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

    // Session log (LOG\gvrlaunch.log) once we know the ini - [Debug] Log=true switches it on.
    open_session_log(ini);
    log_pc_config();   // dump CPU / board / GPU+driver / OS first, for "works on my machine" reports
    lflog("ini     : %s", ini[0] ? ini : "(none)");
    lflog("shell   : %s", shell);
    lflog("size    : %dx%d", w, h);
    if (logEarly[0]) { char* p = logEarly; while (*p == '\r' || *p == '\n' || *p == ' ') ++p; lflog("race    : %s", p); }

    // ---- prerequisite guard: .NET Framework 1.1 ------------------------------------------------
    // The game files can be copied to a PC, but .NET 1.1 cannot - it is installed per machine by
    // Install.bat. Running GvrLaunch on a box that never ran the installer would otherwise start
    // the shell under the wrong/absent runtime and fail in confusing ways. Detected by the 1.1
    // FILES (see dotnet11_installed), so a working 1.1 with no NDP registry key - which is normal
    // for 1.1 - is NOT falsely blocked. This is the one hard thing a bare folder copy is missing.
    if (!dotnet11_installed()) {
        lflog("PREREQ FAIL: .NET Framework 1.1 not found - not launching; asking the user to run Install.bat");
        if (g_lf) fclose(g_lf);
        MessageBoxA(nullptr,
            "NFS Underground GVR is not fully set up on this PC.\n\n"
            "Microsoft .NET Framework 1.1 - which the game needs - was not found.\n"
            "It is installed for you by Install.bat (in this folder); copying the game\n"
            "folder by hand does not install it.\n\n"
            "Please run Install.bat once, then start the game again.",
            "NFS Underground GVR - please run Install.bat", MB_ICONERROR | MB_OK);
        return 1;
    }

    // This install's database (<GvrRoot>\..\GvrPlus\game.db) for the shell and the race it
    // starts, which inherit our environment. It overrides the machine-wide GVRSQLITE_DB an
    // older installer set, so two installs never share a database, and no log-off is needed.
    //
    // CRUCIAL: also clear GVRSQLITE_DB_NAS1 for the child. That is NASCAR's per-title override,
    // and the SQLite provider checks it FIRST - so with NASCAR installed, NFSU would otherwise
    // open NASCAR's game.db, every NFSU table would be "no such table", and Plus would fail. We
    // only clear it in the process we launch; NASCAR's own launcher re-sets it, so the two titles
    // stay on their own databases.
    {
        char db[MAX_PATH], full[MAX_PATH];
        wsprintfA(db, "%s\\..\\GvrPlus\\game.db", shellDir);
        if (GetFullPathNameA(db, MAX_PATH, full, nullptr) && GetFileAttributesA(full) != INVALID_FILE_ATTRIBUTES) {
            SetEnvironmentVariableA("GVRSQLITE_DB", full);
            lflog("db      : %s", full);
        } else {
            lflog("db      : <GvrRoot>\\..\\GvrPlus\\game.db not found - provider will derive from the registry");
        }
        // delete NASCAR's per-title override so it cannot capture NFSU's shell
        char nas1[MAX_PATH] = {0};
        DWORD nlen = GetEnvironmentVariableA("GVRSQLITE_DB_NAS1", nas1, sizeof(nas1));
        if (nlen > 0) {
            SetEnvironmentVariableA("GVRSQLITE_DB_NAS1", nullptr);
            lflog("db      : cleared inherited GVRSQLITE_DB_NAS1 (was %s) so NFSU uses its own database", nas1);
        }
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
    if (ini[0]) {
        char ks[16] = {0};
        GetPrivateProfileStringA("Launcher", "KeepShell", "false", ks, sizeof(ks), ini);
        if (_stricmp(ks, "true") == 0 || _stricmp(ks, "1") == 0 || _stricmp(ks, "yes") == 0) {
            BYTE* base = remote_image_base(pi.hProcess);
            if (base) g_keepShell = patch_keep_shell(pi.hProcess, base, shell, log, sizeof(log));
        }
    }
    if (g_lf && log[0]) {
        // the patch buffer is multi-line "key = value\r\n"; emit each as its own entry
        char tmp[1024]; lstrcpynA(tmp, log, sizeof(tmp));
        for (char* line = strtok(tmp, "\r\n"); line; line = strtok(nullptr, "\r\n")) lflog("patch   : %s", line);
    }
    lflog("keepshell: %s", g_keepShell ? "on" : "off");
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
    if (g_keepShell) {                // the window is also the focus watcher: always needed
        g_splash = useBackdrop;       // Backdrop=false -> watcher only, no boot screen
        useBackdrop = true;
    }
    if (useBackdrop) {
        OleInitialize(nullptr);                 // needed by OleLoadPicture
        // installRoot = the folder holding gvr_settings.ini (falls back to our own folder)
        char root[MAX_PATH]; lstrcpynA(root, ini[0] ? ini : selfDir, MAX_PATH);
        if (ini[0]) { char* s2 = strrchr(root, '\\'); if (s2) *s2 = 0; }
        load_boot_image(root);
        create_backdrop(hInst, w, h, raceW, raceH);
    }

    // Load the shell's GVRInputRaw.dll (our GvrInputEmu) before UniverShell2's own code: it
    // carries the game's PRIVATE registry (nfsu_registry.ini, GvrPrivReg) and the shell reads
    // its keys long before its menu plug-in would load the DLL. Queued as an APC on the main
    // thread, it runs while the loader initialises the process.
    {
        char dll[MAX_PATH];
        wsprintfA(dll, "%s\\GVRInputRaw.dll", shellDir);
        SIZE_T n = lstrlenA(dll) + 1;
        void* mem = GetFileAttributesA(dll) == INVALID_FILE_ATTRIBUTES ? nullptr
                  : VirtualAllocEx(pi.hProcess, nullptr, n, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
        if (mem && WriteProcessMemory(pi.hProcess, mem, dll, n, nullptr))
            QueueUserAPC((PAPCFUNC)GetProcAddress(GetModuleHandleA("kernel32.dll"), "LoadLibraryA"),
                         pi.hThread, (ULONG_PTR)mem);
    }

    lflog("resuming shell (backdrop=%s, merge=%s)", useBackdrop ? "on" : "off", g_merge ? "on" : "off");
    ResumeThread(pi.hThread);
    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);

    if (!useBackdrop) { lflog("no backdrop - launcher exiting"); if (g_lf) fclose(g_lf); return 0; }

    // Stay alive behind the two programs until both are gone.
    g_lastSeen = GetTickCount();
    MSG msg;
    while (GetMessageA(&msg, nullptr, 0, 0)) { TranslateMessage(&msg); DispatchMessageA(&msg); }
    if (g_shot) DeleteObject(g_shot);
    lflog("both programs gone - launcher exiting");
    if (g_lf) fclose(g_lf);
    return 0;
}
