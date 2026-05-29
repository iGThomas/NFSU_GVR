# ============================================================
# Import-NFSU.ps1 - PowerShell 2.0 compatible
# Place inside NFSU_Export folder, run as Administrator
# ============================================================

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# -----------------------------------------------
# CONSTANTS
# -----------------------------------------------
$SQLDestRoot  = "C:\Program Files\Microsoft SQL Server"
$SQLXMLDest   = "C:\Program Files\SQLXML 3.0"
$RegDir       = Join-Path $ScriptDir "Registry"
$SQLServerSrc = Join-Path $ScriptDir "SQLServer"
$SQLXMLSrc    = Join-Path $ScriptDir "SQLXML\SQLXML 3.0"
$TempReg      = "$env:TEMP\nfsu_import_temp.reg"
$tempKeyName  = "NFSU_HIVE_TEMP"

# -----------------------------------------------
function Log($msg)  { Write-Host "[*] $msg" -ForegroundColor Cyan }
function OK($msg)   { Write-Host "[+] $msg" -ForegroundColor Green }
function WARN($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }
function ERR($msg)  { Write-Host "[X] $msg" -ForegroundColor Red }
function Step($msg) { Write-Host ""; Write-Host "--- $msg ---" -ForegroundColor Magenta }

# Import a .reg file safely:
# - reads original untouched
# - does path replacement in memory
# - writes to a temp file
# - imports the temp file
# - deletes temp file
# Original .reg files are NEVER modified
function ImportReg($regFilePath) {
    if (!(Test-Path $regFilePath)) {
        WARN "Not found, skipping: $regFilePath"
        return
    }

    $fileName = Split-Path $regFilePath -Leaf
    Log "Importing $fileName..."

    # Read raw bytes and decode as Unicode (UTF-16 LE) which is what reg export produces
    $bytes = [System.IO.File]::ReadAllBytes($regFilePath)
    $content = [System.Text.Encoding]::Unicode.GetString($bytes)

    # Replace temp hive names with correct registry paths
    $content = $content -replace "HKEY_LOCAL_MACHINE\\$tempKeyName`_SW\\", "HKEY_LOCAL_MACHINE\SOFTWARE\"
    $content = $content -replace "HKEY_LOCAL_MACHINE\\$tempKeyName`_SYS\\ControlSet001\\", "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\"
    $content = $content -replace "HKEY_LOCAL_MACHINE\\$tempKeyName`_SW", "HKEY_LOCAL_MACHINE\SOFTWARE"
    $content = $content -replace "HKEY_LOCAL_MACHINE\\$tempKeyName`_SYS", "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet"

    # Write temp file as UTF-16 LE without BOM - reg import requires no BOM
    $encoding = New-Object System.Text.UnicodeEncoding($false, $false)
    $bytes = $encoding.GetBytes($content)
    [System.IO.File]::WriteAllBytes($TempReg, $bytes)

    # Import
    & reg import "$TempReg" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        OK "Imported: $fileName"
    } else {
        WARN "Failed: $fileName"
        # Show first few lines for debugging
        $preview = $content.Substring(0, [Math]::Min(200, $content.Length))
        Write-Host "  Preview: $preview" -ForegroundColor DarkYellow
    }

    # Delete temp file
    if (Test-Path $TempReg) { Remove-Item $TempReg -Force }
}

# -----------------------------------------------
# Verify admin
# -----------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
if (-not $isAdmin) { ERR "Run as Administrator!"; Read-Host | Out-Null; exit 1 }

if (!(Test-Path $RegDir)) {
    ERR "Registry folder not found. Run from inside NFSU_Export!"
    Read-Host | Out-Null
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " NFSU GlobalVR - Import Script" -ForegroundColor Cyan
Write-Host " Target: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# -----------------------------------------------
# STEP 1 - Stop existing SQL service
# -----------------------------------------------
Step "Step 1: Stopping existing SQL Server (if any)"
$existingSvc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
if ($existingSvc) {
    Log "Stopping MSSQLSERVER..."
    Stop-Service -Name "MSSQLSERVER" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    OK "Stopped"
} else {
    Log "No existing MSSQLSERVER found, continuing..."
}

# -----------------------------------------------
# STEP 2 - Copy SQL Server files
# -----------------------------------------------
Step "Step 2: Copying SQL Server (MSDE) files"

if (!(Test-Path $SQLDestRoot)) { New-Item -ItemType Directory -Path $SQLDestRoot -Force | Out-Null }

$mssqlSrc = Join-Path $SQLServerSrc "MSSQL"
$mssqlDst = Join-Path $SQLDestRoot "MSSQL"
if (Test-Path $mssqlSrc) {
    Log "Copying MSSQL folder..."
    New-Item -ItemType Directory -Path $mssqlDst -Force | Out-Null
    Copy-Item "$mssqlSrc\*" "$mssqlDst\" -Recurse -Force
    OK "MSSQL folder copied"
} else { ERR "MSSQL source not found: $mssqlSrc" }

$sql80Src = Join-Path $SQLServerSrc "80"
$sql80Dst = Join-Path $SQLDestRoot "80"
if (Test-Path $sql80Src) {
    Log "Copying SQL Server 80 folder..."
    New-Item -ItemType Directory -Path $sql80Dst -Force | Out-Null
    Copy-Item "$sql80Src\*" "$sql80Dst\" -Recurse -Force
    OK "SQL 80 folder copied"
}

$commonSrc = Join-Path $SQLServerSrc "CommonFiles"
$commonDst = "C:\Program Files\Common Files\Microsoft Shared\SQL Server"
if (Test-Path $commonSrc) {
    Log "Copying SQL common files..."
    New-Item -ItemType Directory -Path $commonDst -Force | Out-Null
    Copy-Item "$commonSrc\*" "$commonDst\" -Recurse -Force
    OK "SQL common files copied"
}

# -----------------------------------------------
# STEP 3 - Copy SQLXML
# -----------------------------------------------
Step "Step 3: Copying SQLXML 3.0 files"
if (Test-Path $SQLXMLSrc) {
    Log "Copying SQLXML 3.0..."
    New-Item -ItemType Directory -Path $SQLXMLDest -Force | Out-Null
    Copy-Item "$SQLXMLSrc\*" "$SQLXMLDest\" -Recurse -Force
    OK "SQLXML 3.0 copied"
} else { WARN "SQLXML source not found, skipping" }

# -----------------------------------------------
# STEP 4 - Import registry keys (originals untouched)
# -----------------------------------------------
Step "Step 4: Importing registry keys"

$importOrder = @(
    "SOFTWARE_MSSQLServer.reg",
    "SOFTWARE_MicrosoftSQLServer.reg",
    "SOFTWARE_ODBC.reg",
    "SOFTWARE_GlobalVR.reg",
    "SOFTWARE_NvidiaGlobal.reg",
    "SYSTEM_Services_MSSQLSERVER.reg",
    "SYSTEM_Services_SQLSERVERAGENT.reg",
    "SYSTEM_Services_MSSQLAdHelper.reg",
    "SYSTEM_Environment.reg"
)

foreach ($regFile in $importOrder) {
    ImportReg (Join-Path $RegDir $regFile)
}

# -----------------------------------------------
# STEP 5 - Fix SQL paths in registry
# -----------------------------------------------
Step "Step 5: Fixing SQL Server paths in registry"

$paramsPath = "HKLM:\SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\Parameters"
if (Test-Path $paramsPath) {
    Set-ItemProperty $paramsPath -Name "SQLArg0" -Value "-dC:\Program Files\Microsoft SQL Server\MSSQL\Data\master.mdf"
    Set-ItemProperty $paramsPath -Name "SQLArg1" -Value "-eC:\Program Files\Microsoft SQL Server\MSSQL\LOG\ERRORLOG"
    Set-ItemProperty $paramsPath -Name "SQLArg2" -Value "-lC:\Program Files\Microsoft SQL Server\MSSQL\Data\mastlog.ldf"
    OK "SQLArg paths fixed"
} else { WARN "Parameters key not found" }

$setupPath = "HKLM:\SOFTWARE\Microsoft\MSSQLServer\Setup"
if (Test-Path $setupPath) {
    Set-ItemProperty $setupPath -Name "SQLDataRoot" -Value "C:\Program Files\Microsoft SQL Server\MSSQL" -ErrorAction SilentlyContinue
    Set-ItemProperty $setupPath -Name "SQLPath"     -Value "C:\Program Files\Microsoft SQL Server\MSSQL" -ErrorAction SilentlyContinue
    OK "Setup paths fixed"
}

# -----------------------------------------------
# STEP 6 - Fix SQL Server server-side protocol list
# -----------------------------------------------
Step "Step 6: Fixing SQL Server protocol list"

# Without this, SQL only listens on shared memory and osql -S . fails
$sslPath = "HKLM:\SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib"
if (Test-Path $sslPath) {
    $protocols = [string[]]@("tcp", "np")
    Set-ItemProperty $sslPath -Name "ProtocolList" -Value $protocols -Type MultiString
    OK "ProtocolList set to: tcp, np"
} else {
    WARN "SuperSocketNetLib key not found"
}

# -----------------------------------------------
# STEP 7 - Register SQL Server client DLLs
# -----------------------------------------------
Step "Step 7: Registering SQL Server client DLLs"

$sqlDLLs = @(
    "C:\Program Files\Microsoft SQL Server\MSSQL\Binn\ssmssh70.dll",
    "C:\Program Files\Microsoft SQL Server\MSSQL\Binn\ssnetlib.dll",
    "C:\Program Files\Microsoft SQL Server\MSSQL\Binn\sqlsrv32.dll",
    "C:\Program Files\Microsoft SQL Server\MSSQL\Binn\sqloledb.dll"
)

foreach ($dll in $sqlDLLs) {
    if (Test-Path $dll) {
        Log "Registering $([System.IO.Path]::GetFileName($dll))..."
        & regsvr32 /s "$dll"
        if ($LASTEXITCODE -eq 0) {
            OK "Registered: $([System.IO.Path]::GetFileName($dll))"
        } else {
            WARN "Failed (may not be COM dll, ok): $([System.IO.Path]::GetFileName($dll))"
        }
    } else {
        WARN "Not found, skipping: $dll"
    }
}

# -----------------------------------------------
# STEP 8 - Fix service ImagePath
# -----------------------------------------------
Step "Step 8: Fixing service binary paths"

foreach ($svcName in @("MSSQLSERVER", "SQLSERVERAGENT")) {
    $svcReg = "HKLM:\SYSTEM\CurrentControlSet\Services\$svcName"
    if (Test-Path $svcReg) {
        $imgPath = (Get-ItemProperty $svcReg -ErrorAction SilentlyContinue).ImagePath
        if ($imgPath) {
            $fixed = $imgPath -replace "^[A-Za-z]:\\", "C:\"
            Set-ItemProperty $svcReg -Name "ImagePath" -Value $fixed
            OK "$svcName ImagePath: $fixed"
        }
    } else { WARN "$svcName service key not found" }
}

# -----------------------------------------------
# STEP 9 - Start MSSQLSERVER
# -----------------------------------------------
Step "Step 9: Starting MSSQLSERVER service"

$svc = Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
if ($svc) {
    Log "Starting MSSQLSERVER..."
    Start-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    $svc.Refresh()
    if ($svc.Status -eq "Running") {
        OK "MSSQLSERVER is running!"
    } else {
        WARN "MSSQLSERVER status: $($svc.Status)"
        WARN "Check Event Viewer > Windows Logs > Application"
    }
} else {
    ERR "MSSQLSERVER service not found - registry import failed"
}

# -----------------------------------------------
# DONE
# -----------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Import complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Insert Disc 1 - extract game files to C:\Underground" -ForegroundColor Yellow
Write-Host "  2. Insert Disc 2 - extract remaining files" -ForegroundColor Yellow
Write-Host "  3. Register GVR DLLs with regsvr32" -ForegroundColor Yellow
Write-Host "  4. Run NFS.msi silently" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Enter to exit..."
Read-Host | Out-Null
