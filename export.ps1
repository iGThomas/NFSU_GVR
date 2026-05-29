# ============================================================
# Export-NFSU.ps1
# Exports all necessary files and registry keys for
# Need For Speed Underground (GlobalVR) + MSDE installation
#
# SOURCE: E:\ (mounted GlobalVR WinXPe disk)
# OUTPUT: .\NFSU_Export\ (next to this script)
#
# Run as Administrator on your current Windows OS
# ============================================================

$ErrorActionPreference = "Continue"

# -----------------------------------------------
# CONSTANTS - change these if your drive letters differ
# -----------------------------------------------
$SourceDrive    = "E:"
$ScriptDir      = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExportDir      = Join-Path $ScriptDir "NFSU_Export"
$TempHiveKey    = "NFSU_HIVE_TEMP"   # temporary name in regedit while loaded

# Source paths on E:\
$GamePath       = "$SourceDrive\Underground"
$GVRDLLPath     = "$SourceDrive\GVRDLL"
$SQLServerPath  = "$SourceDrive\Program Files\Microsoft SQL Server"
$SQLXMLPath     = "$SourceDrive\Program Files\SQLXML 3.0"
$SQLXML4Path    = "$SourceDrive\Program Files\SQLXML 4.0"
$SQLCommonPath  = "$SourceDrive\Program Files\Common Files\Microsoft Shared\SQL Server"

# Registry hive files on E:\
$HiveSoftware   = "$SourceDrive\Windows\System32\config\SOFTWARE"
$HiveSystem     = "$SourceDrive\Windows\System32\config\SYSTEM"

# -----------------------------------------------
function Log($msg)  { Write-Host "[*] $msg" -ForegroundColor Cyan }
function OK($msg)   { Write-Host "[+] $msg" -ForegroundColor Green }
function WARN($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }
function ERR($msg)  { Write-Host "[X] $msg" -ForegroundColor Red }

# -----------------------------------------------
# Verify running as admin
# -----------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
if (-not $isAdmin) {
    ERR "Please run this script as Administrator!"
    exit 1
}

# -----------------------------------------------
# Verify source drive exists
# -----------------------------------------------
if (!(Test-Path $SourceDrive)) {
    ERR "Source drive $SourceDrive not found! Check your drive letter."
    exit 1
}
OK "Source drive $SourceDrive found"

# -----------------------------------------------
# Create export folder structure
# -----------------------------------------------
$folders = @(
    "$ExportDir\GameFiles",
    "$ExportDir\GVRDLL",
    "$ExportDir\SQLServer\MSSQL",
    "$ExportDir\SQLServer\80",
    "$ExportDir\SQLServer\CommonFiles",
    "$ExportDir\SQLXML",
    "$ExportDir\Registry",
    "$ExportDir\Scripts"
)
foreach ($f in $folders) {
    New-Item -ItemType Directory -Path $f -Force | Out-Null
}
OK "Export directory created: $ExportDir"

# -----------------------------------------------
# 1. GAME FILES from E:\Underground
# -----------------------------------------------
Log "Copying game files from $GamePath..."
if (Test-Path $GamePath) {
    Copy-Item "$GamePath\*" "$ExportDir\GameFiles\" -Recurse -Force
    OK "Game files copied"
} else {
    WARN "$GamePath not found - trying lowercase..."
    $GamePathLower = "$SourceDrive\underground"
    if (Test-Path $GamePathLower) {
        Copy-Item "$GamePathLower\*" "$ExportDir\GameFiles\" -Recurse -Force
        OK "Game files copied (lowercase path)"
    } else {
        WARN "Game folder not found on $SourceDrive"
    }
}

# -----------------------------------------------
# 2. GVR DLLs from E:\GVRDLL
# -----------------------------------------------
Log "Copying GVR DLLs from $GVRDLLPath..."
if (Test-Path $GVRDLLPath) {
    Copy-Item "$GVRDLLPath\*" "$ExportDir\GVRDLL\" -Recurse -Force
    OK "GVR DLLs copied"
} else {
    WARN "$GVRDLLPath not found"
}

# -----------------------------------------------
# 3. SQL SERVER FILES from E:\Program Files\Microsoft SQL Server
# -----------------------------------------------
Log "Copying SQL Server files from $SQLServerPath..."
if (Test-Path "$SQLServerPath\MSSQL") {
    Copy-Item "$SQLServerPath\MSSQL\*" "$ExportDir\SQLServer\MSSQL\" -Recurse -Force
    OK "SQL Server MSSQL folder copied"
} else {
    WARN "SQL Server MSSQL folder not found"
}

if (Test-Path "$SQLServerPath\80") {
    Copy-Item "$SQLServerPath\80\*" "$ExportDir\SQLServer\80\" -Recurse -Force
    OK "SQL Server 80 folder copied"
} else {
    WARN "SQL Server 80 folder not found"
}

# -----------------------------------------------
# 4. SQLXML FILES
# -----------------------------------------------
Log "Copying SQLXML files..."
foreach ($p in @($SQLXMLPath, $SQLXML4Path)) {
    if (Test-Path $p) {
        $name = Split-Path $p -Leaf
        New-Item -ItemType Directory -Path "$ExportDir\SQLXML\$name" -Force | Out-Null
        Copy-Item "$p\*" "$ExportDir\SQLXML\$name\" -Recurse -Force
        OK "SQLXML copied from $p"
    }
}

if (Test-Path $SQLCommonPath) {
    Copy-Item "$SQLCommonPath\*" "$ExportDir\SQLServer\CommonFiles\" -Recurse -Force
    OK "SQL common files copied"
}

# -----------------------------------------------
# 5. LOAD HIVES AND EXPORT REGISTRY
# -----------------------------------------------
Log "Loading registry hives from $SourceDrive\Windows\System32\config..."

# --- Load SOFTWARE hive ---
if (Test-Path $HiveSoftware) {
    Log "Loading SOFTWARE hive..."
    & reg load "HKLM\$TempHiveKey`_SW" "$HiveSoftware" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        OK "SOFTWARE hive loaded as HKLM\$TempHiveKey`_SW"

        $swExports = @{
            "SOFTWARE_GlobalVR"           = "HKLM\$TempHiveKey`_SW\GlobalVR"
            "SOFTWARE_MSSQLServer"        = "HKLM\$TempHiveKey`_SW\Microsoft\MSSQLServer"
            "SOFTWARE_MicrosoftSQLServer" = "HKLM\$TempHiveKey`_SW\Microsoft\Microsoft SQL Server"
            "SOFTWARE_SQLXML"             = "HKLM\$TempHiveKey`_SW\Microsoft\SQLXML"
            "SOFTWARE_ODBC"               = "HKLM\$TempHiveKey`_SW\ODBC"
            "SOFTWARE_NvidiaGlobal"       = "HKLM\$TempHiveKey`_SW\NVIDIA Corporation\Global"
        }

        foreach ($entry in $swExports.GetEnumerator()) {
            $outFile = "$ExportDir\Registry\$($entry.Key).reg"
            & reg export "$($entry.Value)" "$outFile" /y 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                OK "  Exported: $($entry.Key).reg"
            } else {
                WARN "  Not found: $($entry.Value)"
            }
        }

        # Unload SOFTWARE hive
        [GC]::Collect()
        Start-Sleep -Seconds 2
        & reg unload "HKLM\$TempHiveKey`_SW" | Out-Null
        OK "SOFTWARE hive unloaded"
    } else {
        WARN "Failed to load SOFTWARE hive - it may be locked"
    }
} else {
    WARN "SOFTWARE hive not found at $HiveSoftware"
}

# --- Load SYSTEM hive ---
if (Test-Path $HiveSystem) {
    Log "Loading SYSTEM hive..."
    & reg load "HKLM\$TempHiveKey`_SYS" "$HiveSystem" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        OK "SYSTEM hive loaded as HKLM\$TempHiveKey`_SYS"

        $sysExports = @{
            "SYSTEM_Services_MSSQLSERVER"    = "HKLM\$TempHiveKey`_SYS\ControlSet001\Services\MSSQLSERVER"
            "SYSTEM_Services_SQLSERVERAGENT" = "HKLM\$TempHiveKey`_SYS\ControlSet001\Services\SQLSERVERAGENT"
            "SYSTEM_Services_MSSQLAdHelper"  = "HKLM\$TempHiveKey`_SYS\ControlSet001\Services\MSSQLServerADHelper"
            "SYSTEM_Services_GVR"            = "HKLM\$TempHiveKey`_SYS\ControlSet001\Services\GVR"
            "SYSTEM_Environment"             = "HKLM\$TempHiveKey`_SYS\ControlSet001\Control\Session Manager\Environment"
        }

        foreach ($entry in $sysExports.GetEnumerator()) {
            $outFile = "$ExportDir\Registry\$($entry.Key).reg"
            & reg export "$($entry.Value)" "$outFile" /y 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                OK "  Exported: $($entry.Key).reg"
            } else {
                WARN "  Not found: $($entry.Value)"
            }
        }

        # Also try to list ALL services to see what GVR installed
        Log "Listing all services from SYSTEM hive..."
        $svcListOut = "$ExportDir\Scripts\AllServices.txt"
        & reg query "HKLM\$TempHiveKey`_SYS\ControlSet001\Services" 2>&1 | Out-File $svcListOut -Encoding UTF8
        OK "Service list saved to AllServices.txt"

        # Unload SYSTEM hive
        [GC]::Collect()
        Start-Sleep -Seconds 2
        & reg unload "HKLM\$TempHiveKey`_SYS" | Out-Null
        OK "SYSTEM hive unloaded"
    } else {
        WARN "Failed to load SYSTEM hive"
    }
} else {
    WARN "SYSTEM hive not found at $HiveSystem"
}

# -----------------------------------------------
# 6. LIST ALL DLLs found (for regsvr32 later)
# -----------------------------------------------
Log "Listing DLLs for registration..."
$dllList = @()
foreach ($searchPath in @($GamePath, $GVRDLLPath)) {
    if (Test-Path $searchPath) {
        Get-ChildItem $searchPath -Filter "*.dll" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $dllList += $_.FullName.Replace($SourceDrive, "C:")
        }
    }
}
$dllList | Out-File "$ExportDir\Scripts\DLLList.txt" -Encoding UTF8
OK "DLL list saved ($($dllList.Count) DLLs found)"

# -----------------------------------------------
# 7. GENERATE SIZE REPORT
# -----------------------------------------------
Log "Generating report..."
$totalSize = 0
$reportLines = @("NFSU GlobalVR Export Report", "=" * 40, "Date: $(Get-Date)", "Source: $SourceDrive", "Output: $ExportDir", "")

Get-ChildItem $ExportDir -Recurse -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer } | ForEach-Object {
    $totalSize += $_.Length
    $sizeKB = [math]::Round($_.Length / 1KB, 1)
    $reportLines += "  $($_.FullName.Replace($ExportDir,'').PadRight(60)) $sizeKB KB"
}

$totalMB = [math]::Round($totalSize / 1MB, 1)
$reportLines += ""
$reportLines += "Total export size: $totalMB MB"
$reportLines | Out-File "$ExportDir\ExportReport.txt" -Encoding UTF8

# -----------------------------------------------
# DONE
# -----------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Export complete! ($totalMB MB total)" -ForegroundColor Green
Write-Host " Output: $ExportDir" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files exported:" -ForegroundColor Yellow
Write-Host "  GameFiles\        - C:\Underground contents" -ForegroundColor Yellow
Write-Host "  GVRDLL\           - GVR DLLs" -ForegroundColor Yellow
Write-Host "  SQLServer\        - MSDE file tree" -ForegroundColor Yellow
Write-Host "  SQLXML\           - SQLXML files" -ForegroundColor Yellow
Write-Host "  Registry\*.reg    - All registry keys" -ForegroundColor Yellow
Write-Host "  Scripts\          - Service info + DLL list" -ForegroundColor Yellow
