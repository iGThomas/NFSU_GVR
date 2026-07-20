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
static DWORD g_ejectUntil = 0;      // tick count until which the card reads as absent
static DWORD g_lastIo = 0;          // last Connect/Read/Write/GetId
static bool  g_armed = false;       // a Write has happened since the last eject
static DWORD g_autoEjectMs = 2500;  // idle gap after a write before auto-ejecting
static DWORD g_ejectMs = 2000;      // how long the card stays "out"

static void ArmAndTouch(bool isWrite)
{
    g_lastIo = GetTickCount();
    if (isWrite) g_armed = true;
}

static void DoEject(const char* why)
{
    g_ejectUntil = GetTickCount() + g_ejectMs;
    g_armed = false;
    Log("*** simulating card REMOVAL for %lu ms (%s) ***", g_ejectMs, why);
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

    if (g_ejectUntil && (int)(now - g_ejectUntil) < 0)
        return true;                            // still "out"

    if (g_ejectUntil && (int)(now - g_ejectUntil) >= 0) {
        g_ejectUntil = 0;
        Log("*** card RE-INSERTED ***");
        g_lastIo = now;                         // don't immediately re-trigger
    }

    // manual: F9 forces an eject at any time
    if (GetAsyncKeyState(VK_F9) & 0x8000) {
        DoEject("F9 pressed");
        return true;
    }

    // automatic: the shell wrote the session to the card, then went quiet - which is
    // what happens when it puts up "PLEASE REMOVE PLAYER'S CARD" and waits.
    if (g_autoEjectMs && g_armed && g_lastIo &&
        (now - g_lastIo) > g_autoEjectMs) {
        DoEject("idle after write - assuming 'please remove card'");
        return true;
    }
    return false;
}

bool CGvrCardEmu::IsPresent()
{
    // IsPresent answers "is a READER attached", so it stays true even while the card
    // is out; the card's own presence is reported through GetStatus bit0.
    Log("IsPresent -> true");
    return true;
}

int CGvrCardEmu::GetStatus(int& status)
{
    bool out = Ejected();
    status = out ? 0 : 1;           // bit0 = card inserted (IsAnyCardInserted tests &1)
    if (out) Log("GetStatus -> 0 (card removed)");
    else     Log("GetStatus -> %d", status);
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
    return new CGvrCardEmu();
}

extern "C" void ReleaseGVRStorageDeviceImp(void* p)
{
    delete (CGvrCardEmu*)p;
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID)
{
    if (reason == DLL_PROCESS_ATTACH) {
        InitializeCriticalSection(&g_lock);

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
        if (GetEnvironmentVariableA("GVRCARD_EJECTMS", v, sizeof(v)) > 0) {
            int n = 0;
            for (char* p = v; *p >= '0' && *p <= '9'; ++p) n = n * 10 + (*p - '0');
            if (n > 0) g_ejectMs = (DWORD)n;    // how long the card stays out
        }

        char exe[MAX_PATH];
        GetModuleFileNameA(NULL, exe, MAX_PATH);
        Log("=== GvrCardEmu attached to %s ===", exe);
        Log("    card=%s", g_cardPath);
        Log("    auto-eject after %lu ms idle-following-a-write (0=off), out for %lu ms; F9 = manual eject",
            g_autoEjectMs, g_ejectMs);
    }
    else if (reason == DLL_PROCESS_DETACH) {
        DeleteCriticalSection(&g_lock);
    }
    return TRUE;
}
