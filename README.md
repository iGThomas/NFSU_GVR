# NFSU_GVR

Knowledge, notes, and installation findings for running **Need for Speed Underground: Global VR Arcade Edition** outside the original cabinet.

This project documents what was discovered while reverse engineering and installing the Global VR arcade version on Windows XP, Windows XP Embedded, Windows 7 (32-bit), and virtual machines.

---

## 📚 Installation Guides

Pick the guide that matches your target system:

| Guide | Summary |
|-------|---------|
| **[NFSU GVR Portable Edition Installer](NFSU_GVR_Portable/README.md)** | ⭐ Recommended. Standalone installer that installs the game from your OEM discs into **any folder you choose** and runs it on an **embedded SQLite database** — no MSDE, no SQLXML, no `sa` password, no reboot, no fixed `C:\` paths. Runs on **Windows XP → Windows 11 (x64)**. Configurable resolution via `gvr_settings.ini`. Files are in the [`NFSU_GVR_Portable`](NFSU_GVR_Portable) folder. |
| **[Windows 7 32-bit — Game-Only Install (V1, MSDE)](docs/install-windows-7-32bit.md)** | The original game-only installer using the migrated MSDE/SQL Server 2000 backend. Superseded by the SQLite Edition, but kept for reference and for setups closest to the original cabinet. Files are in the [`Win7-GameOnly`](Win7-GameOnly) folder. |
| **[Windows XP — Standalone Install](docs/install-windows-xp.md)** | Manual step-by-step clean install on real XP SP3 hardware: registry values, .NET 1.1, manual MSDE setup, and disc installation. |
| **[Recovery Disc & Virtual Machines](docs/recovery-disc-and-vm.md)** | Notes on the original Windows XPe System Recovery Disc and getting it to boot inside VirtualBox/VMware. |

## 🔧 Reference

| Document | Summary |
|----------|---------|
| **[Technical Notes](docs/technical-notes.md)** | Registry values, SQL password findings, database internals, dongle/smart card behavior, GPU driver requirements, game controls, and launch arguments. |

## 💻 VirtualBox Support

The Windows 7 32-bit game-only install also works inside VirtualBox. Tested on **VirtualBox 6.0.24** with a Windows 7 32-bit guest and Guest Additions installed:

```
Processors:          2
RAM:                 4096 MB
Video Memory:        256 MB
Graphics Controller: VBoxVGA
Acceleration:        3D
```

See the [Windows 7 32-bit guide](docs/install-windows-7-32bit.md#installing-inside-virtualbox) for details.

---

## Requirements

You need the original Global VR media:

- Need for Speed Underground: Global VR System Recovery Disc *(only for the recovery disc / VM route)*
- Need for Speed Underground: Global VR Game Installation Disc 1
- Need for Speed Underground: Global VR Game Installation Disc 2

The recovery disc and both installation discs can be found on the Internet Archive:

```
https://archive.org/details/nfsug_gvr
```

The disc images can be mounted with [WinCDEMU](https://wincdemu.sysprogs.org/) (Windows XP and 7 have no built-in ISO mounting).

---

## Current Status

**Working:**

- ✅ SQLite Edition (V2): game runs on an embedded SQLite database — no MSDE service, no reboot
- ✅ **Windows 11 (x64) on real hardware** — full install, frontend and racing (registry into `WOW6432Node`, real .NET 1.1 SP1 via slipstream, 60 fps cap via app-local DXVK)
- ✅ Installs to **any folder**; nothing is written outside it except a handful of registry keys
- ✅ Frontend car liveries, leaderboards and best times (needed a `SELECT TOP` → `LIMIT` fix in the SQLite shim)
- ✅ Configurable resolution (`gvr_settings.ini`) — the stock 800×600 is not a hard limit
- ✅ Game-only install on Windows 7 32-bit via the automated PowerShell installer (V1, MSDE)
- ✅ Windows 7 32-bit install inside VirtualBox (tested on VirtualBox 6.0.24, VBoxVGA + 3D acceleration)
- ✅ Game discs install on normal Windows XP after adding the required registry value
- ✅ .NET Framework 1.1 allows Disc 2 to continue
- ✅ Manual MSDE installation solves part of the database requirement
- ✅ Game starts on real hardware with compatible NVIDIA drivers
- ✅ Career mode without smart card reader

**Not working yet:**

- ❌ Full original cabinet behavior
- ❌ Complete understanding of all dongle-related checks
- ❌ Online tournaments
- ❌ **True 16:9 widescreen.** The engine never adapts its projection to the render aspect, so a
  widescreen resolution stretches the image. Use a 4:3 mode (1280×960) for correct geometry.
  ThirteenAG's retail NFSU WidescreenFix loads but is inert here — only 9 of its 42 byte
  patterns match this recompiled build. See [Technical Notes](docs/technical-notes.md#resolution-and-widescreen).

---

## Credits

Thanks to **Ratface** from [Emuline.org](https://emuline.org) for the default MSDE password discovery.

Thanks to [**SheepyChris**](https://github.com/SheepyChris) for the idea of using PCMover to install the game on a newer OS than XPe.

---

## Notes

This documentation is based on personal testing and reverse engineering of an original Global VR installation.

Use original discs and legally owned software.
