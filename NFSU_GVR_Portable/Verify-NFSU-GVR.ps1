<#
  Verify-NFSU-GVR.ps1  -  file-by-file integrity check of an NFSU GVR install.

  Compares every file in your install against manifest.sha256 (shipped next to
  this script) and reports what is MISSING, the WRONG SIZE, or a WRONG HASH
  (corrupt / different build) versus a known-good installation.

  Use it when the game will not start: a truncated or missing file from a bad
  copy or download is a common cause, and this pins it down in one pass.

      Right-click -> Run with PowerShell,  or:
      powershell -ExecutionPolicy Bypass -File Verify-NFSU-GVR.ps1

  Options:
      -InstallRoot <path>   the install to check (default: this script's folder)
      -QuickSizeOnly        check existence + size only (skip hashing; faster)
      -ShowOk               also list files that passed

  A report is written to <InstallRoot>\LOG\verify-report.txt - attach that to a
  bug report. PowerShell 2.0 compatible (Windows XP/7 onwards).
#>
param(
    [string]$InstallRoot = "",
    [string]$ManifestFile = "",
    [switch]$QuickSizeOnly,
    [switch]$ShowOk
)

$ErrorActionPreference = "Stop"
trap { Write-Host "[X] $($_.Exception.Message)" -ForegroundColor Red; exit 1 }

$Version = "2026-10-09-verify-v1"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($InstallRoot))  { $InstallRoot  = $scriptDir }
if ([string]::IsNullOrEmpty($ManifestFile)) { $ManifestFile = Join-Path $scriptDir "manifest.sha256" }

if (-not (Test-Path -LiteralPath $InstallRoot))  { throw "install folder not found: $InstallRoot" }
if (-not (Test-Path -LiteralPath $ManifestFile)) { throw "manifest not found: $ManifestFile (it ships next to this script)" }
$InstallRoot = (Resolve-Path -LiteralPath $InstallRoot).Path.TrimEnd('\')

# files whose correctness matters most for starting the game (flagged in the report)
$criticalRx = @(
    'gvrlaunch\.exe$','gvrinputraw\.dll$','gvrinputraw_oem\.dll$','dsound\.dll$',
    'plusde\.dll$','gvrsqlite\.dll$','sqlite3\.dll$','univershell2\.exe$',
    'undergroundgvr\.exe$','\.enc$','\\gvr\\[^\\]*\.gvr$','msvcr71\.dll$','msvcp71\.dll$'
)
function IsCritical($rel) { foreach ($rx in $criticalRx) { if ($rel -match $rx) { return $true } } return $false }

function Sha256([string]$path) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    try { $b = $sha.ComputeHash($fs); (-join ($b | ForEach-Object { $_.ToString("x2") })) }
    finally { $fs.Close(); $sha.Clear() }
}

$report = New-Object System.Collections.ArrayList
function Emit($line) { [void]$report.Add($line); Write-Host $line }

Emit "NFSU GVR install verification  ($Version)"
Emit "  install : $InstallRoot"
# echo the manifest header (source/version) so it is clear what we compared against
Get-Content -LiteralPath $ManifestFile | Where-Object { $_ -like '#*' } | ForEach-Object { Emit ("  manifest: " + $_.TrimStart('# ')) }
Emit ("  mode    : " + $(if ($QuickSizeOnly) { "existence + size only" } else { "existence + size + SHA-256" }))
Emit ""

$missing = New-Object System.Collections.ArrayList
$sizeBad = New-Object System.Collections.ArrayList
$hashBad = New-Object System.Collections.ArrayList
$okCount = 0; $total = 0

foreach ($line in (Get-Content -LiteralPath $ManifestFile)) {
    if ($line -like '#*' -or [string]::IsNullOrEmpty($line)) { continue }
    $parts = $line.Split('|')
    if ($parts.Count -lt 3) { continue }
    $rel = $parts[0]; $size = [int64]$parts[1]; $sha = $parts[2]
    $total++
    $full = Join-Path $InstallRoot $rel
    $crit = IsCritical $rel
    $tag = $(if ($crit) { "[CRITICAL] " } else { "" })
    if (-not (Test-Path -LiteralPath $full)) { [void]$missing.Add("$tag$rel"); continue }
    $fi = Get-Item -LiteralPath $full
    if ($fi.Length -ne $size) { [void]$sizeBad.Add(("{0}{1}  (have {2}, expected {3} bytes)" -f $tag, $rel, $fi.Length, $size)); continue }
    if (-not $QuickSizeOnly) {
        $h = Sha256 $full
        if ($h -ne $sha) { [void]$hashBad.Add("$tag$rel"); continue }
    }
    $okCount++
    if ($ShowOk) { Emit "  OK    $rel" }
}

# game.db is excluded from the manifest (it changes with play); check it exists and looks valid
$dbRel = "Underground\GVR\GvrPlus\game.db"
$db = Join-Path $InstallRoot $dbRel
$dbNote = ""
if (-not (Test-Path -LiteralPath $db)) { $dbNote = "MISSING - the database was not created (install/first-run did not complete)" }
else {
    $fs = [System.IO.File]::Open($db, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try { $hdr = New-Object byte[] 16; [void]$fs.Read($hdr, 0, 16) } finally { $fs.Close() }
    $magic = [System.Text.Encoding]::ASCII.GetString($hdr, 0, 15)
    if ($magic -eq "SQLite format 3") { $dbNote = "present, valid SQLite ($((Get-Item -LiteralPath $db).Length) bytes)" }
    else { $dbNote = "present but NOT a valid SQLite file (corrupt)" }
}

Emit ""
Emit "---------------------------------------------"
Emit ("checked : {0} files" -f $total)
Emit ("  OK        : {0}" -f $okCount)
Emit ("  MISSING   : {0}" -f $missing.Count)
Emit ("  WRONG SIZE: {0}" -f $sizeBad.Count)
if (-not $QuickSizeOnly) { Emit ("  WRONG HASH: {0}" -f $hashBad.Count) }
Emit ("game.db   : {0}" -f $dbNote)
Emit "---------------------------------------------"

function Dump($title, $list) {
    if ($list.Count -eq 0) { return }
    Emit ""; Emit ("{0} ({1}):" -f $title, $list.Count)
    # critical first
    $list | Where-Object { $_ -like '`[CRITICAL`]*' } | ForEach-Object { Emit "  $_" }
    $list | Where-Object { $_ -notlike '`[CRITICAL`]*' } | ForEach-Object { Emit "  $_" }
}
Dump "MISSING files"    $missing
Dump "WRONG SIZE files" $sizeBad
Dump "WRONG HASH files (corrupt or a different build)" $hashBad

$problems = $missing.Count + $sizeBad.Count + $hashBad.Count
Emit ""
if ($problems -eq 0 -and $dbNote -notlike "*MISSING*" -and $dbNote -notlike "*corrupt*") {
    Emit "RESULT: install matches the reference. Files are intact."
} else {
    Emit "RESULT: PROBLEMS FOUND. A [CRITICAL] entry above is very likely why the game will not start."
    Emit "        Re-run Install.bat into this folder to repair, or reinstall cleanly."
}

# write the report into LOG\ so it can be attached to a bug report
try {
    $logDir = Join-Path $InstallRoot "LOG"
    if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
    $rf = Join-Path $logDir "verify-report.txt"
    Set-Content -LiteralPath $rf -Value $report -Encoding ASCII
    Write-Host ""
    Write-Host "[i] report written to $rf"
} catch { Write-Host "[!] could not write report to LOG: $($_.Exception.Message)" }

if ($problems -gt 0) { exit 2 } else { exit 0 }
