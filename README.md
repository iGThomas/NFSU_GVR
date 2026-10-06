# NFSU_GVR

Run **Need for Speed Underground: GlobalVR Arcade Edition** as a normal Windows game — the real
arcade menus and races, on SQLite instead of SQL Server, with Xbox / PlayStation controllers and
free play, installed into one folder of your choice.

## ▶ Get started

1. Download the latest **`NFSU_GVR_Portable-<version>.zip`** from
   [Releases](https://github.com/iGThomas/NFSU_GVR/releases/latest).
2. Get **Disc 1** and **Disc 2** — [archive.org/details/nfsug_gvr](https://archive.org/details/nfsug_gvr).
3. Double-click **`Install.bat`** — see the [install guide](NFSU_GVR_Portable/README.md).

Works on Windows 10 and 11 (64-bit).

---

## What works

- ✅ Full arcade frontend and racing on Windows 11, including career mode (no smart card reader needed)
- ✅ Any install folder, and the install can be moved — nothing is written to the Windows registry
- ✅ Xbox and PlayStation controllers (analog steering and pedals, remappable buttons)
- ✅ Any resolution, windowed or fullscreen (`gvr_settings.ini`)
- ✅ Leaderboards, best times and car liveries on the built-in SQLite database

**Not yet:** true 16:9 widescreen (use a 4:3 size such as 1440×1080 — 16:9 stretches the picture),
online tournaments, and full original cabinet behaviour.

---

## Other guides and references

| | |
|---|---|
| [Full reference — Portable Edition](docs/portable-reference.md) | Every setting, the controller mapping, how the install works, diagnostics |
| [Technical notes](docs/technical-notes.md) | Registry values, database internals, dongle / smart card, GPU drivers, launch arguments |
| [Windows 7 32-bit — game-only install (V1, MSDE)](docs/install-windows-7-32bit.md) | The original SQL Server-based installer, also in VirtualBox. Superseded by the Portable Edition. |
| [Windows XP — standalone install](docs/install-windows-xp.md) | Manual clean install on real XP SP3 hardware |
| [Recovery disc and virtual machines](docs/recovery-disc-and-vm.md) | The original Windows XPe recovery disc in VirtualBox / VMware |

---

## Credits

Thanks to **Ratface** from [Emuline.org](https://emuline.org) for the default MSDE password discovery.

Thanks to [**SheepyChris**](https://github.com/SheepyChris) for the idea of using PCMover to install
the game on a newer OS than XPe.

Based on personal testing and reverse engineering of an original Global VR installation.
