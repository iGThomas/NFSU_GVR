# NFSU GlobalVR — Portable SQLite Edition (Release V2)

Installs Need for Speed Underground: GlobalVR into **one folder of your choice**,
with the GVR folders **nested inside it**, running on **SQLite** — no fixed `C:\`
paths, no MSDE / SQL Server / SQLXML, no cabinet-lockdown boot entries.

Runs on **Windows XP → Windows 11 (x64)**.

## Layout it produces
For an install root you choose (e.g. `D:\Games\NFSU`):
```
D:\Games\NFSU\Underground\                game (UndergroundGVR.exe, TRACKS, ...)
D:\Games\NFSU\Underground\GVR\GvrRoot\    arcade shell (UniverShell2/GVRBoot + gvr\*.gvr)
D:\Games\NFSU\Underground\GVR\GvrPlus\    plus libs + schema + game.db
D:\Games\NFSU\Underground\GVR\Gvr\        helpers
D:\Games\NFSU\gvr_settings.ini            resolution settings (editable)
D:\Games\NFSU\Tools\Apply-GvrSettings.ps1
```

## How it stays location-independent
- **Registry:** the installer emits every GVR path key pointing at your chosen
  folder (`NFSUNDERGROUND\Ini`, `Gvr\Plus\1.1\Cabinet`/`Server` `PlusSchemaPath`,
  `PublicKeyPath`, `GVRCrashMonitor\Prog0x path`). The game reads its locations
  from these keys — verified in the binaries.
- **Shell:** `UniverShell2.exe`'s hardcoded `C:\gvrRoot\…` strings were confirmed
  by Ghidra to be **dead editor constants** (zero code references); at runtime the
  shell loads content relative to its working dir. No binary patching needed.
- **SQLite db:** the provider derives `game.db` from the registry `PlusSchemaPath`
  (`<GvrPlus>\game.db`), so it's always co-located — no env var, no reboot.
- **GVRD content:** the four binary containers in `GvrRoot\gvr`
  (`CommandlineArgs_data`, `OperatorData`, `normalData`, `OpReg_data`) hold absolute
  paths (game exe/workdir, per-car `vinyls.bin`, volume/gamma/lib paths) and are
  rebuilt in place for the chosen root. Without this, "start race" silently returns
  to the frontend.
- **Batch files** (`setcab*.bat`, `ResetShadows.bat`, `UnregisterDlls.bat`) are
  rewritten to the new paths.
- Runtime DLLs and the patched engine/provider are placed **app-local** (beside the
  EXEs), so nothing depends on `C:\Windows\system32`.

## Windows 10 / 11 (x64) support
Each of these is a separate, clearly-marked block in the installer and is gated so a
genuine XP/Win7 install is unaffected:

- **Registry into WOW6432Node.** The game is 32-bit and reads `HKLM\SOFTWARE` through
  the WOW64 view; a 64-bit `reg.exe` import alone leaves it blind (game exits `-10`).
  The installer imports into both views via `SysWOW64\reg.exe`.
- **Real .NET 1.1 SP1 via slipstream.** Plain `dotnetfx.exe` fails with MSI 1603 on
  Win10/11. The installer builds an administrative image, applies the SP1 patch, and
  installs that. CLR 2.0 redirection via `.exe.config` is **not** a substitute —
  `PLUSDE.dll`'s mixed-mode native C++ exception handling access-violates on CLR 2.0.
- **DXVK (D3D9→Vulkan), game-side only.** NFSU's physics is framerate-tied and the
  game has no vsync switch — on a modern GPU it runs at hundreds of fps and the
  driving is absurdly fast. `dxvk.conf` caps it to 60. *Not* deployed next to the
  shell: tried, did not help, and broke the intro video.
- **Cabinet `GammaSet.exe` disabled.** The shell spawns it ~5s after start; it
  hard-codes `rundll32 NvCpl.dll,dtcfg …`, and on 64-bit Windows the 32-bit rundll32
  can't find `NvCpl.dll` (only the 64-bit copy exists), producing a RunDLL error
  popup on every launch. It only set gamma `1.00` (a no-op) and a CRT vibrance tweak,
  so nothing is lost. Left enabled where a 32-bit `NvCpl.dll` is present.

## Resolution — `gvr_settings.ini`
Neither executable has any resolution setting: no ini, no registry value, no
command-line switch. Both are set by rewriting constants in place. Edit
`gvr_settings.ini`, then run `Tools\Apply-GvrSettings.ps1`.

```ini
[Race]      ; UndergroundGVR.exe  (fullscreen)
Width=1280
Height=960

[Shell]     ; UniverShell2.exe    (borderless window)
Width=1440
Height=1080
```

A pristine `<exe>.orig` is kept and every run re-patches **from that backup**, so it's
idempotent and setting `800x600` restores the untouched original.

**Use a 4:3 mode.** The engine derives vertical FOV from a fixed *horizontal* FOV and
never adapts the projection to the render aspect, so a 16:9 resolution stretches the
image. 1280×960 gives 2.5× the stock pixels with the original camera geometry,
pillarboxed. (Generic wrappers like dgVoodoo2/DXVK only scale output — they cannot fix
a projection. ThirteenAG's retail NFSU WidescreenFix loads but is inert here: only
9 of its 42 byte patterns match this recompiled build.)

## Free play is ON by default
The shipped `game.db` has `Settings_NFS1.FreePlay = 1`. **This is deliberate and is the only
value changed from the stock cabinet settings row.**

The stock value is `0` because this is arcade software — an operator wants the coin door to
charge for each play. A home install has no coin mechanism and no dongle, so with free play
off the frontend asks for credits it can never receive, and the game looks broken.

It is still a normal operator setting: press **`O`** in the frontend to open the operator menu
and switch it back off if you want genuine coin-op behaviour.

## Install (elevated Administrator PowerShell)
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
cd <this folder>
.\Install-NFSU-GVR-Portable.ps1
```
It asks **where to install**, then for **Disc 1** and **Disc 2**, extracts the game
into the nested layout, wires the registry, and deploys the SQLite backend. The
provider is compiled on the target with its .NET 1.1 `csc` (prebuilt binary is a
fallback). No reboot needed.

Switches: `-InstallRoot <dir>`, `-ExpandedPayloadRoot <dir>` (skip discs), `-DryRun`,
`-ForceOverwrite`, `-Disc1Path`/`-Disc2Path`, `-SkipDirectX`, `-SkipDotNet`.

The desktop shortcut launches `GvrRoot\UniverShell2.exe` (the frontend). The arcade
`GVRBoot` chain (dongle/coin/stall monitors + 60s warm-up) is deliberately skipped —
it isn't needed for home play and its crash monitor spawns no children on a normal PC.

## Package contents
`Install-NFSU-GVR-Portable.ps1`, `gvr_settings.ini`, `Tools\` (`unshield.exe`,
`Apply-GvrSettings.ps1`), `DLLs\` (runtime DLLs), `Dependencies\` (`DotNet11` incl.
the SP1 patch, `DirectX9`, `DXVK`), `SQLite\` (patched `PLUSDE.dll`, `GvrSqlite.dll`
+ `.cs`, `sqlite3.dll`, seeded `game.db`), `Reference_GVR_All.reg`.
Not included: the game payload (from your OEM discs).

## Diagnostics
Set env var `GVRSQLITE_LOG=1` to trace every SQL statement and error. On Windows
Vista+ the log is redirected by UAC virtualisation to
`%LOCALAPPDATA%\VirtualStore\gvrsqlite.log`.

This is the first thing to check for odd frontend behaviour — the provider is a
hand-written shim, so any untranslated T-SQL fails at prepare time and silently
returns **zero rows** with no error shown in-game. Grep the log for `prepare FAIL`.
(That is exactly how the "all cars are white in the car-select screen" bug was found:
the shell issues `SELECT TOP 1 * FROM CarConfiguration_NFS1 …`, which SQLite cannot
parse — so it got no car configuration and drew every car with no paint or vinyl.)
