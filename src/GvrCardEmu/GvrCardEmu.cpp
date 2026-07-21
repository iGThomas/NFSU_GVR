// ---------------------------------------------------------------------------
// GvrCardEmu - a software GlobalVR smart card reader + player card.
//
// Drop-in replacement for GVRSCR28.dll (the PC/SC reader driver). PLUSDE.dll
// hardcodes that filename and hands it to GVRStorageDevice::Initialize, which
// only does LoadLibraryA(name) + GetProcAddress("CreateGVRStorageDeviceImp")
// and then calls through the returned object's vtable. So a faithful
// implementation is indistinguishable from hardware to everything above it -
// IsCardReaderPresent, PLUSISPRESENTSC, PLUSISPLAYERSC, ReadHeader,
// RegisterPlayerCard, the career flow.
//
// ABI (recovered from GVRStorageDevice.dll @ imagebase 0x10000000, cross-checked
// against the shipped GVRSCR28.dll and GVRSDEmulator.dll vtables):
//
//   void* CreateGVRStorageDeviceImp(void);        __cdecl, no args   (call eax, no cleanup)
//   void  ReleaseGVRStorageDeviceImp(void* p);    __cdecl, 1 arg     (add esp,4)
//
//   object is 0x408 bytes:
//     +0x000  vtable pointer
//     +0x004  char name[0x400]   <-- the facade strcpy's this out of us in
//                                    Initialize AND Connect. Must be a valid
//                                    NUL-terminated C string or it walks memory.
//     +0x404  private state
//
//   vtable: 15 __thiscall slots, in exactly this order (declaration order below).
//   No virtual destructor - slot 0 must be Initialize.
//
// Return convention: 0 = success for every int-returning method.
//   1003 already initialized, 1004 not initialized, 1009 not connected,
//   5000 read/write range error.
//
// GVRSDType (from PLUSDE IL): 0 = PLAYER CARD, 1 = OPERATOR, 2 = DONGLE, 3 = HOURLY.
//
// Why not just reuse GlobalVR's own GVRSDEmulator.dll: it reports IsPresent=true
// and GetType=0 correctly, but (a) it never writes GetId's out-param (leaving the
// caller's card id uninitialised), and (b) its 8 KB image is malloc'd and zeroed
// on every process start, so nothing persists and the card always reads back as
// an unregistered, unactivated blank. This implementation fixes both and, more
// importantly, LOGS every call so we can see exactly what the shell asks for and
// where it gives up.
//
// Build: build.cmd  (32-bit, static CRT, .def for undecorated export names)
// ---------------------------------------------------------------------------

#include <windows.h>
#include <stdio.h>

#define CARD_SIZE      8192       // GetSize(); matches the stock emulator's 0x2000
#define NAME_LEN       0x400
#define RC_OK          0
#define RC_NOTINIT     1004
#define RC_RANGE       5000
#define SDTYPE_PLAYER  0

// Fixed serial for our virtual card. Any non-zero value works; it is what
// GvrSmartDevice caches as the card id and what CareerData_NFS1.CardId keys on.
static const __int64 kCardSerial = 1;

static HMODULE g_hModule = NULL;    // needed by SetWindowsHookEx

// Shared with our PCSCSCR2.dll (GvrPcscEmu). Until the player presses START the cabinet must
// look completely stock - no card AND NO READER - otherwise the shell does not run the plain
// attract sequence and the intro never plays. This event is the single source of truth:
// signalled = the card is in the slot, and the reader "exists".
#define GVRCARD_EVENT_NAME "Local\\GvrCardEmuInserted"
static HANDLE g_evInserted = NULL;
static char g_logPath[MAX_PATH];
static char g_cardPath[MAX_PATH];
static CRITICAL_SECTION g_lock;
static BOOL g_pathsReady = FALSE;

// ---- logging ---------------------------------------------------------------
// Plain Win32 so we never depend on CRT file handles being initialised while
// the host process is still starting up.
static void Log(const char* fmt, ...)
{
    if (!g_pathsReady) return;

    char line[1024];
    SYSTEMTIME st;
    GetLocalTime(&st);
    int n = wsprintfA(line, "%02d:%02d:%02d.%03d  ",
                      st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);

    va_list ap;
    va_start(ap, fmt);
    n += wvsprintfA(line + n, fmt, ap);
    va_end(ap);

    line[n++] = '\r';
    line[n++] = '\n';

    HANDLE h = CreateFileA(g_logPath, FILE_APPEND_DATA, FILE_SHARE_READ | FILE_SHARE_WRITE,
                           NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h != INVALID_HANDLE_VALUE) {
        DWORD w = 0;
        SetFilePointer(h, 0, NULL, FILE_END);
        WriteFile(h, line, n, &w, NULL);
        CloseHandle(h);
    }
}

// ---- the device ------------------------------------------------------------
class CGvrCardEmu
{
public:
    // slot 0
    virtual int Initialize(__int64 trustSig);
    // slot 1
    virtual int Shutdown();
    // slot 2
    virtual bool IsPresent();
    // slot 3
    virtual int GetStatus(int& status);
    // slot 4
    virtual int Connect();
    // slot 5
    virtual int Disconnect();
    // slot 6
    virtual int GetId(__int64* id);
    // slot 7
    virtual unsigned char GetType();
    // slot 8
    virtual int GetSize();
    // slot 9
    virtual int GetManufacturerInfo(char* dst);
    // slot 10
    virtual int Format(char* label, int flags, __int64 sig);
    // slot 11
    virtual bool SetAccessIndicator(bool on);
    // slot 12
    virtual int Read(int offset, int length, BYTE* dst);
    // slot 13
    virtual int Write(int offset, int length, const BYTE* src);
    // slot 14
    virtual int ReadMagStripe(char* dst);

    CGvrCardEmu();
    ~CGvrCardEmu();

    // MUST be the first data member: the facade reads a C string at this+4.
    char  m_name[NAME_LEN];

private:
    void  LoadImage();
    void  SaveImage();
    bool  Ejected();

    BYTE  m_card[CARD_SIZE];
    bool  m_init;
    bool  m_connected;
    bool  m_dirty;
};

// ---- simulated card removal -------------------------------------------------
// The shell sometimes shows "PLEASE REMOVE PLAYER'S CARD" and then waits for the card
// to actually go away - it polls GetStatus until bit0 clears. A real player would pull
// the card out; our card is software, so it has to pull itself out.
//
// There is NO explicit eject signal in the device API to trigger on. Verified against
// 3848 logged calls: SetAccessIndicator is only ever called with 0, Format/ReadMagStripe
// are never called, and every long GetStatus-only stretch follows a plain Disconnect -
// including idle attract waits of up to 279 s. So "polling for a while" on its own is
// useless as a trigger; it would fire constantly while the cabinet sits at attract.
//
// What IS distinctive is that the prompt only appears after the shell has written the
// session to the card. So the auto trigger is:
//
//     a Write has happened since the last eject   AND
//     no card I/O at all for GVRCARD_AUTOEJECT ms (default 2500)
//
// The "Write since last eject" condition is what keeps it from firing over and over
// while idle: once we eject, it is disarmed until the shell writes to the card again.
// The card then reappears after EJECT_MS, exactly like re-inserting it.
//
// GVRCARD_AUTOEJECT=0 disables the automatic behaviour. VK_F9 always forces an eject
// manually - GetStatus is polled continuously, so it is a convenient place to check.
//
// CARD STARTS OUT OF THE SLOT.
// On a real cabinet the attract reel (NFS_Intro.wmv, cars, tracks, career...) plays while
// the card slot is EMPTY; inserting a card is what interrupts it. An always-inserted card
// makes the shell jump straight into the player flow at boot, so the intro never plays.
// Default is therefore "out": attract/intro behaves exactly like stock, and F9 inserts the
// card when you actually want to play career. GVRCARD_START=in restores always-inserted.
// The slot state must be SHARED BETWEEN PROCESSES. The shell (GvrRoot) and the game
// (Underground) each load their own copy of this DLL, so a per-process flag meant the card
// could be "in" for the shell and "out" for the game - which is what produced "insert card"
// inside career mode. g_evInserted (below) is the single source of truth; this is only a
// cache for logging transitions.
static bool  g_inserted = false;
static DWORD g_reinsertAt = 0;      // if non-zero, auto re-insert at this tick
static DWORD g_lastIo = 0;          // last Connect/Read/Write/GetId
static bool  g_armed = false;       // a Write has happened since the last eject
static DWORD g_autoEjectMs = 2500;  // idle gap after a write before auto-ejecting
// Once the card is in it stays in, and attract (the intro) only plays with an EMPTY slot -
// so without this the intro never comes back after the first game. Pull the card after a
// longer idle, which is exactly when the cabinet would be dropping back to attract anyway.
static DWORD g_idleEjectMs = 20000;
static DWORD g_insertedAt = 0;   // when the card last went in - idle is measured from this too
static DWORD g_lastUserKey = 0;     // last REAL keypress, so we don't eject mid-menu
// Set from the keyboard hook / window subclass, acted on by the key thread. Those callbacks
// must stay fast: a slow LL hook callback gets silently unhooked by Windows.
static volatile LONG g_pendingInsert = 0;
static volatile LONG g_pendingToggle = 0;
static HWND  g_msgWnd = NULL;       // our message-only window (excluded from the search below)
static DWORD g_reinsertMs = 0;      // 0 = stay out after an eject (lets attract resume)
static bool  g_f9Down = false;      // edge detection for the manual toggle
static bool  g_sDown = false;       // edge detection for START (S) -> auto-insert

// Cross-process truth for "is the card in the slot".
static bool IsCardIn()
{
    if (!g_evInserted) return g_inserted;
    return WaitForSingleObject(g_evInserted, 0) == WAIT_OBJECT_0;
}

static void ArmAndTouch(bool isWrite)
{
    g_lastIo = GetTickCount();
    if (isWrite) g_armed = true;
}

static void DoEject(const char* why)
{
    g_inserted = false;
    if (g_evInserted) ResetEvent(g_evInserted);      // reader disappears with the card
    g_armed = false;
    g_reinsertAt = g_reinsertMs ? (GetTickCount() + g_reinsertMs) : 0;
    Log("*** card REMOVED (%s)%s ***", why,
        g_reinsertMs ? " - will re-insert" : " - press F9 to insert again");
}

// Skipping the intro with S leaves the keyboard focus on the video/attract window that just
// went away, so the game stops responding until the user alt-tabs back. Put the foreground
// back on the game's own top-level window when the card goes in.
static BOOL CALLBACK FindGameWnd(HWND h, LPARAM lp)
{
    DWORD pid = 0;
    GetWindowThreadProcessId(h, &pid);
    if (pid != GetCurrentProcessId()) return TRUE;
    if (h == g_msgWnd || !IsWindowVisible(h) || GetWindow(h, GW_OWNER)) return TRUE;
    RECT r;
    if (!GetWindowRect(h, &r) || (r.right - r.left) < 200 || (r.bottom - r.top) < 200)
        return TRUE;                                  // skip tiny helper windows
    *(HWND*)lp = h;
    return FALSE;
}

// A bare SetForegroundWindow is refused unless the calling thread already owns the
// foreground - which is why the first attempt logged success but the game stayed dead until
// the user alt-tabbed. Attaching to the current foreground thread's input queue lifts that
// restriction. It also has to be retried: at the moment the card goes in the intro video
// window is still tearing down and takes focus back.
// Log every top-level window this process owns, so we can tell the real game window from the
// transient intro-video window (they have different HWNDs and the video one disappears,
// taking focus with it - which is what left the game unresponsive until an alt-tab).
static BOOL CALLBACK LogWnd(HWND h, LPARAM)
{
    DWORD pid = 0;
    GetWindowThreadProcessId(h, &pid);
    if (pid != GetCurrentProcessId() || h == g_msgWnd) return TRUE;
    if (!IsWindowVisible(h)) return TRUE;
    char cls[64] = "", txt[64] = "";
    GetClassNameA(h, cls, sizeof(cls));
    GetWindowTextA(h, txt, sizeof(txt));
    RECT r;
    GetWindowRect(h, &r);
    Log("      wnd %p  %ldx%ld  class='%s' title='%s'%s", h,
        r.right - r.left, r.bottom - r.top, cls, txt,
        GetWindow(h, GW_OWNER) ? " (owned)" : "");
    return TRUE;
}

static void RestoreGameFocus(const char* when)
{
    HWND game = NULL;
    EnumWindows(FindGameWnd, (LPARAM)&game);
    if (!game) return;

    HWND fg = GetForegroundWindow();
    DWORD fgTid = fg ? GetWindowThreadProcessId(fg, NULL) : 0;
    DWORD myTid = GetCurrentThreadId();
    bool attached = (fgTid && fgTid != myTid && AttachThreadInput(myTid, fgTid, TRUE));

    BringWindowToTop(game);
    SetForegroundWindow(game);
    SetActiveWindow(game);
    SetFocus(game);

    if (attached) AttachThreadInput(myTid, fgTid, FALSE);

    Log("    focus -> game window %p (%s)%s", game, when,
        (GetForegroundWindow() == game) ? " [OK]" : " [still not foreground]");
}

// Ask the key thread to keep re-asserting focus for a couple of seconds.
static DWORD g_focusUntil = 0;
static DWORD g_focusNext = 0;

static void DoInsert(const char* why)
{
    g_inserted = true;
    if (g_evInserted) SetEvent(g_evInserted);        // reader appears with the card
    g_reinsertAt = 0;
    g_lastIo = GetTickCount();
    g_insertedAt = g_lastIo;
    g_armed = false;
    Log("*** card INSERTED (%s) ***", why);
    // A single, gentle focus nudge. The earlier 10s retry loop was chasing the wrong theory:
    // the process owns exactly ONE window ('Univershell2 - Shell'), we always focused it, and
    // Windows reported success every time - so unresponsive input was never a focus problem.
    // It was our own RegisterRawInputDevices call displacing the game's raw input; see
    // TrySubclassShell(). Kept only because it is harmless and costs nothing.
    RestoreGameFocus("on insert");
    g_focusUntil = 0;
}

// Samples F9 independently of the shell's polling, at a steady 40 ms, so a normal key
// press is never missed. Polling it inside GetStatus did not work: with no card in the
// slot the shell only calls GetStatus every couple of seconds, so a quick press fell
// between samples. Started lazily from the factory - never from DllMain, since creating
// threads under the loader lock is asking for trouble.
// GetAsyncKeyState is system-wide: without this, typing 's' in a browser or chat window
// (in-process key detection removed - see StartKeyWatcher / GvrCardKey.exe)
static DWORD WINAPI KeyThread(LPVOID)
{
    // NO KEYBOARD HOOK, NO RAW INPUT, NO WINDOW SUBCLASS IN THIS PROCESS.
    //
    // All key detection lives in GvrCardKey.exe (see StartKeyWatcher). Everything tried in
    // here either did not work or actively broke the game:
    //   * RegisterRawInputDevices displaced the game's own GVRInputRaw registration, so the
    //     shell stopped receiving keys until an alt-tab forced it to re-register;
    //   * WH_KEYBOARD_LL received nothing at all here, not even injected test keys;
    //   * and a low-level hook inside the game's own process taxes EVERY keystroke, which
    //     made the controls feel sticky while racing.
    // This thread now only launches the watcher, applies the idle rules and logs a heartbeat.

    DWORD beat = GetTickCount();
    for (;;) {
        DWORD now = GetTickCount();
        // keep re-asserting focus for a few seconds after the card goes in
        if (g_focusUntil && (int)(now - g_focusUntil) < 0) {
            if (!g_focusNext || (int)(now - g_focusNext) >= 0) {
                RestoreGameFocus("retry");
                g_focusNext = now + 700;
            }
        } else if (g_focusUntil && (int)(now - g_focusUntil) >= 0) {
            g_focusUntil = 0;
        }
        if (now - beat > 10000) {
            beat = now;
            Log("    [keythread alive] card=%s  idle=%lums (pull at %lums)",
                g_inserted ? "IN" : "OUT",
                g_lastIo ? (now - g_lastIo) : 0, g_idleEjectMs);
        }
        Sleep(10);
    }
}

// Launch the out-of-process key watcher. In-process detection does not work here (see the
// header of GvrCardKey.cpp for the full list of what was tried and why each failed), so the
// watcher runs as its own process and signals the shared event. It self-limits to one
// instance and exits when the game does.
static void StartKeyWatcher()
{
    char exe[MAX_PATH], dir[MAX_PATH];
    GetModuleFileNameA(g_hModule, dir, MAX_PATH);
    char* s = dir;
    for (char* p = dir; *p; ++p) if (*p == '\\' || *p == '/') s = p;
    *s = 0;
    wsprintfA(exe, "%s\\GvrCardKey.exe", dir);
    if (GetFileAttributesA(exe) == INVALID_FILE_ATTRIBUTES) {
        Log("    !! GvrCardKey.exe not found next to the DLL - S/F9 will not work");
        return;
    }

    // pass the folder holding the card image so it logs to the same file
    char cmd[MAX_PATH * 2], cardDir[MAX_PATH];
    lstrcpynA(cardDir, g_cardPath, MAX_PATH);
    s = cardDir;
    for (char* p = cardDir; *p; ++p) if (*p == '\\' || *p == '/') s = p;
    *s = 0;
    wsprintfA(cmd, "\"%s\" %s", exe, cardDir);

    STARTUPINFOA si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_HIDE;
    if (CreateProcessA(NULL, cmd, NULL, NULL, FALSE, CREATE_NO_WINDOW,
                       NULL, dir, &si, &pi)) {
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
        Log("    key watcher launched: %s", exe);
    } else {
        Log("    !! could not launch GvrCardKey.exe (err %lu)", GetLastError());
    }
}

static void StartKeyThread()
{
    static bool started = false;
    if (started) return;
    started = true;
    StartKeyWatcher();
    DWORD tid;
    HANDLE h = CreateThread(NULL, 0, KeyThread, NULL, 0, &tid);
    if (h) CloseHandle(h);
}

CGvrCardEmu::CGvrCardEmu()
{
    ZeroMemory(m_name, sizeof(m_name));
    lstrcpynA(m_name, "GVR Emulated Card Reader", NAME_LEN);
    ZeroMemory(m_card, sizeof(m_card));
    m_init = m_connected = m_dirty = false;
    Log("Create -> object %p", this);
}

CGvrCardEmu::~CGvrCardEmu()
{
    SaveImage();
    Log("Release");
}

// Persist the card image next to this DLL, so career progress survives a
// relaunch. This is the piece the stock emulator lacks.
void CGvrCardEmu::LoadImage()
{
    HANDLE h = CreateFileA(g_cardPath, GENERIC_READ, FILE_SHARE_READ, NULL,
                           OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h == INVALID_HANDLE_VALUE) {
        Log("  no card image at %s - starting from a blank card", g_cardPath);
        return;
    }
    DWORD got = 0;
    ReadFile(h, m_card, CARD_SIZE, &got, NULL);
    CloseHandle(h);
    Log("  loaded card image (%lu bytes) from %s", got, g_cardPath);
}

void CGvrCardEmu::SaveImage()
{
    if (!m_dirty) return;
    HANDLE h = CreateFileA(g_cardPath, GENERIC_WRITE, 0, NULL,
                           CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h == INVALID_HANDLE_VALUE) {
        Log("  !! could not write card image to %s (err %lu)", g_cardPath, GetLastError());
        return;
    }
    DWORD w = 0;
    WriteFile(h, m_card, CARD_SIZE, &w, NULL);
    CloseHandle(h);
    m_dirty = false;
    Log("  saved card image (%lu bytes)", w);
}

int CGvrCardEmu::Initialize(__int64 trustSig)
{
    // trustSig is GvrLocalTrust.GenerateTrustSignature output - licence/anti-tamper
    // for real hardware. Nothing validates it on our side.
    Log("Initialize(trustSig=0x%08lx%08lx)",
        (DWORD)(trustSig >> 32), (DWORD)trustSig);
    EnterCriticalSection(&g_lock);
    if (!m_init) { LoadImage(); m_init = true; }
    LeaveCriticalSection(&g_lock);
    return RC_OK;
}

int CGvrCardEmu::Shutdown()
{
    Log("Shutdown");
    EnterCriticalSection(&g_lock);
    SaveImage();
    m_init = m_connected = false;
    LeaveCriticalSection(&g_lock);
    return RC_OK;
}

// True while we are pretending the card has been pulled out. Also evaluates the two
// eject triggers (manual F9, and the armed idle-after-write rule).
bool CGvrCardEmu::Ejected()
{
    DWORD now = GetTickCount();

    // NOTE: F9 is sampled by g_keyThread below, NOT here. Polling it in GetStatus was
    // unreliable: with no card in the slot the shell only calls GetStatus every couple of
    // seconds, so a quick key press fell between samples and was silently lost.

    bool in = IsCardIn();
    if (in != g_inserted) {             // another process (or the key watcher) changed it
        g_inserted = in;
        // RESTART OUR TIMERS. Without this the process that did not perform the insert still
        // holds an ancient g_lastIo, so the idle test below is true immediately and it ejects
        // the card the instant the other process inserts it - the two then fight, insert /
        // eject, many times a second.
        g_lastIo = now;
        g_insertedAt = now;
        g_armed = false;
        Log("    slot now %s (changed elsewhere) - idle timers restarted", in ? "IN" : "OUT");
    }

    // optional timed re-insert (GVRCARD_REINSERT); off by default so that after the
    // shell asks for the card back, attract - and the intro - can resume.
    if (!in && g_reinsertAt && (int)(now - g_reinsertAt) >= 0)
        DoInsert("auto re-insert");

    // automatic removal: the shell wrote the session to the card and then went quiet,
    // which is what it does while showing "PLEASE REMOVE PLAYER'S CARD".
    if (in && g_autoEjectMs && g_armed && g_lastIo &&
        (now - g_lastIo) > g_autoEjectMs)
        DoEject("idle after write - assuming 'please remove card'");

    // longer idle with no card activity AND no user input: the cabinet is dropping back to
    // attract, and attract (the intro) only plays with an empty slot. The keypress check
    // matters - browsing menus does not touch the card, so without it the card would be
    // pulled out from under a player who is simply reading the screen.
    else if (in && g_idleEjectMs && g_lastIo &&
             (now - g_lastIo) > g_idleEjectMs &&
             (!g_insertedAt || (now - g_insertedAt) > g_idleEjectMs) &&
             (!g_lastUserKey || (now - g_lastUserKey) > g_idleEjectMs))
        DoEject("idle - returning to attract so the intro can play");

    return !IsCardIn();
}

bool CGvrCardEmu::IsPresent()
{
    // ALWAYS true: this answers "is a READER attached", not "is a card in it".
    //
    // Do not gate this on card presence. The shell decides reader availability early and
    // does not re-check it, so reporting "no reader" at startup permanently greys out
    // CAREER - inserting the card later does not bring it back. The intro is instead kept
    // by leaving the CARD out (GetStatus bit0) until the player presses START, which is
    // enough for the attract sequence to play.
    Log("IsPresent -> true");
    return true;
}

int CGvrCardEmu::GetStatus(int& status)
{
    bool out = Ejected();
    status = out ? 0 : 1;           // bit0 = card inserted (IsAnyCardInserted tests &1)

    // Log only on CHANGE. The shell polls this ~60x/second; logging every call meant a file
    // open/append/close 60 times a second, which drowned the log and - far worse - starved
    // the low-level keyboard hook. Windows silently unhooks a LL callback that takes too
    // long (LowLevelHooksTimeout), which is why S was detected only intermittently.
    static int last = -1;
    if (status != last) {
        last = status;
        Log("GetStatus -> %d (%s)", status, status ? "card in slot" : "slot empty");
    }
    return RC_OK;
}

int CGvrCardEmu::Connect()
{
    if (Ejected()) {                // no card in the slot -> cannot connect
        Log("Connect -> %d (card removed)", RC_NOTINIT);
        return RC_NOTINIT;
    }
    m_connected = true;
    ArmAndTouch(false);
    Log("Connect -> 0");
    return RC_OK;
}

int CGvrCardEmu::Disconnect()
{
    m_connected = false;
    Log("Disconnect");
    return RC_OK;
}

int CGvrCardEmu::GetId(__int64* id)
{
    if (!id) return RC_NOTINIT;
    *id = kCardSerial;              // stock emulator never writes this - we must
    Log("GetId -> %ld", (long)kCardSerial);
    return RC_OK;
}

unsigned char CGvrCardEmu::GetType()
{
    Log("GetType -> %d (PLAYER)", SDTYPE_PLAYER);
    return SDTYPE_PLAYER;
}

int CGvrCardEmu::GetSize()
{
    Log("GetSize -> %d", CARD_SIZE);
    return CARD_SIZE;
}

int CGvrCardEmu::GetManufacturerInfo(char* dst)
{
    if (dst) lstrcpyA(dst, "GlobalVR");
    Log("GetManufacturerInfo");
    return RC_OK;
}

int CGvrCardEmu::Format(char* label, int flags, __int64 sig)
{
    Log("Format(label=%s, flags=%d)", label ? label : "(null)", flags);
    EnterCriticalSection(&g_lock);
    ZeroMemory(m_card, sizeof(m_card));
    m_dirty = true;
    SaveImage();
    LeaveCriticalSection(&g_lock);
    return RC_OK;
}

bool CGvrCardEmu::SetAccessIndicator(bool on)
{
    Log("SetAccessIndicator(%d)", on ? 1 : 0);
    return true;
}

int CGvrCardEmu::Read(int offset, int length, BYTE* dst)
{
    if (offset < 0 || offset >= CARD_SIZE || length < 0 ||
        offset + length > CARD_SIZE || !dst) {
        Log("Read(off=%d,len=%d) -> RANGE ERROR", offset, length);
        return RC_RANGE;
    }
    EnterCriticalSection(&g_lock);
    CopyMemory(dst, m_card + offset, length);
    LeaveCriticalSection(&g_lock);
    ArmAndTouch(false);
    Log("Read(off=%d,len=%d) -> 0  [%02x %02x %02x %02x ...]", offset, length,
        length > 0 ? dst[0] : 0, length > 1 ? dst[1] : 0,
        length > 2 ? dst[2] : 0, length > 3 ? dst[3] : 0);
    return RC_OK;
}

int CGvrCardEmu::Write(int offset, int length, const BYTE* src)
{
    if (offset < 0 || offset >= CARD_SIZE || length < 0 ||
        offset + length > CARD_SIZE || !src) {
        Log("Write(off=%d,len=%d) -> RANGE ERROR", offset, length);
        return RC_RANGE;
    }
    EnterCriticalSection(&g_lock);
    CopyMemory(m_card + offset, src, length);
    m_dirty = true;
    SaveImage();                    // persist eagerly; writes are rare
    LeaveCriticalSection(&g_lock);
    ArmAndTouch(true);              // arms the automatic "please remove card" eject
    Log("Write(off=%d,len=%d) -> 0  [%02x %02x %02x %02x ...]", offset, length,
        length > 0 ? src[0] : 0, length > 1 ? src[1] : 0,
        length > 2 ? src[2] : 0, length > 3 ? src[3] : 0);
    return RC_OK;
}

int CGvrCardEmu::ReadMagStripe(char* dst)
{
    if (dst) *dst = 0;
    Log("ReadMagStripe");
    return RC_OK;
}

// ---- exports ---------------------------------------------------------------
extern "C" void* CreateGVRStorageDeviceImp(void)
{
    StartKeyThread();
    return new CGvrCardEmu();
}

extern "C" void ReleaseGVRStorageDeviceImp(void* p)
{
    delete (CGvrCardEmu*)p;
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID)
{
    if (reason == DLL_PROCESS_ATTACH) {
        g_hModule = hModule;

        // PIN OURSELVES IN MEMORY.
        // GVRStorageDevice::Shutdown calls FreeLibrary on us, and PLUSDE creates/destroys the
        // device constantly (42 Initialize / 16 Shutdown cycles in one short session). Every
        // unload killed the keyboard hook - its callback lives in this image - so by the time
        // the player pressed S there was no live hook and NOTHING was delivered, not even
        // injected keys. Pinning keeps the image (and the hook thread) alive for the life of
        // the process. It also keeps the card image and insert/remove state stable across
        // those cycles instead of being reconstructed each time.
        HMODULE pin = NULL;
        GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_PIN | GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
                           (LPCSTR)&DllMain, &pin);

        InitializeCriticalSection(&g_lock);
        // manual-reset, starts unsignalled = no card, no reader
        g_evInserted = CreateEventA(NULL, TRUE, FALSE, GVRCARD_EVENT_NAME);

        char dll[MAX_PATH];
        GetModuleFileNameA(hModule, dll, MAX_PATH);
        char* slash = dll;
        for (char* p = dll; *p; ++p) if (*p == '\\' || *p == '/') slash = p;
        *slash = 0;                                 // directory of this DLL

        // The card image must be SHARED between the shell (GvrRoot) and the game
        // (Underground) - they load their own copy of this DLL from different
        // directories, so keying the image off the DLL's own folder would give each
        // process a private card and career progress would not carry from the
        // frontend into a race. Pin it next to game.db instead, which is the same
        // file for both processes and is already where career data lives.
        // GVRCARD_PATH overrides, for testing with more than one card.
        char envPath[MAX_PATH];
        DWORD n = GetEnvironmentVariableA("GVRCARD_PATH", envPath, MAX_PATH);
        if (n > 0 && n < MAX_PATH) {
            lstrcpynA(g_cardPath, envPath, MAX_PATH);
        } else {
            n = GetEnvironmentVariableA("GVRSQLITE_DB", envPath, MAX_PATH);
            if (n > 0 && n < MAX_PATH) {
                char* s = envPath;
                for (char* p = envPath; *p; ++p) if (*p == '\\' || *p == '/') s = p;
                *s = 0;                             // directory holding game.db
                wsprintfA(g_cardPath, "%s\\GvrCardEmu.card", envPath);
            } else {
                wsprintfA(g_cardPath, "%s\\GvrCardEmu.card", dll);
            }
        }
        // one shared log too, so the shell's and the game's calls interleave in
        // a single trace
        {
            char dir[MAX_PATH];
            lstrcpynA(dir, g_cardPath, MAX_PATH);
            char* s = dir;
            for (char* p = dir; *p; ++p) if (*p == '\\' || *p == '/') s = p;
            *s = 0;
            wsprintfA(g_logPath, "%s\\GvrCardEmu.log", dir);
        }
        g_pathsReady = TRUE;

        // Tunables for the simulated card removal (see the notes above Ejected()).
        char v[64];
        if (GetEnvironmentVariableA("GVRCARD_AUTOEJECT", v, sizeof(v)) > 0) {
            int n = 0;
            for (char* p = v; *p >= '0' && *p <= '9'; ++p) n = n * 10 + (*p - '0');
            g_autoEjectMs = (DWORD)n;           // 0 disables the automatic eject
        }
        if (GetEnvironmentVariableA("GVRCARD_IDLEEJECT", v, sizeof(v)) > 0) {
            int n = 0;
            for (char* p = v; *p >= '0' && *p <= '9'; ++p) n = n * 10 + (*p - '0');
            g_idleEjectMs = (DWORD)n;           // 0 = never pull the card on idle
        }
        if (GetEnvironmentVariableA("GVRCARD_REINSERT", v, sizeof(v)) > 0) {
            int n = 0;
            for (char* p = v; *p >= '0' && *p <= '9'; ++p) n = n * 10 + (*p - '0');
            g_reinsertMs = (DWORD)n;            // 0 = stay out until F9
        }
        // GVRCARD_START=in keeps the card permanently inserted (pre-intro-fix behaviour).
        // Default is "out" so the attract reel / NFS_Intro.wmv plays as it does on a cabinet.
        if (GetEnvironmentVariableA("GVRCARD_START", v, sizeof(v)) > 0 &&
            (v[0] == 'i' || v[0] == 'I'))
            g_inserted = true;

        char exe[MAX_PATH];
        GetModuleFileNameA(NULL, exe, MAX_PATH);
        Log("=== GvrCardEmu attached to %s ===", exe);
        Log("    card=%s", g_cardPath);
        Log("    card starts %s; F9 = insert/remove; auto-remove after %lu ms idle-following-a-write (0=off); re-insert after %lu ms (0=stay out)",
            g_inserted ? "INSERTED" : "OUT (attract/intro plays)", g_autoEjectMs, g_reinsertMs);
    }
    else if (reason == DLL_PROCESS_DETACH) {
        DeleteCriticalSection(&g_lock);
    }
    return TRUE;
}
