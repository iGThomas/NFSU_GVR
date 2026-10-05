// ============================================================================
//  NfsuPrivReg.cpp  -  NFS Underground's private registry (part of GVRInputRaw.dll)
//
//  The engine is the shared GvrPrivReg library (GIT\src\GvrPrivReg); this file
//  only says what NFSU's registry looks like - exactly what the portable
//  installer used to import (Install-NFSU-GVR-Portable.ps1, $RegTemplate).
//  Every registry call for HKLM\SOFTWARE\Gvr, \GlobalVR or \GVRShell is answered
//  from <install>\nfsu_registry.ini:
//    * folder values are computed from the install folder (%ROOT%), so a moved
//      install just works and NASCAR (which shares Gvr\Plus\1.1\Cabinet in the
//      real registry) can no longer repoint them;
//    * the values below fill in anything the file does not have;
//    * only these keys (and ones the game creates) exist, as before.
//  UndergroundGVR.exe imports this DLL; GvrLaunch.exe loads it into
//  UniverShell2.exe before the shell's own code. GVR_NO_PRIVATE_REGISTRY=1
//  turns it off.
// ============================================================================

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "GvrPrivReg.h"

#define UG      "%ROOT%\\Underground"
#define GVRROOT "%ROOT%\\Underground\\GVR\\GvrRoot"
#define GVRPLUS "%ROOT%\\Underground\\GVR\\GvrPlus"

static const char* const kRoots[] = { "Gvr", "GlobalVR", "GVRShell" };

static const PrivRegDefault kDefaults[] = {
    { "Gvr\\hercules\\Boot", "BootValue", "dword:00000002" },
    { "Gvr\\hercules\\Dongle", "Inserted", "dword:00000000" },
    { "Gvr\\hercules\\GVRBoot", NULL, NULL },
    { "Gvr\\hercules\\GVRCacheWarmer", "NumResources", "dword:00000000" },
    { "Gvr\\hercules\\GVRCoinMonitor", "CoinMeterMask1", "dword:00000000" },
    { "Gvr\\hercules\\GVRCoinMonitor", "CoinMeterMask2", "dword:00000004" },
    { "Gvr\\hercules\\GVRCrashMonitor", "NumApps", "dword:00000005" },
    { "Gvr\\hercules\\GVRCrashMonitor", "SleepDelay", "dword:00000064" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog00", "cmdargs", "" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog00", "delay", "dword:0000ea60" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog00", "enabled", "dword:00000003" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog00", "path", GVRROOT },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog00", "program", "GVRDongleMonitor.exe" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog01", "cmdargs", " " },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog01", "delay", "dword:0000ea60" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog01", "enabled", "dword:00000001" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog01", "path", GVRROOT },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog01", "program", "GVRCoinMonitor.exe" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog02", "cmdargs", "" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog02", "delay", "dword:00000064" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog02", "enabled", "dword:00000001" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog02", "path", GVRROOT },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog02", "program", "GVRStallMonitor.exe" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog03", "cmdargs", "" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog03", "delay", "dword:00000064" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog03", "enabled", "dword:00000000" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog03", "path", GVRROOT },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog03", "program", "GVRCacheWarmer.exe" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog04", "cmdargs", "-nosnapshot" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog04", "delay", "dword:0000ea60" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog04", "enabled", "dword:00000001" },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog04", "path", GVRROOT },
    { "Gvr\\hercules\\GVRCrashMonitor\\Prog04", "program", "Univershell2.exe" },
    { "Gvr\\hercules\\GVRDongleMonitor", NULL, NULL },
    { "Gvr\\hercules\\GVRStallMonitor", NULL, NULL },
    { "Gvr\\hercules\\UNDERGROUNDGVR", NULL, NULL },
    { "Gvr\\hercules\\UniverShell2", "Restart_Flags", "0" },
    { "Gvr\\hercules\\UniverShell2", "Restart_Idle", "300000" },
    { "Gvr\\hercules\\UniverShell2", "Restart_Reset", "82800000" },
    { "Gvr\\hercules\\UniverShell2", "Restart_Timeout", "86400000" },
    { "Gvr\\hercules\\UniverShell2", "RestartEnable", "1" },
    { "Gvr\\Installer\\DeskTopEngine", "Exists", "dword:00000001" },
    { "Gvr\\Plus\\1.1\\Cabinet", "GvrEventLogRemovalThreshold", "30" },
    { "Gvr\\Plus\\1.1\\Cabinet", "LeaderboardWaitTime", "20000" },
    { "Gvr\\Plus\\1.1\\Cabinet", "MaxObjectLoadCount", "30" },
    { "Gvr\\Plus\\1.1\\Cabinet", "PatchDownloadPath", "%ROOT%\\PatchService\\" },
    { "Gvr\\Plus\\1.1\\Cabinet", "PatchMaxDownloadRetry", "9" },
    { "Gvr\\Plus\\1.1\\Cabinet", "PatchMaxExecutionRetry", "1" },
    { "Gvr\\Plus\\1.1\\Cabinet", "PlayerCardRequestThreshold", "20" },
    { "Gvr\\Plus\\1.1\\Cabinet", "PlusSchemaPath", GVRPLUS "\\1\\schema\\nfscabinetXml.enc" },
    { "Gvr\\Plus\\1.1\\Cabinet", "PublicKeyPath", GVRPLUS "\\1\\key\\publickey.xml" },
    { "Gvr\\Plus\\1.1\\Cabinet", "SyncRetryInterval", "15" },
    { "Gvr\\Plus\\1.1\\Cabinet", "WebServerIP", "66.107.15.47" },
    { "Gvr\\Plus\\1.1\\Server", "PlusSchemaPath", GVRPLUS "\\1\\schema\\nfsserverXml.enc" },
    { "GlobalVR", "PQI Version", "PGA 2.0.0" },
    { "GlobalVR\\Need For Speed UnderGround", "Build", "027" },
    { "GlobalVR\\Need For Speed UnderGround", "Prefix", "" },
    { "GlobalVR\\Need For Speed UnderGround", "Suffix", "" },
    { "GlobalVR\\Need For Speed UnderGround", "Version", "1.1.0" },
    { "GVRShell\\Operator\\Games\\NFSUNDERGROUND", "Ini", UG "\\NFSUnderground.ini" },
};

static const PrivRegConfig kNfsu = {
    "nfsu_registry.ini",
    kRoots, (int)(sizeof(kRoots) / sizeof(kRoots[0])),
    kDefaults, (int)(sizeof(kDefaults) / sizeof(kDefaults[0])),
    false,  // only these keys exist (the shell probes some keys for existence)
    true,   // no copy from the real registry: its Gvr keys are shared with NASCAR
};

void nfsu_privreg_attach(const char* installRoot, void (*log)(const char*, ...))
{
    privreg_attach(installRoot, &kNfsu, log);
}
