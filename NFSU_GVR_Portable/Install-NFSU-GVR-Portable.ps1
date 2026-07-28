<#
  Install-NFSU-GVR-Portable.ps1  (Release V2 - portable, SQLite)

  Installs Need For Speed Underground: GlobalVR into a SINGLE user-chosen
  folder, with the GVR folders nested inside it, and running on SQLite.

  Layout produced (for install root <ROOT>):
     <ROOT>\Underground\                 game files (UndergroundGVR.exe, TRACKS, ...)
     <ROOT>\Underground\GVR\GvrRoot\      the arcade shell (UniverShell2/GVRBoot + gvr\*.gvr)
     <ROOT>\Underground\GVR\GvrPlus\      plus libs + schema + game.db
     <ROOT>\Underground\GVR\Gvr\          helpers

  No MSDE / SQL Server / SQLXML, no cabinet-lockdown Run keys, no fixed C:\.
  The game learns its locations from the registry keys this installer emits at
  the chosen paths (verified: UniverShell2's hardcoded C:\gvrRoot strings are
  dead editor constants; everything runtime is registry- or cwd-relative).

  Prompts for OEM Disc 1 / Disc 2 (or -ExpandedPayloadRoot).
#>
[CmdletBinding()]
param(
    [string]$InstallRoot = "",
    [string]$Disc1Path = "",
    [string]$Disc2Path = "",
    [string]$ExtractorPath = "",
    [string]$ExpandedPayloadRoot = "",
    [switch]$SkipDotNet,
    [switch]$SkipDirectX,
    [switch]$ForceOverwrite,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
trap { Write-Host "FAIL: $($_.Exception.Message)" -ForegroundColor Red; exit 1 }

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Version = "2026-07-17-portable-v2"
$WorkRoot = Join-Path $env:TEMP ("NFSU_GVR_V2_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
$LogFile = Join-Path $WorkRoot "install.log"

function Log($m)  { $s="[v2] $m"; Write-Host $s; if(!(Test-Path $WorkRoot)){New-Item -ItemType Directory -Force $WorkRoot|Out-Null}; Add-Content $LogFile $s }
function Warn($m) { Write-Host "[v2] WARN: $m" -ForegroundColor Yellow; Add-Content $LogFile "WARN: $m" }
function Fail($m) { throw $m }
function New-Dir($p){ if(!(Test-Path $p)){ if($DryRun){Log "would mkdir $p"; return}; New-Item -ItemType Directory -Force $p|Out-Null } }
function Test-Admin { $id=[Security.Principal.WindowsIdentity]::GetCurrent(); (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }
# GDI font registration (Deploy-Fonts). AddFontResource makes a newly copied font usable without a
# reboot; the WM_FONTCHANGE broadcast tells already-running programs to re-read the font table.
Add-Type -Name GvrFontApi -Namespace "" -MemberDefinition @'
[DllImport("gdi32.dll", CharSet=CharSet.Auto)] public static extern int AddFontResource(string lpszFilename);
[DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int SendMessageTimeout(IntPtr hWnd,int Msg,IntPtr wParam,IntPtr lParam,int flags,int timeout,out IntPtr result);
'@ -EA SilentlyContinue
function Copy-FileRequired($s,$d){ if(!(Test-Path $s)){Fail "required file missing: $s"}; New-Dir (Split-Path -Parent $d); Copy-Item -LiteralPath $s $d -Force }
function Copy-Contents($s,$d){ if(!(Test-Path $s)){return}; New-Dir $d; Copy-Item -Path (Join-Path $s "*") -Destination $d -Recurse -Force }

# ===================== disc extraction (from the proven AIO) ==============
function Test-Disc1($p){ (Test-Path (Join-Path $p "data1.hdr")) -and (Test-Path (Join-Path $p "data1.cab")) -and (Test-Path (Join-Path $p "data2.cab")) }
function Test-Disc2($p){ Test-Path (Join-Path $p "data3.cab") }
function Find-Disc($kind,$pref){
    if(![string]::IsNullOrEmpty($pref)){ if(($kind -eq "Disc1" -and (Test-Disc1 $pref)) -or ($kind -eq "Disc2" -and (Test-Disc2 $pref))){return (Resolve-Path $pref).Path}; Fail "$kind path is not the expected OEM disc: $pref" }
    foreach($drv in [System.IO.DriveInfo]::GetDrives()){ if(!$drv.IsReady){continue}; $c=$drv.RootDirectory.FullName; if($kind -eq "Disc1" -and (Test-Disc1 $c)){return $c}; if($kind -eq "Disc2" -and (Test-Disc2 $c)){return $c} }
    return $null
}
function Request-Disc($kind,$pref){ $d=Find-Disc $kind $pref; while(!$d){ [void](Read-Host "Insert/mount $kind, then press Enter"); $d=Find-Disc $kind "" }; Log "$kind found: $d"; return $d }
function Stage-Disc1($r){ $r=(Resolve-Path $r).Path; $s=Join-Path $WorkRoot "DISCS\DISC 1"; New-Dir $s; foreach($n in @("data1.hdr","data1.cab","data2.cab")){ Copy-FileRequired (Join-Path $r $n) (Join-Path $s $n) } }
function Stage-Disc2($r){ $r=(Resolve-Path $r).Path; $s=Join-Path $WorkRoot "DISCS\DISC 2"; New-Dir $s; Copy-FileRequired (Join-Path $r "data3.cab") (Join-Path $s "data3.cab") }
function Find-Extractor {
    if(![string]::IsNullOrEmpty($ExtractorPath)){ if(!(Test-Path $ExtractorPath)){Fail "extractor not found: $ExtractorPath"}; return (Resolve-Path $ExtractorPath).Path }
    foreach($c in @((Join-Path $Root "Tools\unshield.exe"),(Join-Path $Root "Tools\isxunpack.exe"))){ if(Test-Path $c){return (Resolve-Path $c).Path} }
    return $null
}
function Test-ExpandedPayload($r){ $b=$r; if(Test-Path (Join-Path $r "C")){$b=Join-Path $r "C"}; (Test-Path (Join-Path $b "Underground")) -and (Test-Path (Join-Path $b "GvrRoot")) -and (Test-Path (Join-Path $b "GvrPlus")) -and (Test-Path (Join-Path $b "Gvr")) }
function Assert-ShellContent($extract){
    $g=$null; foreach($c in @((Join-Path $extract "GvrRoot\gvr"),(Join-Path $extract "gvr"))){ if(Test-Path $c){$g=$c;break} }
    if(!$g){ Fail "No GvrRoot\gvr content folder in extraction - Disc 2's data3.cab is required (the GvrRoot group spans cabinet volumes 1-3)." }
    $files=@(Get-ChildItem $g -Filter *.gvr -EA SilentlyContinue|Where-Object{!$_.PSIsContainer}); $bytes=0; foreach($f in $files){$bytes+=$f.Length}
    Log ("shell content: {0} .gvr, {1:N0} MB" -f $files.Count,($bytes/1MB))
    if($files.Count -lt 30 -or $bytes -lt (300*1MB) -or !(Test-Path (Join-Path $g "SHELLCARS.gvr"))){ Fail "Extraction did not produce the shell content (need ~41 .gvr / ~448MB). Disc 2 data3.cab missing/unreadable." }
}
function Run-Extract($exe,$argv,$wd){ $p=Start-Process -FilePath $exe -ArgumentList $argv -WorkingDirectory $wd -Wait -PassThru -NoNewWindow; Log "extractor exit $($p.ExitCode)"; return $p.ExitCode }
function Reshape-Payload($extract,$targetC){
    $game=$extract; if(Test-Path (Join-Path $extract "GvrGame\UndergroundGVR.exe")){$game=Join-Path $extract "GvrGame"}
    if(!(Test-Path (Join-Path $game "UndergroundGVR.exe"))){ return $false }
    Log "reshaping raw InstallShield extraction into a game tree"
    $ug=Join-Path $targetC "Underground"; $gr=Join-Path $targetC "GvrRoot"; $gp=Join-Path $targetC "GvrPlus\1"; $gv=Join-Path $targetC "Gvr"
    New-Dir $ug; New-Dir $gr; New-Dir $gp; New-Dir $gv
    Copy-Contents $game $ug
    Copy-Contents (Join-Path $extract "GvrRoot") $gr
    # GvrRoot\gvr (shell content) arrives via the GvrRoot copy above. The extraction's GVR\ folder
    # is the C:\Gvr payload (gvr_data+system) - copy it to Gvr, NOT over GvrRoot\gvr (case collision).
    foreach($n in @("gvr_data","system")){ foreach($src in @($extract,(Join-Path $extract "GVR"))){ $s=Join-Path $src $n; if(Test-Path $s){ New-Dir $gv; Copy-Item -LiteralPath $s (Join-Path $gv $n) -Recurse -Force } } }
    Copy-Contents (Join-Path $extract "Plus") $gp
    Copy-Contents (Join-Path $extract "PlusScripts") (Join-Path $gp "scripts")
    foreach($d in @("SharedDlls","[Support]Non-SelfRegistering","[Engine]SelfRegistering")){ Copy-Contents (Join-Path $extract $d) (Join-Path $gp "lib") }
    $schema=Join-Path $gp "schema"; New-Dir $schema
    foreach($f in @("nfscabinet.enc","nfscabinetXml.enc","nfscabinet_Content.enc")){ foreach($src in @($extract,(Join-Path $extract "Plus"))){ $s=Join-Path $src $f; if(Test-Path $s){Copy-Item -LiteralPath $s (Join-Path $schema $f) -Force} } }
    foreach($f in @("GvrPlusExportDatabaseScript.exe","GvrPlusLib.DLL","Interop.SQLDMO.DLL","sqldmo.dll","AKSHASP.DLL")){ $s=Join-Path $extract $f; if(Test-Path $s){Copy-Item -LiteralPath $s (Join-Path $gp "scripts") -Force} }
    return (Test-ExpandedPayload $targetC)
}
function Extract-Discs {
    $ex=Find-Extractor; if(!$ex){Fail "No extractor. Put unshield.exe in Tools\, or use -ExpandedPayloadRoot."}
    $s1=Join-Path $WorkRoot "DISCS\DISC 1"; Copy-FileRequired (Join-Path $WorkRoot "DISCS\DISC 2\data3.cab") (Join-Path $s1 "data3.cab")
    $cab=Join-Path $WorkRoot "CabExtract"; New-Dir $cab
    foreach($c in @("data1.hdr","data1.cab","data2.cab","data3.cab")){ Copy-FileRequired (Join-Path $s1 $c) (Join-Path $cab $c) }
    foreach($c in @("data2.cab","data3.cab")){ if((Get-Item (Join-Path $cab $c)).Length -lt 100MB){ Fail "$c is too small - the disc wasn't fully mounted. Re-run." } }
    $extract=Join-Path $WorkRoot "Extracted"; New-Dir $extract
    Run-Extract $ex @("x","-d",$extract,(Join-Path $cab "data1.hdr")) $cab | Out-Null
    Assert-ShellContent $extract
    $targetC=Join-Path $WorkRoot "C"
    if(Test-ExpandedPayload $extract){ Copy-Contents $extract $targetC }
    elseif(!(Reshape-Payload $extract $targetC)){ Fail "Extractor ran but expected game folders were not produced. See $WorkRoot." }
}

# ===================== registry (parameterized) ===========================
$RegTemplate = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\Boot]
"BootValue"=dword:00000002

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\Dongle]
"Inserted"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRBoot]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCacheWarmer]
"NumResources"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCoinMonitor]
"CoinMeterMask1"=dword:00000000
"CoinMeterMask2"=dword:00000004

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor]
"NumApps"=dword:00000005
"SleepDelay"=dword:00000064

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog00]
"cmdargs"=""
"delay"=dword:0000ea60
"enabled"=dword:00000003
"path"="__GVRROOT__"
"program"="GVRDongleMonitor.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog01]
"cmdargs"=" "
"delay"=dword:0000ea60
"enabled"=dword:00000001
"path"="__GVRROOT__"
"program"="GVRCoinMonitor.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog02]
"cmdargs"=""
"delay"=dword:00000064
"enabled"=dword:00000001
"path"="__GVRROOT__"
"program"="GVRStallMonitor.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog03]
"cmdargs"=""
"delay"=dword:00000064
"enabled"=dword:00000000
"path"="__GVRROOT__"
"program"="GVRCacheWarmer.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog04]
"cmdargs"="-nosnapshot"
"delay"=dword:0000ea60
"enabled"=dword:00000001
"path"="__GVRROOT__"
"program"="Univershell2.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\UniverShell2]
"Restart_Flags"="0"
"Restart_Idle"="300000"
"Restart_Reset"="82800000"
"Restart_Timeout"="86400000"
"RestartEnable"="1"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\Installer\DeskTopEngine]
"Exists"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\Plus\1.1\Cabinet]
"GvrEventLogRemovalThreshold"="30"
"LeaderboardWaitTime"="20000"
"MaxObjectLoadCount"="30"
"PatchDownloadPath"="__PATCH__"
"PatchMaxDownloadRetry"="9"
"PatchMaxExecutionRetry"="1"
"PlayerCardRequestThreshold"="20"
"PlusSchemaPath"="__GVRPLUS__\\1\\schema\\nfscabinetXml.enc"
"PublicKeyPath"="__GVRPLUS__\\1\\key\\publickey.xml"
"SyncRetryInterval"="15"
"WebServerIP"="66.107.15.47"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\Plus\1.1\Server]
"PlusSchemaPath"="__GVRPLUS__\\1\\schema\\nfsserverXml.enc"

[HKEY_LOCAL_MACHINE\SOFTWARE\GlobalVR]
"PQI Version"="PGA 2.0.0"

[HKEY_LOCAL_MACHINE\SOFTWARE\GlobalVR\Need For Speed UnderGround]
"Build"="027"
"Prefix"=""
"Suffix"=""
"Version"="1.1.0"

[HKEY_LOCAL_MACHINE\SOFTWARE\GVRShell\Operator\Games\NFSUNDERGROUND]
"Ini"="__UG__\\NFSUnderground.ini"
'@

function Emit-Registry($ug,$gvrroot,$gvrplus,$gvr,$root){
    function E($p){ $p.Replace("\","\\") }   # .reg backslash escaping
    $t = $RegTemplate
    $t = $t.Replace("__GVRROOT__", (E $gvrroot))
    $t = $t.Replace("__GVRPLUS__", (E $gvrplus))
    $t = $t.Replace("__UG__",      (E $ug))
    $t = $t.Replace("__PATCH__",   (E (Join-Path $root "PatchService")) + "\\")
    $out=Join-Path $WorkRoot "game_paths.reg"
    if(!(Test-Path $WorkRoot)){ New-Dir $WorkRoot }
    Set-Content -LiteralPath $out -Value $t -Encoding ASCII
    Log "importing relocated game registry (no SQL keys, no boot Run keys)"
    if($DryRun){ Log "would reg import $out"; return }
    $ErrorActionPreference="Continue"
    & reg import $out 2>&1 | Out-Null
    $ec=$LASTEXITCODE; $ErrorActionPreference="Stop"
    if($ec -ne 0){ Fail "reg import failed ($ec) - $out" }
    # ---- 64-bit OS (Win10/11 x64, also Win7 x64) support ------------------------------
    # The game is 32-bit: on x64 Windows it reads HKLM\SOFTWARE via the WOW6432Node view.
    # The import above (64-bit reg.exe) only populates the 64-bit view, and the game then
    # silently exits (code -10) on its startup registry probe. Import again with the
    # 32-bit reg.exe, which auto-redirects SOFTWARE into WOW6432Node.
    $reg32=Join-Path $env:WINDIR "SysWOW64\reg.exe"
    if(Test-Path $reg32){
        $ErrorActionPreference="Continue"
        & $reg32 import $out 2>&1 | Out-Null
        $ec=$LASTEXITCODE; $ErrorActionPreference="Stop"
        if($ec -ne 0){ Fail "32-bit reg import failed ($ec) - $out" }
        Log "  registry also imported into the 32-bit view (WOW6432Node) for the 32-bit game"
    }
    # ------------------------------------------------------------------------------------
    Log "  registry imported (GVRROOT=$gvrroot, GVRPLUS=$gvrplus)"
}

# ===================== .NET 1.1 / DirectX =================================
function Ensure-DotNet {
    if($SkipDotNet){return}
    if(Test-Path (Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\mscorlib.dll")){ Log ".NET 1.1 present"; return }
    $dep=Join-Path $Root "Dependencies\DotNet11"
    $dfx=Join-Path $dep "dotnetfx.exe"
    $sp1=Join-Path $dep "NDP1.1sp1-KB867460-X86.exe"
    if(!(Test-Path $dfx)){ Fail ".NET 1.1 missing and dotnetfx.exe not bundled." }
    # ---- Win10/11 (and any modern OS) support ------------------------------------------
    # The plain 1.1 redist dies with MSI error 1603 on Windows 10/11. The documented fix is
    # slipstreaming SP1 into an MSI admin image and installing that - verified working on
    # Windows 11 (2026-07-17). Do NOT fall back to binding the game to CLR 2.0 instead: the
    # mixed-mode PLUSDE.dll uses native C++ exceptions as control flow ("row not found") and
    # that EH interop AVs on CLR 2.0 (System.AccessViolationException in GetGvrObject). The
    # game requires REAL CLR 1.1.
    if(Test-Path $sp1){
        Log "installing .NET 1.1 + SP1 (slipstreamed - required on Windows 10/11)"; if($DryRun){return}
        $w=Join-Path $WorkRoot "dotnet11"; $adm=Join-Path $WorkRoot "dotnet11_admin"
        New-Dir $w
        $p=Start-Process $dfx -ArgumentList "/q /c /t:`"$w`"" -Wait -PassThru
        if(!(Test-Path (Join-Path $w "netfx.msi"))){ Fail "dotnetfx.exe extraction failed ($($p.ExitCode))" }
        $p=Start-Process $sp1 -ArgumentList "/Xp:`"$w\netfxsp.msp`"" -Wait -PassThru
        if(!(Test-Path (Join-Path $w "netfxsp.msp"))){ Fail "SP1 extraction failed ($($p.ExitCode))" }
        $p=Start-Process msiexec -ArgumentList "/a `"$w\netfx.msi`" TARGETDIR=`"$adm`" /qn" -Wait -PassThru
        if(!(Test-Path (Join-Path $adm "netfx.msi"))){ Fail "admin image creation failed ($($p.ExitCode))" }
        $p=Start-Process msiexec -ArgumentList "/a `"$adm\netfx.msi`" /p `"$w\netfxsp.msp`" /qn" -Wait -PassThru
        if($p.ExitCode -ne 0){ Fail "SP1 slipstream failed ($($p.ExitCode))" }
        $p=Start-Process msiexec -ArgumentList "/i `"$adm\netfx.msi`" /qn /norestart" -Wait -PassThru
        if($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010){ Fail ".NET 1.1 SP1 install failed ($($p.ExitCode))" }
        if(!(Test-Path (Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\mscorlib.dll"))){ Fail ".NET 1.1 install reported success but v1.1.4322 is missing" }
        Log "  .NET 1.1 SP1 installed"
        return
    }
    # ------------------------------------------------------------------------------------
    # legacy path (XP/Win7 era, SP1 not bundled): plain redist install
    Log "installing .NET 1.1"; if($DryRun){return}
    $p=Start-Process $dfx -ArgumentList '/q:a /c:"install /q"' -Wait -PassThru
    if($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010){ Fail ".NET 1.1 install failed ($($p.ExitCode)). On Windows 10/11, bundle Dependencies\DotNet11\NDP1.1sp1-KB867460-X86.exe so the installer can slipstream SP1." }
}
function Ensure-DirectX {
    if($SkipDirectX){return}
    # The June-2010 redist is a self-extractor that installs correctly on Win7. Do NOT use the
    # XPe-era dxsetup that ships in some GVR media - it only works on Windows XP Embedded.
    $redist=@((Join-Path $Root "Dependencies\DirectX\directx_Jun2010_redist.exe"))|Where-Object{Test-Path $_}|Select-Object -First 1
    if(!$redist){ Warn "DirectX June-2010 redist not bundled (Dependencies\DirectX\directx_Jun2010_redist.exe). Install DirectX 9 (d3dx9) yourself, or re-run with it present."; return }
    if($DryRun){ Log "would install DirectX 9 (June 2010 redist)"; return }
    Log "installing DirectX 9 (June 2010 redist - extract then DXSETUP /silent)"
    $tmp=Join-Path $WorkRoot "dx"; New-Dir $tmp
    Start-Process $redist -ArgumentList @("/Q","/T:$tmp","/C") -Wait
    $dxs=Join-Path $tmp "DXSETUP.exe"
    if(Test-Path $dxs){ Start-Process $dxs -ArgumentList "/silent" -Wait; Log "  DirectX 9 installed" }
    else { Warn "DXSETUP.exe not found after extracting the redist to $tmp" }
}
function Deploy-Dxvk($ug){
    # ---- Modern-hardware (Win10/11 + fast GPU) frame cap ------------------------------
    # NFSU's physics is framerate-tied and the game has no vsync/fps arg; the cabinet ran on
    # a fixed-60Hz CRT. On modern GPUs it runs at hundreds of fps -> the driving is absurdly
    # fast. Drop an app-local DXVK d3d9.dll (D3D9->Vulkan) next to UndergroundGVR.exe with
    # d3d9.maxFrameRate=60. Only when Vulkan is present (all modern GPUs); on XP/Win7 without
    # Vulkan we leave native d3d9 alone (the old hardware doesn't overrun 60fps anyway).
    #
    # GAME ONLY - deliberately NOT deployed next to UniverShell2.exe in GvrRoot. Tried that to
    # chase the white-cars-in-frontend bug (the shell's car art is DXT2, a premultiplied-alpha
    # format modern D3D9 drivers no longer expose); it did NOT restore the liveries and it broke
    # the shell's intro/attract video playback. Do not re-add without re-testing both.
    if($SkipDirectX){return}   # same "graphics stack" gate
    $dll=Join-Path $Root "Dependencies\DXVK\d3d9.dll"
    if(!(Test-Path $dll)){ Warn "DXVK d3d9.dll not bundled (Dependencies\DXVK\d3d9.dll) - skipping 60fps cap; game will run too fast on modern GPUs"; return }
    if(!(Test-Path (Join-Path $env:WINDIR "System32\vulkan-1.dll"))){ Log "no Vulkan runtime - skipping DXVK frame cap (native d3d9, fine on period hardware)"; return }
    if($DryRun){ Log "would deploy DXVK d3d9.dll + dxvk.conf (60fps cap) next to UndergroundGVR.exe"; return }
    Copy-Item $dll (Join-Path $ug "d3d9.dll") -Force
    [System.IO.File]::WriteAllText((Join-Path $ug "dxvk.conf"), "# cap NFSU to 60fps (physics is framerate-tied; cabinet ran at fixed 60Hz)`r`nd3d9.maxFrameRate = 60`r`n")
    Log "  DXVK d3d9.dll + dxvk.conf deployed (60fps cap) - fixes the sped-up driving on modern GPUs"
    # ------------------------------------------------------------------------------------
}

function Deploy-CardEmulator($ug,$gvrroot){
    # ---- Software smart card + reader (enables CAREER mode) -----------------------------
    # A GlobalVR cabinet has a PC/SC smart card reader and the player owns a Players' Card.
    # Career mode is the card's whole reason to exist: your name, the career car you keep,
    # and the upgrades bought between races all live ON the card (GamePlayerInfo.NFS).
    # With no reader the shell greys CAREER out as "No Smart Card Reader".
    #
    # There are TWO independent gates, and both must be satisfied:
    #
    #  1. the CARD - PLUSDE loads GVRSCR28.dll through GVRStorageDevice (LoadLibraryA +
    #     GetProcAddress "CreateGVRStorageDeviceImp") and calls a 15-slot vtable on the
    #     object it returns. Our GVRSCR28.dll implements that ABI and serves an 8 KB card
    #     image, so the shell sees a real PLAYER card it can read, write and register.
    #
    #  2. the READER - ScriptPlug-Ins\SCDiagnostic.dll does NOT go through that abstraction.
    #     It calls PCSCSCR2.dll!PCSC_GetReaderNames -> SCardListReadersA against the real
    #     Windows smart card service, gets SCARD_E_NO_READERS_AVAILABLE, and the shell then
    #     writes CabinetStatus_NFS1.SmartCardReaderStatus = 0 and greys CAREER out no matter
    #     how well the card behaves. Our PCSCSCR2.dll answers "one reader present".
    #
    # Both DLLs are game-local: nothing is installed on the host and no Windows virtual smart
    # card is required. Originals are kept as *.real-hardware, so a machine that really does
    # have a GlobalVR reader can be restored by putting those two files back.
    #
    # Career progress persists in GvrPlus\GvrCardEmu.card (deliberately next to game.db, so
    # the shell in GvrRoot and the game in Underground share one card) and the shell also
    # backs the image up into CareerData_NFS1.GamePlayerInfo, keyed by CardId.
    # F9 forces a card eject; see docs/technical-notes.md.
    $src = Join-Path $Root "CardEmu"
    if(!(Test-Path $src)){ Warn "CardEmu folder not bundled - career mode will stay greyed out (no smart card reader)"; return }

    # GvrCardKey.exe is the out-of-process key watcher: the card starts OUT of the slot so the
    # attract reel / intro plays as it does on a cabinet, and pressing S (START) inserts it.
    # It has to be a separate process - every in-process method of reading the keyboard either
    # failed outright or broke the game's own input. The DLL launches it automatically and it
    # exits with the game. See docs/technical-notes.md.
    $pairs = @(
        @{ name="GVRSCR28.dll";   dirs=@($ug,$gvrroot) },
        @{ name="PCSCSCR2.dll";   dirs=@($ug,$gvrroot) },
        @{ name="GvrCardKey.exe"; dirs=@($ug,$gvrroot) }
    )
    foreach($p in $pairs){
        $from = Join-Path $src $p.name
        if(!(Test-Path $from)){ Warn "  $($p.name) missing from CardEmu - skipped"; continue }
        foreach($d in $p.dirs){
            if(!(Test-Path $d)){ continue }
            $dst = Join-Path $d $p.name
            $bak = "$dst.real-hardware"
            if($DryRun){ Log "DRY RUN would install software $($p.name) in $d"; continue }
            # keep the genuine driver exactly once - never overwrite an existing backup with
            # our own DLL on a re-install. (GvrCardKey.exe is ours alone, nothing to back up.)
            if((Test-Path $dst) -and !(Test-Path $bak) -and $p.name -ne "GvrCardKey.exe"){
                Copy-Item -LiteralPath $dst -Destination $bak -Force
            }
            Copy-Item -LiteralPath $from -Destination $dst -Force
            Log "  software card layer: $($p.name) -> $d"
        }
    }
    Log "  CAREER mode enabled (virtual card + virtual reader, no hardware, nothing installed on the host)"
}

function Disable-GammaSet($gvr){
    # ---- Cabinet display-calibration tool (Win10/11 / any non-NVIDIA-XP host) -----------
    # UniverShell2 shells out to Gvr\system\GammaSet.exe -gammasetting 0 a few seconds after
    # start. GammaSet is a Hot Pursuit 2-era cabinet tool that hard-codes two NVIDIA
    # display-tweak calls:
    #     rundll32.exe NvCpl.dll,dtcfg setgamma all all 1.00
    #     rundll32.exe NvCpl.dll,dtcfg setdvc  all 22
    # On 64-bit Windows the 32-bit rundll32 looks in SysWOW64, where NvCpl.dll does not exist
    # (modern NVIDIA drivers ship only the 64-bit copy in System32; non-NVIDIA GPUs have none),
    # so each call raises a "There was a problem starting NvCpl.dll" RunDLL dialog. It is not
    # fatal - the shell keeps running - but it pops on every launch.
    # Suppressing it costs nothing visually: gamma 1.00 IS the neutral/no-op value and dvc 22 is
    # a mild vibrance bump calibrated for the cabinet's CRT. It is also exactly the kind of
    # host display manipulation a game-only install must not do. Rename rather than delete so
    # the original stays recoverable; renaming is enough because the shell's launch is
    # fire-and-forget (CreateProcess simply fails, silently).
    $gs=Join-Path $gvr "system\GammaSet.exe"
    if(!(Test-Path $gs)){ return }
    if(Test-Path (Join-Path $env:WINDIR "SysWOW64\NvCpl.dll")){
        Log "  32-bit NvCpl.dll present - leaving GammaSet.exe enabled"; return
    }
    if($DryRun){ Log "would disable cabinet GammaSet.exe (avoids NvCpl.dll RunDLL popups)"; return }
    $bak="$gs.arcade-disabled"
    if(Test-Path $bak){ Remove-Item $bak -Force }
    Move-Item $gs $bak -Force
    Log "  GammaSet.exe disabled (-> GammaSet.exe.arcade-disabled) - no NvCpl.dll RunDLL popups"
    # ------------------------------------------------------------------------------------
}

function Get-Max43ForPrimaryScreen(){
    # Largest 4:3 size that fits the PRIMARY screen, e.g. 1920x1080 -> 1440x1080.
    # Read from EnumDisplaySettings(ENUM_CURRENT_SETTINGS) rather than GetSystemMetrics or
    # Windows.Forms, because those report DPI-SCALED values in a non-DPI-aware process (a 1080p
    # screen at 150% would come back as 1280x720 and we would write a needlessly small window).
    try {
        Add-Type -ErrorAction Stop @"
using System;using System.Runtime.InteropServices;
public class GvrCurMode{
 [DllImport("user32.dll",CharSet=CharSet.Ansi)] static extern bool EnumDisplaySettingsA(string d,int n,ref DEVMODE m);
 [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Ansi)] public struct DEVMODE{
  [MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)] public string dmDeviceName;
  public ushort dmSpecVersion,dmDriverVersion,dmSize,dmDriverExtra; public uint dmFields;
  public short u1,u2,u3,u4,u5,u6,u7,u8; public short dmColor,dmDuplex,dmYResolution,dmTTOption,dmCollate;
  [MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)] public string dmFormName;
  public ushort dmLogPixels; public uint dmBitsPerPel,dmPelsWidth,dmPelsHeight,dmDisplayFlags,dmDisplayFrequency;}
 public static uint[] Current(){ var m=new DEVMODE(); m.dmSize=(ushort)Marshal.SizeOf(typeof(DEVMODE));
  if(!EnumDisplaySettingsA(null,-1,ref m)) return new uint[]{0,0};
  return new uint[]{m.dmPelsWidth,m.dmPelsHeight}; } }
"@
        $cur=[GvrCurMode]::Current()
        $sw=[int]$cur[0]; $sh=[int]$cur[1]
        if($sw -lt 640 -or $sh -lt 480){ return $null }
        $w=[Math]::Min($sw, [Math]::Floor($sh*4/3))
        $h=[Math]::Floor($w*3/4)
        $w=[int]($w - ($w % 2)); $h=[int]($h - ($h % 2))   # keep both even
        if($w -lt 640 -or $h -lt 480){ return $null }
        return @{ w=$w; h=$h; sw=$sw; sh=$sh }
    } catch { return $null }
}

function Set-IniResolution($iniPath,$w,$h){
    # Rewrite Width=/Height= under [Display]; comments and everything else untouched.
    # [Race]/[Shell] are the pre-merge section names and are still handled for older inis.
    $section=""
    $out=@()
    foreach($line in (Get-Content $iniPath)){
        $t=$line.Trim()
        if($t -match '^\[(.+)\]$'){ $section=$matches[1] }
        elseif($section -eq "Display" -or $section -eq "Race" -or $section -eq "Shell"){
            if($t -match '^Width\s*='){  $out += "Width=$w";  continue }
            if($t -match '^Height\s*='){ $out += "Height=$h"; continue }
        }
        $out += $line
    }
    Set-Content -Path $iniPath -Value $out -Encoding UTF8
}

function Deploy-Settings($installRoot){
    # ---- user-editable settings (gvr_settings.ini) --------------------------------------
    # Neither EXE has any settings screen - no ini, no registry value, no command-line switch
    # (the game's full 62-entry option table was dumped; the only display switches are
    # -forcewindowed / -forcefullscreen and the undocumented -screenshot, which forces
    # 1280x1024). So this file is simply DEPLOYED here, and applied AT LAUNCH:
    #   GvrLaunch.exe    - frontend window size, and the fullscreen/windowed token for the race
    #   GVRInputRaw.dll  - race resolution + the whole controller map
    #   GvrCardKey.exe   - the card button
    # All three patch memory only, every launch, so nothing on disk is ever modified and editing
    # this file is enough. (Players must start the game via GvrLaunch.exe for the window size.)
    $src=Join-Path $Root "gvr_settings.ini"
    $dstIni=Join-Path $installRoot "gvr_settings.ini"
    if($DryRun){ Log "would deploy gvr_settings.ini (sized to this screen)"; return }
    if(Test-Path $dstIni){ Log "  gvr_settings.ini already present - keeping your settings" }
    elseif(Test-Path $src){
        Copy-Item $src $dstIni -Force
        Log "  gvr_settings.ini written"
        # Size a FRESH ini to this machine: the biggest 4:3 that fits the primary screen. One
        # [Display] size drives both the race and the frontend, so the two always line up and no
        # wallpaper shows around them.
        # 4:3 because the engine derives vertical FOV from a fixed horizontal one - a 16:9 render
        # stretches the picture. Written as plain numbers you can edit afterwards; we never
        # re-detect at launch, and an existing ini is never touched.
        $best=Get-Max43ForPrimaryScreen
        if($best){
            Set-IniResolution $dstIni $best.w $best.h
            Log ("  screen {0}x{1} -> [Display] {2}x{3} (largest 4:3 that fits)" -f $best.sw,$best.sh,$best.w,$best.h)
        } else {
            Log "  could not read the primary display mode - keeping the shipped 1280x960"
        }
    }
    else { Warn "  gvr_settings.ini not bundled - skipping" }
    # ------------------------------------------------------------------------------------
}

# ===================== SQLite backend (app-local, portable) ================
function Deploy-Sqlite($ug,$gvrroot,$gvrplus){
    $sd=Join-Path $Root "SQLite"
    foreach($f in @("PLUSDE.dll","GvrSqlite.dll","GvrSqlite.cs","sqlite3.dll","game.db")){ if(!(Test-Path (Join-Path $sd $f))){Fail "missing SQLite payload: $f"} }
    Log "deploying SQLite backend (app-local, no SQL Server)"
    if($DryRun){return}
    # MUST be the 1.1 csc: a 2.0-compiled assembly is rejected by CLR 1.1 (BadImageFormat).
    # After Ensure-DotNet the 1.1 runtime (which ships csc.exe) is always present.
    $csc=Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\csc.exe"
    # the two EXE app dirs (game + shell) get the patched engine + provider + sqlite3
    foreach($d in @($ug,$gvrroot)){
        Copy-Item (Join-Path $sd "PLUSDE.dll")  (Join-Path $d "PLUSDE.dll")  -Force
        Copy-Item (Join-Path $sd "sqlite3.dll") (Join-Path $d "sqlite3.dll") -Force
        $built=$false
        if(Test-Path $csc){
            $cs=Join-Path $d "GvrSqlite.cs"; Copy-Item (Join-Path $sd "GvrSqlite.cs") $cs -Force
            & $csc /nologo /target:library /out:(Join-Path $d "GvrSqlite.dll") /r:System.dll /r:System.Data.dll $cs 2>&1|Out-Null
            if(Test-Path (Join-Path $d "GvrSqlite.dll")){$built=$true}; Remove-Item $cs -Force -EA SilentlyContinue
        }
        if(!$built){ Warn "no usable csc in $d; using prebuilt GvrSqlite.dll"; Copy-Item (Join-Path $sd "GvrSqlite.dll") (Join-Path $d "GvrSqlite.dll") -Force }
    }
    # patched engine also in GvrPlus\1\lib (some plugins load it from there)
    New-Dir (Join-Path $gvrplus "1\lib"); Copy-Item (Join-Path $sd "PLUSDE.dll") (Join-Path $gvrplus "1\lib\PLUSDE.dll") -Force
    # the shared seeded db lives at <GvrPlus>\game.db - the provider derives this from the
    # registry PlusSchemaPath, so no env var / reboot is needed.
    #
    # NEVER clobber an existing game.db. Once the game has run, this file is not seed data any
    # more - it holds all player and operator state: car configurations (CarConfiguration_NFS1),
    # leaderboards and best times (GameResult_NFS1), and everything set in the O operator menu
    # (Settings_NFS1: volume, laps per track, difficulty, free play), plus coin/accounting rows.
    # Re-running the installer to repair an install used to silently reset all of that.
    # This matches how the rest of the installer treats an existing game tree: keep it unless
    # -ForceOverwrite is passed.
    $dbDst = Join-Path $gvrplus "game.db"
    if((Test-Path $dbDst) -and -not $ForceOverwrite){
        Log "  game.db already exists - KEEPING it (scores/settings preserved; -ForceOverwrite resets to the seed)"
    } else {
        Copy-Item (Join-Path $sd "game.db") $dbDst -Force
        Log "  game.db -> $dbDst  (fresh seed)"
    }
    # belt-and-suspenders: the newer provider derives this from the registry, but the prebuilt
    # fallback (used when the target has no 1.1 csc) reads GVRSQLITE_DB first.
    [Environment]::SetEnvironmentVariable("GVRSQLITE_DB", $dbDst, "Machine")
}

# ===================== batch-file path rewrite ============================
function Rewrite-Batches($ug,$gvrroot,$gvrplus,$gvr){
    if($DryRun){return}
    # batch files use single-backslash literal paths; ordered so GvrRoot/GvrPlus win before bare Gvr
    $subs = @(
        @("C:\GvrRoot",     $gvrroot),
        @("C:\GvrPlus",     $gvrplus),
        @("C:\Underground", $ug),
        @("C:\Gvr\",        ($gvr + "\"))
    )
    Get-ChildItem -Path @($ug,$gvrroot,$gvrplus,$gvr) -Filter *.bat -Recurse -EA SilentlyContinue | Where-Object{!$_.PSIsContainer} | ForEach-Object {
        $c=[System.IO.File]::ReadAllText($_.FullName); $orig=$c
        foreach($p in $subs){ $c=[regex]::Replace($c,[regex]::Escape($p[0]),$p[1],"IgnoreCase") }
        if($c -ne $orig){ [System.IO.File]::WriteAllText($_.FullName, $c); Log "  rewrote paths in $($_.Name)" }
    }
}

function Patch-GvrdContent($ug,$gvrroot,$gvrplus,$gvr){
    # The shell reads its launch/tool paths from GVRD v5 binary containers in GvrRoot\gvr -
    # CommandlineArgs_data.gvr holds the game exe/workdir (without this patch "start race"
    # silently returns to the frontend), OperatorData/normalData/OpReg hold volume/gamma/
    # vinyl/lib paths. Container: 0x20 header (magic,ver,idxBytes,count,0,count,dataStart,0),
    # index of count x 16-byte entries (0,id,size,absOffset), then contiguous records of
    # 16-byte subheader (size,id,strLen,cap) + NUL-terminated string. Rebuilds sizes/offsets.
    if($DryRun){return}
    $subs = @(   # ordered: GvrPlus/GvrRoot before the bare C:\Gvr helper dir
        @("^c:\\gvrplus",       $gvrplus),
        @("^c:\\gvrroot",       $gvrroot),
        @("^c:\\gvr(?=\\|$)",   $gvr),
        @("^c:\\underground",   $ug)
    )
    $targets = @($ug,$gvrroot,$gvrplus,$gvr)
    foreach($name in @("CommandlineArgs_data.gvr","OperatorData.gvr","normalData.gvr","OpReg_data.gvr")){
        $path = Join-Path $gvrroot "gvr\$name"
        if(!(Test-Path $path)){ Warn "  $name missing - skipped"; continue }
        $d = [System.IO.File]::ReadAllBytes($path)
        if([System.Text.Encoding]::ASCII.GetString($d,0,4) -ne "GVRD" -or [BitConverter]::ToUInt32($d,4) -ne 5){ Warn "  $name is not GVRD v5 - skipped"; continue }
        $count     = [BitConverter]::ToUInt32($d,12)
        $dataStart = [BitConverter]::ToUInt32($d,24)
        # index entries in file order: (flags,id,size,offset)
        $idx = New-Object System.Collections.ArrayList
        for($i=0;$i -lt $count;$i++){
            $o = 0x20 + $i*16
            [void]$idx.Add(@([BitConverter]::ToUInt32($d,$o),[BitConverter]::ToUInt32($d,$o+4),[BitConverter]::ToUInt32($d,$o+8),[BitConverter]::ToUInt32($d,$o+12)))
        }
        # walk records in physical order, patch string payloads
        $byOffset = $idx | Sort-Object { $_[3] }
        $recs = @{}   # id -> new raw bytes
        $nPatched = 0
        foreach($e in $byOffset){
            $size=$e[2]; $off=$e[3]
            $raw = New-Object byte[] $size
            [Array]::Copy($d,$off,$raw,0,$size)
            if($size -ge 17){
                $strLen = [BitConverter]::ToUInt32($raw,8)
                if($strLen -gt 0 -and ($strLen+16) -lt $size -and $raw[16+$strLen] -eq 0){
                    $s = [System.Text.Encoding]::ASCII.GetString($raw,16,$strLen)
                    $already = $false   # idempotence: skip strings already under an install dir
                    foreach($t in $targets){ if($s.StartsWith($t,[StringComparison]::OrdinalIgnoreCase)){ $already=$true; break } }
                    if(-not $already){
                        $new = $s
                        foreach($p in $subs){ $new = [regex]::Replace($new,$p[0],$p[1].Replace('$','$$'),"IgnoreCase") }
                        if($new -ne $s){
                            $b = [System.Text.Encoding]::ASCII.GetBytes($new)
                            $raw = New-Object byte[] (16 + $b.Length + 1)
                            [Array]::Copy([BitConverter]::GetBytes([UInt32]$raw.Length),0,$raw,0,4)
                            [Array]::Copy([BitConverter]::GetBytes([UInt32]$e[1]),0,$raw,4,4)
                            [Array]::Copy([BitConverter]::GetBytes([UInt32]$b.Length),0,$raw,8,4)
                            [Array]::Copy([BitConverter]::GetBytes([UInt32]$b.Length),0,$raw,12,4)
                            [Array]::Copy($b,0,$raw,16,$b.Length)
                            $nPatched++
                        }
                    }
                }
            }
            $recs[$e[1]] = $raw
        }
        if($nPatched -eq 0){ Log "  $name - no paths to repoint (already patched?)"; continue }
        # rebuild: data section in original physical order, index in original entry order
        $ms = New-Object System.IO.MemoryStream
        $ms.Write($d,0,0x20) | Out-Null
        $pos = $dataStart
        $newIdx = @{}   # id -> @(size,offset)
        foreach($e in $byOffset){
            $raw = $recs[$e[1]]
            $newIdx[$e[1]] = @($raw.Length,$pos)
            $pos += $raw.Length
        }
        foreach($e in $idx){
            $ni = $newIdx[$e[1]]
            $ms.Write([BitConverter]::GetBytes([UInt32]$e[0]),0,4) | Out-Null
            $ms.Write([BitConverter]::GetBytes([UInt32]$e[1]),0,4) | Out-Null
            $ms.Write([BitConverter]::GetBytes([UInt32]$ni[0]),0,4) | Out-Null
            $ms.Write([BitConverter]::GetBytes([UInt32]$ni[1]),0,4) | Out-Null
        }
        if($ms.Length -ne $dataStart){ Warn "  $name - index rebuild size mismatch, file left untouched"; continue }
        foreach($e in $byOffset){ $raw=$recs[$e[1]]; $ms.Write($raw,0,$raw.Length) | Out-Null }
        [System.IO.File]::WriteAllBytes($path,$ms.ToArray())
        Log "  repointed $nPatched path record(s) in $name"
    }
}

function Register-Assemblies($gvrplus){
    $regasm=Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\RegAsm.exe"
    $lib=Join-Path $gvrplus "1\lib"
    if(!(Test-Path $regasm) -or !(Test-Path $lib)){ Warn "RegAsm 1.1 or lib dir missing - skipping assembly registration"; return }
    Log "registering GvrPlus .NET assemblies (best-effort)"; if($DryRun){return}
    # only the managed GvrPe* assemblies are RegAsm-able; the other DLLs in lib are native
    foreach($name in @("GvrPeUtil.dll","GvrPeSchemaUtil.dll","GvrPeClient.dll","GvrPeEngine.dll","GvrPeDialer.dll")){
        $dll=Join-Path $lib $name
        if(!(Test-Path $dll)){ continue }
        $ErrorActionPreference="Continue"
        & $regasm $dll /codebase 2>&1 | Out-Null
        $ec=$LASTEXITCODE; $ErrorActionPreference="Stop"
        Log ("  regasm " + $name + " (exit " + $ec + ")")
    }
}

function Deploy-Fonts($installRoot){
    # ---- the OEM font component ----------------------------------------------------------
    # The shell's art definitions (GvrRoot\gvr\art.gvr) name four families that ship on Disc 1
    # and exist on NO Windows install: GVR_nfsu (383 references), GVR_digital (81), Ethnocentric
    # (76) and Digital dream Narrow. Without them GDI substitutes Arial - readable, but not the
    # NFSU styling - on the main menu ("START GAME"), the circuit name and the operator menu.
    #
    # THIS IS THE ONE THING THE INSTALL PUTS OUTSIDE ITS OWN FOLDER, and it is deliberate.
    # App-local loading was tried first and does not work: GVRInputRaw.dll called
    # AddFontResourceEx(..., FR_PRIVATE) on these files, and the frontend then rendered those
    # same fields as UNREADABLE GARBAGE - worse than not loading them at all, with or without
    # FR_NOT_ENUM. The engine resolves the family by name but cannot use a privately-loaded
    # face. A normally-registered font renders correctly, so that is what we do - the same
    # thing the OEM installer did.
    #
    # Only families Windows does not already have are installed. The component also carries
    # Microsoft's Arial bold/italic, Arial Narrow, Impact and Trebuchet MS Bold; every modern
    # Windows has those, and dropping the disc's Arial (bold/italic faces with NO regular face)
    # over the system family is a good way to break text everywhere.
    $dst=Join-Path $installRoot "Fonts"
    $cands=@((Join-Path $WorkRoot "Extracted\Fonts"), (Join-Path $WorkRoot "C\Fonts"), (Join-Path $Root "Fonts"))
    if(![string]::IsNullOrEmpty($ExpandedPayloadRoot)){
        $cands += (Join-Path $ExpandedPayloadRoot "Fonts"), (Join-Path $ExpandedPayloadRoot "C\Fonts")
    }
    $src=$cands | Where-Object { Test-Path $_ } | Select-Object -First 1
    if(!$src){ Warn "OEM Fonts component not found - the frontend will fall back to Arial for GVR_nfsu et al."; return }
    if($DryRun){ Log "would copy the OEM fonts from $src to $dst and install the missing families into Windows"; return }

    # keep a copy in the install folder: it documents what was installed and lets anyone
    # re-install by hand (right-click -> Install) if the registration is ever lost.
    New-Dir $dst
    $files=@(Get-ChildItem $src -File -EA SilentlyContinue | Where-Object { $_.Extension -match '^\.(ttf|otf|ttc|fon)$' })
    foreach($f in $files){ Copy-Item $f.FullName (Join-Path $dst $f.Name) -Force }
    Log "  fonts: $($files.Count) file(s) -> $dst"

    try { Add-Type -AssemblyName System.Drawing -EA Stop } catch { Warn "  System.Drawing unavailable - skipping font registration"; return }
    $installed=(New-Object System.Drawing.Text.InstalledFontCollection).Families | ForEach-Object { $_.Name }
    $winFonts=Join-Path $env:windir "Fonts"
    $key="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $added=0; $skipped=0
    foreach($f in $files){
        $fam=$null
        try { $pfc=New-Object System.Drawing.Text.PrivateFontCollection; $pfc.AddFontFile($f.FullName); $fam=$pfc.Families[0].Name } catch { }
        if(!$fam){ Warn "  fonts: cannot read the family name of $($f.Name) - skipped"; continue }
        if($installed -contains $fam){ $skipped++; continue }        # Windows already has it
        try {
            Copy-Item $f.FullName (Join-Path $winFonts $f.Name) -Force
            New-ItemProperty -Path $key -Name "$fam (TrueType)" -Value $f.Name -PropertyType String -Force | Out-Null
            [void][GvrFontApi]::AddFontResource((Join-Path $winFonts $f.Name))
            Log "  fonts: installed $fam ($($f.Name))"
            $added++
        } catch { Warn "  fonts: could not install $fam - $_" }
    }
    if($added){ $r=[IntPtr]::Zero; [void][GvrFontApi]::SendMessageTimeout([IntPtr]0xffff,0x001D,[IntPtr]::Zero,[IntPtr]::Zero,2,1000,[ref]$r) }  # WM_FONTCHANGE
    Log "  fonts: $added installed into Windows, $skipped already present"
}

function Deploy-Launcher($installRoot){
    # ---- GvrLaunch.exe : the thing the player actually starts ---------------------------
    # It applies gvr_settings.ini at startup (frontend window size, and the
    # -forcefullscreen/-forcewindowed token for the race), hands the foreground to whichever
    # program is live, and paints the game's own boot screen over the desktop while the
    # frontend and the race swap. None of that modifies an executable on disk.
    # (The [Display] resolution + controller map are applied by GVRInputRaw.dll instead, which the
    #  game loads before its own entry point, so those work however you launch it.)
    $src=Join-Path $Root "GvrLaunch.exe"
    if(!(Test-Path $src)){ Warn "GvrLaunch.exe not bundled - settings will not be applied at launch"; return }
    if($DryRun){ Log "would deploy GvrLaunch.exe (+ NFSU_GVR.ico) to $installRoot"; return }
    Copy-Item $src (Join-Path $installRoot "GvrLaunch.exe") -Force
    Log "  launcher: GvrLaunch.exe -> $installRoot"
    # Desktop-shortcut icon. GvrLaunch.exe carries no resource icon of its own, so the .ico ships
    # beside the installer and is copied into the install root; the shortcut points at it there
    # (a shortcut stores the icon by PATH, so it must live somewhere permanent, not in %TEMP%).
    $ico=Join-Path $Root "NFSU_GVR.ico"
    if(Test-Path $ico){
        Copy-Item $ico (Join-Path $installRoot "NFSU_GVR.ico") -Force
        Log "  icon: NFSU_GVR.ico -> $installRoot"
    } else { Warn "NFSU_GVR.ico not bundled - the shortcut will use the default exe icon" }
}

function Verify-Deployment($ug,$gvrroot,$installRoot){
    # These four are easy to lose in a partial copy and each fails in a way that is hard to
    # attribute, so state plainly whether they landed.
    #   GVRInputRaw_oem.dll : the STOCK driver. Our frontend copy of GVRInputRaw.dll forwards the
    #       whole cabinet ABI to it; without it the frontend freezes after roughly 100 seconds
    #       (it looks like a race-end hang, but it is idle time).
    #   dsound.dll          : keeps audio alive when the window is not focused, and stops the
    #       frontend warping the mouse pointer into the corner.
    if($DryRun){ return }
    $checks=@(
        @{ p=(Join-Path $gvrroot   "GVRInputRaw_oem.dll"); why="frontend would hang after ~100s" },
        @{ p=(Join-Path $gvrroot   "GVRInputRaw.dll");     why="no gamepad in the menus" },
        @{ p=(Join-Path $ug        "GVRInputRaw.dll");     why="no gamepad in the race" },
        @{ p=(Join-Path $gvrroot   "dsound.dll");          why="audio stops when unfocused; mouse gets trapped" },
        @{ p=(Join-Path $installRoot "gvr_settings.ini");  why="settings cannot be applied" }
    )
    $missing=@()
    foreach($c in $checks){ if(!(Test-Path $c.p)){ $missing += "$(Split-Path $c.p -Leaf) ($($c.why))" } }
    if($missing.Count -eq 0){ Log "  verified: controller + audio + settings components in place" }
    else { foreach($m in $missing){ Warn "MISSING $m" } }
}

function Make-Shortcut($ug,$gvrroot,$installRoot){
    # Point at GvrLaunch.exe so the ini is applied every time. It starts the frontend itself
    # (UniverShell2); GVRBoot - the arcade boot chain with the dongle/coin/stall monitors and a
    # 60s warm-up - stays skipped, as it is unnecessary and flaky for a home install.
    $exe=Join-Path $installRoot "GvrLaunch.exe"
    if(!(Test-Path $exe)){ $exe=Join-Path $gvrroot "UniverShell2.exe" }      # fallback: frontend
    if(!(Test-Path $exe)){ $exe=Join-Path $ug "UndergroundGVR.exe" }
    if(!(Test-Path $exe)){ return }
    $lnk=Join-Path ([Environment]::GetFolderPath("DesktopDirectory")) "NFS Underground GVR.lnk"
    # Icon deployed by Deploy-Launcher; fall back to the exe's own (default) icon if it is missing.
    $ico=Join-Path $installRoot "NFSU_GVR.ico"
    Log "shortcut -> $exe"; if($DryRun){return}
    $ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut($lnk); $s.TargetPath=$exe; $s.WorkingDirectory=(Split-Path -Parent $exe)
    if(Test-Path $ico){ $s.IconLocation="$ico,0"; Log "  icon: $ico" }
    $s.Save()
}

# ============================ run =========================================
if(!(Test-Admin)){ Fail "Run from an elevated Administrator PowerShell window." }
Log "NFSU GlobalVR portable (SQLite) installer $Version"

if([string]::IsNullOrEmpty($InstallRoot)){
    $InstallRoot = Read-Host "Where would you like to install the game? (e.g. C:\Games\NFSU or D:\NFSU)"
    if([string]::IsNullOrEmpty($InstallRoot)){ Fail "No install folder given." }
}
$InstallRoot = $InstallRoot.TrimEnd("\")
$UG      = Join-Path $InstallRoot "Underground"
$GVRROOT = Join-Path $UG "GVR\GvrRoot"
$GVRPLUS = Join-Path $UG "GVR\GvrPlus"
$GVR     = Join-Path $UG "GVR\Gvr"
Log "install root : $InstallRoot"
Log "  game       : $UG"
Log "  shell      : $GVRROOT"
Log "  plus       : $GVRPLUS"
Log "  gvr        : $GVR"

$gameInstalled = (Test-Path (Join-Path $UG "UndergroundGVR.exe")) -and (Test-Path (Join-Path $GVRROOT "UniverShell2.exe"))

Ensure-DotNet

if($gameInstalled -and -not $ForceOverwrite){
    Log "game already present at $UG - resuming remaining steps (registry/SQLite/...), skipping disc extraction"
} else {
    if((Test-Path $UG) -and -not $ForceOverwrite -and -not $DryRun -and -not $gameInstalled){
        Fail "$UG exists but looks incomplete. Use -ForceOverwrite to redo, or pick another folder."
    }
    # get the game tree into $WorkRoot\C
    if(![string]::IsNullOrEmpty($ExpandedPayloadRoot)){
        $b=$ExpandedPayloadRoot; if(Test-Path (Join-Path $ExpandedPayloadRoot "C")){$b=Join-Path $ExpandedPayloadRoot "C"}
        if(!(Test-ExpandedPayload $b)){ Fail "Expanded payload must contain Underground\ GvrRoot\ GvrPlus\ Gvr\: $ExpandedPayloadRoot" }
        Copy-Contents $b (Join-Path $WorkRoot "C")
    } else {
        $d1=Request-Disc "Disc1" $Disc1Path; Stage-Disc1 $d1; Log "Disc 1 staged - you can eject it now."
        $d2=Request-Disc "Disc2" $Disc2Path; Stage-Disc2 $d2; Log "Disc 2 staged - you can eject it now."
        Extract-Discs
    }
    $srcC = Join-Path $WorkRoot "C"
    Log "installing into $UG (nested GVR layout)"
    Copy-Contents (Join-Path $srcC "Underground") $UG
    Copy-Contents (Join-Path $srcC "GvrRoot")     $GVRROOT
    Copy-Contents (Join-Path $srcC "GvrPlus")     $GVRPLUS
    Copy-Contents (Join-Path $srcC "Gvr")         $GVR
}

# legacy runtime DLLs (MSVC71 etc.) -> app-local beside both EXEs. Always (idempotent) so it
# also applies on resume - V2 is system32-free, so these must sit next to the game/shell.
Copy-Contents (Join-Path $Root "DLLs") $UG
Copy-Contents (Join-Path $Root "DLLs") $GVRROOT

Emit-Registry $UG $GVRROOT $GVRPLUS $GVR $InstallRoot
Register-Assemblies $GVRPLUS
Deploy-Sqlite $UG $GVRROOT $GVRPLUS
Rewrite-Batches $UG $GVRROOT $GVRPLUS $GVR
Patch-GvrdContent $UG $GVRROOT $GVRPLUS $GVR
# clean up .exe.config CLR-2.0 bindings from any earlier install attempt - the game needs
# real CLR 1.1 (PLUSDE's native C++ exception interop AVs on 2.0), so these must not linger
if(!$DryRun){
    foreach($d in @($UG,$GVRROOT,(Join-Path $GVRPLUS "1\bin"))){
        Get-ChildItem $d -Filter "*.exe.config" -EA SilentlyContinue | ForEach-Object { Remove-Item $_.FullName -Force; Log "  removed stale $($_.Name)" }
    }
}
Ensure-DirectX
Deploy-Dxvk $UG
Disable-GammaSet $GVR
Deploy-CardEmulator $UG $GVRROOT
Deploy-Fonts $InstallRoot
Deploy-Settings $InstallRoot
Deploy-Launcher $InstallRoot
Verify-Deployment $UG $GVRROOT $InstallRoot
Make-Shortcut $UG $GVRROOT $InstallRoot

Log "DONE. Installed to $UG on SQLite - no SQL Server, no fixed C:\ paths."
Log "Launch: $InstallRoot\GvrLaunch.exe (what the shortcut points at - applies gvr_settings.ini)"
Log "Settings: edit $InstallRoot\gvr_settings.ini - resolution, fullscreen/windowed, gamepad map."
Log "  Nothing else to run: the exes are never modified, the settings apply on the next launch."
# The SQLite provider locates game.db via the GVRSQLITE_DB machine env var. Processes already
# running (Explorer!) don't see a var set mid-session, so a shortcut launch before re-logon
# hands the game an empty environment -> the shell waits on a db it can't find (AppHangB1).
Warn "IMPORTANT: log off and back on (or reboot) ONCE before first launch."
Warn "Launching from the shortcut before that will hang - Explorer only picks up the"
Warn "GVRSQLITE_DB environment variable on a fresh logon."
if(!$DryRun){ Remove-Item -LiteralPath $WorkRoot -Recurse -Force -EA SilentlyContinue }
