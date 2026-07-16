# NFSU GlobalVR Game-Only Release Package

This release package is designed to install the GlobalVR NFS Underground game/runtime without running the original cabinet lockdown scripts.

It does not include the game payload. The installer asks for the original OEM Disc 1 and Disc 2, then stages and extracts the required payload locally.

## Included

- `Install-NFSU-GVR-AIO.ps1` - user-facing installer
- `Core\Install-NFSU-GVR-GameOnly.ps1` - tested core install logic
- `DLLs\` - mandatory legacy/GlobalVR dependency DLLs collected during testing
- `C\Program Files\Microsoft SQL Server\` - migrated MSDE/SQL Server 2000 runtime payload
- `C\Program Files\SQLXML 3.0\` - migrated SQLXML runtime payload
- `C\GvrPlus\` - GlobalVR Plus/.NET runtime binaries required by the frontend and Disc 2 database tooling
- `C\Windows\system32\` - selected support DLLs and NVIDIA compatibility files
- `Dependencies\DotNet11\dotnetfx.exe` - .NET Framework 1.1 redistributable used by GvrPlus tools
- `Database\` - decoded Disc 2 `nfscabinet` SQL/XML payload used to populate MSDE without running the hanging Disc 2 updater EXE
- `Reference_GVR_All.reg` and `Registry_Export.reg` - filtered registry sources used by the installer

## Not Included

- `C\Underground`
- `C\GvrRoot`
- `C\Gvr`
- Disc cabinet files such as `data1.cab`, `data2.cab`, or `data3.cab`
- Original `Setup.exe` execution flow or cabinet takeover scripts

Those are supplied by the user's original OEM media at install time.

## Install

Before mounting discs, put one supported InstallShield extractor in `Tools\`:

- `unshield.exe` preferred
- `isxunpack.exe`

Open an **elevated Administrator PowerShell window** and allow scripts to run first, otherwise
PowerShell blocks the installer or interrupts it with "Do you want to run this script?" prompts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

Then run the installer:

```powershell
cd C:\NFSU_GVR_Release
.\Install-NFSU-GVR-AIO.ps1
```

The script will ask for Disc 1 and Disc 2. Wait until the disc is fully mounted and visible before
pressing Enter - the installer logs each staged cabinet's size, and Disc 2's `data3.cab` must be
about 488 MB. It is mandatory: the OEM cabinet's `GvrRoot` file group spans volumes 1 to 3, so the
shell's content cannot be extracted from Disc 1 alone.

If SQL/MSDE needs a reboot after the service is installed, restart Windows and run the same AIO script again. The second run uses a resume marker at `C:\NFSU_GVR_AIO_State\resume-after-reboot.flag`, skips disc extraction when the game payload is already present, and finishes SQL/database/registry work.

## InstallShield Extractor Requirement

The OEM discs use old InstallShield cabinets, not standard Windows CAB files. Windows cannot extract them by itself.

Place one supported extractor in `Tools\` before running from discs:

- `unshield.exe` preferred
- `isxunpack.exe`

The older `i6comp.exe` tool is not accepted for disc mode in this release. The tested build extracts only InstallShield engine files and then fails on these OEM cabinets with `Could not open value.shl`.

If you already have a legally extracted OEM payload for testing, run:

```powershell
.\Install-NFSU-GVR-AIO.ps1 -ExpandedPayloadRoot C:\Path\To\ExtractedPayload
```

The extracted payload must contain `C\Underground`, `C\GvrRoot`, `C\GvrPlus`, and `C\Gvr`, or those four folders directly.

## Notes

- NVIDIA compatibility files are added only when missing. Existing NVIDIA files are never replaced by this release script.
- .NET Framework 1.1 is installed automatically from `Dependencies\DotNet11\dotnetfx.exe` when missing.
- Disc 2 database setup is run by default because the frontend depends on the populated MSDE database.
- The release imports `Database\nfscabinet.txt` and `Database\nfscabinet_Content.txt` directly with `osql`.
- `GvrPlusExportDatabaseScript.exe` and `UnregDlls.exe` are not launched as database/update steps because they can hang or crash on Win7 game-only installs.
- `MSSQLSERVER` is restarted before the database import because SQL 2000 may report as running before local connections are fully usable.
- For VirtualBox Win7 testing, `VBoxVGA` has been the working display adapter. `VBoxSVGA` caused misleading .NET/cordbg crash behavior.
