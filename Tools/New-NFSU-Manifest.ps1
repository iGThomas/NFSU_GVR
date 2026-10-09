<#
  New-NFSU-Manifest.ps1  (developer tool - NOT shipped to users)

  Snapshots a KNOWN-GOOD installed NFSU GVR tree into a manifest that
  Verify-NFSU-GVR.ps1 checks a user's install against, file by file.

  Output line format (pipe-delimited, one per file, paths relative to the
  install root, '\' separators, lowercased for comparison):

      <relative-path>|<size-bytes>|<sha256-hex>

  Volatile / per-machine files are EXCLUDED (they legitimately differ between
  installs): the LOG folder, gvr_settings.ini (user-edited), nfsu_registry.ini
  (created on first run), game.db (mutated by play), *.orig backups, *.log.

  Usage:
      .\New-NFSU-Manifest.ps1 -InstallRoot D:\Games\NFSU_GVR
      .\New-NFSU-Manifest.ps1 -InstallRoot D:\Games\NFSU_GVR -OutFile ..\NFSU_GVR_Portable\manifest.sha256
#>
param(
    [Parameter(Mandatory = $true)][string]$InstallRoot,
    [string]$OutFile = ""
)

$ErrorActionPreference = "Stop"
trap { Write-Host "[X] $($_.Exception.Message)" -ForegroundColor Red; exit 1 }

$Version = "2026-10-09-manifest-v1"

if (-not (Test-Path -LiteralPath $InstallRoot)) { throw "install root not found: $InstallRoot" }
$InstallRoot = (Resolve-Path -LiteralPath $InstallRoot).Path.TrimEnd('\')
if ([string]::IsNullOrEmpty($OutFile)) { $OutFile = Join-Path (Split-Path -Parent $PSScriptRoot) "NFSU_GVR_Portable\manifest.sha256" }

# files that legitimately differ per install - never put them in the manifest
$excludeRx = @(
    '\\LOG\\',                 # diagnostic logs
    '(^|\\)gvr_settings\.ini$',# user-edited settings
    '(^|\\)nfsu_registry\.ini$', # private registry, created on first run
    '(^|\\)game\.db($|-)',     # mutated by play (verified separately by Verify, by existence)
    '\.orig$', '\.log$', '\.tmp$',
    '(^|\\)manifest\.sha256$',
    '(^|\\)Verify-NFSU-GVR\.ps1$'
)

function Excluded($rel) {
    foreach ($rx in $excludeRx) { if ($rel -match $rx) { return $true } }
    return $false
}

function Sha256([string]$path) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    try {
        $bytes = $sha.ComputeHash($fs)
        -join ($bytes | ForEach-Object { $_.ToString("x2") })
    }
    finally { $fs.Close(); $sha.Clear() }
}

Write-Host "[i] manifest of $InstallRoot"
$all = Get-ChildItem -LiteralPath $InstallRoot -Recurse -File -Force -ErrorAction SilentlyContinue
$lines = New-Object System.Collections.ArrayList
$n = 0; $skipped = 0
foreach ($f in $all) {
    $rel = $f.FullName.Substring($InstallRoot.Length).TrimStart('\')
    if (Excluded $rel) { $skipped++; continue }
    $hash = Sha256 $f.FullName
    [void]$lines.Add(("{0}|{1}|{2}" -f $rel.ToLower(), $f.Length, $hash))
    $n++
    if ($n % 200 -eq 0) { Write-Host ("    hashed {0} files..." -f $n) }
}

$lines.Sort()
$header = @(
    "# NFSU GVR install manifest",
    "# $Version",
    "# source: $InstallRoot",
    "# generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "# format: relative-path|size|sha256   (volatile/per-machine files excluded)"
)
$outDir = Split-Path -Parent $OutFile
if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
Set-Content -LiteralPath $OutFile -Value ($header + $lines) -Encoding ASCII

Write-Host ("[OK] {0} files hashed, {1} volatile skipped -> {2}" -f $n, $skipped, $OutFile)
