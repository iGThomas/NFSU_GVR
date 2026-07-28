// dsound.dll proxy - keeps NFSU's audio playing when its window is not the foreground window.
//
// WHY
// ---
// UniverShell2 and UndergroundGVR create their DirectSound buffers WITHOUT DSBCAPS_GLOBALFOCUS,
// so Windows mutes them the moment the app loses focus. That is fine for a cabinet (it is always
// the foreground app) but it blocks merging the two programs into one host window: a re-parented
// child window can never BE the foreground window, so both apps would fall silent.
//
// This proxy sits next to the exe, forwards every dsound export to the real system dsound.dll, and
// hooks IDirectSound::CreateSoundBuffer to OR in DSBCAPS_GLOBALFOCUS. Buffers then keep playing
// regardless of focus, which is exactly what the merged view needs (and it also fixes the "shell
// goes silent when I click another window" annoyance on its own).
//
// Set GVRSOUND_LOG=1 to trace what it does (%TEMP%\gvrsound.log).

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <mmsystem.h>   // WAVEFORMATEX - dsound.h needs it (WIN32_LEAN_AND_MEAN drops it)
#include <mmreg.h>
#include <dsound.h>
#include <cstdio>
#include <cstdarg>

static HMODULE g_real = nullptr;
static FILE*   g_log  = nullptr;

static void logf(const char* f, ...) {
    if (!g_log) return;
    va_list a; va_start(a, f); vfprintf(g_log, f, a); va_end(a);
    fputc('\n', g_log); fflush(g_log);
}

// ---- real exports ----------------------------------------------------------------------------
typedef HRESULT (WINAPI *pDSC)(LPCGUID, LPDIRECTSOUND*, LPUNKNOWN);
typedef HRESULT (WINAPI *pDSC8)(LPCGUID, LPDIRECTSOUND8*, LPUNKNOWN);
static pDSC  real_DirectSoundCreate  = nullptr;
static pDSC8 real_DirectSoundCreate8 = nullptr;
static FARPROC r_EnumA, r_EnumW, r_CanUnload, r_GetClassObject, r_RegSvr, r_UnregSvr,
               r_CapCreate, r_CapEnumA, r_CapEnumW, r_GetDeviceID, r_FullDuplex, r_CapCreate8;

// ---- CreateSoundBuffer hook ------------------------------------------------------------------
// IDirectSound vtable: 0 QueryInterface, 1 AddRef, 2 Release, 3 CreateSoundBuffer, ...
typedef HRESULT (STDMETHODCALLTYPE *pCSB)(void*, LPCDSBUFFERDESC, LPDIRECTSOUNDBUFFER*, LPUNKNOWN);
static pCSB orig_CSB = nullptr;

static HRESULT STDMETHODCALLTYPE my_CreateSoundBuffer(void* self, LPCDSBUFFERDESC desc,
                                                      LPDIRECTSOUNDBUFFER* out, LPUNKNOWN unk) {
    if (desc && !(desc->dwFlags & DSBCAPS_PRIMARYBUFFER)) {
        DSBUFFERDESC copy = *desc;
        copy.dwFlags |= DSBCAPS_GLOBALFOCUS;      // keep playing when we are not foreground
        HRESULT hr = orig_CSB(self, &copy, out, unk);
        static int n = 0;
        if (n++ < 8) logf("CreateSoundBuffer flags 0x%08lX -> 0x%08lX hr=0x%X", desc->dwFlags, copy.dwFlags, hr);
        return hr;
    }
    return orig_CSB(self, desc, out, unk);
}

static void hook_device(void* ds) {
    if (!ds || orig_CSB) return;
    void** vt = *(void***)ds;
    DWORD old;
    if (VirtualProtect(&vt[3], sizeof(void*), PAGE_EXECUTE_READWRITE, &old)) {
        orig_CSB = (pCSB)vt[3];
        vt[3] = (void*)my_CreateSoundBuffer;
        VirtualProtect(&vt[3], sizeof(void*), old, &old);
        logf("hooked IDirectSound::CreateSoundBuffer (orig=%p)", orig_CSB);
    }
}

extern "C" HRESULT WINAPI DirectSoundCreate(LPCGUID g, LPDIRECTSOUND* out, LPUNKNOWN unk) {
    HRESULT hr = real_DirectSoundCreate ? real_DirectSoundCreate(g, out, unk) : DSERR_GENERIC;
    logf("DirectSoundCreate hr=0x%X obj=%p", hr, out ? *out : nullptr);
    if (SUCCEEDED(hr) && out && *out) hook_device(*out);
    return hr;
}
extern "C" HRESULT WINAPI DirectSoundCreate8(LPCGUID g, LPDIRECTSOUND8* out, LPUNKNOWN unk) {
    HRESULT hr = real_DirectSoundCreate8 ? real_DirectSoundCreate8(g, out, unk) : DSERR_GENERIC;
    logf("DirectSoundCreate8 hr=0x%X obj=%p", hr, out ? *out : nullptr);
    if (SUCCEEDED(hr) && out && *out) hook_device(*out);
    return hr;
}

// ---- straight pass-through exports ------------------------------------------------------------
extern "C" HRESULT WINAPI DirectSoundEnumerateA(LPDSENUMCALLBACKA cb, LPVOID p)
    { return ((HRESULT(WINAPI*)(LPDSENUMCALLBACKA,LPVOID))r_EnumA)(cb,p); }
extern "C" HRESULT WINAPI DirectSoundEnumerateW(LPDSENUMCALLBACKW cb, LPVOID p)
    { return ((HRESULT(WINAPI*)(LPDSENUMCALLBACKW,LPVOID))r_EnumW)(cb,p); }
extern "C" HRESULT WINAPI DllCanUnloadNow()
    { return ((HRESULT(WINAPI*)())r_CanUnload)(); }
extern "C" HRESULT WINAPI DllGetClassObject(REFCLSID a, REFIID b, LPVOID* c)
    { return ((HRESULT(WINAPI*)(REFCLSID,REFIID,LPVOID*))r_GetClassObject)(a,b,c); }
extern "C" HRESULT WINAPI DllRegisterServer()
    { return ((HRESULT(WINAPI*)())r_RegSvr)(); }
extern "C" HRESULT WINAPI DllUnregisterServer()
    { return ((HRESULT(WINAPI*)())r_UnregSvr)(); }
extern "C" HRESULT WINAPI DirectSoundCaptureCreate(LPCGUID a, LPDIRECTSOUNDCAPTURE* b, LPUNKNOWN c)
    { return ((HRESULT(WINAPI*)(LPCGUID,LPDIRECTSOUNDCAPTURE*,LPUNKNOWN))r_CapCreate)(a,b,c); }
extern "C" HRESULT WINAPI DirectSoundCaptureCreate8(LPCGUID a, LPDIRECTSOUNDCAPTURE8* b, LPUNKNOWN c)
    { return ((HRESULT(WINAPI*)(LPCGUID,LPDIRECTSOUNDCAPTURE8*,LPUNKNOWN))r_CapCreate8)(a,b,c); }
extern "C" HRESULT WINAPI DirectSoundCaptureEnumerateA(LPDSENUMCALLBACKA cb, LPVOID p)
    { return ((HRESULT(WINAPI*)(LPDSENUMCALLBACKA,LPVOID))r_CapEnumA)(cb,p); }
extern "C" HRESULT WINAPI DirectSoundCaptureEnumerateW(LPDSENUMCALLBACKW cb, LPVOID p)
    { return ((HRESULT(WINAPI*)(LPDSENUMCALLBACKW,LPVOID))r_CapEnumW)(cb,p); }
extern "C" HRESULT WINAPI GetDeviceID(LPCGUID a, LPGUID b)
    { return ((HRESULT(WINAPI*)(LPCGUID,LPGUID))r_GetDeviceID)(a,b); }
extern "C" HRESULT WINAPI DirectSoundFullDuplexCreate(LPCGUID a, LPCGUID b, LPCDSCBUFFERDESC c,
        LPCDSBUFFERDESC d, HWND e, DWORD f, LPDIRECTSOUNDFULLDUPLEX* g2,
        LPDIRECTSOUNDCAPTUREBUFFER8* h, LPDIRECTSOUNDBUFFER8* i, LPUNKNOWN j)
    { return ((HRESULT(WINAPI*)(LPCGUID,LPCGUID,LPCDSCBUFFERDESC,LPCDSBUFFERDESC,HWND,DWORD,
        LPDIRECTSOUNDFULLDUPLEX*,LPDIRECTSOUNDCAPTUREBUFFER8*,LPDIRECTSOUNDBUFFER8*,LPUNKNOWN))
        r_FullDuplex)(a,b,c,d,e,f,g2,h,i,j); }

// ================== tame the cabinet lockdown behaviour ========================================
// UniverShell2 was written for a locked-down arcade cabinet, so it:
//   * ClipCursor()s the mouse into its window (on a desktop the pointer ends up pinned, typically
//     stuck in the top-left corner and unusable in other apps), and
//   * keeps forcing itself ALWAYS-ON-TOP, so you cannot click another window / alt-tab away.
// This DLL is loaded through the exe's import table, i.e. BEFORE any shell code runs, which makes
// it the right place to neutralise those calls. We inline-hook the two user32 entry points -
// necessary rather than IAT patching because the shell is a .NET app and reaches them by P/Invoke
// (resolved at runtime via GetProcAddress, so the exe's IAT never contains them).
//   GVRSHELL_KEEPLOCK=1 restores the stock cabinet behaviour.
typedef BOOL (WINAPI *pClipCursor)(const RECT*);
typedef BOOL (WINAPI *pSetWindowPos)(HWND, HWND, int, int, int, int, UINT);
static pSetWindowPos real_SetWindowPos = nullptr;

static BOOL WINAPI my_ClipCursor(const RECT* r) {
    static int n = 0;
    if (n++ < 4) logf("ClipCursor(%s) -> ignored (cursor stays free)", r ? "rect" : "NULL");
    return TRUE;                                   // never confine the pointer
}
// The shell also WARPS the pointer (that is the "mouse jumps to the top-left corner and stays
// there" behaviour - a cabinet has no mouse, so it parks it out of the way). Swallow those calls.
static BOOL WINAPI my_SetCursorPos(int x, int y) {
    static int n = 0;
    if (n++ < 6) logf("SetCursorPos(%d,%d) -> ignored (mouse stays where you put it)", x, y);
    return TRUE;
}
// ...and it FORCES ITSELF FOREGROUND, repeatedly, while the attract/intro reel is playing. On a
// cabinet that is correct; on a desktop it yanks focus back from whatever you switched to, and
// because our z-order rule is "topmost follows focus" the frontend then sat on top of everything.
// Swallow it: the launcher still focuses the shell from OUTSIDE the process when it should be
// active, so start-up and the race->menu hand-over are unaffected.
static BOOL WINAPI my_SetForegroundWindow(HWND h) {
    static int n = 0;
    if (n++ < 6) logf("SetForegroundWindow(%p) -> ignored (frontend may not steal focus)", h);
    return TRUE;
}
static BOOL WINAPI my_SetWindowPos(HWND h, HWND after, int x, int y, int cx, int cy, UINT f) {
    if (after == HWND_TOPMOST) {                   // demote always-on-top to a normal window
        static int n = 0;
        if (n++ < 4) logf("SetWindowPos(HWND_TOPMOST) -> HWND_TOP (not always-on-top)");
        after = HWND_TOP;
    }
    return real_SetWindowPos(h, after, x, y, cx, cy, f);
}

// 5-byte JMP detour. For SetWindowPos we need to keep calling the original, so the first bytes are
// relocated into a small trampoline; ClipCursor is fully replaced so it needs none.
static BYTE* make_trampoline(BYTE* target, int stolen) {
    BYTE* tramp = (BYTE*)VirtualAlloc(nullptr, 32, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    if (!tramp) return nullptr;
    memcpy(tramp, target, stolen);
    tramp[stolen] = 0xE9;
    *(DWORD*)(tramp + stolen + 1) = (DWORD)((target + stolen) - (tramp + stolen + 5));
    return tramp;
}
static bool detour(const char* mod, const char* fn, void* hook, void** trampOut, int stolen) {
    HMODULE h = GetModuleHandleA(mod); if (!h) h = LoadLibraryA(mod);
    if (!h) return false;
    BYTE* p = (BYTE*)GetProcAddress(h, fn);
    if (!p) return false;
    if (trampOut) { *trampOut = make_trampoline(p, stolen); if (!*trampOut) return false; }
    DWORD old;
    if (!VirtualProtect(p, 8, PAGE_EXECUTE_READWRITE, &old)) return false;
    p[0] = 0xE9;
    *(DWORD*)(p + 1) = (DWORD)((BYTE*)hook - (p + 5));
    VirtualProtect(p, 8, old, &old);
    FlushInstructionCache(GetCurrentProcess(), p, 8);
    return true;
}

static void tame_shell() {
    char exe[MAX_PATH] = {0}; GetModuleFileNameA(nullptr, exe, MAX_PATH);
    const char* b = strrchr(exe, '\\'); b = b ? b + 1 : exe;
    if (lstrcmpiA(b, "UniverShell2.exe") != 0) return;      // shell only; the race is left alone
    if (getenv("GVRSHELL_KEEPLOCK")) { logf("cabinet lockdown left in place (GVRSHELL_KEEPLOCK)"); return; }
    // ONLY ClipCursor is detoured, and only because it is a FULL replacement: we never execute the
    // original bytes, so it does not matter how long its first instruction is. Detouring
    // SetWindowPos the same way crashed the shell - that hook needs a trampoline, and blindly
    // copying 5 bytes can split an instruction. Always-on-top is therefore handled without any
    // hooking: GVRInputRaw simply clears WS_EX_TOPMOST on the shell window each second.
    bool a  = detour("user32.dll", "ClipCursor",          (void*)my_ClipCursor,          nullptr, 5);
    bool b2 = detour("user32.dll", "SetCursorPos",        (void*)my_SetCursorPos,        nullptr, 5);
    bool c2 = detour("user32.dll", "SetForegroundWindow", (void*)my_SetForegroundWindow, nullptr, 5);
    logf("tamed cabinet lockdown: ClipCursor=%d SetCursorPos=%d SetForegroundWindow=%d", a, b2, c2);
}

BOOL WINAPI DllMain(HINSTANCE, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) {
        if (getenv("GVRSOUND_LOG")) {
            char exe[MAX_PATH] = {0}; GetModuleFileNameA(nullptr, exe, MAX_PATH);
            const char* b = strrchr(exe, '\\'); b = b ? b + 1 : exe;
            char p[MAX_PATH]; DWORD n = GetTempPathA(MAX_PATH, p);
            wsprintfA(p + n, "gvrsound_%s_%lu.log", b, GetCurrentProcessId());
            g_log = fopen(p, "w");
        }
        char sys[MAX_PATH]; GetSystemDirectoryA(sys, MAX_PATH); strcat(sys, "\\dsound.dll");
        g_real = LoadLibraryA(sys);
        if (!g_real) return FALSE;
        real_DirectSoundCreate  = (pDSC) GetProcAddress(g_real, "DirectSoundCreate");
        real_DirectSoundCreate8 = (pDSC8)GetProcAddress(g_real, "DirectSoundCreate8");
        r_EnumA          = GetProcAddress(g_real, "DirectSoundEnumerateA");
        r_EnumW          = GetProcAddress(g_real, "DirectSoundEnumerateW");
        r_CanUnload      = GetProcAddress(g_real, "DllCanUnloadNow");
        r_GetClassObject = GetProcAddress(g_real, "DllGetClassObject");
        r_RegSvr         = GetProcAddress(g_real, "DllRegisterServer");
        r_UnregSvr       = GetProcAddress(g_real, "DllUnregisterServer");
        r_CapCreate      = GetProcAddress(g_real, "DirectSoundCaptureCreate");
        r_CapCreate8     = GetProcAddress(g_real, "DirectSoundCaptureCreate8");
        r_CapEnumA       = GetProcAddress(g_real, "DirectSoundCaptureEnumerateA");
        r_CapEnumW       = GetProcAddress(g_real, "DirectSoundCaptureEnumerateW");
        r_GetDeviceID    = GetProcAddress(g_real, "GetDeviceID");
        r_FullDuplex     = GetProcAddress(g_real, "DirectSoundFullDuplexCreate");
        logf("dsound proxy loaded (real=%p)", g_real);
        tame_shell();      // free the mouse cursor + stop the shell forcing always-on-top
    }
    return TRUE;
}
