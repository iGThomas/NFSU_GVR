# ============================================================
# Install-NFSU-GVR-GameOnly.ps1
#
# Installs Need For Speed Underground GlobalVR as a normal game
# payload instead of an arcade cabinet takeover.
#
# This script intentionally does NOT run:
# - original Setup.exe
# - SetupCabinet.wsf
# - Startup/Desktop/Hercules cabinet registry payloads
# - NVIDIA/network/display/taskbar/boot scripts
#
# Run as Administrator.
# ============================================================

param(
    [string]$SourceRoot = "",
    [string]$TargetDrive = "C:",
    [switch]$DryRun,
    [switch]$SkipSql,
    [switch]$SkipSystemDlls,
    [switch]$SkipGamePayload,
    [switch]$NoStartSql,
    [switch]$NoShortcut,
    [switch]$ValidateDiscs,
    [switch]$InitializePlusData,
    [switch]$RunDisc2DatabaseUpdate,
    [switch]$SkipDotNetCheck,
    [switch]$SkipDirectXCheck,
    [switch]$InstallLegacyNvidiaCplFiles,
    [switch]$SkipGvrPlusAssemblyRegistration,
    [switch]$SkipSaPasswordRotation,
    [string]$DirectXRedistPath = "",
    [int]$Disc2DatabaseUpdateTimeoutSeconds = 120,
    [switch]$ForceOverwrite
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrEmpty($SourceRoot)) {
    $SourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$TargetDrive = $TargetDrive.TrimEnd("\")
$LogDir = Join-Path $env:TEMP "NFSU_GVR_Install"
$LogFile = Join-Path $LogDir "install.log"
$InstallerVersion = "2026-07-15-rotate-sa-password"

# The MSDE setup password is what setup.exe SAPWD= installs. The frontend's connection string
# in nfscabinetXml.enc is baked to the final password, so sa must end up on the final one.
$MsdeSetupSaPassword = "q2Z35o"
$GvrFrontendSaPassword = "Q31y2Z29wpEsd"

function New-Dir($Path) {
    if (!(Test-Path $Path)) {
        if ($DryRun) { Log "DRY RUN create directory: $Path"; return }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Log($Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    Add-Content -Path $LogFile -Value $line
}

function Warn($Message) {
    Write-Host "[!] $Message" -ForegroundColor Yellow
    Log "WARN: $Message"
}

function Fail($Message) {
    Write-Host "[X] $Message" -ForegroundColor Red
    Log "ERROR: $Message"
    throw $Message
}

trap {
    try { Log ("FATAL: " + $_.Exception.Message) } catch {}
    exit 1
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-File($Path, $Label) {
    if (!(Test-Path $Path)) { Fail "$Label not found: $Path" }
}

function Copy-Tree($Source, $Destination, $Label) {
    if (!(Test-Path $Source)) { Fail "$Label source not found: $Source" }
    if ((Test-Path $Destination) -and !$ForceOverwrite) {
        Warn "Destination already exists for ${Label}: $Destination"
        Warn "Keeping existing files and repairing only missing files."
        Copy-MissingTree $Source $Destination $Label
        return
    }
    if ($DryRun) {
        Log "DRY RUN would copy $Label"
        Log "  From: $Source"
        Log "  To:   $Destination"
        return
    }
    Log "Copying $Label"
    Log "  From: $Source"
    Log "  To:   $Destination"
    New-Dir $Destination
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function Copy-MissingTree($Source, $Destination, $Label) {
    if (!(Test-Path $Source)) { Fail "$Label source not found: $Source" }
    New-Dir $Destination

    $copied = 0
    $dirs = Get-ChildItem -LiteralPath $Source -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.PSIsContainer }
    foreach ($dir in $dirs) {
        $relative = $dir.FullName.Substring((Get-Item -LiteralPath $Source).FullName.Length).TrimStart("\")
        if ($relative.Length -eq 0) { continue }
        New-Dir (Join-Path $Destination $relative)
    }

    $files = Get-ChildItem -LiteralPath $Source -Recurse -ErrorAction SilentlyContinue |
        Where-Object { !$_.PSIsContainer }
    foreach ($file in $files) {
        $relative = $file.FullName.Substring((Get-Item -LiteralPath $Source).FullName.Length).TrimStart("\")
        $dst = Join-Path $Destination $relative
        if (Test-Path $dst) { continue }

        if ($DryRun) {
            Log "DRY RUN would repair missing $Label file: $file -> $dst"
        } else {
            New-Dir (Split-Path -Parent $dst)
            Copy-Item -LiteralPath $file.FullName -Destination $dst -Force
        }
        $copied += 1
    }

    if ($copied -gt 0) {
        Log "Repaired $copied missing $Label file(s)."
    } else {
        Log "No missing $Label files found."
    }
}

function Copy-FileIfPresent($Source, $DestinationDir) {
    if (!(Test-Path $Source)) {
        Warn "Optional file not found: $Source"
        return
    }
    New-Dir $DestinationDir
    $dst = Join-Path $DestinationDir (Split-Path $Source -Leaf)
    if ((Test-Path $dst) -and !$ForceOverwrite) {
        Warn "Skipping existing file: $dst"
        return
    }
    if ($DryRun) {
        Log "DRY RUN would copy file: $Source -> $dst"
        return
    }
    Log "Copying file: $Source -> $dst"
    try {
        Copy-Item -LiteralPath $Source -Destination $dst -Force -ErrorAction Stop
    } catch {
        Warn "Could not copy optional file to $dst"
        Warn "Reason: $($_.Exception.Message)"
        if (Test-Path $dst) {
            Warn "Keeping existing file in place and continuing."
        }
    }
}

function Copy-LatestSystemFileIfPresent($Pattern, $DestinationDir, $Label) {
    $matches = Get-ChildItem -Path $env:WINDIR -Filter $Pattern -Recurse -ErrorAction SilentlyContinue |
        Where-Object { !$_.PSIsContainer } |
        Sort-Object LastWriteTime -Descending

    $source = $matches | Select-Object -First 1
    if (!$source) {
        Warn "Optional system file not found on this Windows install: $Label ($Pattern)"
        return
    }

    Copy-FileIfPresent $source.FullName $DestinationDir
}

function Copy-NvidiaFileIfMissing($Source, $DestinationDir) {
    if (!(Test-Path $Source)) {
        Warn "Optional NVIDIA file not found: $Source"
        return
    }

    New-Dir $DestinationDir
    $dst = Join-Path $DestinationDir (Split-Path $Source -Leaf)
    if (Test-Path $dst) {
        Log "Keeping existing NVIDIA file: $dst"
        return
    }

    if ($DryRun) {
        Log "DRY RUN would add missing NVIDIA file: $Source -> $dst"
        return
    }

    Log "Adding missing NVIDIA file: $Source -> $dst"
    try {
        Copy-Item -LiteralPath $Source -Destination $dst -ErrorAction Stop
    } catch {
        Warn "Could not add missing NVIDIA file to $dst"
        Warn "Reason: $($_.Exception.Message)"
    }
}

function Import-RegFile($Path, $Label) {
    if ($DryRun) {
        Log "DRY RUN would import registry: $Label"
        Log "  Path: $Path"
        return
    }
    Assert-File $Path $Label
    Log "Importing registry: $Label"
    & reg import "$Path" | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "Registry import failed: $Path" }
}

function Extract-RegistrySections($InputReg, $OutputReg, $Prefixes) {
    Assert-File $InputReg "Registry export"
    Log "Creating filtered registry file: $OutputReg"

    $lines = Get-Content -LiteralPath $InputReg
    $out = New-Object System.Collections.ArrayList
    [void]$out.Add("Windows Registry Editor Version 5.00")
    [void]$out.Add("")

    $include = $false
    foreach ($line in $lines) {
        if ($line -match '^\[(.+)\]$') {
            $key = $matches[1]
            $include = $false
            foreach ($prefix in $Prefixes) {
                if ($key.ToLower().StartsWith($prefix.ToLower())) {
                    $include = $true
                    break
                }
            }
            if ($include) {
                [void]$out.Add("")
                [void]$out.Add($line)
            }
            continue
        }

        if ($include) { [void]$out.Add($line) }
    }

    if ($DryRun) {
        Log "DRY RUN would write filtered registry file with $($out.Count) lines"
        return
    }

    $encoding = New-Object System.Text.UnicodeEncoding($false, $true)
    [System.IO.File]::WriteAllLines($OutputReg, [string[]]$out, $encoding)
}

function Write-MinimalGameRegistry($Path) {
    if ($DryRun) {
        Log "DRY RUN would create minimal NFS/GVR registry file: $Path"
    } else {
        Log "Creating minimal NFS/GVR registry file: $Path"
    }
    $content = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\GlobalVR]
"PQI Version"="PGA 2.0.0"

[HKEY_LOCAL_MACHINE\SOFTWARE\GlobalVR\Need For Speed UnderGround]
"Version"="1.1.0"
"Build"="027"
"Prefix"=""
"Suffix"=""

[HKEY_LOCAL_MACHINE\SOFTWARE\GVRShell]

[HKEY_LOCAL_MACHINE\SOFTWARE\GVRShell\Operator]

[HKEY_LOCAL_MACHINE\SOFTWARE\GVRShell\Operator\Games]

[HKEY_LOCAL_MACHINE\SOFTWARE\GVRShell\Operator\Games\NFSUNDERGROUND]
"Ini"="C:\\Underground\\NFSUnderground.ini"

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\GlobalVR]
"PQI Version"="PGA 2.0.0"

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\GlobalVR\Need For Speed UnderGround]
"Version"="1.1.0"
"Build"="027"
"Prefix"=""
"Suffix"=""

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\GVRShell]

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\GVRShell\Operator]

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\GVRShell\Operator\Games]

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\GVRShell\Operator\Games\NFSUNDERGROUND]
"Ini"="C:\\Underground\\NFSUnderground.ini"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\Plus\1.1\Server]
"PlusSchemaPath"="C:\\GvrPlus\\1\\schema\\nfsserverXml.enc"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\Plus\1.1\Cabinet]
"PatchMaxDownloadRetry"="9"
"GvrEventLogRemovalThreshold"="30"
"PublicKeyPath"="C:\\GvrPlus\\1\\key\\publickey.xml"
"WebServerIP"="66.107.15.47"
"PatchDownloadPath"="C:\\PatchService\\"
"PlusSchemaPath"="C:\\GvrPlus\\1\\schema\\nfscabinetXml.enc"
"SyncRetryInterval"="15"
"PlayerCardRequestThreshold"="20"
"MaxObjectLoadCount"="30"
"LeaderboardWaitTime"="20000"
"PatchMaxExecutionRetry"="1"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\Boot]
"BootValue"=dword:00000002

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\Dongle]
"Inserted"=dword:00000000
"GameName"="NFSUNDERGROUND"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRBoot]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCacheWarmer]
"NumResources"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCoinMonitor]
"CoinMeterMask1"=dword:00000000
"CoinMeterMask2"=dword:00000004

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCoinMonitor\Nytric]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCoinMonitor\Nytric\Board0]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCoinMonitor\Nytric\Board0\OnBoard1]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor]
"NumApps"=dword:00000005
"SleepDelay"=dword:00000064

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog00]
"cmdargs"=""
"delay"=dword:0000ea60
"enabled"=dword:00000003
"path"="c:\\gvrroot"
"program"="GVRDongleMonitor.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog01]
"cmdargs"=" "
"delay"=dword:0000ea60
"enabled"=dword:00000001
"path"="c:\\gvrroot"
"program"="GVRCoinMonitor.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog02]
"cmdargs"=""
"delay"=dword:00000064
"enabled"=dword:00000001
"path"="c:\\gvrroot"
"program"="GVRStallMonitor.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog03]
"cmdargs"=""
"delay"=dword:00000064
"enabled"=dword:00000000
"path"="c:\\gvrroot"
"program"="GVRCacheWarmer.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRCrashMonitor\Prog04]
"cmdargs"="-nosnapshot"
"delay"=dword:0000ea60
"enabled"=dword:00000001
"path"="c:\\gvrroot"
"program"="Univershell2.exe"

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRDongleMonitor]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\GVRStallMonitor]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\UNDERGROUNDGVR]

[HKEY_LOCAL_MACHINE\SOFTWARE\Gvr\hercules\UniverShell2]
"Restart_Flags"="0"
"Restart_Idle"="300000"
"Restart_Reset"="82800000"
"Restart_Timeout"="86400000"
"RestartEnable"="1"

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Gvr\Plus\1.1\Server]
"PlusSchemaPath"="C:\\GvrPlus\\1\\schema\\nfsserverXml.enc"

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Gvr\Plus\1.1\Cabinet]
"PatchMaxDownloadRetry"="9"
"GvrEventLogRemovalThreshold"="30"
"PublicKeyPath"="C:\\GvrPlus\\1\\key\\publickey.xml"
"WebServerIP"="66.107.15.47"
"PatchDownloadPath"="C:\\PatchService\\"
"PlusSchemaPath"="C:\\GvrPlus\\1\\schema\\nfscabinetXml.enc"
"SyncRetryInterval"="15"
"PlayerCardRequestThreshold"="20"
"MaxObjectLoadCount"="30"
"LeaderboardWaitTime"="20000"
"PatchMaxExecutionRetry"="1"

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment]
"RUNTIMEOEMREV"="NFS - UG,XP Embedded,HW Rev 865 e,05052005"
"RUNTIMEGUID"="{657AA858-5ACA-4F13-9855-E645192C4A8F}"
"RUNTIMEPID"="Q79DV-JVH86-MGXYC-67TQJ-Q2M2J"
"RUNTIMESKUCODE"="XPeCli"
"DEVICEMODEL"="{00000000-0000-0000-0000-000000000000}"
"DEVICEROLE"="0"
"WEBUILDDATE"="4/29/2005 4:00:03 AM"

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Application\GVR]

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\HardwareEvents\GVR]

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Internet Explorer\GVR]

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Key Management Service\GVR]

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Media Center\GVR]
"@

    if ($DryRun) { return }
    $encoding = New-Object System.Text.UnicodeEncoding($false, $true)
    [System.IO.File]::WriteAllText($Path, $content, $encoding)
}

function Register-Component($Path) {
    if ($DryRun) {
        Log "DRY RUN would register component: $Path"
        return
    }
    if (!(Test-Path $Path)) {
        Warn "Component not found for registration: $Path"
        return
    }
    Log "Registering component: $Path"
    & regsvr32.exe /s "$Path"
    if ($LASTEXITCODE -ne 0) {
        Warn "regsvr32 failed or component is not COM: $Path"
    }
}

function Register-SqlComponents {
    Register-Component (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\80\Tools\Binn\SQLDMO.dll")
    Register-Component (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\Binn\SSmsSH70.dll")
    Register-Component (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\Binn\SSnetlib.dll")
}

function Write-SqlXmlAssemblyFolderRegistry {
    $regPath = Join-Path $LogDir "nfsu_sqlxml_assemblyfolder.reg"
    if ($DryRun) {
        Log "DRY RUN would create SQLXML .NET assembly folder registry file: $regPath"
    } else {
        Log "Creating SQLXML .NET assembly folder registry file: $regPath"
    }

    $content = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\SQLXML 3.0]
@="c:\\Program Files\\SQLXML 3.0\\bin\\"

"@

    if ($DryRun) { return }
    $encoding = New-Object System.Text.UnicodeEncoding($false, $true)
    [System.IO.File]::WriteAllText($regPath, $content, $encoding)
    Import-RegFile $regPath "SQLXML .NET assembly folder registry"
}

function Test-ManagedDirectXInstalled {
    $direct3dGac = Join-Path $env:WINDIR "assembly\GAC\Microsoft.DirectX.Direct3D"
    $directXGac = Join-Path $env:WINDIR "assembly\GAC\Microsoft.DirectX"
    $d3dx9 = Join-Path $env:WINDIR "System32\d3dx9_43.dll"
    return ((Test-Path $direct3dGac) -and (Test-Path $directXGac) -and (Test-Path $d3dx9))
}

function Install-DirectXOptionalRuntime {
    if ($SkipDirectXCheck) {
        Warn "Skipping legacy DirectX optional runtime check because -SkipDirectXCheck was used"
        return
    }

    if (Test-ManagedDirectXInstalled) {
        Log "Legacy DirectX optional runtime appears installed (Managed DirectX and D3DX present)."
        return
    }

    $setupCandidates = @()
    if (![string]::IsNullOrEmpty($DirectXRedistPath)) {
        if (Test-Path $DirectXRedistPath -PathType Container) {
            $setupCandidates += (Join-Path $DirectXRedistPath "DXSETUP.exe")
        } elseif ((Split-Path $DirectXRedistPath -Leaf).ToLower() -eq "dxsetup.exe") {
            $setupCandidates += $DirectXRedistPath
        } else {
            $directXParent = Split-Path -Parent $DirectXRedistPath
            if ([string]::IsNullOrEmpty($directXParent)) { $directXParent = "." }
            $setupCandidates += (Join-Path $directXParent "DXSETUP.exe")
        }
    }
    $setupCandidates += (Join-Path $SourceRoot "Dependencies\DirectX\DXSETUP.exe")
    $setupCandidates += (Join-Path $SourceRoot "Dependencies\DirectX\Jun2010Extracted\DXSETUP.exe")
    $setupCandidates += (Join-Path $SourceRoot "Dependencies\DirectX\Extracted\DXSETUP.exe")
    $setupCandidates += (Join-Path $SourceRoot "Dependencies\DXSETUP.exe")
    $setupCandidates += (Join-Path $SourceRoot "DXSETUP.exe")

    $dxSetup = $null
    foreach ($candidate in $setupCandidates) {
        if (Test-Path $candidate) {
            $dxSetup = $candidate
            break
        }
    }

    $redistCandidates = @()
    if (![string]::IsNullOrEmpty($DirectXRedistPath)) { $redistCandidates += $DirectXRedistPath }
    $redistCandidates += (Join-Path $SourceRoot "Dependencies\DirectX\directx_Jun2010_redist.exe")
    $redistCandidates += (Join-Path $SourceRoot "Dependencies\directx_Jun2010_redist.exe")
    $redistCandidates += (Join-Path $SourceRoot "directx_Jun2010_redist.exe")

    $redist = $null
    foreach ($candidate in $redistCandidates) {
        if (Test-Path $candidate) {
            $redist = $candidate
            break
        }
    }

    if (!$dxSetup -and !$redist) {
        Warn "Legacy DirectX optional runtime is missing. PCMover-success VM has Managed DirectX 1.1 and D3DX side-by-side files."
        Warn "Download Microsoft's DirectX End-User Runtimes (June 2010), extract it, and place DXSETUP.exe plus its CAB files in Dependencies\DirectX\Jun2010Extracted."
        return
    }

    if (!$dxSetup) {
        Warn "Found the DirectX June 2010 self-extracting redist, but DXSETUP.exe was not found yet: $redist"
        Warn "Extract directx_Jun2010_redist.exe manually into Dependencies\DirectX\Jun2010Extracted, then rerun this installer."
        Warn "This script will not wait on the self-extractor because it can hang on Win7 test systems."
        return
    }

    if ($DryRun) {
        Log "DRY RUN would run DXSETUP.exe /silent from: $dxSetup"
        return
    }

    Log "Installing Microsoft DirectX optional runtime side-by-side components"
    $p = Start-Process -FilePath $dxSetup -ArgumentList "/silent" -Wait -PassThru
    if ($p.ExitCode -ne 0) {
        Warn "DXSETUP.exe returned exit code $($p.ExitCode)"
    } elseif (Test-ManagedDirectXInstalled) {
        Log "Legacy DirectX optional runtime installed successfully."
    } else {
        Warn "DXSETUP.exe completed, but Managed DirectX/D3DX check still did not pass."
    }
}

function Register-GvrPlusAssemblies {
    if ($SkipGvrPlusAssemblyRegistration) {
        Warn "Skipping GvrPlus .NET assembly registration because -SkipGvrPlusAssemblyRegistration was used"
        return
    }

    $libDir = Join-Path $TargetDrive "GvrPlus\1\lib"
    $regDllsDir = Join-Path $TargetDrive "GvrPlus\1\scripts\RegDlls"
    $regAsm = Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\RegAsm.exe"
    $gacUtil = Join-Path $regDllsDir "gacutil.exe"

    $assemblies = @(
        (Join-Path $libDir "GvrPeUtil.dll"),
        (Join-Path $libDir "GvrPeSchemaUtil.dll"),
        (Join-Path $libDir "GvrPeClient.dll"),
        (Join-Path $libDir "GvrPeEngine.dll"),
        (Join-Path $libDir "GvrPeDialer.dll")
    )

    foreach ($assembly in $assemblies) {
        Assert-File $assembly "GvrPlus assembly"
    }
    Assert-File $regAsm ".NET 1.1 RegAsm"
    Assert-File $gacUtil "GvrPlus gacutil"

    foreach ($assembly in $assemblies) {
        if ($DryRun) {
            Log "DRY RUN would register GvrPlus assembly with RegAsm: $assembly"
            Log "DRY RUN would install GvrPlus assembly into GAC: $assembly"
            continue
        }

        Log "Registering GvrPlus assembly with RegAsm: $assembly"
        & "$regAsm" "$assembly" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Warn "RegAsm returned exit code $LASTEXITCODE for $assembly"
        }

        Log "Installing GvrPlus assembly into GAC: $assembly"
        & "$gacUtil" "-i" "$assembly" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Warn "gacutil returned exit code $LASTEXITCODE for $assembly"
        }
    }
}

function Start-SqlService {
    if ($DryRun) {
        Log "DRY RUN would start MSSQLSERVER"
        return
    }

    $svc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
    if (!$svc) {
        $sqlServerExe = Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\Binn\sqlservr.exe"
        if (!(Test-Path $sqlServerExe)) {
            Fail "MSSQLSERVER service was not found after registry import, and sqlservr.exe is missing: $sqlServerExe"
        }

        Warn "MSSQLSERVER service was not visible after registry import. Creating service entry."
        $binPath = '"' + $sqlServerExe + '" -sMSSQLSERVER'

        try {
            New-Service -Name "MSSQLSERVER" -BinaryPathName $binPath -DisplayName "MSSQLSERVER" -StartupType Automatic -ErrorAction Stop | Out-Null
        } catch {
            Warn "New-Service failed: $($_.Exception.Message)"
            Warn "Trying sc.exe fallback."
            & sc.exe create MSSQLSERVER "binPath= $binPath" "start= auto" "obj= LocalSystem" "DisplayName= MSSQLSERVER" | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Fail "Could not create MSSQLSERVER service. sc.exe exit code: $LASTEXITCODE"
            }
        }

        Start-Sleep -Seconds 2
        $svc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
        if (!$svc) {
            Fail "MSSQLSERVER service was created but is still not visible. Reboot Windows, then rerun the installer."
        }
    }

    if ($svc.Status -ne "Running") {
        Log "Starting MSSQLSERVER"
        if (!$DryRun) {
            Start-Service -Name "MSSQLSERVER"
            Start-Sleep -Seconds 5
            $svc.Refresh()
        }
    }

    if (!$DryRun -and $svc.Status -ne "Running") {
        Fail "MSSQLSERVER did not start. Current status: $($svc.Status)"
    }
    Log "MSSQLSERVER status: $($svc.Status)"
}

function Restart-SqlServiceForDisc2Update {
    if ($DryRun) {
        Log "DRY RUN would restart MSSQLSERVER before Disc 2 database update"
        return
    }

    if ($NoStartSql) {
        Warn "Skipping MSSQLSERVER restart before Disc 2 database update because -NoStartSql was used."
        return
    }

    $svc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
    if (!$svc) {
        Fail "MSSQLSERVER service was not found before Disc 2 database update."
    }

    Log "Restarting MSSQLSERVER before Disc 2 database update"
    try {
        Restart-Service -Name "MSSQLSERVER" -Force -ErrorAction Stop
        Start-Sleep -Seconds 8
        $svc.Refresh()
    } catch {
        Fail "Could not restart MSSQLSERVER before Disc 2 database update: $($_.Exception.Message)"
    }

    if ($svc.Status -ne "Running") {
        Fail "MSSQLSERVER did not return to Running after restart. Current status: $($svc.Status)"
    }

    Log "MSSQLSERVER status after restart: $($svc.Status)"
}

function Write-CommandDiagnostics($Label, $FilePath, $Arguments) {
    if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    $safeLabel = ($Label -replace '[^A-Za-z0-9_.-]', '_')
    $outFile = Join-Path $LogDir ("diag_" + $safeLabel + ".out.log")
    $errFile = Join-Path $LogDir ("diag_" + $safeLabel + ".err.log")

    Log "Diagnostic command: $FilePath $Arguments"
    try {
        $p = Start-Process -FilePath $FilePath -ArgumentList $Arguments -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outFile -RedirectStandardError $errFile
        Log "Diagnostic command exit code: $($p.ExitCode)"
        if (Test-Path $outFile) {
            foreach ($line in (Get-Content -LiteralPath $outFile -ErrorAction SilentlyContinue)) {
                if ($line.Trim()) { Log "  $line" }
            }
        }
        if (Test-Path $errFile) {
            foreach ($line in (Get-Content -LiteralPath $errFile -ErrorAction SilentlyContinue)) {
                if ($line.Trim()) { Log "  STDERR: $line" }
            }
        }
    } catch {
        Warn "Diagnostic command failed: $Label"
        Warn "Reason: $($_.Exception.Message)"
    }
}

function Write-SqlDiagnostics {
    if ($DryRun) {
        Log "DRY RUN would collect SQL/MSDE diagnostics"
        return
    }

    Warn "Collecting SQL/MSDE diagnostics because local SQL is not connectable."

    $svc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
    if ($svc) {
        Log "MSSQLSERVER service status: $($svc.Status)"
    } else {
        Warn "MSSQLSERVER service is not visible to Get-Service."
    }

    Write-CommandDiagnostics "sc_qc_MSSQLSERVER" "sc.exe" "qc MSSQLSERVER"
    Write-CommandDiagnostics "sc_queryex_MSSQLSERVER" "sc.exe" "queryex MSSQLSERVER"
    Write-CommandDiagnostics "reg_services_MSSQLSERVER" "reg.exe" "query HKLM\SYSTEM\CurrentControlSet\Services\MSSQLSERVER /s"
    Write-CommandDiagnostics "reg_mssqlserver_software" "reg.exe" "query HKLM\SOFTWARE\Microsoft\MSSQLServer /s"

    $paths = @(
        (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\Binn\sqlservr.exe"),
        (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\Data\master.mdf"),
        (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\Data\mastlog.ldf"),
        (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\LOG\ERRORLOG"),
        (Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\Install\errorlog")
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            $item = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
            if ($item) {
                Log "SQL diagnostic path exists: $path ($($item.Length) bytes, modified $($item.LastWriteTime))"
            } else {
                Log "SQL diagnostic path exists: $path"
            }
        } else {
            Warn "SQL diagnostic path missing: $path"
        }
    }

    $errorLog = Join-Path $TargetDrive "Program Files\Microsoft SQL Server\MSSQL\LOG\ERRORLOG"
    if (Test-Path $errorLog) {
        Log "Last SQL ERRORLOG lines:"
        $lines = Get-Content -LiteralPath $errorLog -ErrorAction SilentlyContinue | Select-Object -Last 80
        foreach ($line in $lines) {
            if ($line.Trim()) { Log "  $line" }
        }
    }
}

function Get-SqlServerNames {
    $names = @()
    if ($env:COMPUTERNAME) { $names += $env:COMPUTERNAME }
    $names += "."
    $names += "(local)"
    $names += "localhost"

    $unique = @()
    foreach ($name in $names) {
        if ($name -and ($unique -notcontains $name)) { $unique += $name }
    }
    return $unique
}

function Get-SqlServerEndpoints {
    $endpoints = @()
    foreach ($serverName in (Get-SqlServerNames)) {
        $endpoints += $serverName
        $endpoints += ("lpc:" + $serverName)
        $endpoints += ("np:\\" + $serverName + "\pipe\sql\query")
    }
    $endpoints += "np:\\.\pipe\sql\query"
    foreach ($serverName in (Get-SqlServerNames)) {
        $endpoints += ("tcp:" + $serverName + ",1433")
    }

    $unique = @()
    foreach ($endpoint in $endpoints) {
        if ($endpoint -and ($unique -notcontains $endpoint)) { $unique += $endpoint }
    }
    return $unique
}

function Get-SqlAuthAttempts($Query) {
    $attempts = @()
    foreach ($serverName in (Get-SqlServerEndpoints)) {
        $attempts += @{
            Args = @("-E", "-S", $serverName, "-Q", $Query)
            Label = "integrated auth on $serverName"
        }
        $attempts += @{
            Args = @("-U", "sa", "-P", $GvrFrontendSaPassword, "-S", $serverName, "-Q", $Query)
            Label = "sa / final GlobalVR password on $serverName"
        }
        $attempts += @{
            Args = @("-U", "sa", "-P", $MsdeSetupSaPassword, "-S", $serverName, "-Q", $Query)
            Label = "sa / default MSDE setup password on $serverName"
        }
    }
    return $attempts
}

function Get-SqlInputFileAuthAttempts($InputFile) {
    $attempts = @()
    foreach ($serverName in (Get-SqlServerEndpoints)) {
        $attempts += @{
            Args = @("-E", "-S", $serverName, "-i", $InputFile)
            Label = "integrated auth on $serverName"
        }
        $attempts += @{
            Args = @("-U", "sa", "-P", $GvrFrontendSaPassword, "-S", $serverName, "-i", $InputFile)
            Label = "sa / final GlobalVR password on $serverName"
        }
        $attempts += @{
            Args = @("-U", "sa", "-P", $MsdeSetupSaPassword, "-S", $serverName, "-i", $InputFile)
            Label = "sa / default MSDE setup password on $serverName"
        }
    }
    return $attempts
}

function Invoke-OsqlInputFile($InputFile, $Label) {
    foreach ($attempt in (Get-SqlInputFileAuthAttempts $InputFile)) {
        Log "Running $Label using $($attempt["Label"])"
        $result = Invoke-OsqlProcess $attempt["Args"] ($Label + " " + $attempt["Label"]) 600
        if (Test-OsqlResultSuccess $result) {
            Log "$Label succeeded using $($attempt["Label"])."
            return $true
        }

        $firstLine = @($result.Output -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
        if ($firstLine.Count -gt 0) {
            Log "$Label failed using $($attempt["Label"]) (exit $($result.ExitCode)): $($firstLine[0].Trim())"
        } else {
            Log "$Label failed using $($attempt["Label"]) (exit $($result.ExitCode))."
        }
    }

    return $false
}

function Test-OsqlResultSuccess($Result, $RequiredPattern = "") {
    if (!$Result) { return $false }

    $output = [string]$Result.Output
    $failurePattern = '(?im)(Login failed|SQL Server does not exist|access denied|ConnectionOpen|OS Error|Msg\s+\d+|timed out|argument list was empty|OSQL not found)'
    if ($output -match $failurePattern) { return $false }

    if ($Result.ExitCode -eq 0) { return $true }

    if (![string]::IsNullOrEmpty($RequiredPattern)) {
        return ($output -match $RequiredPattern)
    }

    return ($output -match '(?im)(^\s*\d+\s*$|\(\d+\s+rows?\s+affected\)|Changed database context|Microsoft SQL Server)')
}

function Repair-SqlNetworkRegistry {
    if ($DryRun) {
        Log "DRY RUN would repair SQL 2000 network protocol registry"
        return
    }

    Warn "Repairing SQL 2000 local network protocol registry."

    $client = "HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client"
    $clientNet = "HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\SuperSocketNetLib"
    $server = "HKLM:\SOFTWARE\Microsoft\MSSQLServer\MSSQLServer"
    $serverNet = "HKLM:\SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib"
    $serverNp = Join-Path $serverNet "Np"
    $serverTcp = Join-Path $serverNet "Tcp"

    foreach ($key in @($client, $clientNet, $server, $serverNet, $serverNp, $serverTcp)) {
        if (!(Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    }

    New-ItemProperty -Path $client -Name "SharedMemoryOn" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $clientNet -Name "ProtocolOrder" -Value @("sm", "np", "tcp") -PropertyType MultiString -Force | Out-Null
    New-ItemProperty -Path $server -Name "ListenOn" -Value @("SSMSSH70", "SSNETLIB") -PropertyType MultiString -Force | Out-Null
    New-ItemProperty -Path $serverNet -Name "ProtocolList" -Value @("SSMSSH70", "SSNETLIB") -PropertyType MultiString -Force | Out-Null
    New-ItemProperty -Path $serverNp -Name "PipeName" -Value "\\.\pipe\sql\query" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $serverTcp -Name "TcpPort" -Value "1433" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $serverTcp -Name "TcpDynamicPorts" -Value "0" -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $serverTcp -Name "TcpHideFlag" -Value 0 -PropertyType DWord -Force | Out-Null
}

function Test-SqlWithOsql {
    $osql = Join-Path $TargetDrive "Program Files\Microsoft SQL Server\80\Tools\Binn\OSQL.EXE"
    if (!(Test-Path $osql)) {
        Warn "OSQL not found, skipping SQL query test"
        return
    }
    if ($DryRun) {
        Log "DRY RUN would test local SQL connection with OSQL"
        return
    }
    Log "Testing local SQL connection with OSQL"
    foreach ($attempt in (Get-SqlAuthAttempts "select @@version")) {
        $result = Invoke-OsqlProcess $attempt["Args"] $attempt["Label"]
        ($result.Output | Out-String) | ForEach-Object { Log $_.TrimEnd() }
        if (Test-OsqlResultSuccess $result "Microsoft SQL Server") {
            Log "OSQL test succeeded using $($attempt["Label"])."
            return $true
        }
        Log "OSQL test failed using $($attempt["Label"])."
    }

    Warn "OSQL tests failed. SQL may still be running but not accepting this auth/protocol."
    Write-SqlDiagnostics
    return $false
}

function Invoke-OsqlProcess($OsqlArguments, $Label, $TimeoutSeconds = 0) {
    $osql = Join-Path $TargetDrive "Program Files\Microsoft SQL Server\80\Tools\Binn\OSQL.EXE"
    if (!(Test-Path $osql)) {
        return @{
            ExitCode = 9009
            Output = "OSQL not found: $osql"
            Label = $Label
        }
    }

    if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    $safeLabel = ($Label -replace '[^A-Za-z0-9_.-]', '_')
    $stamp = Get-Date -Format "yyyyMMddHHmmssfff"
    $outFile = Join-Path $LogDir ("osql_" + $safeLabel + "_" + $stamp + ".out.log")
    $errFile = Join-Path $LogDir ("osql_" + $safeLabel + "_" + $stamp + ".err.log")

    $cleanArgs = @($OsqlArguments | Where-Object { $_ -ne $null -and $_.ToString().Length -gt 0 } | ForEach-Object { $_.ToString() })
    if ($cleanArgs.Count -eq 0) {
        return @{
            ExitCode = 9008
            Output = "OSQL argument list was empty for $Label"
            Label = $Label
        }
    }

    $quotedArgs = @()
    foreach ($arg in $cleanArgs) {
        if ($arg -match '[\s"]') {
            $quotedArgs += '"' + ($arg -replace '"', '\"') + '"'
        } else {
            $quotedArgs += $arg
        }
    }
    $argumentLine = $quotedArgs -join " "

    $p = Start-Process -FilePath $osql -ArgumentList $argumentLine -PassThru -NoNewWindow -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    if ($TimeoutSeconds -and $TimeoutSeconds -gt 0) {
        $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
        while (!$p.HasExited -and ((Get-Date) -lt $deadline)) {
            Start-Sleep -Seconds 10
            if (!$p.HasExited) {
                $remaining = [int][Math]::Max(0, ($deadline - (Get-Date)).TotalSeconds)
                Log "OSQL still running for $Label; $remaining second(s) before timeout."
            }
        }

        if (!$p.HasExited) {
            try {
                $p.Kill()
            } catch {
                Warn "Could not stop hung OSQL process for $Label`: $($_.Exception.Message)"
            }
            $text = ""
            if (Test-Path $outFile) { $text += (Get-Content -Path $outFile -ErrorAction SilentlyContinue | Out-String) }
            if (Test-Path $errFile) { $text += (Get-Content -Path $errFile -ErrorAction SilentlyContinue | Out-String) }
            return @{
                ExitCode = 9010
                Output = "OSQL timed out after $TimeoutSeconds seconds for $Label.`r`n$text"
                Label = $Label
            }
        }
    } else {
        $p.WaitForExit()
    }

    $text = ""
    if (Test-Path $outFile) { $text += (Get-Content -Path $outFile -ErrorAction SilentlyContinue | Out-String) }
    if (Test-Path $errFile) { $text += (Get-Content -Path $errFile -ErrorAction SilentlyContinue | Out-String) }

    return @{
        ExitCode = $p.ExitCode
        Output = $text
        Label = $Label
    }
}

function Test-SqlConnectable {
    $attempts = Get-SqlAuthAttempts "select @@version"

    foreach ($attempt in $attempts) {
        $result = Invoke-OsqlProcess $attempt["Args"] $attempt["Label"]
        if (Test-OsqlResultSuccess $result "Microsoft SQL Server") {
            Log "SQL connection succeeded using $($attempt["Label"])."
            return $true
        }

        $firstLine = @($result.Output -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
        if ($firstLine.Count -gt 0) {
            Log "SQL connection check failed using $($attempt["Label"]) (exit $($result.ExitCode)): $($firstLine[0].Trim())"
        } else {
            Log "SQL connection check failed using $($attempt["Label"]) (exit $($result.ExitCode))."
        }
    }

    return $false
}

function Invoke-OsqlText($Query) {
    $osql = Join-Path $TargetDrive "Program Files\Microsoft SQL Server\80\Tools\Binn\OSQL.EXE"
    if (!(Test-Path $osql)) { return $null }

    if ($DryRun) {
        Log "DRY RUN would query SQL: $Query"
        return $null
    }

    $attempts = Get-SqlAuthAttempts $Query

    foreach ($attempt in $attempts) {
        $result = Invoke-OsqlProcess $attempt["Args"] $attempt["Label"]
        $exitCode = $result.ExitCode
        $outputText = $result.Output
        if (Test-OsqlResultSuccess $result) {
            return @{
                Label = $attempt.Label
                Output = $outputText
            }
        }
        $firstLine = @($outputText -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
        if ($firstLine.Count -gt 0) {
            Log "SQL query failed using $($attempt.Label) (exit $exitCode): $($firstLine[0].Trim())"
        } else {
            Log "SQL query failed using $($attempt.Label) (exit $exitCode)."
        }
    }

    return $null
}

function Get-OsqlFirstInteger($Text) {
    foreach ($line in ([string]$Text -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^\d+$') {
            return [int]$trimmed
        }
    }

    return $null
}

function Invoke-OsqlScalarInt($Query, $Label) {
    $result = Invoke-OsqlText $Query
    if (!$result) {
        Warn "Could not query SQL for $Label."
        return $null
    }

    $value = Get-OsqlFirstInteger $result.Output
    if ($value -eq $null) {
        Warn "SQL query for $Label did not return a parseable integer."
        return $null
    }

    return $value
}

function Get-SqlDatabaseInfo {
    $result = Invoke-OsqlText "select name from master.dbo.sysdatabases order by name"
    if (!$result) { return $null }

    $dbs = @()
    foreach ($line in ($result.Output -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -and
            $trimmed -notmatch '^\(\d+ rows affected\)$' -and
            $trimmed -notmatch '^name$' -and
            $trimmed -notmatch '^-+$') {
            $dbs += $trimmed
        }
    }

    $defaultDbs = @("master", "model", "msdb", "tempdb")
    $extraDbs = @($dbs | Where-Object { $defaultDbs -notcontains $_ })

    return @{
        Label = $result.Label
        Databases = $dbs
        ExtraDatabases = $extraDbs
    }
}

function Test-NfscabinetDatabaseConfigured([switch]$Quiet) {
    if ($DryRun) {
        if (!$Quiet) { Log "DRY RUN would validate nfscabinet database content" }
        return $false
    }

    $exists = Invoke-OsqlScalarInt "set nocount on select count(*) from master.dbo.sysdatabases where name='nfscabinet'" "nfscabinet database existence"
    if ($exists -ne 1) {
        if (!$Quiet) { Warn "nfscabinet database is missing." }
        return $false
    }

    $tableCount = Invoke-OsqlScalarInt "set nocount on select count(*) from nfscabinet.dbo.sysobjects where xtype='U'" "nfscabinet user table count"
    $gameCount = Invoke-OsqlScalarInt "set nocount on select count(*) from nfscabinet.dbo.GvrGame" "nfscabinet GvrGame row count"
    $nfsGameCount = Invoke-OsqlScalarInt "set nocount on select count(*) from nfscabinet.dbo.GvrGame where GameCode='NFSUG001'" "nfscabinet NFS Underground game row"
    $pricingTypeCount = Invoke-OsqlScalarInt "set nocount on select count(*) from nfscabinet.dbo.PricingTypeLookup" "nfscabinet pricing lookup row count"

    if (!$Quiet) {
        Log "nfscabinet validation: tables=$tableCount, GvrGame rows=$gameCount, NFSUG001 rows=$nfsGameCount, PricingTypeLookup rows=$pricingTypeCount"
    }

    if (($tableCount -ge 80) -and ($gameCount -ge 4) -and ($nfsGameCount -ge 1) -and ($pricingTypeCount -ge 5)) {
        if (!$Quiet) { Log "nfscabinet database appears configured for NFS Underground." }
        return $true
    }

    if (!$Quiet) { Warn "nfscabinet database exists but does not appear fully populated/configured." }
    return $false
}

function Test-SqlDatabaseState {
    if ($DryRun) {
        Log "DRY RUN would classify SQL database state"
        return
    }

    $svc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
    if (!$svc) {
        Warn "MSSQLSERVER service not found; cannot classify database state yet."
        return
    }

    if ($svc.Status -ne "Running") {
        Warn "MSSQLSERVER exists but is not running; database state check skipped. Current status: $($svc.Status)"
        return
    }

    $info = Get-SqlDatabaseInfo
    if (!$info) {
        Warn "Could not connect to SQL to classify database state."
        return
    }

    Log "SQL database connection succeeded using $($info.Label)."
    Log "SQL databases found: $($info.Databases -join ', ')"

    if ($info.ExtraDatabases.Count -eq 0) {
        Warn "SQL appears default/empty-ish: only system databases were found."
    } else {
        Log "SQL appears populated: non-system database(s) found: $($info.ExtraDatabases -join ', ')"
    }

    Test-NfscabinetDatabaseConfigured | Out-Null
}

function Test-DotNet11 {
    if ($SkipDotNetCheck) {
        Warn "Skipping .NET Framework 1.1 check because -SkipDotNetCheck was used"
        return
    }

    $net11 = Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\mscorwks.dll"
    $regAsm = Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\RegAsm.exe"
    if (Test-Path $net11) {
        Log ".NET Framework 1.1 found: $net11"
        return
    }

    Warn ".NET Framework 1.1 was not found. GlobalVR Disc 2/tools and some frontend components are known to require v1.1.4322."
    Install-DotNet11

    if ((Test-Path $net11) -and (Test-Path $regAsm)) {
        Log ".NET Framework 1.1 installed successfully: $net11"
        return
    }

    Fail ".NET Framework 1.1 is still missing after install attempt. Reboot Windows if dotnetfx.exe requested it, then rerun this installer."
}

function Install-DotNet11 {
    $candidates = @(
        (Join-Path $SourceRoot "Dependencies\DotNet11\dotnetfx.exe"),
        (Join-Path $SourceRoot "Dependencies\dotnetfx.exe"),
        (Join-Path $SourceRoot "dotnetfx.exe")
    )

    $installer = $null
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            $installer = $candidate
            break
        }
    }

    if (!$installer) {
        Fail ".NET Framework 1.1 installer was not found. Put dotnetfx.exe in release\Dependencies\DotNet11, then rerun."
    }

    if ($DryRun) {
        Log "DRY RUN would install .NET Framework 1.1 from: $installer"
        return
    }

    Log "Installing .NET Framework 1.1 from: $installer"
    $args = '/q:a /c:"install /q"'
    $p = Start-Process -FilePath $installer -ArgumentList $args -Wait -PassThru
    if (($p.ExitCode -ne 0) -and ($p.ExitCode -ne 3010)) {
        Fail ".NET Framework 1.1 installer failed with exit code $($p.ExitCode)"
    }

    if ($p.ExitCode -eq 3010) {
        Warn ".NET Framework 1.1 installer requested a reboot. Reboot Windows, then rerun this installer."
    }
}

function New-GameShortcut {
    if ($NoShortcut) { return }
    $exe = Join-Path $TargetDrive "Underground\UndergroundGVR.exe"
    if ($DryRun) {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $lnk = Join-Path $desktop "Need For Speed Underground GlobalVR.lnk"
        Log "DRY RUN would create shortcut: $lnk -> $exe"
        return
    }
    if (!(Test-Path $exe)) {
        Warn "Game exe not found for shortcut: $exe"
        return
    }
    $desktop = [Environment]::GetFolderPath("Desktop")
    $lnk = Join-Path $desktop "Need For Speed Underground GlobalVR.lnk"
    Log "Creating shortcut: $lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($lnk)
    $shortcut.TargetPath = $exe
    $shortcut.WorkingDirectory = Split-Path -Parent $exe
    $shortcut.IconLocation = $exe
    $shortcut.Save()
}

function Find-DiscSource($Kind) {
    $candidates = @()
    if ($Kind -eq "Disc1") {
        $candidates += Join-Path $SourceRoot "DISCS\DISC 1"
    } else {
        $candidates += Join-Path $SourceRoot "DISCS\DISC 2"
        $candidates += Join-Path $SourceRoot "DISCS\DISC 1"
    }

    foreach ($drive in [System.IO.DriveInfo]::GetDrives()) {
        if ($drive.IsReady) { $candidates += $drive.RootDirectory.FullName }
    }

    foreach ($candidate in $candidates) {
        if (!(Test-Path $candidate)) { continue }
        if ($Kind -eq "Disc1") {
            if ((Test-Path (Join-Path $candidate "Setup.exe")) -and
                (Test-Path (Join-Path $candidate "data1.cab")) -and
                (Test-Path (Join-Path $candidate "data1.hdr"))) {
                return $candidate
            }
        } else {
            if ((Test-Path (Join-Path $candidate "data3.cab")) -or
                (Test-Path (Join-Path $candidate "data2.cab"))) {
                return $candidate
            }
        }
    }
    return $null
}

function Validate-DiscPayloads {
    if (!$ValidateDiscs) { return }

    Log "Validating original disc media"

    $disc1 = Find-DiscSource "Disc1"
    while (!$disc1) {
        Read-Host "Mount/insert Disc 1, then press Enter"
        $disc1 = Find-DiscSource "Disc1"
    }
    Log "Disc 1 found: $disc1"

    $disc2 = Find-DiscSource "Disc2"
    while (!$disc2) {
        Read-Host "Mount/insert Disc 2, then press Enter"
        $disc2 = Find-DiscSource "Disc2"
    }
    Log "Disc 2 cabinet found: $disc2"
}

function Install-SqlPayload {
    if ($SkipSql) {
        Warn "Skipping SQL install because -SkipSql was used"
        Write-SqlXmlAssemblyFolderRegistry
        return
    }

    $existingSqlService = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue

    $sqlSource = Join-Path $SourceRoot "C\Program Files\Microsoft SQL Server"
    $sqlXmlSource = Join-Path $SourceRoot "C\Program Files\SQLXML 3.0"
    $sqlTarget = Join-Path $TargetDrive "Program Files\Microsoft SQL Server"
    $sqlXmlTarget = Join-Path $TargetDrive "Program Files\SQLXML 3.0"

    if (Test-Path $sqlTarget) {
        Warn "Skipping Microsoft SQL Server / MSDE file copy because destination already exists: $sqlTarget"
        Warn "This avoids overwriting live SQL files that may be locked by the MSSQLSERVER service."
        Warn "Repairing only missing Microsoft SQL Server / MSDE files."
        Copy-MissingTree $sqlSource $sqlTarget "Microsoft SQL Server / MSDE"
    } else {
        Copy-Tree $sqlSource $sqlTarget "Microsoft SQL Server / MSDE"
    }

    if (Test-Path $sqlXmlTarget) {
        Warn "Skipping SQLXML 3.0 file copy because destination already exists: $sqlXmlTarget"
        Warn "Repairing only missing SQLXML 3.0 files."
        Copy-MissingTree $sqlXmlSource $sqlXmlTarget "SQLXML 3.0"
    } else {
        Copy-Tree $sqlXmlSource $sqlXmlTarget "SQLXML 3.0"
    }

    $regExport = Join-Path $SourceRoot "Registry_Export.reg"
    $filteredSqlReg = Join-Path $LogDir "nfsu_sql_filtered.reg"
    $prefixes = @(
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer",
        "HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\SQL Server",
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\SQLXML 3.0",
        "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MSSQLSERVER",
        "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT",
        "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MSSQLServerADHelper",
        "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\MSSQLSERVER",
        "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\MSSQLServerADHelper",
        "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\SQLSERVERAGENT",
        "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\SQLCTR"
    )

    $importedSqlRegistry = $false
    if ($existingSqlService -and !$ForceOverwrite) {
        Warn "MSSQLSERVER service already exists. Checking whether SQL is usable before skipping registry repair."
        if (Test-SqlConnectable) {
            Log "SQL is connectable; skipping SQL registry import."
        } else {
            Warn "SQL service exists but is not connectable. Re-importing MSDE/SQL registry to repair paths/protocols."
            Extract-RegistrySections $regExport $filteredSqlReg $prefixes
            Import-RegFile $filteredSqlReg "filtered MSDE/SQL registry repair"
            $importedSqlRegistry = $true
        }
    } else {
        Extract-RegistrySections $regExport $filteredSqlReg $prefixes
        Import-RegFile $filteredSqlReg "filtered MSDE/SQL registry"
        $importedSqlRegistry = $true
    }

    Register-SqlComponents
    Write-SqlXmlAssemblyFolderRegistry
    Repair-SqlNetworkRegistry

    if (!$NoStartSql) {
        if ($importedSqlRegistry) {
            $svc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -eq "Running") {
                Log "Restarting MSSQLSERVER after SQL registry repair"
                Restart-Service -Name "MSSQLSERVER" -Force
                Start-Sleep -Seconds 5
            }
        }
        Start-SqlService
        Test-SqlWithOsql
        Test-SqlDatabaseState
    } else {
        Warn "Not starting SQL because -NoStartSql was used"
        Test-SqlDatabaseState
    }
}

function Install-SystemDllPayload {
    if ($SkipSystemDlls) {
        Warn "Skipping system DLL payload because -SkipSystemDlls was used"
        return
    }

    $system32 = Join-Path $env:WINDIR "System32"
    $dllSource = Join-Path $SourceRoot "DLLs"
    $capturedSystem32 = Join-Path $SourceRoot "C\Windows\system32"
    $discSetup = Join-Path $SourceRoot "DISCS\DISC 1\_Setup"

    $files = @(
        (Join-Path $dllSource "GVRInputRaw.dll"),
        (Join-Path $dllSource "PLUSDE.dll"),
        (Join-Path $dllSource "USBIOExtreme.dll"),
        (Join-Path $dllSource "JesDLL.dll"),
        (Join-Path $dllSource "sqlunirl.dll"),
        (Join-Path $dllSource "odbcbcp.dll"),
        (Join-Path $dllSource "atl.dll"),
        (Join-Path $capturedSystem32 "dinput.dll"),
        (Join-Path $capturedSystem32 "msvcirt.dll"),
        (Join-Path $capturedSystem32 "sqlwoa.dll"),
        (Join-Path $capturedSystem32 "dbmsadsn.dll"),
        (Join-Path $capturedSystem32 "dbmsgnet.dll"),
        (Join-Path $capturedSystem32 "DBmsLPCn.dll"),
        (Join-Path $capturedSystem32 "dbmsqlgc.dll"),
        (Join-Path $capturedSystem32 "dbmsrpcn.dll"),
        (Join-Path $capturedSystem32 "dbmsvinn.dLL"),
        (Join-Path $capturedSystem32 "msvcr71.dll"),
        (Join-Path $dllSource "msvcp71.dll"),
        (Join-Path $capturedSystem32 "msvcp71.dll"),
        (Join-Path $dllSource "msvcp71d.dll"),
        (Join-Path $capturedSystem32 "msvcp71d.dll"),
        (Join-Path $dllSource "msvcr71d.dll"),
        (Join-Path $capturedSystem32 "msvcr71d.dll"),
        (Join-Path $dllSource "msvcr70d.dll"),
        (Join-Path $capturedSystem32 "msvcr70d.dll"),
        (Join-Path $dllSource "gdiplus.dll"),
        (Join-Path $capturedSystem32 "gdiplus.dll"),
        (Join-Path $dllSource "PCSCSCR2.dll"),
        (Join-Path $capturedSystem32 "PCSCSCR2.dll"),
        (Join-Path $dllSource "VNSAPI32.dll"),
        (Join-Path $capturedSystem32 "VNSAPI32.dll"),
        (Join-Path $dllSource "odbcp32r.dll"),
        (Join-Path $capturedSystem32 "odbcp32r.dll"),
        (Join-Path $dllSource "plustab.dll"),
        (Join-Path $capturedSystem32 "plustab.dll"),
        (Join-Path $dllSource "xactsrv.dll"),
        (Join-Path $capturedSystem32 "xactsrv.dll"),
        (Join-Path $dllSource "MSVCRTD.DLL"),
        (Join-Path $capturedSystem32 "MSVCRTD.DLL"),
        (Join-Path $dllSource "GVRSCR28.dll"),
        (Join-Path $capturedSystem32 "GVRSCR28.dll"),
        (Join-Path $dllSource "GVRSDEmulator.dll"),
        (Join-Path $capturedSystem32 "GVRSDEmulator.dll"),
        (Join-Path $dllSource "GVRStorageDevice.dll"),
        (Join-Path $capturedSystem32 "GVRStorageDevice.dll"),
        (Join-Path $dllSource "DongleStorageDevice.dll"),
        (Join-Path $capturedSystem32 "DongleStorageDevice.dll"),
        (Join-Path $discSetup "msvcr70.dll")
    )

    foreach ($file in $files) {
        if (Test-Path $file) { Copy-FileIfPresent $file $system32 }
    }

    if (!(Test-Path (Join-Path $system32 "gdiplus.dll"))) {
        Copy-LatestSystemFileIfPresent "gdiplus.dll" $system32 "GDI+ runtime"
    }

    Copy-FileIfPresent (Join-Path $dllSource "JesDLL.dll") (Join-Path $TargetDrive "Underground")

    if (!(Test-Path (Join-Path $system32 "msvcp71.dll"))) {
        Warn "MSVCP71.dll is still missing from $system32. This is the old Visual C++ 2003 C++ runtime; add it to DLLs from a legitimate source if GVR shell tools fail to start."
    }
    if (!(Test-Path (Join-Path $system32 "gdiplus.dll"))) {
        Warn "GDI+ runtime is still missing from $system32. Windows 7 normally contains it under WinSxS; verify the Windows install if graphics/UI tools fail."
    }
    if (!(Test-Path (Join-Path $TargetDrive "Underground\JesDLL.dll"))) {
        Warn "JesDLL.dll is still missing from the game folder. UndergroundGVR.exe may fail to start."
    }
}

function Install-LegacyNvidiaCplFiles {
    if (!$InstallLegacyNvidiaCplFiles) { return }

    $capturedSystem32 = Join-Path $SourceRoot "C\Windows\system32"
    $dllSource = Join-Path $SourceRoot "DLLs"
    $nvidiaSource = Join-Path $SourceRoot "NVIDIA"

    Warn "Adding missing legacy NVIDIA Control Panel/support files from captured payload."
    Warn "Existing NVIDIA files will be kept in place, even when -ForceOverwrite is active."
    Warn "This does not install an NVIDIA display driver; on real NVIDIA hardware, use the correct driver installer instead."

    $destinationDirs = @((Join-Path $env:WINDIR "System32"))
    $sysWow64 = Join-Path $env:WINDIR "SysWOW64"
    if (Test-Path $sysWow64) { $destinationDirs += $sysWow64 }
    $sysNative = Join-Path $env:WINDIR "Sysnative"
    if (Test-Path $sysNative) { $destinationDirs += $sysNative }
    $destinationDirs = @($destinationDirs | Select-Object -Unique)

    $files = @(
        "nvcpl.dll",
        "nvmctray.dll",
        "nview.dll",
        "nvshell.dll",
        "nvwimg.dll",
        "nvwdmcpl.dll",
        "nvnt4cpl.dll",
        "nvappbar.exe",
        "nvdspsch.exe",
        "nvcolor.exe",
        "nvcod.dll",
        "nvcodins.dll",
        "nvapps.xml",
        "nvdisp.nvu",
        "nvhwvid.dll",
        "nvtuicpl.cpl",
        "nvudisp.exe",
        "nvwddi.dll",
        "nv4_disp.dll",
        "nvoglnt.dll"
    )

    foreach ($file in $files) {
        $source = Join-Path $capturedSystem32 $file
        if (!(Test-Path $source)) {
            $source = Join-Path $dllSource $file
        }
        if (!(Test-Path $source)) {
            $source = Join-Path $nvidiaSource $file
        }

        if (!(Test-Path $source)) {
            Warn "Legacy NVIDIA source file not found in captured System32, DLLs, or NVIDIA folder: $file"
            continue
        }

        foreach ($destinationDir in $destinationDirs) {
            Copy-NvidiaFileIfMissing $source $destinationDir
        }
    }

    $required = @("nvcpl.dll", "nvmctray.dll")
    foreach ($file in $required) {
        $found = $false
        foreach ($destinationDir in $destinationDirs) {
            $target = Join-Path $destinationDir $file
            if (Test-Path $target) {
                Log "Legacy NVIDIA file present after copy: $target"
                $found = $true
            }
        }

        if (!$found) {
            Fail "Legacy NVIDIA file is still missing after copy: $file"
        }
    }
}

function Install-GamePayload {
    if ($SkipGamePayload) {
        Warn "Skipping game payload copy because -SkipGamePayload was used."
        return
    }

    Copy-Tree (Join-Path $SourceRoot "C\Underground") (Join-Path $TargetDrive "Underground") "game files"
    Copy-Tree (Join-Path $SourceRoot "C\GvrRoot") (Join-Path $TargetDrive "GvrRoot") "GVR root/runtime"
    Copy-Tree (Join-Path $SourceRoot "C\GvrPlus") (Join-Path $TargetDrive "GvrPlus") "GVR Plus"
    Copy-Tree (Join-Path $SourceRoot "C\Gvr") (Join-Path $TargetDrive "Gvr") "GVR system helpers"
}

function Install-MinimalGameRegistry {
    $referenceRegPath = Join-Path $SourceRoot "Reference_GVR_All.reg"
    if (Test-Path $referenceRegPath) {
        Import-RegFile $referenceRegPath "working-reference GVR/GlobalVR/GVRShell registry"
    } else {
        Warn "Reference_GVR_All.reg not found; using built-in GVR registry payload only."
    }

    $regPath = Join-Path $LogDir "nfsu_game_minimal.reg"
    Write-MinimalGameRegistry $regPath
    Import-RegFile $regPath "NFS/GVR Win7 compatibility registry overlay"
}

function Initialize-GvrRuntimeUserRegistry {
    $dongleKey = "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Gvr\hercules\Dongle"
    if ($DryRun) {
        Log "DRY RUN would initialize runtime user registry key: $dongleKey"
        return
    }

    Log "Initializing runtime user registry key: $dongleKey"
    New-Item -Path $dongleKey -Force | Out-Null
    New-ItemProperty -Path $dongleKey -Name "Inserted" -Value 0 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $dongleKey -Name "GameName" -Value "NFSUNDERGROUND" -PropertyType String -Force | Out-Null
}

function Clear-GvrVirtualStoreRegistry {
    $virtualStoreKeys = @(
        "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Gvr",
        "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\GVRShell",
        "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\GlobalVR",
        "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\Gvr",
        "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\GVRShell",
        "HKCU:\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Wow6432Node\GlobalVR"
    )

    foreach ($key in $virtualStoreKeys) {
        if (!(Test-Path $key)) { continue }

        if ($DryRun) {
            Log "DRY RUN would remove stale registry virtual-store key: $key"
        } else {
            Log "Removing stale registry virtual-store key: $key"
            Remove-Item -LiteralPath $key -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Repair-DotNetJitDebuggerIfBroken {
    $netKey = "HKLM:\SOFTWARE\Microsoft\.NETFramework"
    $cordbg = Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\cordbg.exe"

    if (!(Test-Path $netKey)) { return }

    $props = Get-ItemProperty -Path $netKey -ErrorAction SilentlyContinue
    if (!$props) { return }

    $debugger = $props.DbgManagedDebugger
    if (!$debugger) { return }

    if (($debugger -match "cordbg") -and !(Test-Path $cordbg)) {
        if ($DryRun) {
            Log "DRY RUN would remove stale .NET managed JIT debugger value pointing to missing cordbg.exe"
            return
        }

        Warn "Removing stale .NET managed JIT debugger value because cordbg.exe is missing."
        Warn "This removes the misleading cordbg popup; it does not hide the underlying game exception."
        Remove-ItemProperty -Path $netKey -Name "DbgManagedDebugger" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $netKey -Name "DbgJITDebugLaunchSetting" -ErrorAction SilentlyContinue
    }
}

function Remove-BrokenNvidiaStartupEntries {
    $nvcpl = Join-Path $env:WINDIR "System32\NvCpl.dll"
    $nvmc = Join-Path $env:WINDIR "System32\NvMcTray.dll"
    $runKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
    )

    foreach ($runKey in $runKeys) {
        if (!(Test-Path $runKey)) { continue }

        if (!(Test-Path $nvcpl)) {
            if ($DryRun) {
                Log "DRY RUN would remove stale NVIDIA startup value NvCplDaemon from $runKey"
            } else {
                Remove-ItemProperty -Path $runKey -Name "NvCplDaemon" -ErrorAction SilentlyContinue
            }
        }

        if (!(Test-Path $nvmc)) {
            if ($DryRun) {
                Log "DRY RUN would remove stale NVIDIA startup value NvMediaCenter from $runKey"
            } else {
                Remove-ItemProperty -Path $runKey -Name "NvMediaCenter" -ErrorAction SilentlyContinue
            }
        }
    }

    if (!(Test-Path $nvcpl)) {
        Warn "NVIDIA Control Panel DLL NvCpl.dll is not installed. Removed stale NVIDIA startup hooks if present."
        Warn "This is expected on VirtualBox/VBoxVGA. On real NVIDIA hardware, install the correct NVIDIA display driver instead."
    }
}

function Initialize-PlusData {
    if (!$InitializePlusData) { return }
    $exe = Join-Path $TargetDrive "Underground\UndergroundGVR.exe"
    Assert-File $exe "UndergroundGVR.exe"
    Log "Running optional Plus table initialization"
    if ($DryRun) { return }
    & "$exe" -initializeplustabledata
    if ($LASTEXITCODE -ne 0) {
        Warn "Plus table initialization returned exit code $LASTEXITCODE"
    }
}

function Invoke-TimedProcess($Label, $ExePath, $WorkingDirectory, $TimeoutSeconds, $StdOutPath, $StdErrPath) {
    Remove-Item -LiteralPath $StdOutPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $StdErrPath -Force -ErrorAction SilentlyContinue

    Push-Location $WorkingDirectory
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $ExePath
        $startInfo.WorkingDirectory = $WorkingDirectory
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $startInfo
        [void]$process.Start()
        Log "$Label process started. PID: $($process.Id)"

        $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
        while (!$process.HasExited -and ((Get-Date) -lt $deadline)) {
            Start-Sleep -Seconds 5
            if (!$process.HasExited) {
                $remaining = [int][Math]::Max(0, ($deadline - (Get-Date)).TotalSeconds)
                Log "$Label still running; $remaining second(s) before timeout."
            }
        }

        if (!$process.HasExited) {
            try {
                $process.Kill()
            } catch {
                Warn "Could not stop hung $Label process: $($_.Exception.Message)"
            }
            Warn "$Label timed out after $TimeoutSeconds seconds and was stopped."
            Warn "Output logs: $StdOutPath and $StdErrPath"
            Fail "$Label did not finish."
        }

        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        Set-Content -LiteralPath $StdOutPath -Value $stdout -Encoding ASCII
        Set-Content -LiteralPath $StdErrPath -Value $stderr -Encoding ASCII
        $exit = $process.ExitCode
    } finally {
        Pop-Location
    }

    foreach ($outputFile in @($StdOutPath, $StdErrPath)) {
        if (!(Test-Path $outputFile)) { continue }
        foreach ($line in (Get-Content -LiteralPath $outputFile -ErrorAction SilentlyContinue)) {
            if ($line) { Log "$Label tool: $line" }
        }
    }

    return $exit
}

function Decode-GvrPlusEncryptedFile($DecoderAssembly, $EncryptedPath, $OutputPath) {
    Assert-File $DecoderAssembly "GvrPlus database decoder assembly"
    Assert-File $EncryptedPath "GvrPlus encrypted database payload"

    Log "Decoding encrypted GvrPlus payload: $EncryptedPath"
    try {
        $assembly = [System.Reflection.Assembly]::LoadFrom($DecoderAssembly)
        $class = $assembly.GetType("ExportDatabaseScript.Class1")
        if (!$class) { Fail "Decoder class not found in $DecoderAssembly" }

        $method = $class.GetMethod("GetFileContent", [System.Reflection.BindingFlags]"NonPublic,Static")
        if (!$method) { Fail "Decoder method GetFileContent not found in $DecoderAssembly" }

        $decodeArgs = New-Object 'System.Object[]' 2
        $decodeArgs[0] = [string]$EncryptedPath
        $decodeArgs[1] = [string]""
        $result = $method.Invoke($null, $decodeArgs)
        if ($result -ne 0) {
            Fail "GvrPlus payload decoder returned $result for $EncryptedPath"
        }

        $text = [string]$decodeArgs[1]
        if ([string]::IsNullOrEmpty($text)) {
            Fail "GvrPlus payload decoder returned empty content for $EncryptedPath"
        }

        Set-Content -LiteralPath $OutputPath -Value $text -Encoding ASCII
        Log "Decoded GvrPlus payload written: $OutputPath"
    } catch {
        Fail "Could not decode GvrPlus payload $EncryptedPath`: $($_.Exception.Message)"
    }
}

function Find-FirstExistingFile($Directories, $Names) {
    foreach ($directory in $Directories) {
        if ([string]::IsNullOrEmpty($directory)) { continue }
        foreach ($name in $Names) {
            $candidate = Join-Path $directory $name
            if (Test-Path $candidate) { return $candidate }
        }
    }
    return $null
}

function Copy-DecodedGvrPlusFileOrDecode($DecodedSource, $DecoderAssembly, $EncryptedPath, $OutputPath, $Label) {
    if ($DecodedSource -and (Test-Path $DecodedSource)) {
        Log "Using decoded GvrPlus $Label payload: $DecodedSource"
        Copy-Item -LiteralPath $DecodedSource -Destination $OutputPath -Force
        return
    }

    Decode-GvrPlusEncryptedFile $DecoderAssembly $EncryptedPath $OutputPath
}

function Invoke-Disc2DatabaseSqlImport($DecoderAssembly) {
    $schemaDir = Join-Path $TargetDrive "GvrPlus\1\schema"
    $schemaEnc = Join-Path $schemaDir "nfscabinet.enc"
    $contentEnc = Join-Path $schemaDir "nfscabinet_Content.enc"
    $xmlEnc = Join-Path $schemaDir "nfscabinetXml.enc"

    $schemaSql = Join-Path $LogDir "disc2_nfscabinet_schema.sql"
    $contentSql = Join-Path $LogDir "disc2_nfscabinet_content.sql"
    $xmlDecoded = Join-Path $LogDir "disc2_nfscabinetXml.xml"

    $decodedDirs = @(
        (Join-Path $SourceRoot "Database"),
        $SourceRoot,
        $schemaDir
    )
    $schemaDecoded = Find-FirstExistingFile $decodedDirs @("nfscabinet.sql", "nfscabinet.txt", "nfscabinet.decoded.txt")
    $contentDecoded = Find-FirstExistingFile $decodedDirs @("nfscabinet_Content.sql", "nfscabinet_Content.txt", "nfscabinet_Content.decoded.txt")
    $xmlDecodedSource = Find-FirstExistingFile $decodedDirs @("nfscabinetXml.xml", "nfscabinetXml.txt", "nfscabinetXml.decoded.txt")

    Copy-DecodedGvrPlusFileOrDecode $schemaDecoded $DecoderAssembly $schemaEnc $schemaSql "schema SQL"
    Copy-DecodedGvrPlusFileOrDecode $contentDecoded $DecoderAssembly $contentEnc $contentSql "content SQL"
    Copy-DecodedGvrPlusFileOrDecode $xmlDecodedSource $DecoderAssembly $xmlEnc $xmlDecoded "schema XML"

    Log "Running direct Disc 2 SQL schema import from decoded OEM payload"
    if (!(Invoke-OsqlInputFile $schemaSql "Disc 2 nfscabinet schema import")) {
        Fail "Disc 2 nfscabinet schema import failed for every SQL auth/protocol attempt."
    }

    Log "Running direct Disc 2 SQL content import from decoded OEM payload"
    if (!(Invoke-OsqlInputFile $contentSql "Disc 2 nfscabinet content import")) {
        Fail "Disc 2 nfscabinet content import failed for every SQL auth/protocol attempt."
    }
}

function Set-GvrSaPassword {
    # The GlobalVR frontend reads its connection string from nfscabinetXml.enc, which is
    # baked to: Data Source=(local);Initial Catalog=nfscabinet;User ID=sa;Password=Q31y2Z29wpEsd
    # The OEM GvrPlusExportDatabaseScript.exe rotated sa from the MSDE setup password to that
    # value. We deliberately skip that tool because it hangs, so the rotation has to happen here
    # or the frontend and UndergroundGVR.exe -initializeplustabledata cannot log in at all.
    if ($SkipSql) { return }
    if ($SkipSaPasswordRotation) {
        Warn "Skipping sa password rotation. The GlobalVR frontend will not connect unless sa already uses its expected password."
        return
    }
    if ($DryRun) {
        Log "DRY RUN would rotate the sa password to the final GlobalVR password expected by the frontend"
        return
    }

    $probe = "set nocount on select 1"

    foreach ($endpoint in (Get-SqlServerEndpoints)) {
        $atFinal = Invoke-OsqlProcess @("-U", "sa", "-P", $GvrFrontendSaPassword, "-S", $endpoint, "-Q", $probe) "sa_password_probe_final" 30
        if (Test-OsqlResultSuccess $atFinal) {
            Log "sa already uses the final GlobalVR password expected by the frontend."
            return
        }

        $atDefault = Invoke-OsqlProcess @("-U", "sa", "-P", $MsdeSetupSaPassword, "-S", $endpoint, "-Q", $probe) "sa_password_probe_default" 30
        if (!(Test-OsqlResultSuccess $atDefault)) { continue }

        Log "sa is using the default MSDE setup password; rotating it to the final GlobalVR password on $endpoint"
        $rotateQuery = "EXEC sp_password @old = '$MsdeSetupSaPassword', @new = '$GvrFrontendSaPassword', @loginame = 'sa'"
        $rotate = Invoke-OsqlProcess @("-U", "sa", "-P", $MsdeSetupSaPassword, "-S", $endpoint, "-Q", $rotateQuery) "sa_password_rotate" 60

        # sp_password reports success through informational message 15478 ("Password changed."),
        # which Test-OsqlResultSuccess reads as a failure because it rejects any "Msg <number>".
        # Logging back in with the new password is the only reliable signal here.
        $verify = Invoke-OsqlProcess @("-U", "sa", "-P", $GvrFrontendSaPassword, "-S", $endpoint, "-Q", $probe) "sa_password_verify" 30
        if (Test-OsqlResultSuccess $verify) {
            Log "sa password rotated to the final GlobalVR password expected by the frontend."
            return
        }

        $rotateLine = @([string]$rotate.Output -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
        if ($rotateLine.Count -gt 0) {
            Fail "Failed to rotate the sa password on $endpoint : $($rotateLine[0].Trim())"
        }
        Fail "Failed to rotate the sa password to the final GlobalVR password on $endpoint."
    }

    Warn "Could not log in as sa with either the final GlobalVR password or the default MSDE setup password."
    Warn "The GlobalVR frontend expects sa to use its final password, so it may fail to start."
}

function Invoke-Disc2DatabaseUpdate {
    if (!$RunDisc2DatabaseUpdate) { return }

    $scriptDir = Join-Path $TargetDrive "GvrPlus\1\scripts"
    $exe = Join-Path $scriptDir "GvrPlusExportDatabaseScript.exe"
    $deleteRegistryExe = Join-Path $TargetDrive "GvrPlus\1\lib\DeleteRegistry\DeleteRegistry.exe"
    if ($DryRun) {
        Log "DRY RUN would run optional Disc 2 database update: $exe"
        Log "DRY RUN would require .NET Framework 1.1 and a running MSSQLSERVER service"
        return
    }

    Assert-File $exe "Disc 2 GvrPlusExportDatabaseScript.exe"
    Assert-File $deleteRegistryExe "Disc 2 DeleteRegistry.exe custom-action helper"

    $requiredFiles = @(
        (Join-Path $TargetDrive "GvrPlus\1\schema\nfscabinetXml.enc"),
        (Join-Path $TargetDrive "GvrPlus\1\schema\nfscabinet.enc"),
        (Join-Path $TargetDrive "GvrPlus\1\schema\nfscabinet_Content.enc"),
        (Join-Path $TargetDrive "GvrPlus\1\key\publickey.xml"),
        (Join-Path $scriptDir "GvrPlusLib.DLL"),
        (Join-Path $scriptDir "Interop.SQLDMO.DLL"),
        (Join-Path $scriptDir "AKSHASP.DLL"),
        (Join-Path $scriptDir "sqldmo.dll")
    )
    foreach ($file in $requiredFiles) {
        Assert-File $file "Disc 2 database update dependency"
    }

    $net11 = Join-Path $env:WINDIR "Microsoft.NET\Framework\v1.1.4322\mscorwks.dll"
    if (!(Test-Path $net11)) {
        Fail ".NET Framework 1.1 is required before running the Disc 2 database update tool."
    }

    if ($NoStartSql) {
        Warn "Disc 2 database update requested; SQL must be running even though -NoStartSql was used."
    }
    Start-SqlService
    Restart-SqlServiceForDisc2Update

    if ((Test-NfscabinetDatabaseConfigured -Quiet) -and !$ForceOverwrite) {
        Warn "Skipping Disc 2 database update because nfscabinet already appears configured."
        Warn "Use -ForceOverwrite only on a disposable/test system if you intentionally want to rerun the database update."
        return
    }

    Log "Running optional Disc 2 database update from encrypted OEM SQL payloads"
    Log "This mirrors the useful Disc 2 MSI database work without launching the hanging database updater EXE."

    $deleteStdOut = Join-Path $LogDir "disc2_delete_registry.stdout.log"
    $deleteStdErr = Join-Path $LogDir "disc2_delete_registry.stderr.log"

    Log "Running Disc 2 pre-database helper: $deleteRegistryExe"
    $deleteExit = Invoke-TimedProcess "Disc 2 DeleteRegistry" $deleteRegistryExe (Split-Path -Parent $deleteRegistryExe) 60 $deleteStdOut $deleteStdErr
    if ($deleteExit -ne 0) {
        Warn "Disc 2 DeleteRegistry returned exit code $deleteExit"
    }

    Invoke-Disc2DatabaseSqlImport $exe
    Log "Disc 2 direct SQL database update completed"
    if (!(Test-NfscabinetDatabaseConfigured)) {
        Fail "Disc 2 SQL import finished, but nfscabinet validation failed."
    }

    Warn "Skipping Disc 2 post-database UnregDlls.exe helper because it can hang/crash on Win7 game-only installs."
    Warn "The direct SQL database import has already completed; UnregDlls.exe is treated as MSI cleanup, not required DB setup."

    Test-SqlDatabaseState
}

New-Dir $LogDir
Log "NFSU GlobalVR game-only installer starting"
Log "Installer version: $InstallerVersion"
Log "SourceRoot: $SourceRoot"
Log "TargetDrive: $TargetDrive"
if ($DryRun) { Warn "DRY RUN mode active; no changes will be made" }
if ($ForceOverwrite) {
    Warn "-ForceOverwrite is active. Protected/in-use optional System32 DLLs may be left in place if Windows denies replacement."
}

if (!(Test-Admin)) { Fail "Run this script as Administrator" }
if ($TargetDrive.ToUpper() -ne "C:") {
    Fail "This first installer version only supports TargetDrive C:. The captured game and SQL registry paths are C-drive based."
}
if ([Environment]::Is64BitOperatingSystem) {
    Warn "64-bit Windows detected. This old MSDE/GlobalVR stack is expected to be most reliable on 32-bit Windows XP/7-era systems."
}

Test-DotNet11
Validate-DiscPayloads
Install-GamePayload
Install-SystemDllPayload
Install-LegacyNvidiaCplFiles
Install-DirectXOptionalRuntime
Install-SqlPayload
Clear-GvrVirtualStoreRegistry
Install-MinimalGameRegistry
Initialize-GvrRuntimeUserRegistry
Repair-DotNetJitDebuggerIfBroken
Remove-BrokenNvidiaStartupEntries
Register-Component (Join-Path $TargetDrive "Gvr\system\ShellControl.ocx")
Register-GvrPlusAssemblies
Invoke-Disc2DatabaseUpdate
Set-GvrSaPassword
Initialize-PlusData
New-GameShortcut

Log "Install complete"
Write-Host ""
Write-Host "Install complete. Log: $LogFile" -ForegroundColor Green



