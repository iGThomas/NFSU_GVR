# NFSU_GVR

Knowledge, notes, and installation findings for running Need for Speed Underground: Global VR Arcade Edition.

This project documents what I discovered while trying to install and run the Global VR arcade version on Windows XP, Windows XP Embedded, and virtual machines.

## Contents

- [Requirements](#requirements)
- [About the recovery disc](#about-the-recovery-disc)
- [Virtual machine notes](#virtual-machine-notes)
- [Installing on normal Windows XP](#installing-on-normal-windows-xp)
- [Required registry values](#required-registry-values)
- [Disc 1 installation notes](#disc-1-installation-notes)
- [Disc 2 and .NET Framework 1.1](#disc-2-and-net-framework-11)
- [Database installation](#database-installation)
- [SQL password findings](#sql-password-findings)
- [SQL tools](#sql-tools)
- [GPU driver requirement](#gpu-driver-requirement)
- [Dongle and smart card notes](#dongle-and-smart-card-notes)
- [Game controls](#game-controls)
- [Credits](#credits)

## Requirements

You need the original Global VR media:

- Need for Speed Underground: Global VR System Recovery Disc
- Need for Speed Underground: Global VR Game Installation Disc 1
- Need for Speed Underground: Global VR Game Installation Disc 2

The recovery disc is a Windows XP Embedded system restore image preconfigured for Global VR arcade hardware.

## About the recovery disc

The System Recovery Disc installs a preconfigured Windows XPe environment used by Global VR arcade systems.

It can install successfully inside a virtual machine such as VirtualBox or VMware, but the hardware configuration matters.

If the VM configuration is too modern or too powerful, the recovery disc may freeze on a black screen either during boot or after installation.

## Virtual machine notes

Recommended starting point:

```text
RAM: 2 GB
CPU: 2 cores
Chipset: try different VirtualBox/VMware chipset options if it fails
```

Avoid increasing the RAM or CPU too much. In my testing, higher values caused black screens or freezes.

If the recovery disc does not boot correctly, try changing:

- chipset type
- IDE/SATA controller mode
- video adapter settings
- amount of RAM
- CPU count

## Installing on normal Windows XP

The game installation discs do not install correctly on a normal Windows XP SP3 installation by default.

The installer checks for a specific registry value that normally exists on the Global VR Windows XPe image.

Without this value, the installer fails or blocks the installation.

## Required registry values

Open Registry Editor and go to:

```text
HKLM\System\CurrentControlSet\Control\Session Manager\Environment
```

Add this string value:

```text
Name:  RUNTIMEOEMREV
Type:  String
Value: NFS - UG,XP Embedded,HW Rev 865 e,05052005
```

This value is required for the game installer to continue.

These values also seem related, although they do not appear to block the installation:

```text
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

Fun detail: after installing the original recovery disc and opening `regedit`, it opens directly at this registry path. It looks like this was one of the last things checked or edited before the restore image was created.

## Disc 1 installation notes

During Disc 1 installation, you may see popups about locked files, especially related to fonts.

These can be ignored.

You may also see an error about `NvCpl.dll` being missing if NVIDIA drivers are not installed yet.

## Disc 2 and .NET Framework 1.1

At some point during Disc 2 installation, the installer asks for:

```text
.NET Framework version 1.1.4322
```

You can find the Windows XP-compatible installer here:

```text
https://archive.org/details/dotnetfx_202102
```

After installing .NET Framework 1.1, Disc 2 was able to continue further.

## Database installation

After installing .NET Framework 1.1, Disc 2 continued but eventually failed when running this file:

```text
C:\GvrPlus\1\scripts\GvRPlusExportDatabaseScript.exe
```

The error was similar to:

```text
Database installation started.
COM object with CLSID (...) is either not valid or not registered.
Failure changing Account Password.
Press enter to continue.
```

The database is required by the game.

From what I found, the frontend appears to rely heavily on SQL, and it eventually launches `UndergroundGVR.exe` with arguments.

Someone also ported the game to Windows using a custom launcher, but this README focuses on the original Global VR installation behavior.

## Installing MSDE manually

The required database setup files are present on the original recovery installation under:

```text
C:\gvr\Database
```

There are two folders:

```text
_MSDERelA
_SqlXml
```

The important folder is:

```text
_MSDERelA
```

The setup does not launch correctly by simply double-clicking it because it expects specific arguments.

Copy the files and run:

```cmd
setup.exe SAPWD="q2Z35o" DISABLENETWORKPROTOCOLS=1 SECURITYMODE=SQL /qb
```

The default password was found thanks to Ratface from Emuline.org.

## SQL password findings

After the game installation, the SQL password appears to be changed.

I wanted to know the new password, so I looked deeper into:

```text
GvRPlusExportDatabaseScript.exe
```

This file is installed inside the `GvrPlus` folder after the game installation.

Using `dnSpy`, I found that the tool decrypts an encrypted XML file and changes the SQL password.

The encrypted file was:

```text
nfscabinetXml.enc
```

Using a small Python script, I decrypted it and recovered the raw:

```text
nfscabinetXml
```

This file appears to contain the game database configuration.

The SQL password was visible in plain text:

```text
Q31y2Z29wpEsd
```

To log in to the database:

```cmd
osql -U sa -P Q31y2Z29wpEsd -S .
```

## SQL tools

To view the database more easily with a UI, I used an old Microsoft SQL tool:

```text
http://download.microsoft.com/download/SQLSVR2000/Trial/2000/NT45/EN-US/SQLEVAL.exe
```

This is useful for browsing the database instead of using only command-line tools.

## GPU driver requirement

Another requirement for the game to start successfully is a working NVIDIA driver.

I could not start the game successfully inside a virtual machine yet.

However, on a cheap laptop, an Acer Aspire 9300 with AMD CPU and NVIDIA GeForce Go 6100 graphics, the game started once the NVIDIA video drivers were installed.

## Dongle and smart card notes

Interesting finding: on a standalone Windows XP SP3 installation, the dongle was not required for the game to boot.

This is different from the original recovery disc installation, where the dongle is normally required.

Most likely, a registry value or service related to the dongle is missing from the standalone XP installation, which unintentionally bypasses the dongle check.

Career mode is greyed out because there is no smart card reader.

## Game controls

| Key | Action |
|---|---|
| Numpad 8 | Accelerate |
| Numpad 4 | Steer left |
| Numpad 6 | Steer right |
| O | Operator menu |
| Arrow keys | Scroll in operator menu |
| S | Start / reset car |
| N | Nitrous |
| V | Change view |
| Q | Quit |
| E | E-brake |
| M | Reduce song volume / stop music / change song |

## Current status

Working:

- Game discs can be installed further on normal Windows XP after adding the required registry value.
- .NET Framework 1.1 allows Disc 2 to continue.
- Manual MSDE installation solves part of the database requirement.
- Game can start on real hardware with compatible NVIDIA drivers.

Not working yet:

- Reliable startup inside a virtual machine.
- Full original cabinet behavior.
- Career mode without smart card reader.
- Complete understanding of all dongle-related checks.

## Credits

Thanks to Ratface from Emuline.org for the default MSDE password discovery.

## Notes

This documentation is based on personal testing and reverse engineering of an original Global VR installation.

Use original discs and legally owned software.
