# ============================================================
# Install-NFSU-GVR-AIO.ps1
#
# Release/front-end installer for Need For Speed Underground
# GlobalVR game-only installs.
#
# This package intentionally does not include the game payload.
# The user must provide the original OEM Disc 1 and Disc 2.
# ============================================================

param(
    [string]$TargetDrive = "C:",
    [string]$Disc1Path = "",
    [string]$Disc2Path = "",
    [string]$ExtractorPath = "",
    [string]$ExpandedPayloadRoot = "",
    [switch]$DryRun,
    [switch]$ForceOverwrite,
    [switch]$SkipSql,
    [switch]$SkipDirectXCheck,
    [switch]$SkipDisc2DatabaseUpdate,
    [switch]$SkipLegacyNvidiaCplFiles,
    [int]$Disc2DatabaseUpdateTimeoutSeconds = 120,
    [switch]$KeepWorkDir
)

$ErrorActionPreference = "Stop"

$ReleaseRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$CoreInstaller = Join-Path $ReleaseRoot "Core\Install-NFSU-GVR-GameOnly.ps1"
$WorkRoot = Join-Path $env:TEMP ("NFSU_GVR_AIO_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
$LogFile = Join-Path $WorkRoot "aio_install.log"
$AioVersion = "2026-07-16-fix-gvr-case-collision"
$RequiredCoreVersion = '2026-07-15-rotate-sa-password'
$ResumeDir = Join-Path $TargetDrive "NFSU_GVR_AIO_State"
$ResumeMarker = Join-Path $ResumeDir "resume-after-reboot.flag"

function Write-Log($Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    if (!(Test-Path $WorkRoot)) { New-Item -ItemType Directory -Path $WorkRoot -Force | Out-Null }
    Add-Content -Path $LogFile -Value $line
}

function Warn($Message) {
    Write-Host "[!] $Message" -ForegroundColor Yellow
    Write-Log "WARN: $Message"
}

function Fail($Message) {
    Write-Host "[X] $Message" -ForegroundColor Red
    Write-Log "ERROR: $Message"
    throw $Message
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-Dir($Path) {
    if (!(Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
}

function Copy-TreeIfPresent($Source, $Destination, $Label) {
    if (!(Test-Path $Source)) {
        Warn "$Label not found in release package: $Source"
        return
    }

    Write-Log "Staging $Label"
    New-Dir $Destination
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function Copy-FileRequired($Source, $Destination) {
    if (!(Test-Path $Source)) { Fail "Required file not found: $Source" }
    New-Dir (Split-Path -Parent $Destination)
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Test-FinalPayloadPresent {
    # SHELLCARS.gvr is deliberately in this list. Executables alone are a false "installed":
    # the shell's content lives in C:\GvrRoot\gvr (41 files, ~448MB) and comes from cabinet
    # volumes that need Disc 2's data3.cab. A payload with every EXE but no content installs
    # cleanly, runs the game, and leaves GVRBoot/UniverShell2 black-screening forever - so a
    # payload missing it must count as incomplete, not as "already installed".
    $required = @(
        (Join-Path $TargetDrive "Underground\UndergroundGVR.exe"),
        (Join-Path $TargetDrive "GvrRoot\UniverShell2.exe"),
        (Join-Path $TargetDrive "GvrRoot\gvr\SHELLCARS.gvr"),
        (Join-Path $TargetDrive "GvrRoot\gvr\art.gvr"),
        (Join-Path $TargetDrive "GvrPlus\1\scripts\GvrPlusExportDatabaseScript.exe"),
        (Join-Path $TargetDrive "GvrPlus\1\lib\GvrPeUtil.dll"),
        (Join-Path $TargetDrive "GvrPlus\1\lib\GvrPeDialer.dll"),
        (Join-Path $TargetDrive "Gvr")
    )

    foreach ($path in $required) {
        if (!(Test-Path $path)) { return $false }
    }
    return $true
}

function Test-ResumeAfterReboot {
    if (!(Test-Path $ResumeMarker)) { return $false }
    if (Test-FinalPayloadPresent) { return $true }

    Warn "Resume marker exists, but final game payload is incomplete. A full disc install will run."
    return $false
}

function Set-ResumeMarker {
    New-Dir $ResumeDir
    $lines = @(
        "NFSU GlobalVR AIO resume marker",
        ("Created=" + (Get-Date)),
        ("Reason=Payload copied; SQL/MSDE may need reboot before database update can finish.")
    )
    Set-Content -LiteralPath $ResumeMarker -Value $lines -Encoding ASCII
    Write-Log "Resume marker written: $ResumeMarker"
}

function Clear-ResumeMarker {
    if (Test-Path $ResumeMarker) {
        Remove-Item -LiteralPath $ResumeMarker -Force -ErrorAction SilentlyContinue
        Write-Log "Resume marker removed: $ResumeMarker"
    }
}

function Test-Disc1($Path) {
    return ((Test-Path (Join-Path $Path "Setup.exe")) -and
        (Test-Path (Join-Path $Path "data1.hdr")) -and
        (Test-Path (Join-Path $Path "data1.cab")) -and
        (Test-Path (Join-Path $Path "data2.cab")))
}

function Test-Disc2($Path) {
    return (Test-Path (Join-Path $Path "data3.cab"))
}

function Find-Disc($Kind, $PreferredPath) {
    if (![string]::IsNullOrEmpty($PreferredPath)) {
        if (($Kind -eq "Disc1" -and (Test-Disc1 $PreferredPath)) -or
            ($Kind -eq "Disc2" -and (Test-Disc2 $PreferredPath))) {
            return (Resolve-Path $PreferredPath).Path
        }
        Fail "$Kind path does not look like the expected OEM disc: $PreferredPath"
    }

    foreach ($drive in [System.IO.DriveInfo]::GetDrives()) {
        if (!$drive.IsReady) { continue }
        $candidate = $drive.RootDirectory.FullName
        if ($Kind -eq "Disc1" -and (Test-Disc1 $candidate)) { return $candidate }
        if ($Kind -eq "Disc2" -and (Test-Disc2 $candidate)) { return $candidate }
    }

    return $null
}

function Request-Disc($Kind, $PreferredPath) {
    $disc = Find-Disc $Kind $PreferredPath
    while (!$disc) {
        [void](Read-Host "Mount/insert $Kind, then press Enter")
        $disc = Find-Disc $Kind ""
    }
    Write-Log "$Kind found: $disc"
    return $disc
}

function Stage-Disc1($Disc1Root) {
    if ($Disc1Root -is [array]) { $Disc1Root = @($Disc1Root | Where-Object { ![string]::IsNullOrEmpty($_) })[0] }
    if ([string]::IsNullOrEmpty($Disc1Root)) { Fail "Disc 1 root path is empty." }
    $Disc1Root = (Resolve-Path $Disc1Root).Path

    $stageDisc1 = Join-Path $WorkRoot "DISCS\DISC 1"
    New-Dir $stageDisc1

    Write-Log "Staging OEM Disc 1 metadata and cabinets"
    foreach ($name in @("Setup.exe", "Setup.ini", "setup.inx", "layout.bin", "data1.hdr", "data1.cab", "data2.cab")) {
        Copy-FileRequired (Join-Path $Disc1Root $name) (Join-Path $stageDisc1 $name)
    }

    $setupDir = Join-Path $Disc1Root "_Setup"
    if (Test-Path (Join-Path $setupDir "msvcr70.dll")) {
        Copy-FileRequired (Join-Path $setupDir "msvcr70.dll") (Join-Path $stageDisc1 "_Setup\msvcr70.dll")
    }
}

function Stage-Disc2($Disc2Root) {
    if ($Disc2Root -is [array]) { $Disc2Root = @($Disc2Root | Where-Object { ![string]::IsNullOrEmpty($_) })[0] }
    if ([string]::IsNullOrEmpty($Disc2Root)) { Fail "Disc 2 root path is empty." }
    $Disc2Root = (Resolve-Path $Disc2Root).Path

    $stageDisc2 = Join-Path $WorkRoot "DISCS\DISC 2"
    New-Dir $stageDisc2

    Write-Log "Staging OEM Disc 2 cabinet"
    Copy-FileRequired (Join-Path $Disc2Root "data3.cab") (Join-Path $stageDisc2 "data3.cab")
}

function Test-ExpandedPayload($Root) {
    $base = $Root
    if (Test-Path (Join-Path $Root "C")) { $base = Join-Path $Root "C" }

    $hasRequiredFolders = ((Test-Path (Join-Path $base "Underground")) -and
        (Test-Path (Join-Path $base "GvrRoot")) -and
        (Test-Path (Join-Path $base "GvrPlus")) -and
        (Test-Path (Join-Path $base "Gvr")))

    if (!$hasRequiredFolders) { return $false }

    $gvrPlus = Join-Path $base "GvrPlus"
    $requiredGvrPlusFiles = @(
        (Join-Path $gvrPlus "1\lib\GvrPeUtil.dll"),
        (Join-Path $gvrPlus "1\lib\GvrPeDialer.dll"),
        (Join-Path $gvrPlus "1\scripts\GvrPlusExportDatabaseScript.exe")
    )

    foreach ($file in $requiredGvrPlusFiles) {
        if (!(Test-Path $file)) { return $false }
    }

    return $true
}

function Copy-ExpandedPayload($Root) {
    $base = $Root
    if (Test-Path (Join-Path $Root "C")) { $base = Join-Path $Root "C" }
    if (!(Test-ExpandedPayload $Root)) {
        Fail "Expanded payload root must contain C\Underground, C\GvrRoot, C\GvrPlus, and C\Gvr, or those folders directly: $Root"
    }

    Write-Log "Using pre-expanded OEM payload: $base"
    foreach ($folder in @("Underground", "GvrRoot", "GvrPlus", "Gvr")) {
        Copy-TreeIfPresent (Join-Path $base $folder) (Join-Path $WorkRoot ("C\" + $folder)) ("expanded " + $folder)
    }
}

function Copy-ExtractedItemIfPresent($SourceRoot, $Name, $DestinationRoot) {
    $src = Join-Path $SourceRoot $Name
    if (!(Test-Path $src)) { return }

    New-Dir $DestinationRoot
    $dst = Join-Path $DestinationRoot $Name
    if (Test-Path $dst) { Remove-Item -LiteralPath $dst -Recurse -Force -ErrorAction SilentlyContinue }
    Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
}

function Copy-ExtractedContentsIfPresent($Source, $Destination) {
    if (!(Test-Path $Source)) { return }

    New-Dir $Destination
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function Convert-I6CompExtractedPayload($ExtractRoot) {
    $gameRoot = $ExtractRoot
    if (Test-Path (Join-Path $ExtractRoot "GvrGame\UndergroundGVR.exe")) {
        $gameRoot = Join-Path $ExtractRoot "GvrGame"
    }

    if (!(Test-Path (Join-Path $gameRoot "UndergroundGVR.exe"))) { return $false }
    if (!(Test-Path (Join-Path $ExtractRoot "UniverShell2.exe")) -and
        !(Test-Path (Join-Path $ExtractRoot "GvrRoot")) -and
        !(Test-Path (Join-Path $ExtractRoot "GVR"))) { return $false }

    Write-Log "Detected raw InstallShield extraction layout. Reshaping into installed C-drive payload."

    $targetC = Join-Path $WorkRoot "C"
    $underground = Join-Path $targetC "Underground"
    $gvrRoot = Join-Path $targetC "GvrRoot"
    $gvrPlus = Join-Path $targetC "GvrPlus\1"
    $gvr = Join-Path $targetC "Gvr"

    New-Dir $underground
    New-Dir $gvrRoot
    New-Dir $gvrPlus
    New-Dir $gvr

    $undergroundItems = @(
        "CARS", "defaultCustomizations", "fx", "GLOBAL", "LANGUAGES", "LoadScreens",
        "MARKERS", "NIS", "records", "shadowAttack", "SNDSTREAMS", "SOUND", "TRACKS",
        "amusementCustomTweaks.hoo", "assert.txt", "careerCustomTweaks.hoo",
        "CareerInfo.bin", "catchup.txt", "cleanshadows.bat", "gvrcar.bin",
        "gvrcpt.bin", "GvrKitData.bin", "HOTCHUNK.TAG", "JesDLL.dll",
        "NFSUnderground.ini", "ResetShadows.bat", "snapshot.dds",
        "statsAndPrefs.bin", "UndergroundGVR.exe"
    )
    foreach ($item in $undergroundItems) { Copy-ExtractedItemIfPresent $gameRoot $item $underground }

    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "GvrRoot") $gvrRoot
    # "gvr" and "GVR" are deliberately NOT in this list. The extraction has TWO different things:
    #   <Extract>\GvrRoot\gvr = the shell's 41 content files (SHELLCARS.gvr, art.gvr, artTex*.gvr)
    #   <Extract>\GVR         = gvr_data + system, i.e. the C:\Gvr payload
    # Windows is case-insensitive, so an entry of "gvr" here resolves to <Extract>\GVR and copies
    # the C:\Gvr payload into C:\GvrRoot\gvr, overwriting the real content that the
    # Copy-ExtractedContentsIfPresent "GvrRoot" call below already placed there correctly. That is
    # what left GvrRoot\gvr holding 17 wrong files and the shell black-screening with no content.
    # GvrRoot\gvr arrives via the GvrRoot copy; GVR\* goes to C:\Gvr further down.
    $gvrRootItems = @(
        "music", "nodongle", "plug-ins", "ScriptPlug-Ins", "Shaders",
        "source", "transaction", "video", "BadWords.txt", "cache.txt",
        "DbaseInterface.dll", "DbaseInterface.~dll", "DebugView.dll",
        "DisableAutoRestart.reg", "EnableAutoRestart.reg", "GVE_Resources.dll",
        "GVRBoot.exe", "GVRCacheWarmer.exe", "GVRCoinMonitor.exe", "GVRcoins.dll",
        "GVRCoinSound.exe", "GvrConvertDatabase.dll", "GVRCrashMonitor.exe",
        "GVRDongleMonitor.exe", "GvrFontLib.dll", "GvrId.dll", "GvrIdLib2.dll",
        "GVRInputRawTest.exe", "GvrLobbyDll.dll", "GvrLogDll.dll", "GVRLogger.exe",
        "GvrMessage.dll", "GvrScript.dll", "GVRStallMonitor.exe",
        "GvrTransaction.dll", "GvrTranslator.dll", "gvrtypes.dtd", "gvrtypes.xml",
        "GVR_Resources.dll", "hercules.xml", "HerculesStatus.exe", "HerculesTest.exe",
        "HerculesUI.exe", "inpout32.dll", "NFSSetDesktop2.exe", "PlusError.log",
        "Resources.dll", "RestartQuickTimers.reg", "select_02.wav", "SetIpAddress.exe",
        "SetupAutoRestart.reg", "SetVolume.exe", "SqlIdManagerCtrl.dll",
        "SqlInterface.dll", "SqlTypedDataSet.dll", "StringSubs.txt", "systray.ico",
        "Univer2Editor.exe", "UniverShell2.exe", "Watch.dll"
    )
    foreach ($item in $gvrRootItems) { Copy-ExtractedItemIfPresent $ExtractRoot $item $gvrRoot }

    # Do NOT copy the extraction's GVR\ folder into GvrRoot\gvr. Windows treats "gvr" and "GVR" as
    # the same name, so the old line here dumped GVR\{gvr_data,system} (the C:\Gvr payload) on top
    # of GvrRoot\gvr - the shell's content folder. That made GvrRoot\gvr look populated (17 wrong
    # files) while the real 41 .gvr content files were absent, which is indistinguishable from a
    # failed extraction until the shell black-screens. GvrRoot\gvr comes from the GvrRoot group,
    # already copied by the Copy-ExtractedContentsIfPresent "GvrRoot" call above.
    Copy-ExtractedItemIfPresent $ExtractRoot "gvr_data" $gvr
    Copy-ExtractedItemIfPresent $ExtractRoot "system" $gvr
    Copy-ExtractedItemIfPresent (Join-Path $ExtractRoot "GVR") "gvr_data" $gvr
    Copy-ExtractedItemIfPresent (Join-Path $ExtractRoot "GVR") "system" $gvr

    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "Plus") $gvrPlus
    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "PlusScripts") (Join-Path $gvrPlus "scripts")
    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "SharedDlls") (Join-Path $gvrPlus "lib")
    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "[Support]Non-SelfRegistering") (Join-Path $gvrPlus "lib")
    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "[Engine]SelfRegistering") (Join-Path $gvrPlus "lib")
    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "_Support_Non-SelfRegistering") (Join-Path $gvrPlus "lib")
    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "_Engine_SelfRegistering") (Join-Path $gvrPlus "lib")
    Copy-ExtractedContentsIfPresent (Join-Path $ExtractRoot "System32") (Join-Path $targetC "Windows\system32")

    $schema = Join-Path $gvrPlus "schema"
    New-Dir $schema
    foreach ($file in @("nfscabinet.enc", "nfscabinetXml.enc", "nfscabinet_Content.enc")) {
        Copy-ExtractedItemIfPresent $ExtractRoot $file $schema
        Copy-ExtractedItemIfPresent (Join-Path $ExtractRoot "Plus") $file $schema
    }

    $rootScriptFiles = @("GvrPlusExportDatabaseScript.exe", "GvrPlusLib.DLL", "Interop.SQLDMO.DLL", "sqldmo.dll", "AKSHASP.DLL")
    foreach ($file in $rootScriptFiles) {
        Copy-ExtractedItemIfPresent $ExtractRoot $file (Join-Path $gvrPlus "scripts")
    }

    $libFiles = @(
        "db_propagate.exe",
        "GvrPeClient.dll",
        "GvrPeDialer.dll",
        "GvrPeEngine.dll",
        "GvrPeSchemaUtil.DLL",
        "GvrPeUtil.DLL",
        "GvrPlusLib.dll",
        "ICSharpCode.SharpZipLib.dll",
        "Interop.SQLDMO.dll"
    )
    $libSearchRoots = @(
        $ExtractRoot,
        (Join-Path $ExtractRoot "SharedDlls"),
        (Join-Path $ExtractRoot "Plus"),
        (Join-Path $ExtractRoot "PlusScripts"),
        (Join-Path $ExtractRoot "[Support]Non-SelfRegistering"),
        (Join-Path $ExtractRoot "[Engine]SelfRegistering")
    )
    foreach ($file in $libFiles) {
        foreach ($searchRoot in $libSearchRoots) {
            if (!(Test-Path $searchRoot)) { continue }
            $match = Get-ChildItem -Path $searchRoot -Filter $file -Recurse -ErrorAction SilentlyContinue |
                Where-Object { !$_.PSIsContainer } |
                Select-Object -First 1
            if ($match) {
                Copy-ExtractedItemIfPresent (Split-Path -Parent $match.FullName) $match.Name (Join-Path $gvrPlus "lib")
                break
            }
        }
    }

    if (!(Test-ExpandedPayload $targetC)) {
        Warn "Raw extraction was reshaped, but one or more expected install folders are still incomplete."
        return $false
    }

    # Verifying the EXTRACTION is not enough - the reshape itself used to destroy the content by
    # copying <Extract>\GVR over the staged GvrRoot\gvr (Windows treats gvr and GVR as one name).
    # So re-check at the reshaped destination, which is what actually gets copied to C:\GvrRoot.
    $stagedGvr = Join-Path $gvrRoot "gvr"
    $staged = @(Get-ChildItem -Path $stagedGvr -Filter "*.gvr" -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer })
    $stagedBytes = 0
    foreach ($f in $staged) { $stagedBytes += $f.Length }
    Write-Log ("Reshaped shell content: {0} .gvr files, {1:N0} MB in {2}" -f $staged.Count, ($stagedBytes/1MB), $stagedGvr)
    if ($staged.Count -lt 30 -or $stagedBytes -lt (300 * 1MB) -or !(Test-Path (Join-Path $stagedGvr "SHELLCARS.gvr"))) {
        Fail ("Reshape produced a GvrRoot\gvr with {0} .gvr files / {1:N0} MB (expected ~41 / ~448MB). " -f $staged.Count, ($stagedBytes/1MB) +
              "The shell content was lost between extraction and staging - most likely something " +
              "copied the extraction's GVR\ folder over it. Installing would give a working game " +
              "and a black-screening arcade shell.")
    }
    if (Test-Path (Join-Path $stagedGvr "system")) {
        Fail ("Reshape put a 'system' folder inside GvrRoot\gvr. That is the C:\Gvr payload landing " +
              "in the shell's content folder - the gvr/GVR case-collision bug. Do not install.")
    }

    Write-Log "Raw InstallShield extraction reshaped successfully."
    return $true
}

function Find-Extractor {
    if (![string]::IsNullOrEmpty($ExtractorPath)) {
        if (!(Test-Path $ExtractorPath)) { Fail "Extractor not found: $ExtractorPath" }
        return (Resolve-Path $ExtractorPath).Path
    }

    $candidates = @(
        (Join-Path $ReleaseRoot "Tools\unshield.exe"),
        (Join-Path $ReleaseRoot "Tools\isxunpack.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
    }

    return $null
}

function Assert-DiscModeExtractor($Extractor) {
    $name = ([IO.Path]::GetFileName($Extractor)).ToLower()
    if ($name -eq "i6comp.exe") {
        Fail "The bundled i6comp.exe cannot extract these OEM discs reliably. Put unshield.exe or isxunpack.exe in C:\release\Tools before mounting discs, or run with -ExpandedPayloadRoot pointing at a legally extracted OEM payload."
    }
}

$script:ExtractAttempt = 0

function Run-ProcessLogged($FilePath, $Arguments, $WorkingDirectory) {
    $script:ExtractAttempt += 1
    Write-Log ("Trying extractor command: " + $FilePath + " " + ($Arguments -join " "))
    Write-Log ("  Working directory: " + $WorkingDirectory)
    $prefix = "extract_{0}_{1}" -f $script:ExtractAttempt, ([IO.Path]::GetFileNameWithoutExtension($FilePath))
    $outFile = Join-Path $WorkRoot ($prefix + ".out.log")
    $errFile = Join-Path $WorkRoot ($prefix + ".err.log")
    $p = Start-Process -FilePath $FilePath -ArgumentList $Arguments -WorkingDirectory $WorkingDirectory -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    Write-Log "Extractor exit code: $($p.ExitCode)"

    # unshield reports per-file failures on stdout and STILL exits 0. Trusting the exit code
    # silently installs a partial payload: the GvrRoot file group spans cabinet volumes 1-3, so
    # if data3.cab is absent or unreadable every large GvrRoot\gvr\*.gvr file fails while the
    # install reports success, and the shell then black-screens with no content to load.
    $script:LastExtractFailures = 0
    foreach ($log in @($outFile, $errFile)) {
        if (!(Test-Path $log)) { continue }
        $failed = @(Select-String -Path $log -Pattern "Failed to extract file" -ErrorAction SilentlyContinue)
        if ($failed.Count -gt 0) {
            $script:LastExtractFailures += $failed.Count
            Warn ("Extractor reported {0} file extraction failure(s) despite exit code {1}." -f $failed.Count, $p.ExitCode)
            foreach ($f in ($failed | Select-Object -First 5)) { Warn ("  " + $f.Line.Trim()) }
            if ($failed.Count -gt 5) { Warn ("  ... and {0} more (see {1})" -f ($failed.Count - 5), $log) }
        }
        $vol = @(Select-String -Path $log -Pattern "Failed to open (input cabinet file|volume)" -ErrorAction SilentlyContinue)
        if ($vol.Count -gt 0) {
            Warn "Extractor could not open a cabinet volume. A required data*.cab is missing or unreadable."
            Warn "Disc 2's data3.cab is mandatory: the GvrRoot file group spans volumes 1-3."
        }
    }
    return $p.ExitCode
}

function Assert-ShellContentExtracted($ExtractRoot) {
    # C:\GvrRoot\gvr holds the shell's content: SHELLCARS.gvr, art.gvr and the artTex*.gvr car
    # texture packs, ~448MB over 41 files. Without it UniverShell2/GVRBoot start, find nothing to
    # render, and sit on a black screen forever saying "Waiting for all components to initialize".
    # A correct extraction yields 41 files here; a data3.cab-less one yields zero, silently.
    $gvr = $null
    foreach ($c in @((Join-Path $ExtractRoot "GvrRoot\gvr"), (Join-Path $ExtractRoot "gvr"))) {
        if (Test-Path $c) { $gvr = $c; break }
    }
    if (!$gvr) {
        Fail ("Extraction produced no GvrRoot\gvr content folder under $ExtractRoot. " +
              "The shell cannot run without it. This usually means Disc 2's data3.cab was missing " +
              "or unreadable during extraction - the GvrRoot file group spans cabinet volumes 1-3.")
    }

    $files = @(Get-ChildItem -Path $gvr -Filter "*.gvr" -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer })
    $bytes = 0
    foreach ($f in $files) { $bytes += $f.Length }
    Write-Log ("Shell content check: {0} .gvr files, {1:N0} MB in {2}" -f $files.Count, ($bytes/1MB), $gvr)

    $markers = @("SHELLCARS.gvr", "art.gvr", "sound.gvr", "normalScript.gvr")
    $missing = @()
    foreach ($m in $markers) { if (!(Test-Path (Join-Path $gvr $m))) { $missing += $m } }

    if ($missing.Count -gt 0 -or $files.Count -lt 30 -or $bytes -lt (300 * 1MB)) {
        Warn ("Shell content is incomplete: {0} .gvr files, {1:N0} MB (expected ~41 files, ~448 MB)." -f $files.Count, ($bytes/1MB))
        if ($missing.Count -gt 0) { Warn ("Missing required shell content: " + ($missing -join ", ")) }
        Fail ("Extraction did not produce the GlobalVR shell content. Installing anyway would give a " +
              "game that runs but an arcade shell (GVRBoot/UniverShell2) that black-screens forever. " +
              "Most likely Disc 2's data3.cab was not staged or was unreadable - the GvrRoot file " +
              "group spans cabinet volumes 1-3, so Disc 2 is required to extract Disc 1's content.")
    }
    Write-Log "Shell content verified: the arcade shell has its .gvr content."
}

function Find-ExpandedPayloadRoot($SearchRoots) {
    foreach ($root in $SearchRoots) {
        if (!(Test-Path $root)) { continue }
        if (Test-ExpandedPayload $root) { return $root }

        $undergroundDirs = Get-ChildItem -Path $root -Filter "Underground" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.PSIsContainer }
        foreach ($dir in $undergroundDirs) {
            $dirPath = $null
            if ($dir -and $dir.PSObject.Properties["FullName"] -and ![string]::IsNullOrEmpty($dir.FullName)) {
                $dirPath = $dir.FullName
            } elseif ($dir -is [string] -and ![string]::IsNullOrEmpty($dir)) {
                $dirPath = $dir
            }

            if ([string]::IsNullOrEmpty($dirPath)) { continue }

            $parent = Split-Path -Parent $dirPath
            if (Test-ExpandedPayload $parent) { return $parent }
            $grandParent = Split-Path -Parent $parent
            if ($grandParent -and (Test-ExpandedPayload $grandParent)) { return $grandParent }
        }
    }

    return $null
}

function Write-ExtractorLogTail {
    $logs = Get-ChildItem -Path $WorkRoot -Filter "extract_*.log" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 4

    foreach ($log in $logs) {
        Write-Log ("Extractor log tail: " + $log.FullName)
        Get-Content -Path $log.FullName -ErrorAction SilentlyContinue |
            Select-Object -Last 12 |
            ForEach-Object { Write-Log ("  " + $_) }
    }
}

function Expand-OemInstallShieldPayload {
    $extractor = Find-Extractor
    if (!$extractor) {
        Fail "No usable InstallShield extractor found. Put unshield.exe or isxunpack.exe in release\Tools, or run this script with -ExpandedPayloadRoot pointing at a legally extracted OEM payload."
    }

    $stagedDisc1 = Join-Path $WorkRoot "DISCS\DISC 1"
    Copy-FileRequired (Join-Path $WorkRoot "DISCS\DISC 2\data3.cab") (Join-Path $stagedDisc1 "data3.cab")

    $cabRoot = Join-Path $WorkRoot "CabExtract"
    New-Dir $cabRoot
    foreach ($cabFile in @("data1.hdr", "data1.cab", "data2.cab", "data3.cab")) {
        Copy-FileRequired (Join-Path $stagedDisc1 $cabFile) (Join-Path $cabRoot $cabFile)
    }

    # All four volumes must be present and intact before extracting. unshield opens volumes on
    # demand and only whines on stdout when one is missing, so verify sizes here rather than
    # discover it later as a black screen. Disc 2's data3.cab is ~488MB and Disc 1's data2.cab
    # ~680MB; a truncated copy (eject mid-copy, disc swapped too early) is the failure mode.
    $minSizes = @{ "data1.hdr" = 1KB; "data1.cab" = 1KB; "data2.cab" = 100MB; "data3.cab" = 100MB }
    foreach ($cabFile in @("data1.hdr", "data1.cab", "data2.cab", "data3.cab")) {
        $p = Join-Path $cabRoot $cabFile
        if (!(Test-Path $p)) { Fail "Cabinet volume missing from extraction folder: $p" }
        $len = (Get-Item -LiteralPath $p).Length
        Write-Log ("Staged cabinet: {0,-10} {1,12:N0} bytes" -f $cabFile, $len)
        if ($len -lt $minSizes[$cabFile]) {
            Fail ("Staged cabinet $cabFile is only $len bytes, which is far too small. The copy from " +
                  "the disc was incomplete or the wrong disc was mounted. Re-run and make sure the " +
                  "disc is fully mounted before continuing.")
        }
    }

    $extractRoot = Join-Path $WorkRoot "Extracted"
    New-Dir $extractRoot

    $name = ([IO.Path]::GetFileName($extractor)).ToLower()
    $payloadRoot = $null
    if ($name -eq "unshield.exe") {
        Run-ProcessLogged $extractor @("x", "-d", $extractRoot, (Join-Path $cabRoot "data1.hdr")) $cabRoot | Out-Null
        Assert-ShellContentExtracted $extractRoot
        $payloadRoot = Find-ExpandedPayloadRoot @($extractRoot, $cabRoot)
        if (!$payloadRoot -and (Convert-I6CompExtractedPayload $extractRoot)) { $payloadRoot = Join-Path $WorkRoot "C" }
    } elseif ($name -eq "isxunpack.exe") {
        Run-ProcessLogged $extractor @((Join-Path $cabRoot "data1.hdr")) $extractRoot | Out-Null
        Assert-ShellContentExtracted $extractRoot
        $payloadRoot = Find-ExpandedPayloadRoot @($extractRoot, $cabRoot)
        if (!$payloadRoot -and (Convert-I6CompExtractedPayload $extractRoot)) { $payloadRoot = Join-Path $WorkRoot "C" }
    } else {
        $attempts = @(
            @{ Args = @("x", "-f", "data1.cab"); WorkDir = $cabRoot },
            @{ Args = @("e", "-f", "data1.cab"); WorkDir = $cabRoot },
            @{ Args = @("x", "-f", "data1.cab", "*"); WorkDir = $cabRoot },
            @{ Args = @("e", "-f", "data1.cab", "*"); WorkDir = $cabRoot },
            @{ Args = @("l", "data1.cab"); WorkDir = $cabRoot },
            @{ Args = @("l", "data1.hdr"); WorkDir = $cabRoot },
            @{ Args = @("x", "data1.cab", "*"); WorkDir = $extractRoot },
            @{ Args = @("x", "data1.hdr", "*"); WorkDir = $extractRoot },
            @{ Args = @("x", "data1.cab", "*.*"); WorkDir = $extractRoot },
            @{ Args = @("x", "data1.hdr", "*.*"); WorkDir = $extractRoot },
            @{ Args = @("x", "-r", "data1.cab", "*"); WorkDir = $extractRoot },
            @{ Args = @("x", "-r", "data1.hdr", "*"); WorkDir = $extractRoot },
            @{ Args = @("x", "data1.cab"); WorkDir = $cabRoot },
            @{ Args = @("x", "data1.hdr"); WorkDir = $cabRoot },
            @{ Args = @("e", "data1.cab"); WorkDir = $cabRoot },
            @{ Args = @("e", "data1.hdr"); WorkDir = $cabRoot },
            @{ Args = @("x", "data1.cab", "*"); WorkDir = $cabRoot },
            @{ Args = @("x", "data1.hdr", "*"); WorkDir = $cabRoot },
            @{ Args = @("x", "data1.cab", "*.*"); WorkDir = $cabRoot },
            @{ Args = @("x", "data1.hdr", "*.*"); WorkDir = $cabRoot }
        )

        foreach ($attempt in $attempts) {
            Run-ProcessLogged $extractor $attempt.Args $attempt.WorkDir | Out-Null
            $payloadRoot = Find-ExpandedPayloadRoot @($extractRoot, $cabRoot)
            if (!$payloadRoot -and (Convert-I6CompExtractedPayload $cabRoot)) { $payloadRoot = Join-Path $WorkRoot "C" }
            if (!$payloadRoot -and (Convert-I6CompExtractedPayload $extractRoot)) { $payloadRoot = Join-Path $WorkRoot "C" }
            if ($payloadRoot) { break }
        }
    }

    if (!$payloadRoot) {
        Write-ExtractorLogTail
        if ($name -eq "i6comp.exe") {
            Fail "This i6comp.exe build cannot read these OEM cabinets. Use unshield.exe in release\Tools, or run with -ExpandedPayloadRoot pointing at a legally extracted OEM payload."
        }
        Fail "The extractor ran, but the expected game folders were not produced. Check $WorkRoot extract logs, or provide -ExpandedPayloadRoot."
    }

    Write-Log "Expanded OEM payload found: $payloadRoot"
    if ((Resolve-Path $payloadRoot).Path -ne (Resolve-Path (Join-Path $WorkRoot "C")).Path) {
        Copy-ExpandedPayload $payloadRoot
    }
}

function Stage-ReleasePayload {
    Write-Log "Preparing staged install source: $WorkRoot"
    New-Dir $WorkRoot

    Copy-FileRequired $CoreInstaller (Join-Path $WorkRoot "Install-NFSU-GVR-GameOnly.ps1")
    Copy-TreeIfPresent (Join-Path $ReleaseRoot "DLLs") (Join-Path $WorkRoot "DLLs") "dependency DLLs"
    Copy-TreeIfPresent (Join-Path $ReleaseRoot "C") (Join-Path $WorkRoot "C") "runtime payload"
    Copy-TreeIfPresent (Join-Path $ReleaseRoot "Dependencies") (Join-Path $WorkRoot "Dependencies") "external dependency installers"
    Copy-TreeIfPresent (Join-Path $ReleaseRoot "Database") (Join-Path $WorkRoot "Database") "decoded database payload"

    foreach ($reg in @("Registry_Export.reg", "Reference_GVR_All.reg")) {
        $src = Join-Path $ReleaseRoot $reg
        if (Test-Path $src) {
            Copy-FileRequired $src (Join-Path $WorkRoot $reg)
        } else {
            Warn "Release registry payload missing: $reg"
        }
    }
}

function Invoke-CoreInstaller([switch]$SkipGamePayloadCopy) {
    $script = Join-Path $WorkRoot "Install-NFSU-GVR-GameOnly.ps1"
    $coreText = Get-Content -LiteralPath $script | Out-String
    if ($coreText -notmatch [regex]::Escape($RequiredCoreVersion)) {
        Fail "Core installer is not the expected version. Expected $RequiredCoreVersion. Replace C:\release\Core\Install-NFSU-GVR-GameOnly.ps1 with the updated release copy."
    }

    $args = @(
        "-ExecutionPolicy", "Bypass",
        "-File", $script,
        "-SourceRoot", $WorkRoot,
        "-TargetDrive", $TargetDrive
    )

    if ($DryRun) { $args += "-DryRun" }
    if ($ForceOverwrite) { $args += "-ForceOverwrite" }
    if ($SkipSql) { $args += "-SkipSql" }
    if ($SkipGamePayloadCopy) { $args += "-SkipGamePayload" }
    if ($SkipDirectXCheck) { $args += "-SkipDirectXCheck" }
    if (!$SkipDisc2DatabaseUpdate) { $args += "-RunDisc2DatabaseUpdate" }
    $args += @("-Disc2DatabaseUpdateTimeoutSeconds", $Disc2DatabaseUpdateTimeoutSeconds)
    if (!$SkipLegacyNvidiaCplFiles) { $args += "-InstallLegacyNvidiaCplFiles" }

    Write-Log "Launching core game-only installer"
    $args = @("-NoProfile", "-NonInteractive") + $args
    $p = Start-Process -FilePath "powershell.exe" -ArgumentList $args -Wait -PassThru -NoNewWindow
    if ($p.ExitCode -ne 0) { Fail "Core installer failed with exit code $($p.ExitCode)" }
}

if (!(Test-Admin)) {
    Fail "Run this installer from an elevated Administrator PowerShell window."
}

if (!(Test-Path $CoreInstaller)) {
    Fail "Core installer missing from release package: $CoreInstaller"
}

Write-Log "NFSU GlobalVR AIO game-only installer starting"
Write-Log "AIO version: $AioVersion"
Write-Log "ReleaseRoot: $ReleaseRoot"
Write-Log "TargetDrive: $TargetDrive"

$resumeAfterReboot = Test-ResumeAfterReboot
if ($resumeAfterReboot) {
    Write-Log "Resume marker found and final payload is present. Skipping disc extraction and resuming remaining install steps."
}

if (!$resumeAfterReboot -and [string]::IsNullOrEmpty($ExpandedPayloadRoot)) {
    $preflightExtractor = Find-Extractor
    if (!$preflightExtractor) {
        Fail "No usable InstallShield extractor found. Put unshield.exe or isxunpack.exe in release\Tools before mounting discs, or run with -ExpandedPayloadRoot pointing at a legally extracted OEM payload."
    }
    Assert-DiscModeExtractor $preflightExtractor
    Write-Log "InstallShield extractor found: $preflightExtractor"
}

Stage-ReleasePayload

if (!$resumeAfterReboot) {
    if (![string]::IsNullOrEmpty($ExpandedPayloadRoot)) {
        Copy-ExpandedPayload $ExpandedPayloadRoot
    } else {
        $disc1 = Request-Disc "Disc1" $Disc1Path
        Stage-Disc1 $disc1
        Write-Log "Disc 1 has been staged. You can unmount/eject Disc 1 now."

        $disc2 = Request-Disc "Disc2" $Disc2Path
        Stage-Disc2 $disc2
        Write-Log "Disc 2 has been staged. You can unmount/eject Disc 2 now."

        Expand-OemInstallShieldPayload
    }

    Set-ResumeMarker
}

Invoke-CoreInstaller -SkipGamePayloadCopy:$resumeAfterReboot

Write-Log "AIO install complete."
Clear-ResumeMarker
if ($KeepWorkDir) {
    Write-Log "Keeping staged work folder: $WorkRoot"
} else {
    Write-Log "Removing staged work folder: $WorkRoot"
    Remove-Item -LiteralPath $WorkRoot -Recurse -Force -ErrorAction SilentlyContinue
}

