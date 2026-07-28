# NFSU_GVR_Portable — NFS Underground: GlobalVR as a normal Windows game

Installs Need for Speed Underground: GlobalVR into **one folder of your choice**,
with the GVR folders **nested inside it**, running on **SQLite** — no fixed `C:\`
paths, no MSDE / SQL Server / SQLXML, no cabinet-lockdown boot entries.

Runs on **Windows XP → Windows 11 (x64)**.

**Download the ZIP from the Releases page, extract it anywhere, and run the installer below.**
You supply the game itself: the original OEM **Disc 1** and **Disc 2**. Nothing from the discs
is redistributed here — the installer reads them on your machine.

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

**Re-running the installer keeps your `game.db`.** Once the game has run, that file is no
longer seed data — it holds your car configurations, leaderboards and best times, and
everything set in the `O` operator menu. So a repair install preserves it. Pass
`-ForceOverwrite` if you deliberately want to reset it back to the shipped seed.

The desktop shortcut (with the game's icon) launches **`GvrLaunch.exe`** in the install root, which applies
`gvr_settings.ini` and then starts the frontend. (Starting `GvrRoot\UniverShell2.exe`
directly still works — you just don't get the `[Display]` window size or the backdrop.)
The arcade `GVRBoot` chain (dongle/coin/stall monitors + 60s warm-up) is deliberately
skipped — it isn't needed for home play and its crash monitor spawns no children on a
normal PC.

At the end the installer **verifies** that `GVRInputRaw.dll`, `GVRInputRaw_oem.dll`,
`dsound.dll` and `gvr_settings.ini` all landed, and warns per file if one is missing —
each of those fails in a way that is otherwise hard to attribute (see the warning under
*Package contents*).

## Layout it produces
For an install root you choose (e.g. `D:\Games\NFSU`):
```
D:\Games\NFSU\Underground\                game (UndergroundGVR.exe, TRACKS, ...)
D:\Games\NFSU\Underground\GVR\GvrRoot\    arcade shell (UniverShell2/GVRBoot + gvr\*.gvr)
D:\Games\NFSU\Underground\GVR\GvrPlus\    plus libs + schema + game.db
D:\Games\NFSU\Underground\GVR\Gvr\        helpers
D:\Games\NFSU\GvrLaunch.exe               start the game with this
D:\Games\NFSU\gvr_settings.ini            all settings (editable)
D:\Games\NFSU\Fonts\                      the OEM fonts (see below)
D:\Games\NFSU\NFSU_GVR.ico                shortcut icon
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

## Everything is configured in one file — `gvr_settings.ini`
Neither executable has a settings screen, so all of this is applied at launch by
`GvrLaunch.exe` + `GVRInputRaw.dll`. **Start the game with `GvrLaunch.exe`** (in the
install root) and just edit the ini — nothing else to run, and **the executables are
never modified**.

```ini
[Display]     ; ONE size for both the frontend and the race, so they line up
Width=1440         ; installer picks the largest 4:3 that fits your screen
Height=1080
Fullscreen=false   ; default: borderless window. true = take over the screen
Borderless=true    ; windowed only: no title bar, centred

[Controller]  ; gamepad map in a race - see "Controller support"
Cross    = ebrake, confirm, skipintro
Circle   = nitrous
...

[Frontend]    ; gamepad map in the menus
Cross    = select
R3       = card
...

[Launcher]
Backdrop=true      ; show the game's boot screen between frontend and race
Merge=false        ; experimental, see Known behaviour
```

On a **fresh install** the installer measures your primary screen and writes the largest 4:3
size that fits (1920×1080 → `1440x1080`), because the engine needs 4:3 (see the FOV note
below). It is a plain number you can change afterwards; nothing is re-detected at launch, and
an existing ini is never touched.

> **Fullscreen needs a REAL display mode.** The race creates a fullscreen D3D device, so
> a made-up size (e.g. 1440×1080 — fine as a window) fails to create the device.
> Unsupported sizes are auto-corrected to the nearest supported one instead of crashing.
> Windowed mode — the default — accepts any size.

## Fonts — the one thing installed outside the folder
Disc 1 carries a `Fonts` component, and the shell's art definitions (`GvrRoot\gvr\art.gvr`) name
four families from it that **no Windows install has**:

| Family | references in `art.gvr` |
|---|---|
| `GVR_nfsu` | 383 |
| `GVR_digital` (7-segment) | 81 |
| `Ethnocentric` | 76 |
| `Digital dream Narrow` | — |

Without them GDI substitutes Arial: readable, but the main menu (`START GAME`), the circuit name and
the operator menu lose the NFSU styling. So the installer **registers the missing families with
Windows**, as the OEM installer did, and keeps a copy in `<InstallRoot>\Fonts\`.
They are taken from your disc; the four custom families are also bundled in the package's
`Fonts\` folder as a fallback, so an `-ExpandedPayloadRoot` install still gets them.

Only families Windows lacks are installed. The component also holds Microsoft's Arial bold/italic,
Arial Narrow, Impact and Trebuchet MS Bold — every modern Windows already has those, and the disc's
Arial files are bold/italic faces with *no regular face*, which would break text if dropped over the
system family.

> Loading them app-locally instead — `AddFontResourceEx(..., FR_PRIVATE)` from `GVRInputRaw.dll` —
> was tried and **does not work**: the frontend then renders those same fields as unreadable
> garbage, worse than not loading them at all, with or without `FR_NOT_ENUM`. The engine resolves
> the family by name but cannot use a privately-loaded face. Registering the font is the only way
> that renders correctly.

## Controller support (Xbox / PS4, USB or Bluetooth)
A drop-in `GVRInputRaw.dll` replaces the arcade wheel/pedal driver, so a normal pad gives
**analog progressive steering** and analog throttle/brake. Keyboard keeps working alongside it.

| | Race — `[Controller]` | Frontend — `[Frontend]` |
|---|---|---|
| Steer / throttle / brake | left stick, R2, L2 | left stick (or numpad 4/6) |
| Select / back | — | Cross / Circle (or `S` / `E`) |
| Menu navigation | — | D-pad (or the arrow keys) |
| Career name entry | — | R2 accept, L2 backspace |
| Operator menu | — | Options (or `O`) |
| Shift up / down | Square / Triangle | — |
| Camera / look back | R1 / L1 | — |
| Nitrous / e-brake | Circle / Cross | — |
| Start · reset car | Options | — |
| Music / volume | D-pad right | — |
| Skip race intro | Cross (or `S`) | — |
| Quit prompt · confirm | D-pad down (or `Q`) · Cross (or `S`) | — |
| Insert / eject card | — | **R3** (or `S` / `F9`) |

**Every one of these is remappable** — nothing is hardcoded. `[Controller]` is the in-race map and
`[Frontend]` the menu map; they are separate because the same button means different things in the
two programs (Cross is the e-brake while driving, "select" in the menus). One button can carry
several comma-separated actions, e.g. `Cross = ebrake, confirm, skipintro`. Steering (left stick)
and the in-race triggers are fixed. The keyboard keeps working alongside the pad.

**Xbox pads need no edit** — the map is positional, so `Cross` *is* the bottom face button. You can
also write the name printed on your pad: `a`=cross, `b`=circle, `x`=square, `y`=triangle,
`lb`/`rb`=l1/r1, `lt`/`rt`=l2/r2, `start` or `menu`=options, `back` or `view`=share, `ls`/`rs`=l3/r3.
(`guide`/`ps` is DS4-only — XInput does not report the Guide button.)

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

## Known behaviour (by design / not worth fixing)
- **The frontend sits on top while its intro/attract reel plays.** It is cabinet software: it
  forces itself to the front. Most of that is tamed (it no longer clips your mouse pointer, and
  it drops behind other windows once you click away), but during the intro it can still push
  itself forward. Click into the menu, or press `S` to skip the reel, and it behaves normally.
- **Both windows cover the taskbar while they are the active window** and drop behind it as soon
  as you switch away — deliberate, so it feels full-screen without trapping alt-tab.
- **A brief glimpse of the desktop edges** can appear during the frontend↔race hand-over: the
  backdrop covers the game's 4:3 area, not the whole 16:9 screen.
- **`[Launcher] Merge=true`** (run both programs inside one window) is **experimental and off**:
  the frontend exits when it is not a top-level window.
- Verified on Windows 10/11 x64 desktops. **Not tested on real cabinet hardware.**

## Package contents
`Install-NFSU-GVR-Portable.ps1`, `GvrLaunch.exe` (launcher — start the game with this),
`gvr_settings.ini`, `NFSU_GVR.ico` (desktop-shortcut icon, copied into the install root),
`Fonts\` (the four custom families; Microsoft's come from your disc),
`Tools\` (`unshield.exe`), `DLLs\` (runtime DLLs
plus `GVRInputRaw.dll` controller driver, **`GVRInputRaw_oem.dll`** and `dsound.dll`),
`CardEmu\` (`GVRSCR28.dll`, `PCSCSCR2.dll`, `GvrCardKey.exe`), `Dependencies\` (`DotNet11`
incl. the SP1 patch, `DirectX9`, `DXVK`), `SQLite\` (patched `PLUSDE.dll`, `GvrSqlite.dll`
+ `.cs`, `sqlite3.dll`, seeded `game.db`), `Reference_GVR_All.reg`.
Not included: the game payload (from your OEM discs).

> ⚠️ **`GVRInputRaw_oem.dll` must sit next to `UniverShell2.exe`.** The frontend copy of
> `GVRInputRaw.dll` forwards the whole cabinet ABI to it; without it the frontend freezes after
> roughly 100 seconds. `dsound.dll` belongs next to **both** executables (it keeps audio alive
> when the window is not focused and frees the mouse cursor).

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
