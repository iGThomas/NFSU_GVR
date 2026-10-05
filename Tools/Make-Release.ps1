<#
  Make-Release.ps1 - builds the download for a GitHub Release (developer tool).

  Zips the NFSU_GVR_Portable folder (the installer and everything it ships) into
  dist\NFSU_GVR_Portable-<Version>.zip. Upload that zip as the release asset.

    .\Tools\Make-Release.ps1 -Version 2.0
#>
param([Parameter(Mandatory = $true)][string]$Version)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot
$src = Join-Path $repo "NFSU_GVR_Portable"
$dist = Join-Path $repo "dist"
$zip = Join-Path $dist "NFSU_GVR_Portable-$Version.zip"

# the files that must be in every release (the installer warns but continues without them)
foreach ($f in @("Install-NFSU-GVR-Portable.ps1", "GvrLaunch.exe", "gvr_settings.ini",
                 "DLLs\GVRInputRaw.dll", "DLLs\GVRInputRaw_oem.dll", "DLLs\dsound.dll",
                 "Tools\unshield.exe", "SQLite\game.db")) {
    if (!(Test-Path (Join-Path $src $f))) { throw "missing from NFSU_GVR_Portable: $f" }
}
New-Item -ItemType Directory -Force $dist | Out-Null
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path $src -DestinationPath $zip
"{0}  ({1:N1} MB)" -f $zip, ((Get-Item $zip).Length / 1MB)
