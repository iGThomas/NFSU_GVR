# Apply-GvrSettings.ps1 - apply gvr_settings.ini to an installed NFSU GlobalVR (V3 portable).
#
# Both executables hardcode their resolution; there is no config file, registry value or
# command-line switch for it (the full 62-entry option table was dumped - the only display
# switches are -forcewindowed / -forcefullscreen, plus the undocumented -screenshot which
# forces 1280x1024). So resolution is applied by rewriting the constants in place:
#
#   UndergroundGVR.exe (native x86) - the race. The device is created from a hardcoded
#     call  FUN_005c3d30(800,600)  that fills D3DPRESENT_PARAMETERS.BackBufferWidth/Height.
#     Those are the two push immediates at file offsets 0x1c4323 (width) / 0x1c431e (height).
#     NOTE: the g_RacingResolution index (0x7b870c) and the mode table at 0x7b8640 do NOT
#     drive device creation - they size internal render targets, and a validity clamp
#     silently overrides them. Patching those does nothing; this call site is the real lever.
#
#   UniverShell2.exe (managed/CIL) - the frontend. Two ldc.i4 constants at file offsets
#     0x928d (width) / 0x9292 (height). Not strong-named, so an in-place edit still loads.
#
# Always patched FROM the pristine .orig backup, so re-applying is idempotent and never
# compounds. Refuses to touch a binary whose original bytes are not the expected 800x600.

[CmdletBinding()]
param(
    [string]$InstallRoot,           # e.g. D:\Games\NFSU_GVR  (defaults to this script's parent)
    [string]$SettingsFile,          # defaults to <InstallRoot>\gvr_settings.ini
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
trap { Write-Host "FAIL: $_" -ForegroundColor Red; exit 1 }

function Log($m)  { Write-Host "[settings] $m" }
function Warn($m) { Write-Host "[settings] WARN: $m" -ForegroundColor Yellow }

if (!$InstallRoot) { $InstallRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path) }
if (!$SettingsFile) { $SettingsFile = Join-Path $InstallRoot "gvr_settings.ini" }
if (!(Test-Path $SettingsFile)) { throw "settings file not found: $SettingsFile" }

# ---- tiny ini reader (no dependencies, PS2-safe) -------------------------------
function Read-Ini($path) {
    $ini = @{}; $section = ""
    foreach ($line in (Get-Content $path)) {
        $t = $line.Trim()
        if ($t -eq "" -or $t.StartsWith(";") -or $t.StartsWith("#")) { continue }
        if ($t.StartsWith("[") -and $t.EndsWith("]")) { $section = $t.Substring(1, $t.Length-2).Trim(); $ini[$section] = @{}; continue }
        $eq = $t.IndexOf("=")
        if ($eq -lt 1 -or $section -eq "") { continue }
        $ini[$section][$t.Substring(0,$eq).Trim()] = $t.Substring($eq+1).Trim()
    }
    return $ini
}

function Get-Int($ini,$section,$key,$default) {
    if ($ini.ContainsKey($section) -and $ini[$section].ContainsKey($key)) {
        $v = $ini[$section][$key]
        if ($v -match '^\s*(\d+)\s*$') { return [int]$matches[1] }
        Warn "[$section] $key='$v' is not a number - using $default"
    }
    return $default
}

# ---- the patch itself ----------------------------------------------------------
# Each target: file offsets of the width/height dwords, and the values they must hold
# in a pristine binary (a mismatch means a different build -> refuse rather than corrupt).
function Set-Resolution($exe, $wOff, $hOff, $expectW, $expectH, $w, $h, $label) {
    if (!(Test-Path $exe)) { Warn "$label not found ($exe) - skipped"; return }
    $orig = "$exe.orig"
    if (!(Test-Path $orig)) {
        Copy-Item $exe $orig -Force
        Log "  $label - saved pristine backup ($(Split-Path -Leaf $orig))"
    }
    # always start from the pristine copy so repeated runs are idempotent
    $bytes = [System.IO.File]::ReadAllBytes($orig)
    $curW = [BitConverter]::ToUInt32($bytes, $wOff)
    $curH = [BitConverter]::ToUInt32($bytes, $hOff)
    if ($curW -ne $expectW -or $curH -ne $expectH) {
        Warn "$label - backup does not look like the expected build (found ${curW}x${curH}, expected ${expectW}x${expectH}); NOT patching"
        return
    }
    if ($w -eq $expectW -and $h -eq $expectH) {
        if ($DryRun) { Log "  would restore $label to stock ${w}x${h}"; return }
        Copy-Item $orig $exe -Force
        Log "  $label -> ${w}x${h} (stock, restored from backup)"
        return
    }
    if ($DryRun) { Log "  would set $label to ${w}x${h}"; return }
    [Array]::Copy([BitConverter]::GetBytes([UInt32]$w), 0, $bytes, $wOff, 4)
    [Array]::Copy([BitConverter]::GetBytes([UInt32]$h), 0, $bytes, $hOff, 4)
    [System.IO.File]::WriteAllBytes($exe, $bytes)
    Log "  $label -> ${w}x${h}"
}

$ini = Read-Ini $SettingsFile
Log "reading $SettingsFile"

$raceW  = Get-Int $ini "Race"  "Width"  800
$raceH  = Get-Int $ini "Race"  "Height" 600
$shellW = Get-Int $ini "Shell" "Width"  800
$shellH = Get-Int $ini "Shell" "Height" 600

$ug  = Join-Path $InstallRoot "Underground"
$gr  = Join-Path $ug "GVR\GvrRoot"

Set-Resolution (Join-Path $ug "UndergroundGVR.exe") 0x1c4323 0x1c431e 800 600 $raceW  $raceH  "race  (UndergroundGVR.exe)"
Set-Resolution (Join-Path $gr "UniverShell2.exe")   0x928d   0x9292   800 600 $shellW $shellH "shell (UniverShell2.exe)"

# The engine derives vertical FOV from a fixed HORIZONTAL fov and the render aspect
# (out_y is divided by (height*tan(fov/2))/width), i.e. classic Vert-. At 16:9 that
# crops the top and bottom and reads as "zoomed in". A 4:3 resolution keeps the original
# camera geometry exactly; widescreen is sharper and fills the screen but is cropped.
if ($raceH -ne 0) {
    $ar = [math]::Round($raceW / [double]$raceH, 3)
    if ([math]::Abs($ar - 1.333) -gt 0.02) {
        Log ""
        Warn "race aspect is $ar (not 4:3). The engine uses a fixed horizontal FOV, so the"
        Warn "view is cropped vertically and looks slightly zoomed in. Use a 4:3 mode"
        Warn "(1280x960 or 1600x1200) if you prefer the original camera framing."
    }
}
Log "done."
