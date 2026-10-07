# NFS Underground GlobalVR — Portable Edition

Play the **GlobalVR arcade version of Need for Speed Underground** as a normal Windows game:
the real arcade menus and races, Xbox / PlayStation controllers, free play, all in one folder.
Your PC stays a normal PC — nothing takes over Windows.

> [!IMPORTANT]
> You need the original **Disc 1** and **Disc 2** (see *What you need* below). The download
> contains the installer only; the game itself is installed from the discs.

---

## What you need

- **Windows 10 or 11** (64-bit)
- **NFSU GlobalVR Disc 1 and Disc 2** — physical discs or ISO images
  ([archive.org/details/nfsug_gvr](https://archive.org/details/nfsug_gvr))

## Install — 4 steps

**1. Download** `NFSU_GVR_Portable-<version>.zip` from the
[Releases page](https://github.com/iGThomas/NFSU_GVR/releases/latest) and **extract it**
(right-click → *Extract All*). Don't run anything from inside the ZIP.

**2. Mount the discs.** Right-click each ISO → **Mount** (or insert the discs).
Only one drive? Mount Disc 1 now; the installer asks for Disc 2 when it needs it.

**3. Double-click `Install.bat`** in the extracted folder and click **Yes** when Windows asks
for administrator rights. (If Windows asks "Do you want to run this file?", click **Run**.)

**4. Pick where to install** (for example `C:\Games` — an `NFSU_GVR` folder is created inside it).
The installer finds the discs by itself, installs what's missing (.NET 1.1, DirectX) and puts
an **NFS Underground GVR** shortcut on your desktop. It takes a few minutes and tells you when
it is done. No reboot needed.

**Play:** double-click the desktop shortcut (or `GvrLaunch.exe` in the install folder).

---

## Controls

| | Xbox | PlayStation | Keyboard |
|---|---|---|---|
| Steer | Left stick | Left stick | numpad 4 / 6 |
| Gas / brake (reverse) | RT / LT | R2 / L2 | numpad 8 / 2 |
| Nitrous / e-brake | B / A | Circle / Cross | `N` / `E` |
| Shift up / down | X / Y | Square / Triangle | — |
| Change view / look back | RB / LB | R1 / L1 | `V` / — |
| Start / reset car | Menu | Options | `S` |
| Skip race intro | A | Cross | `S` |
| Quit the race | D-pad down, then A | D-pad down, then Cross | `Q`, then `S` |
| Music | D-pad right | D-pad right | `M` |
| Menus: select / back | A / B | Cross / Circle | `S` / `E` |
| Menus: move | D-pad | D-pad | arrow keys |
| Insert / eject card (career) | Right stick click | R3 | `S` / `F9` |
| Operator menu (in the menus) | Menu | Options | `O` |

Every button can be remapped in `gvr_settings.ini` — see the
[full reference](../docs/portable-reference.md#controller-support).

## Settings — `gvr_settings.ini`

In the install folder. Edit it with Notepad; changes apply the next time you start the game.

| Setting | What it does |
|---|---|
| `Width` / `Height` | Screen size. Keep it **4:3** (e.g. `1440` × `1080`) — 16:9 stretches the picture. |
| `Fullscreen` | `false` (default) = borderless window; `true` = real fullscreen. |
| `OnTop` | `true` = covers the taskbar while you play; `false` = other windows can go on top. |
| `KeepShell` | `true` = the menus stay on screen behind the race (faster back to the menus). |

**Free play is on.** Press `O` in the menus for the operator menu if you want coin-op behaviour.

---

## Update or repair

Download the new release and run its installer with the **same install folder**. Your settings,
save data, leaderboards and career are kept. (Only `-ForceOverwrite` resets the database.)

To install a second copy, or to move the install: just pick or move the folder — it is
self-contained.

## Something wrong?

1. Start the game with the **desktop shortcut / `GvrLaunch.exe`**, not `UniverShell2.exe`.
2. Picture stretched or odd? Use a **4:3** size and `Fullscreen=false` first.
3. Re-run the installer into the same folder — it repairs missing files and keeps your data.
4. **Crashes or hangs on launch? Turn on logging.** In `gvr_settings.ini` set `[Debug]`
   `Log=true`, start the game, let it fail **once**, then look in the **`LOG`** folder that
   appears next to `gvr_settings.ini`. It captures the launcher's timeline and, if the frontend
   or the race crashes, the faulting address — set it back to `false` afterwards.
5. Still stuck? Open an [issue](https://github.com/iGThomas/NFSU_GVR/issues) with what you see,
   and attach the zipped **`LOG`** folder from step 4.

---

**More detail:** [full reference](../docs/portable-reference.md) (every setting, how it works,
diagnostics) · [technical notes](../docs/technical-notes.md) (registry, database, dongle, launch
arguments).
