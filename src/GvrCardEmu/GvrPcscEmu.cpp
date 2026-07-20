// ---------------------------------------------------------------------------
// GvrPcscEmu - a software PC/SC layer, drop-in replacement for PCSCSCR2.dll.
//
// WHY THIS EXISTS
// ---------------
// Replacing GVRSCR28.dll (see GvrCardEmu.cpp) gives the shell a working virtual
// *card*, but it does NOT make CAREER available, because the shell asks a second,
// completely separate question first:
//
//   ScriptPlug-Ins\SCDiagnostic.dll  ->  PCSCSCR2.dll  ->  WinSCard.dll
//        PCSC_EstablishContext
//        PCSC_GetReaderNames     <-- "does a physical reader exist?"
//        PCSC_GetLastError
//        PCSC_ReleaseContext
//
// PCSC_GetReaderNames calls SCardListReadersA against the real Windows smart card
// service. With no reader attached that returns 0x8010002E
// (SCARD_E_NO_READERS_AVAILABLE), so the shell writes
// CabinetStatus_NFS1.SmartCardReaderStatus = 0 and shows "No Smart Card Reader".
// This probe never touches GVRStorageDevice, so our virtual card is invisible to it.
//
// Proven experimentally: creating a Windows TPM virtual smart card (tpmvscmgr) made
// SCardListReadersA succeed, SmartCardReaderStatus flipped 0 -> 1, the shell began
// logging "SmartCard is PRESENT" and polling our virtual card, and CAREER became
// selectable. This DLL reproduces just that one answer, so the host no longer needs
// a Windows virtual smart card and everything stays inside the game folder.
//
// ABI (recovered by disassembling the shipped PCSCSCR2.dll @ imagebase 0x10000000):
//   every function is __stdcall taking one PCSC_SCMC*, exported undecorated.
//
//   PCSC_EstablishContext  @0x10B0  ret 4   SCardEstablishContext -> p->hContext,
//                                           p->lastError = rc, returns (rc == 0)
//   PCSC_GetReaderNames    @0x1100  ret 4   SCardListReadersA, then per name:
//                                           copy to p+0x114 + n*0x80, SCardConnect,
//                                           n++ unless rc == 0x80100009; returns 0 on failure
//   PCSC_GetLastError      @0x15A0  ret 4   formats p->lastError into p+0x0C, returns that
//   PCSC_ReleaseContext    @0x10E0  ret 4   SCardReleaseContext, returns (rc == 0)
//
//   struct PCSC_SCMC {
//     +0x000 SCARDCONTEXT hContext;
//     +0x004 SCARDHANDLE  hCard;
//     +0x008 LONG         lastError;
//     +0x00C char         errorMsg[256];
//     +0x110 DWORD        readerCount;
//     +0x114 char         readerNames[][0x80];   // 128-byte slots
//     +0x320 DWORD        activeProtocol;
//   };
//
// The remaining exports are stubs: only SCDiagnostic.dll imports this DLL once
// GVRSCR28.dll is ours (the stock GVRSCR28 imported 16 of them, but it is replaced).
// They are still exported so that load-time binding cannot fail.
// ---------------------------------------------------------------------------

#include <windows.h>

#define OFF_LASTERROR    0x008
#define OFF_ERRORMSG     0x00C
#define OFF_READERCOUNT  0x110
#define OFF_READERNAMES  0x114
#define SLOT             0x80

// What the cabinet will believe is plugged in.
static const char kReaderName[] = "GVR Virtual Card Reader 0";

static void SetLong(void* p, int off, LONG v)
{
    *(LONG*)((BYTE*)p + off) = v;
}

extern "C" {

// Returns non-zero on success (the stock code returns rc == 0).
int __stdcall PCSC_EstablishContext(void* p)
{
    if (!p) return 0;
    SetLong(p, 0x000, 0x47565201);   // dummy non-NULL SCARDCONTEXT ("GVR\1")
    SetLong(p, OFF_LASTERROR, 0);
    return 1;
}

int __stdcall PCSC_GetReaderNames(void* p)
{
    if (!p) return 0;
    SetLong(p, OFF_LASTERROR, 0);
    // exactly one reader, in the first 128-byte slot
    *(DWORD*)((BYTE*)p + OFF_READERCOUNT) = 1;
    char* slot0 = (char*)p + OFF_READERNAMES;
    lstrcpynA(slot0, kReaderName, SLOT);
    return 1;
}

const char* __stdcall PCSC_GetLastError(void* p)
{
    if (!p) return "";
    char* msg = (char*)p + OFF_ERRORMSG;
    LONG e = *(LONG*)((BYTE*)p + OFF_LASTERROR);
    if (e == 0) lstrcpynA(msg, "OK", 256);
    else        wsprintfA(msg, "PCSC error 0x%08lx", e);
    return msg;
}

int __stdcall PCSC_ReleaseContext(void* p)
{
    if (p) SetLong(p, OFF_LASTERROR, 0);
    return 1;
}

// ---- stubs (not reached while GVRSCR28.dll is ours) ------------------------
int __stdcall PCSC_GetCardStatus(void* p)        { if (p) SetLong(p, OFF_LASTERROR, 0); return 1; }
int __stdcall PCSC_READER_Connect(void* p)       { return 1; }
int __stdcall PCSC_READER_Disconnect(void* p)    { return 1; }
int __stdcall PCSC_READER_StartSession(void* p)  { return 1; }
int __stdcall PCSC_READER_EndSession(void* p)    { return 1; }
int __stdcall PCSC_READER_IsCardSwiped(void* p)  { return 1; }
int __stdcall PCSC_READER_ReadTracks(void* p)    { return 0; }
int __stdcall PCSC_READER_GetMode(void* p)       { return 0; }
int __stdcall PCSC_READER_SetToEMV(void* p)      { return 1; }
int __stdcall PCSC_READER_SetToISO7816(void* p)  { return 1; }
int __stdcall PCSC_READER_SetToSync(void* p)     { return 1; }
int __stdcall PCSC_READER_LED1(void* p)          { return 1; }
int __stdcall PCSC_READER_LED2(void* p)          { return 1; }
int __stdcall PCSC_SCARD_Connect(void* p)        { return 1; }
int __stdcall PCSC_SCARD_Disconnect(void* p)     { return 1; }
int __stdcall PCSC_SCARD_Transmit(void* p)       { return 1; }
int __stdcall PCSC_AToSendBuf(void* p)           { return 0; }
int __stdcall PCSC_ByteToOutFormat(void* p)      { return 0; }
int __stdcall ISODeocdeForward(void* p)          { return 0; }
int __stdcall ISODeocdeReverse(void* p)          { return 0; }
int __stdcall JIS2DeocdeForward(void* p)         { return 0; }
int __stdcall JIS2DeocdeReverse(void* p)         { return 0; }

} // extern "C"

// The one C++-mangled export in the original (?PCSC_READER_LED3@@YGHPAUPCSC_SCMC@@H@Z).
// Declared to match so the .def can alias it.
int __stdcall PCSC_READER_LED3_impl(void* p, int n) { return 1; }

BOOL APIENTRY DllMain(HMODULE, DWORD, LPVOID) { return TRUE; }
