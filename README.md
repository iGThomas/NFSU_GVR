# NFSU_GVR

Knowledge, notes, and installation findings for running **Need for Speed Underground: Global VR Arcade Edition**.

This project documents what I discovered while trying to install and run the Global VR arcade version on Windows XP, Windows XP Embedded, and virtual machines.

---

## Contents

- [Requirements](#requirements)
- [About the Recovery Disc](#about-the-recovery-disc)
- [Virtual Machine Notes](#virtual-machine-notes)
- [Standalone Installation Guide (Step by Step)](#standalone-installation-guide-step-by-step)
- [Installing on Normal Windows XP](#installing-on-normal-windows-xp)
- [Required Registry Values](#required-registry-values)
- [Disc 1 Installation Notes](#disc-1-installation-notes)
- [Disc 2 and .NET Framework 1.1](#disc-2-and-net-framework-11)
- [Database Installation](#database-installation)
- [Installing MSDE Manually](#installing-msde-manually)
- [SQL Password Findings](#sql-password-findings)
- [SQL Tools](#sql-tools)
- [GPU Driver Requirement](#gpu-driver-requirement)
- [Dongle and Smart Card Notes](#dongle-and-smart-card-notes)
- [Game Controls](#game-controls)
- [Current Status](#current-status)
- [Credits](#credits)

---

## Requirements

You need the original Global VR media:

- Need for Speed Underground: Global VR System Recovery Disc
- Need for Speed Underground: Global VR Game Installation Disc 1
- Need for Speed Underground: Global VR Game Installation Disc 2

The recovery disc is a Windows XP Embedded system restore image preconfigured for Global VR arcade hardware.

---

## About the Recovery Disc

The System Recovery Disc installs a preconfigured Windows XPe environment used by Global VR arcade systems.

It can install successfully inside a virtual machine such as VirtualBox or VMware, but the hardware configuration matters.

If the VM configuration is too modern or too powerful, the recovery disc may freeze on a black screen either during boot or after installation.

---

## Virtual Machine Notes

Recommended starting point:

```
RAM: 2 GB
CPU: 2 cores
Chipset: try different VirtualBox/VMware chipset options if it fails
```

> ⚠️ Avoid increasing the RAM or CPU too much. In testing, higher values caused black screens or freezes.

If the recovery disc does not boot correctly, try changing:

- Chipset type
- IDE/SATA controller mode
- Video adapter settings
- Amount of RAM
- CPU count

---

## Standalone Installation Guide (Step by Step)

This section covers a clean installation on real hardware without the recovery disc.

**Tested on:** Acer Aspire 9300 — AMD Turion 64 CPU, NVIDIA GeForce Go 6100
> ⚠️ In BIOS settings it's important to set SATA to IDE instead of AHCI otherwise you'll get a blue screen on installation. If you can't do that it won't be compatible.


### Step 1 — Clean Install Windows XP

Install a fresh copy of Windows XP (SP3 recommended) on your machine.

### Step 2 — Install NVIDIA Drivers

Install the NVIDIA drivers for your GPU before proceeding.

The game requires a working NVIDIA driver to start. Without it, the game will not launch successfully.

### Step 3 — Install .NET Framework 1.1

Download and install .NET Framework version 1.1.4322 (required by Disc 2):

```
https://archive.org/details/dotnetfx_202102
```

### Step 4 — Add the Required Registry Value

Open **Registry Editor** (`regedit`) and navigate to:

```
HKLM\System\CurrentControlSet\Control\Session Manager\Environment
```

Add the following String value:

| Name | Type | Value |
|------|------|-------|
| `RUNTIMEOEMREV` | String | `NFS - UG,XP Embedded,HW Rev 865 e,05052005` |

> ⚠️ Without this registry value, the game installer will fail or block the installation.

### Step 5 — Install the Database (MSDE)

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

### Step 6 — Reboot

Reboot your PC to ensure the database is fully installed before proceeding.

### Step 7 — Install the Game Discs

Install **Disc 1**, then install **Disc 2**.

### Step 8 — Enjoy!

The game should now be ready to run. 🏎️

---

## Installing on Normal Windows XP

The game installation discs do not install correctly on a normal Windows XP SP3 installation by default.

The installer checks for a specific registry value that normally exists on the Global VR Windows XPe image. Without this value, the installer fails or blocks the installation.

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

> 💡 Fun detail: after installing the original recovery disc and opening `regedit`, it opens directly at this registry path — likely the last thing checked before the restore image was created.

---

## Disc 1 Installation Notes

During Disc 1 installation, you may see popups about locked files, especially related to fonts. These can be ignored.

You may also see an error about `NvCpl.dll` being missing if NVIDIA drivers are not yet installed.

---

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

---

## Database Installation

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

---

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

---

## SQL Tools

To browse the database with a UI instead of the command line, use the old Microsoft SQL tool:

```
http://download.microsoft.com/download/SQLSVR2000/Trial/2000/NT45/EN-US/SQLEVAL.exe
```

---

## GPU Driver Requirement

A working NVIDIA driver is required for the game to start.

Testing confirmed the game started on an Acer Aspire 9300 (AMD CPU + NVIDIA GeForce Go 6100) once the NVIDIA video drivers were installed.

The game could not be started successfully inside a virtual machine.

---

## Dongle and Smart Card Notes

On a standalone Windows XP SP3 installation, the dongle was **not required** for the game to boot.

This differs from the original recovery disc installation where the dongle is normally required. Most likely, a registry value or service related to the dongle is missing from the standalone XP installation, which unintentionally bypasses the dongle check.

Career mode is greyed out due to the absence of a smart card reader.

---

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

---

## Current Status

**Working:**

- ✅ Game discs install on normal Windows XP after adding the required registry value
- ✅ .NET Framework 1.1 allows Disc 2 to continue
- ✅ Manual MSDE installation solves part of the database requirement
- ✅ Game starts on real hardware with compatible NVIDIA drivers

**Not working yet:**

- ❌ Reliable startup inside a virtual machine
- ❌ Full original cabinet behavior
- ❌ Career mode without smart card reader
- ❌ Complete understanding of all dongle-related checks

---

## Credits

Thanks to **Ratface** from [Emuline.org](https://emuline.org) for the default MSDE password discovery.

---

## Notes

This documentation is based on personal testing and reverse engineering of an original Global VR installation.

Use original discs and legally owned software.
