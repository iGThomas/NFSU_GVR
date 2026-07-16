# NFSU GlobalVR — SQLite Edition (Release V2)

A **standalone installer** for Need for Speed Underground: GlobalVR that installs
the game from your OEM discs and runs it on an **embedded SQLite database** instead
of MSDE / SQL Server 2000.

It prompts for Disc 1 / Disc 2, extracts and installs the game (same as the original
game-only installer), then patches the data engine to use SQLite. There is **no MSDE,
no SQLXML 3.0, no `osql` import, no `sa` password, and no reboot.**

## What's different from the MSDE installer (V1)

| | V1 (MSDE) | V2 (SQLite) |
|---|---|---|
| Ask for discs + install game | yes | **yes (unchanged)** |
| `C\Program Files\Microsoft SQL Server\` (62 MB) | copied + service installed | **not shipped, not installed** |
| `C\Program Files\SQLXML 3.0\` | copied + registered | **not shipped, not installed** |
| Database | `osql` import of nfscabinet + `sa` rotation | pre-seeded `game.db` |
| Reboot | required (SQL service) | **none** |
| DB engine | SQL Server 2000 service | in-process `sqlite3.dll` |

Internally V2 runs the same proven core game install with `-SkipSql` (game files,
.NET 1.1, registry, DLL/assembly registration, shortcut — no SQL), then deploys the
SQLite backend.

## Package contents
- `Install-NFSU-GVR-SQLite.ps1` — the installer
- `Core\` — the game-only core installer (run with `-SkipSql`)
- `Tools\unshield.exe` — InstallShield cabinet extractor
- `DLLs\`, `C\Windows\system32\`, `C\GvrPlus\` — game runtime / support files
- `Dependencies\DotNet11\dotnetfx.exe` — .NET Framework 1.1
- `Dependencies\DirectX9\` — DirectX 9 runtime (`dxsetup.exe` + cabs, incl. Managed DirectX)
- `SQLite\` — the SQLite backend: patched `PLUSDE.dll`, `GvrSqlite.dll` (native 1.1) + `GvrSqlite.cs`, `sqlite3.dll`, seeded `game.db`
- `Reference_GVR_All.reg`, `Registry_Export.reg`

## Install (elevated Administrator PowerShell)

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
cd <this folder>
.\Install-NFSU-GVR-SQLite.ps1
```

It asks for **Disc 1**, then (after staging) **Disc 2** — single-drive friendly, so
you can mount them one at a time. Wait until each disc is fully mounted before pressing
Enter; Disc 2's `data3.cab` (~488 MB) is mandatory (the shell's content spans cabinet
volumes 1–3).

Useful switches: `-DryRun` (preview), `-ExpandedPayloadRoot <dir>` (install from an
already-extracted payload instead of discs), `-ForceOverwrite` (replace existing game
files — test VMs only), `-Disc1Path` / `-Disc2Path` (skip the prompts).

When it finishes there is **no reboot for the database**. The SQLite provider builds
itself on the target with the machine's .NET 1.1 `csc` (prebuilt 1.1 binary is the
fallback), and the seeded db is installed to `C:\GvrPlus\game.db` with `GVRSQLITE_DB`
set. Launch `GVRBoot.exe` (full cabinet) or `Underground\UndergroundGVR.exe`.

Still requires a working Direct3D 9 device, same as the original game. It does **not**
require NVIDIA hardware — the required legacy NVIDIA support DLLs (`nvcpl.dll`,
`nv4_disp.dll`, `nvoglnt.dll`, etc.) are copied into `System32` by the installer.

## Diagnostics
The provider is silent by default. Set env var `GVRSQLITE_LOG` (to anything) to trace
every DB call + exception to `C:\gvrsqlite.log`.

## Revert
Before it is patched, each `PLUSDE.dll` is backed up as `PLUSDE.dll.sqlbak`. The backup is
only written when no `.sqlbak` already exists, so the very first (original, unpatched) DLL is
preserved across re-runs rather than being overwritten by an already-patched copy. To revert,
restore each `PLUSDE.dll.sqlbak` over its `PLUSDE.dll`.
