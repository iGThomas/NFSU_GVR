# NFSU_GVR_Portable

Run **Need for Speed Underground: GlobalVR** like a normal Windows game.

This project installs the GlobalVR arcade release into **one folder of your choice**, keeps the GVR files nested with the game, and replaces the original MSDE / SQL Server backend with **SQLite**. It avoids the cabinet-style fixed `C:\` layout, SQLXML dependency, and arcade boot/lockdown chain.

**Supported:** Windows XP through Windows 11 x64.

> [!IMPORTANT]
> You must provide the original OEM **Disc 1** and **Disc 2** yourself.  
> The game data is **not included** in this project. The installer reads the required files directly from your discs.

---

## Installation

### What you need

Before starting, have these ready:

- The latest project ZIP from the GitHub **[Releases](https://github.com/iGThomas/NFSU_GVR/releases) page**
- The original NFS Underground: GlobalVR **Disc 1** and **Disc 2**, either as physical discs or ISO images made from your original media (https://archive.org/details/nfsug_gvr)
- An account that can run PowerShell as **Administrator**
- A folder where you want the game installed, for example:

```text
D:\Games\NFSU
```

No original GlobalVR SQL Server/MSDE installation is required.

### 1. Download and extract the release

Download the ZIP from the project's **Releases** page.

Extract the ZIP to a normal folder first. Do **not** run the installer from inside the ZIP.

For example:

```text
C:\Users\YourName\Downloads\NFSU_GVR_Portable
```

### 2. Open PowerShell as Administrator

Open the Start menu, search for **PowerShell**, right-click it, and choose:

**Run as administrator**

If Windows asks for permission, choose **Yes**.

### 3. Allow the installer script to run

In the Administrator PowerShell window, run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This only changes the execution policy for the current PowerShell window. Closing that window restores the previous setting.

### 4. Go to the extracted project folder

Change PowerShell to the folder where you extracted the ZIP.

Example:

```powershell
cd "C:\Users\YourName\Downloads\NFSU_GVR_Portable"
```

Use your own path if you extracted it somewhere else.

### 5. Mount or insert the game discs

If you are using ISO images, mount them before starting the installer.

On Windows 8, 10, or 11:

1. Right-click the **Disc 1** ISO.
2. Choose **Mount**.
3. Do the same for **Disc 2** if you can mount both at the same time.

If you are using the original physical discs, insert them normally.

If you only have one optical or virtual drive available, that is also fine. Start with **Disc 1** and swap to **Disc 2** when the installer asks for it.

> [!NOTE]
> Windows XP and Windows 7 do not have the same built-in ISO mounting option. If you are installing from ISO images on those systems, use a virtual-drive tool, or use the original physical discs.

### 6. Start the installer

Run:

```powershell
.\Install-NFSU-GVR-Portable.ps1
```

The installer will guide you through the remaining steps.

It first asks **where you want the game installed**.

For the game discs:

- If **Disc 1 and Disc 2 are already mounted or inserted and detected**, the installer uses them automatically.
- If a disc is not detected, the installer prompts you for it.
- When prompted, mount or insert the requested disc and press **Enter**.
- If you are using a single virtual drive, mount **Disc 1** first, then unmount it and mount **Disc 2** when requested.

The installer then:

- extracts the game files;
- creates the required nested GVR folder layout;
- writes the required registry paths;
- installs the SQLite backend;
- installs or deploys required runtimes;
- copies the controller and audio compatibility DLLs;
- configures the launcher;
- installs the required OEM fonts when they are missing;
- creates a desktop shortcut;
- verifies the important runtime files at the end.

No reboot is normally required.

### 7. Launch the game

After installation, use the desktop shortcut or start:

```text
GvrLaunch.exe
```

from the install folder.

**Use `GvrLaunch.exe` for normal play.**

It applies `gvr_settings.ini`, prepares the frontend, and then starts the game.

You can also start:

```text
GvrRoot\UniverShell2.exe
```

directly, but doing so skips launcher features such as the configured display size and backdrop.

---

## First launch and basic setup

The installer creates:

```text
gvr_settings.ini
```

in the install root.

This is the main configuration file for display, controller mappings, frontend controls, and launcher behaviour.

A fresh install automatically chooses the largest **4:3** window size that fits your primary display. For example, a 1920×1080 desktop will normally use:

```ini
[Display]
Width=1440
Height=1080
Fullscreen=false
Borderless=true
```

The game is designed around a 4:3 projection. A 16:9 render resolution stretches the image rather than increasing the horizontal field of view, so **4:3 is recommended**.

For normal use, the default borderless-window configuration is the easiest option.

> [!NOTE]
> Fullscreen requires a display mode your monitor and GPU actually support.  
> A custom size such as `1440x1080` may work perfectly in a window but fail as an exclusive fullscreen mode. Unsupported fullscreen sizes are automatically corrected to a supported mode.

---

## Repairing or reinstalling

You can run the installer again over an existing installation.

By default, the installer **preserves your `game.db`**.

Once the game has been used, this database contains more than the original seed data. It stores things such as:

- car configurations;
- leaderboards;
- best times;
- operator-menu settings.

This means a normal repair install keeps your existing data.

To deliberately reset the database to the shipped seed, use:

```powershell
.\Install-NFSU-GVR-Portable.ps1 -ForceOverwrite
```

> [!WARNING]
> `-ForceOverwrite` can replace the existing `game.db`. Use it only when you intentionally want a reset.

---

## Useful installer options

The normal interactive installer is recommended for most installations.

For manual or repeat installs, these switches are available:

```text
-InstallRoot <dir>
-ExpandedPayloadRoot <dir>
-DryRun
-ForceOverwrite
-Disc1Path <dir>
-Disc2Path <dir>
-SkipDirectX
-SkipDotNet
```

### Examples

Choose the install directory in advance:

```powershell
.\Install-NFSU-GVR-Portable.ps1 -InstallRoot "D:\Games\NFSU"
```

Provide both disc paths in advance:

```powershell
.\Install-NFSU-GVR-Portable.ps1 `
  -Disc1Path "E:\" `
  -Disc2Path "F:\"
```

Install from an already-expanded payload instead of reading the discs:

```powershell
.\Install-NFSU-GVR-Portable.ps1 `
  -ExpandedPayloadRoot "D:\NFSU_GVR_Expanded"
```

Preview installer actions without applying them:

```powershell
.\Install-NFSU-GVR-Portable.ps1 -DryRun
```

---

# Configuration and controls

## `gvr_settings.ini`

Neither original executable has a normal PC settings screen. Runtime configuration is handled by:

- `GvrLaunch.exe`
- `gvr_settings.ini`
- `GVRInputRaw.dll`

The original game executables are **not modified**.

Example:

```ini
[Display]
Width=1440
Height=1080
Fullscreen=false
Borderless=true

[Controller]
Cross    = ebrake, confirm, skipintro
Circle   = nitrous
...

[Frontend]
Cross    = select
R3       = card
...

[Launcher]
Backdrop=true
Merge=false
```

### Display

`[Display]` controls the size used by both the frontend and the race.

```ini
[Display]
Width=1440
Height=1080
Fullscreen=false
Borderless=true
```

- `Width` / `Height` — render size.
- `Fullscreen=false` — recommended default.
- `Borderless=true` — removes the title bar and centres the window when windowed.
- `Fullscreen=true` — uses an exclusive fullscreen display mode.

The installer chooses a sensible 4:3 size only on a **fresh install**. It does not continuously redetect your display, and it does not overwrite an existing INI during a normal reinstall.

### Launcher

```ini
[Launcher]
Backdrop=true
Merge=false
```

- `Backdrop=true` shows the game's boot screen during the frontend-to-race transition.
- `Merge=true` attempts to run both programs inside one window. This is experimental and disabled by default.

---

## Controller support

A drop-in `GVRInputRaw.dll` replaces the original arcade wheel/pedal input driver.

Normal gamepads can therefore provide:

- analog steering;
- analog throttle;
- analog brake;
- remappable race buttons;
- remappable frontend/menu buttons.

Keyboard input continues to work alongside the controller.

### Default controls

| Action | Race | Frontend |
|---|---|---|
| Steering | Left stick | Left stick / numpad 4 or 6 |
| Throttle / brake | R2 / L2 | — |
| Select / back | — | Cross / Circle or `S` / `E` |
| Menu navigation | — | D-pad or arrow keys |
| Career name entry | — | R2 accept / L2 backspace |
| Operator menu | — | Options or `O` |
| Shift up / down | Square / Triangle | — |
| Camera / look back | R1 / L1 | — |
| Nitrous / e-brake | Circle / Cross | — |
| Start / reset car | Options | — |
| Music / volume | D-pad right | — |
| Skip race intro | Cross or `S` | — |
| Quit prompt / confirm | D-pad down or `Q` / Cross or `S` | — |
| Insert / eject card | — | R3 or `S` / `F9` |

The race and frontend maps are separate because the same physical button can have different meanings in each program.

One button can also perform several actions:

```ini
Cross = ebrake, confirm, skipintro
```

Steering on the left stick and the in-race analog triggers are fixed.

### Xbox button names

Xbox controllers use the same positional mapping, so the bottom face button corresponds to `Cross`.

You can also use familiar Xbox-style names in the INI:

```text
a      = cross
b      = circle
x      = square
y      = triangle
lb     = l1
rb     = r1
lt     = l2
rt     = r2
start  = options
menu   = options
back   = share
view   = share
ls     = l3
rs     = r3
```

`guide` / `ps` is DS4-only because XInput does not report the Xbox Guide button.

---

## Free play

Free play is enabled by default.

The shipped `game.db` changes:

```text
Settings_NFS1.FreePlay = 1
```

This is deliberate.

The original arcade value is `0`, because a real cabinet expects credits from its coin hardware. On a normal home PC there is no coin mechanism or dongle, so leaving the cabinet default enabled would make the frontend request credits it cannot receive.

You can still change this through the normal operator menu:

1. Start the frontend.
2. Press **`O`**.
3. Open the relevant operator setting.
4. Disable free play if you specifically want the original coin-op behaviour.

This is the only value changed from the stock cabinet settings row.

---

# Technical reference

The sections below explain how the installation works and document findings that may be useful for debugging, development, or preservation work. They are not required reading for a normal installation.

## Installed layout

For an install root such as:

```text
D:\Games\NFSU
```

the installer creates:

```text
D:\Games\NFSU\Underground\                game (UndergroundGVR.exe, TRACKS, ...)
D:\Games\NFSU\Underground\GVR\GvrRoot\    arcade shell (UniverShell2/GVRBoot + gvr\*.gvr)
D:\Games\NFSU\Underground\GVR\GvrPlus\    plus libs + schema + game.db
D:\Games\NFSU\Underground\GVR\Gvr\        helpers
D:\Games\NFSU\GvrLaunch.exe               normal launcher
D:\Games\NFSU\gvr_settings.ini            user settings
D:\Games\NFSU\Fonts\                      OEM fonts
D:\Games\NFSU\NFSU_GVR.ico                shortcut icon
```

---

## How the install stays location-independent

### Registry paths

The installer writes the GVR registry paths using the install directory you selected.

This includes keys for:

- `NFSUNDERGROUND\Ini`;
- `Gvr\Plus\1.1\Cabinet`;
- `Gvr\Plus\1.1\Server`;
- `PlusSchemaPath`;
- `PublicKeyPath`;
- `GVRCrashMonitor\Prog0x path`.

The game reads its locations from these registry values.

### `UniverShell2.exe`

`UniverShell2.exe` contains hard-coded `C:\gvrRoot\...` strings, but analysis in Ghidra found them to be dead editor constants with no code references.

At runtime, the shell loads its content relative to its working directory, so no binary patch is required for those strings.

### SQLite database

The SQLite provider derives the `game.db` path from the registry `PlusSchemaPath` value:

```text
<GvrPlus>\game.db
```

The database therefore remains co-located with the selected installation.

No environment variable or reboot is required.

### GVRD content

The four binary containers under:

```text
GvrRoot\gvr
```

contain absolute paths and must be rebuilt for the chosen install root:

- `CommandlineArgs_data`
- `OperatorData`
- `normalData`
- `OpReg_data`

These contain data such as:

- game executable path;
- game working directory;
- per-car `vinyls.bin` paths;
- volume paths;
- gamma paths;
- library paths.

Without rebuilding these values, starting a race can silently return to the frontend.

### Batch files

The installer also rewrites path references in:

```text
setcab*.bat
ResetShadows.bat
UnregisterDlls.bat
```

### App-local runtime files

Required runtime DLLs and the patched engine/provider are placed beside the programs that use them.

This avoids depending on copies in:

```text
C:\Windows\system32
```

---

## Windows 10 / 11 x64 compatibility

The installer contains separate compatibility blocks for modern 64-bit Windows. They are gated so older Windows installations are not unnecessarily changed.

### WOW6432Node registry view

The game is 32-bit and accesses the 32-bit view of:

```text
HKLM\SOFTWARE
```

On 64-bit Windows, importing only through the normal 64-bit `reg.exe` can leave the game unable to see its settings, causing an exit with `-10`.

The installer therefore imports the required data into both registry views, including through:

```text
SysWOW64\reg.exe
```

### .NET Framework 1.1 SP1

A plain `dotnetfx.exe` install can fail with MSI error `1603` on Windows 10/11.

The installer instead creates an administrative image, applies the .NET 1.1 SP1 patch, and installs the slipstreamed result.

Redirecting the application to CLR 2.0 with an `.exe.config` file is not an equivalent workaround. `PLUSDE.dll` uses mixed-mode native C++ exception handling and can access-violate under CLR 2.0.

### DXVK and the 60 FPS limit

NFS Underground's physics is tied to frame rate, and the GlobalVR build does not provide a normal VSync option.

On a modern GPU, the game can otherwise run at hundreds of frames per second, making the driving simulation run far too quickly.

DXVK is therefore deployed on the **game side only**, with `dxvk.conf` limiting the game to 60 FPS.

It is not deployed beside the frontend shell because testing showed that configuration did not help and could break the intro video.

### `GammaSet.exe`

The cabinet shell normally starts `GammaSet.exe` roughly five seconds after launch.

It uses a command similar to:

```text
rundll32 NvCpl.dll,dtcfg ...
```

On 64-bit Windows, the 32-bit `rundll32` may not find a compatible 32-bit `NvCpl.dll`, causing a RunDLL error popup on every launch.

The command only sets gamma to `1.00` plus a CRT-oriented vibrance adjustment, so the installer disables it where the required 32-bit NVIDIA component is absent.

It remains enabled when a compatible 32-bit `NvCpl.dll` is present.

---

## Fonts

Fonts are the main part of the installation that cannot remain completely self-contained inside the game directory.

Disc 1 includes a `Fonts` component, and the frontend art definitions in:

```text
GvrRoot\gvr\art.gvr
```

reference several typefaces that normal Windows installations do not include.

| Family | References in `art.gvr` |
|---|---:|
| `GVR_nfsu` | 383 |
| `GVR_digital` | 81 |
| `Ethnocentric` | 76 |
| `Digital dream Narrow` | — |

Without them, Windows substitutes another font such as Arial. The interface remains readable, but elements such as `START GAME`, circuit names, and operator-menu text lose the intended NFSU styling.

The installer registers missing custom families with Windows, matching the behaviour of the OEM installer, and also keeps copies under:

```text
<InstallRoot>\Fonts\
```

The package contains the four custom families as a fallback so an `-ExpandedPayloadRoot` installation can still receive them.

Only missing families are installed.

The disc also contains Microsoft fonts such as Arial variants, Arial Narrow, Impact, and Trebuchet MS Bold. Modern Windows versions already provide these, and replacing system Arial with the disc's incomplete bold/italic-only faces can cause text problems, so those system families are not overwritten.

### Why the fonts are not loaded privately

Using:

```text
AddFontResourceEx(..., FR_PRIVATE)
```

from `GVRInputRaw.dll` was tested.

The frontend still rendered affected fields incorrectly, with or without `FR_NOT_ENUM`. The engine can resolve the family name but does not correctly use the privately loaded face.

Registering the required fonts with Windows is therefore the working solution.

---

## Why 4:3 is recommended

The engine derives vertical field of view from a fixed horizontal field of view and does not adapt its projection correctly to a widescreen render aspect.

As a result, 16:9 resolutions stretch the image.

A resolution such as:

```text
1280x960
```

keeps the original camera geometry while rendering at substantially more pixels than the original cabinet resolution.

Generic wrappers such as dgVoodoo2 or DXVK can scale the output, but they cannot correct the underlying projection.

ThirteenAG's retail NFSU WidescreenFix can load into this build, but the GlobalVR executable was recompiled enough that only 9 of its 42 expected byte patterns match, so the fix is effectively inert here.

---

## Arcade boot chain

The original cabinet uses the `GVRBoot` chain for hardware-specific tasks such as:

- dongle monitoring;
- coin handling;
- stall/crash monitoring;
- cabinet startup;
- a roughly 60-second warm-up sequence.

This chain is deliberately skipped for normal PC use.

It is not needed for home play, and the cabinet crash monitor does not spawn useful child processes on a normal desktop PC.

---

## Known behaviour

These behaviours are known and are currently considered acceptable.

### Frontend focus during intro / attract mode

The frontend is cabinet software and strongly prefers to remain in the foreground.

Most of this behaviour has been reduced: it no longer permanently clips the mouse cursor and it can fall behind other windows after you switch away.

During the intro or attract sequence, however, it may still push itself to the front.

Click into the menu or press:

```text
S
```

to skip the reel.

### Taskbar coverage

While active, the frontend and game windows can cover the taskbar.

When you switch away from them, they drop behind it again.

This is intentional so the game feels fullscreen without trapping Alt+Tab.

### Desktop edges during transitions

A brief glimpse of the desktop can appear while switching between the frontend and race.

The launcher backdrop covers the game's 4:3 area rather than the entire 16:9 desktop.

### Experimental merged window

```ini
[Launcher]
Merge=true
```

is experimental and disabled by default.

The frontend can exit when it is no longer running as a top-level window.

### Test coverage

The project has been verified on Windows 10 and Windows 11 x64 desktops.

It has not been tested on original cabinet hardware.

---

## Package contents

The release contains:

```text
Install-NFSU-GVR-Portable.ps1
GvrLaunch.exe
gvr_settings.ini
NFSU_GVR.ico
Fonts\
Tools\
DLLs\
CardEmu\
Dependencies\
SQLite\
Reference_GVR_All.reg
```

### Main files

- `Install-NFSU-GVR-Portable.ps1` — installer.
- `GvrLaunch.exe` — normal game launcher.
- `gvr_settings.ini` — display, input, frontend, and launcher configuration.
- `NFSU_GVR.ico` — desktop shortcut icon.

### `Fonts\`

Contains the four custom font families used by the frontend.

Microsoft font files are taken from the original disc when required rather than redistributed as the game payload.

### `Tools\`

Contains:

```text
unshield.exe
```

### `DLLs\`

Contains runtime DLLs plus:

```text
GVRInputRaw.dll
GVRInputRaw_oem.dll
dsound.dll
```

### `CardEmu\`

Contains:

```text
GVRSCR28.dll
PCSCSCR2.dll
GvrCardKey.exe
```

### `Dependencies\`

Contains support packages for:

- .NET Framework 1.1 and SP1;
- DirectX 9;
- DXVK.

### `SQLite\`

Contains:

```text
PLUSDE.dll
GvrSqlite.dll
GvrSqlite.cs
sqlite3.dll
game.db
```

### Not included

The actual NFS Underground: GlobalVR game payload is **not distributed**.

It is read from your original OEM discs during installation.

---

## Important runtime files

At the end of installation, the script verifies that these files were deployed:

```text
GVRInputRaw.dll
GVRInputRaw_oem.dll
dsound.dll
gvr_settings.ini
```

A missing file produces an installer warning because each failure can otherwise be difficult to identify after launch.

> [!WARNING]
> `GVRInputRaw_oem.dll` must be placed beside `UniverShell2.exe`.
>
> The frontend copy of `GVRInputRaw.dll` forwards the cabinet ABI to it. Without the OEM DLL, the frontend can freeze after roughly 100 seconds.

`dsound.dll` belongs beside **both** executables. It keeps audio active when the game window loses focus and also helps free the mouse cursor correctly.

---

# Diagnostics

For SQLite/provider debugging, set:

```text
GVRSQLITE_LOG=1
```

This enables SQL statement and error logging.

On Windows Vista and later, UAC virtualisation can redirect the log to:

```text
%LOCALAPPDATA%\VirtualStore\gvrsqlite.log
```

If the frontend behaves strangely, this is one of the first places to check.

The provider is a hand-written compatibility shim. Unsupported T-SQL can fail during SQLite prepare and return **zero rows** without displaying an in-game error.

Search the log for:

```text
prepare FAIL
```

One example was the "all cars are white in the car-select screen" issue. The frontend used a query in the form:

```sql
SELECT TOP 1 * FROM CarConfiguration_NFS1 ...
```

SQLite does not support `TOP 1`, so the query returned no car configuration and the frontend rendered cars without their expected paint or vinyl data.

---

## Quick troubleshooting checklist

If the game does not behave as expected, check these in order:

1. Start the game with **`GvrLaunch.exe`**, not only `UniverShell2.exe`.
2. Confirm the installer finished without warnings.
3. Confirm `GVRInputRaw.dll`, `GVRInputRaw_oem.dll`, `dsound.dll`, and `gvr_settings.ini` exist in the expected locations.
4. Keep the display at a **4:3** resolution while testing.
5. Use windowed/borderless mode first before trying exclusive fullscreen.
6. If the frontend loads but data is missing or incorrect, enable `GVRSQLITE_LOG=1` and search the log for `prepare FAIL`.
7. If repairing an installation, avoid `-ForceOverwrite` unless you intentionally want to reset `game.db`.

---

## Credits / preservation note

This project does not redistribute the original game payload.

It provides the installer, compatibility work, configuration, and replacement infrastructure needed to run software from the user's own original NFS Underground: GlobalVR OEM media on a normal Windows PC.
