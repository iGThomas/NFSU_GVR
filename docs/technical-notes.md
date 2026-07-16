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

A working NVIDIA driver is required for the game to start.

Testing confirmed the game started on an Acer Aspire 9300 (AMD CPU + NVIDIA GeForce Go 6100) once the NVIDIA video drivers were installed.

The game could not be started successfully inside a virtual machine.

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

[← Back to main README](../README.md)
