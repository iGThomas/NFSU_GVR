# Technical Notes

[← Back to main README](../README.md)

Reference material discovered while reverse engineering the Global VR installation.

---

## Contents

- [Required Registry Values](#required-registry-values)
- [SQL Password Findings](#sql-password-findings)
- [SQL Tools](#sql-tools)
- [GPU Driver Requirement](#gpu-driver-requirement)
- [Dongle and Smart Card Notes](#dongle-and-smart-card-notes)
- [Game Controls](#game-controls)
- [Launch Arguments](#launch-arguments)
- [UndergroundGVR.exe Command-Line Options (complete)](#undergroundgvrexe-command-line-options-complete)
- [Resolution and Widescreen](#resolution-and-widescreen)
- [SQLite Backend: T-SQL Dialect Gaps](#sqlite-backend-t-sql-dialect-gaps)
- [Windows 10 / 11 (x64) Notes](#windows-10--11-x64-notes)
- [Cabinet Leftovers Worth Disabling](#cabinet-leftovers-worth-disabling)

---

## Required Registry Values

Open Registry Editor and navigate to:

```
HKLM\System\CurrentControlSet\Control\Session Manager\Environment
```

Add this string value (required for the installer to continue):

```
Name:  RUNTIMEOEMREV
Type:  String
Value: NFS - UG,XP Embedded,HW Rev 865 e,05052005
```

These values also appear related, though they do not block the installation:

```
Name:  RUNTIMEGUID
Type:  String
Value: {657AA858-5ACA-4F13-9855-E645192C4A8F}

Name:  RUNTIMEPID
Type:  String
Value: Q79DV-JVH86-MGXYC-67TQJ-Q2M2J

Name:  RUNTIMESKUCODE
Type:  String
Value: XPeCli
```

## SQL Password Findings

After game installation, the SQL password is changed.

Using `dnSpy` to analyze `GvRPlusExportDatabaseScript.exe`, it was found that the tool decrypts an encrypted XML file and changes the SQL password.

The encrypted file:

```
nfscabinetXml.enc
```

After decrypting with a Python script, the raw `nfscabinetXml` file contained the SQL password in plain text:

```
Q31y2Z29wpEsd
```

To log in to the database:

```cmd
osql -U sa -P Q31y2Z29wpEsd -S .
```

## SQL Tools

To browse the database with a UI instead of the command line, use the old Microsoft SQL tool:

```
http://download.microsoft.com/download/SQLSVR2000/Trial/2000/NT45/EN-US/SQLEVAL.exe
```

## GPU Driver Requirement

The game checks for NVIDIA support files at startup. This was originally discovered as a hard
requirement: testing confirmed the game started on an Acer Aspire 9300 (AMD CPU + NVIDIA GeForce
Go 6100) only once the NVIDIA video drivers were installed, and it could not be started
successfully inside a virtual machine.

**This is now worked around by the installer.** `Install-LegacyNvidiaCplFiles` in the core
installer copies the bundled legacy NVIDIA support DLLs (`nvcpl.dll`, `nv4_disp.dll`,
`nvoglnt.dll`, `nvmctray.dll`, etc.) into `System32` to satisfy that check, so **actual NVIDIA
hardware is no longer required**. Note this copies support DLLs only — it does *not* install an
NVIDIA display driver; on real NVIDIA hardware, use the correct driver installer instead.

A working Direct3D 9 device is still required.

## Dongle and Smart Card Notes

On a standalone Windows XP SP3 installation, the dongle was **not required** for the game to boot.

This differs from the original recovery disc installation where the dongle is normally required. Most likely, a registry value or service related to the dongle is missing from the standalone XP installation, which unintentionally bypasses the dongle check.

Career mode is greyed out due to the absence of a smart card reader.

## Game Controls

| Key | Action |
|-----|--------|
| `Numpad 8` | Accelerate |
| `Numpad 4` | Steer left |
| `Numpad 6` | Steer right |
| `O` | Operator menu |
| `Arrow keys` | Scroll in operator menu |
| `S` | Start / reset car |
| `N` | Nitrous |
| `V` | Change view |
| `Q` | Quit |
| `E` | E-brake |
| `M` | Reduce song volume / stop music / change song |

## Launch Arguments

To be used in CMD with UniverShell2.exe. For example `./UniverShell2.exe -debug -minvol 0 -maxvol 10`

- nosnapshot
- texmem
- minvol
- maxvol
- debug
- anisotropic
- multisample
- threadmonitor
- fps
- releasemouse
- notop
- editor

---

## UndergroundGVR.exe Command-Line Options (complete)

Recovered from the option table in `.data` starting around `0x0079e3b8` — pairs of
`{int index, char* name}`. The parser sets a flag byte in an array at base **`0x818138`**
indexed by the option id (so `forcewindowed` = id 3 → `0x81813b`, `forcefullscreen` = id 10
→ `0x818142`).

```
carupgrade  trans  graphicsdetail  forcewindowed  stabilitycontrol  camerastiffness
showfps  demoshellmode  gain  dragpilot  forcefullscreen  nojumpcam  noabort  givemenos
noBlur  server  join  numclients  nosound  screenshot  quitearly  playernumber
nogvrinput  custom  catchup  showcatchup  fasterload  numdrags  gvrtournament  track
laps  car  aicars  traffic  aidiff  musictrack  direction  jesler  replayshadow
pauseworld  customize  career  careerrace  notimeout  nosql  resultsTime  nohud  speedo
ImpactForce  ffdropoff  initializeplustabledata  checkpointDiff  nomusic  careerCheat
volume  hardwalls  resetdebug  showdist  shortcheckpoint  serverschema  region
dummytourney
```

Notable ones:

| Option | Effect |
|--------|--------|
| `-screenshot` | **Undocumented high-res mode** — forces 1280×1024 fullscreen, no patching needed |
| `-forcewindowed` / `-forcefullscreen` | the only other display switches |
| `-nosql` | skip PlusDE init (`-nosql specified - PlusDE not initialized!`) |
| `-showfps` | frame counter |
| `-initializeplustabledata` | seeds the GVR Plus tables (needs SQL up first) |

There is **no** width/height/resolution/fov option — the full table was dumped to be sure.

## Resolution and Widescreen

Neither executable has any resolution setting: no ini, no registry value, no command-line
switch. Both hardcode it, so Release V2 rewrites the constants in place (`gvr_settings.ini`
plus `Tools\Apply-GvrSettings.ps1`, always re-patched from a pristine `<exe>.orig`).

**UndergroundGVR.exe** (native x86, image base `0x400000`) — device init is `FUN_005c40e0`,
which calls the hardcoded `FUN_005c3d30(800,600)`; those two args become
`D3DPRESENT_PARAMETERS.BackBufferWidth/Height` (struct at `0x00c24904`). That call site is
the only lever:

| What | File offset | VA |
|------|-------------|-----|
| race width | `0x1c4323` | `0x005c4323` |
| race height | `0x1c431e` | `0x005c431e` |

**Three dead ends** — all look authoritative, all are ignored by the game:

1. the `.data` "current resolution" block at `0x007b8668` (`800, 600, 32, 100`) — overwritten
   at runtime;
2. the mode table at `0x007b8640` (widths `640/800/1024/1280/1280`, heights
   `480/600/768/960/1024`) — real, but it only sizes internal render targets;
3. `g_RacingResolution` at `0x007b870c` (initialised to `1`) — written at runtime from five or
   more sites (three of them set it to `4`) and then clamped by `FUN_005ccd80` against
   `g_RacingResolutionValid[]` (`0x00c27db8`, in `.bss`, filled by display-mode enumeration).
   The dispatch at `0x005c50c0` (jump table at `0x005c51dc`, 5 cases) maps that index to a
   width/height pair, but it is **not** what `CreateDevice` uses.

**UniverShell2.exe** is a **managed (CIL) assembly** — Ghidra's x86 decompiler is useless on
it (it renders the whole managed blob as a single 151k-character "function"; use ILSpy or
dnSpy instead). The window size is two `ldc.i4` constants, and the assembly is not
strong-named, so an in-place edit still loads:

| What | File offset | VA |
|------|-------------|-----|
| shell width | `0x928d` | `0x0040928d` |
| shell height | `0x9292` | `0x00409292` |

The shell is a borderless 800×600 window, and the cabinet ran the *desktop* at 800×600
(`NFSSetDesktop2.exe`) so that window filled the screen. On a modern desktop it simply sits
in the top-left corner — that is the whole "frontend is a small window" symptom.

### Widescreen is not fixable cheaply

At 16:9 the image **stretches**: the projection never adapts to the render aspect. The
engine's convention, from `FUN_0058a7b0`:

```
out_y = (y * invz) / ((height * tan(fov/2)) / width)
```

— a fixed *horizontal* FOV with the vertical derived from it. FOV itself is a per-camera
`ushort` binary angle at **`camera+0xC4`**, sourced from camera data, not a single global.
The projection-matrix construction was never located: `PROJECTIONTRANSFORM` (`0x0075195c`)
has no code xrefs (it is resolved by name as a shader constant), there is no `aspect` string
and no `4/3` float constant anywhere in the image, and the camera math runs through thunks.
Beware: `+0xC4` is a **drift-scoring bitfield** in `FUN_0058ad80` — not every `+0xC4` is FOV.

**Practical answer: use a 4:3 mode** (1280×960 or 1600×1200) — correct camera geometry,
2.5× the stock pixels, pillarboxed. Generic wrappers (dgVoodoo2, DXVK) only scale output and
cannot rewrite a projection, so they reproduce the same stretch.

### ThirteenAG's NFSU WidescreenFix does not work here

GVR **is** the retail NFS Underground engine — confirmed from both directions: the retail
fix's source references `g_RacingResolution`, the same symbol as GVR's assert string
(`GSystem.g_RacingResolutionValid[(int)GSystem.g_RacingResolution]`), and the
resolution-select code is identical instruction-for-instruction.

But of the **42 byte patterns** in `NFSUnderground.WidescreenFix.asi`, only **9** match this
binary, and every important one misses. The reason is visible in the near-miss — retail
`B8 20 03 00 00 BE 58 02 00 00 77 75` versus GVR `B8 20 03 00 00 B9 58 02 00 00 77 75`: the
same source, recompiled, with **different register allocation** (`esi` vs `ecx`).

Tested for real (`dinput8.dll` proxy plus `scripts\` dropped into `Underground\`): the ASI
**loads**, does **not** crash (pattern misses fail soft), and applies **nothing**.

Two things worth keeping from that experiment:

- **The ASI injection path works in UndergroundGVR.** The exe statically imports
  `DINPUT8.dll`, so an app-local `dinput8.dll` proxy loads and correctly chain-loads
  `C:\WINDOWS\system32\DINPUT8.dll`. A GVR-specific `.asi` is therefore buildable — but
  pointless until the projection-matrix construction is found.
- **To verify what a 32-bit process loaded, use 32-bit PowerShell.** `Get-Process().Modules`
  and `tasklist /m` are both blind across WOW64 (they showed neither `d3d9.dll` nor the ASI);
  `%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe` listed all 120 modules
  immediately.

## SQLite Backend: T-SQL Dialect Gaps

The SQLite provider (`GvrSqlite.dll`) is a hand-written ADO.NET-shaped shim, so **any T-SQL
construct it does not translate fails at prepare time and silently returns zero rows** — the
game shows no error, it just renders whatever "no data" looks like.

Real example: the frontend issues

```sql
SELECT TOP 1 * FROM CarConfiguration_NFS1 WHERE ConfigType = <n> AND CarType = <n>
```

per highlighted car. `TOP` is SQL Server syntax; SQLite uses a trailing `LIMIT`. SQLite
failed with `near "1": syntax error`, the shell got no car configuration, and **every car in
the car-select screen rendered plain white** (no paint, no vinyl) — 276 failed queries in a
single browse. The same syntax also broke the leaderboard/best-time queries
(`GameResult_NFS1`) and `TempPlayerInfo_NFS1`. In-race liveries were always correct, because
the game reads car appearance from its own files, not from that query.

Fixed in `Sql.FixDialect()` (which also handles `dbo.` and `GETDATE()`) via `TopToLimit()`,
rewriting `SELECT [DISTINCT] TOP n|(n) …` into `… LIMIT n`. It deliberately declines
`TOP n PERCENT` and statements that already carry a `LIMIT`, rather than silently returning
the wrong rows.

**Debugging method — try this first for any strange frontend behaviour:** launch with
`GVRSQLITE_LOG=1`, exercise the screen, then grep the log (Vista+:
`%LOCALAPPDATA%\VirtualStore\gvrsqlite.log`) for `prepare FAIL` / `Fill EX`. It prints every
statement and every error, and it found the above in about a minute. Screens not yet
exercised (career, tournaments, operator menu) may still hide more untranslated T-SQL.

Related: the frontend also **hangs in a pricing-init loop** unless `game.db` is provisioned
with the GVR Plus operator tables (bulk-loaded from `PlusScripts\a+*.tbl`), a synthesised
free-play cabinet, and the bogus duplicate `GvrGame` row removed. The shipped `game.db` has
this already done.

## Windows 10 / 11 (x64) Notes

- **The registry must land in `WOW6432Node`.** The game is 32-bit and reads `HKLM\SOFTWARE`
  through the WOW64 view. Importing with the 64-bit `reg.exe` only populates the 64-bit view
  and the game exits with code `-10`. Import with `%WINDIR%\SysWOW64\reg.exe` as well.
- **.NET 1.1 needs an SP1 slipstream.** Plain `dotnetfx.exe` fails with MSI **1603** on
  Win10/11. Extract it, build an administrative image (`msiexec /a`), apply
  `NDP1.1sp1-KB867460-X86.exe` (`msiexec /a /p`), then install that image.
- **Do not redirect to CLR 2.0.** Binding the game to .NET 2.0 with an `.exe.config` looks
  like an easy fix and produces an `AccessViolationException` inside
  `GvrDataEngine.GetGvrObject` / `__CxxQueryExceptionSize` — `PLUSDE.dll` is mixed-mode and
  uses native C++ exception handling as control flow, which CLR 2.0 does not tolerate.
- **`GvrSqlite.dll` must be compiled with the real 1.1 `csc`.** A 2.0-built assembly is
  rejected by CLR 1.1 with `BadImageFormat`.
- **Framerate-tied physics.** The game has no vsync switch and the cabinet ran a fixed-60Hz
  CRT, so on a modern GPU it runs at hundreds of fps and drives absurdly fast. An app-local
  DXVK `d3d9.dll` with `d3d9.maxFrameRate = 60` fixes it. Deploy it **next to the game only**
  — next to the shell it did not help and it broke the intro video.

## Cabinet Leftovers Worth Disabling

- **`Gvr\system\GammaSet.exe`** — the shell spawns it (`-gammasetting 0`) about five seconds
  after start. It is a Hot Pursuit 2-era cabinet tool (its PDB path is still
  `c:\Projects\HP2v1_1\GammaSet`) that hard-codes:

  ```
  rundll32.exe NvCpl.dll,dtcfg setgamma all all %1.2f
  rundll32.exe NvCpl.dll,dtcfg setdvc  all 22
  ```

  On 64-bit Windows the **32-bit** rundll32 searches `SysWOW64`, where `NvCpl.dll` does not
  exist (modern NVIDIA drivers ship only the 64-bit copy in `System32`, and non-NVIDIA GPUs
  have none), so each call raises *"There was a problem starting NvCpl.dll"*. It is not
  fatal, but it pops on every launch. Nothing is lost by disabling it: gamma `1.00` is the
  neutral no-op value and `setdvc 22` is a mild vibrance tweak calibrated for the cabinet's
  CRT.

- **`GVRBoot.exe` / `GVRCrashMonitor`** — the arcade boot chain (dongle, coin and stall
  monitors plus a 60-second warm-up). On a normal PC the crash monitor spawns no children, so
  nothing starts. Launch `GvrRoot\UniverShell2.exe` directly instead; the frontend → race
  flow is complete without it.

---

[← Back to main README](../README.md)
