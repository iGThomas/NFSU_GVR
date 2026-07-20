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

function Deploy-Settings($installRoot){
    # ---- user-editable resolution (gvr_settings.ini) ------------------------------------
    # Neither EXE has any resolution setting - no ini, no registry value, no command-line
    # switch (the game's full 62-entry option table was dumped; the only display switches are
    # -forcewindowed / -forcefullscreen and the undocumented -screenshot, which forces
    # 1280x1024). Both are therefore set by rewriting constants in place; see
    # Tools\Apply-GvrSettings.ps1 for the offsets and the reasoning behind each.
    # The tool keeps a pristine <exe>.orig and always re-patches from it, so this is safe to
    # re-run and a value of 800x600 restores the untouched original.
    $src=Join-Path $Root "gvr_settings.ini"
    $tool=Join-Path $Root "Tools\Apply-GvrSettings.ps1"
    if(!(Test-Path $tool)){ Warn "Tools\Apply-GvrSettings.ps1 not bundled - skipping resolution setup"; return }
    $dstIni=Join-Path $installRoot "gvr_settings.ini"
    $dstTool=Join-Path $installRoot "Tools\Apply-GvrSettings.ps1"
    if($DryRun){ Log "would deploy gvr_settings.ini + Tools\Apply-GvrSettings.ps1 and apply the resolutions"; return }
    New-Dir (Join-Path $installRoot "Tools")
    Copy-Item $tool $dstTool -Force                       # always refresh the tool
    if(Test-Path $dstIni){ Log "  gvr_settings.ini already present - keeping your settings" }
    elseif(Test-Path $src){ Copy-Item $src $dstIni -Force; Log "  gvr_settings.ini written (edit it, then run Tools\Apply-GvrSettings.ps1)" }
    else { Warn "  gvr_settings.ini not bundled - skipping"; return }
    try { & $dstTool -InstallRoot $installRoot }
    catch { Warn "  applying gvr_settings.ini failed: $_ (game still runs at its stock 800x600)" }
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
    Copy-Item (Join-Path $sd "game.db") (Join-Path $gvrplus "game.db") -Force
    # belt-and-suspenders: the newer provider derives this from the registry, but the prebuilt
    # fallback (used when the target has no 1.1 csc) reads GVRSQLITE_DB first.
    [Environment]::SetEnvironmentVariable("GVRSQLITE_DB", (Join-Path $gvrplus "game.db"), "Machine")
    Log "  game.db -> $(Join-Path $gvrplus 'game.db')  (GVRSQLITE_DB set)"
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

function Make-Shortcut($ug,$gvrroot){
    # Launch the frontend (UniverShell2) directly. GVRBoot is the arcade boot chain
    # (dongle/coin/stall monitors + 60s warm-up via GVRCrashMonitor) - unnecessary and flaky
    # for a home install; the shell runs standalone and drives the full menu -> race flow.
    $exe=Join-Path $gvrroot "UniverShell2.exe"
    if(!(Test-Path $exe)){ $exe=Join-Path $ug "UndergroundGVR.exe" }
    if(!(Test-Path $exe)){ return }
    $lnk=Join-Path ([Environment]::GetFolderPath("DesktopDirectory")) "NFS Underground (SQLite).lnk"
    Log "shortcut -> $exe"; if($DryRun){return}
    $ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut($lnk); $s.TargetPath=$exe; $s.WorkingDirectory=(Split-Path -Parent $exe); $s.Save()
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
Deploy-Settings $InstallRoot
Make-Shortcut $UG $GVRROOT

Log "DONE. Installed to $UG on SQLite - no SQL Server, no fixed C:\ paths."
Log "Launch: $GVRROOT\UniverShell2.exe (frontend, what the shortcut points at) or $UG\UndergroundGVR.exe"
# The SQLite provider locates game.db via the GVRSQLITE_DB machine env var. Processes already
# running (Explorer!) don't see a var set mid-session, so a shortcut launch before re-logon
# hands the game an empty environment -> the shell waits on a db it can't find (AppHangB1).
Warn "IMPORTANT: log off and back on (or reboot) ONCE before first launch."
Warn "Launching from the shortcut before that will hang - Explorer only picks up the"
Warn "GVRSQLITE_DB environment variable on a fresh logon."
if(!$DryRun){ Remove-Item -LiteralPath $WorkRoot -Recurse -Force -EA SilentlyContinue }
