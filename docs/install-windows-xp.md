# Installing on Windows XP — Standalone (Step by Step)

[← Back to main README](../README.md)

This guide covers a clean installation on real hardware without the recovery disc.

You will need the Global VR Game Installation Disc 1 and Disc 2. The recovery disc and both installation discs can be found on the Internet Archive, and the disc images can be mounted with [WinCDEMU](https://wincdemu.sysprogs.org/):

```
https://archive.org/details/nfsug_gvr
```

**Tested on:** Acer Aspire 9300 — AMD Turion 64 CPU, NVIDIA GeForce Go 6100
> ⚠️ In BIOS settings it's important to set SATA to IDE instead of AHCI otherwise you'll get a blue screen on installation. If you can't do that it won't be compatible.

---

## Contents

- [Step 1 — Clean Install Windows XP](#step-1--clean-install-windows-xp)
- [Step 2 — Install NVIDIA Drivers](#step-2--install-nvidia-drivers)
- [Step 3 — Install .NET Framework 1.1](#step-3--install-net-framework-11)
- [Step 4 — Add the Required Registry Value](#step-4--add-the-required-registry-value)
- [Step 5 — Install the Database (MSDE)](#step-5--install-the-database-msde)
- [Step 6 — Reboot](#step-6--reboot)
- [Step 7 — Install the Game Discs](#step-7--install-the-game-discs)
- [Step 8 — Enjoy!](#step-8--enjoy)
- [Why This Is Needed](#why-this-is-needed)
- [Disc 1 Installation Notes](#disc-1-installation-notes)
- [Disc 2 and .NET Framework 1.1](#disc-2-and-net-framework-11)
- [Database Installation Failure](#database-installation-failure)
- [Installing MSDE Manually](#installing-msde-manually)

---

## Step 1 — Clean Install Windows XP

Install a fresh copy of Windows XP (SP3 recommended) on your machine.

## Step 2 — Install NVIDIA Drivers

Install the NVIDIA drivers for your GPU before proceeding.

The game requires a working NVIDIA driver to start. Without it, the game will not launch successfully.

## Step 3 — Install .NET Framework 1.1

Download and install .NET Framework version 1.1.4322 (required by Disc 2):

```
https://archive.org/details/dotnetfx_202102
```

## Step 4 — Add the Required Registry Value

Open **Registry Editor** (`regedit`) and navigate to:

```
HKLM\System\CurrentControlSet\Control\Session Manager\Environment
```

Add the following String value:

| Name | Type | Value |
|------|------|-------|
| `RUNTIMEOEMREV` | String | `NFS - UG,XP Embedded,HW Rev 865 e,05052005` |

> ⚠️ Without this registry value, the game installer will fail or block the installation.

See [Technical Notes — Required Registry Values](technical-notes.md#required-registry-values) for the additional related values.

## Step 5 — Install the Database (MSDE)

Download the two folders from this repository:

```
_MSDERelA
_SqlXml
```

Open a Command Prompt inside the `_MSDERelA` folder and run:

```cmd
setup.exe SAPWD="q2Z35o" DISABLENETWORKPROTOCOLS=1 SECURITYMODE=SQL /qb
```

After that, run the `setup.exe` inside the `_SqlXml` folder.

## Step 6 — Reboot

Reboot your PC to ensure the database is fully installed before proceeding.

## Step 7 — Install the Game Discs

Install **Disc 1**, then install **Disc 2**.

## Step 8 — Enjoy!

The game should now be ready to run. 🏎️

---

## Why This Is Needed

The game installation discs do not install correctly on a normal Windows XP SP3 installation by default.

The installer checks for a specific registry value that normally exists on the Global VR Windows XPe image. Without this value, the installer fails or blocks the installation.

## Disc 1 Installation Notes

During Disc 1 installation, you may see popups about locked files, especially related to fonts. These can be ignored.

You may also see an error about `NvCpl.dll` being missing if NVIDIA drivers are not yet installed.

## Disc 2 and .NET Framework 1.1

At some point during Disc 2 installation, the installer requires:

```
.NET Framework version 1.1.4322
```

Download the Windows XP-compatible installer from:

```
https://archive.org/details/dotnetfx_202102
```

After installing .NET Framework 1.1, Disc 2 installation can continue.

## Database Installation Failure

After installing .NET Framework 1.1, Disc 2 continues but eventually fails when running:

```
C:\GvrPlus\1\scripts\GvRPlusExportDatabaseScript.exe
```

The error resembles:

```
Database installation started.
COM object with CLSID (...) is either not valid or not registered.
Failure changing Account Password.
Press enter to continue.
```

The database is required by the game. The frontend relies heavily on SQL and eventually launches `UndergroundGVR.exe` with arguments.

## Installing MSDE Manually

The required database setup files are present on the original recovery installation under:

```
C:\gvr\Database
```

There are two folders:

```
_MSDERelA
_SqlXml
```

The setup does not launch correctly by simply double-clicking it — it expects specific arguments.

Copy the files and run:

```cmd
setup.exe SAPWD="q2Z35o" DISABLENETWORKPROTOCOLS=1 SECURITYMODE=SQL /qb
```

> The default password was discovered by **Ratface** from Emuline.org.

---

[← Back to main README](../README.md)
