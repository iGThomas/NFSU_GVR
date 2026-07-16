# Recovery Disc & Virtual Machine Notes

[← Back to main README](../README.md)

## About the Recovery Disc

The System Recovery Disc installs a preconfigured Windows XPe environment used by Global VR arcade systems.

The recovery disc and both installation discs can be found on the Internet Archive, and the disc images can be mounted with [WinCDEMU](https://wincdemu.sysprogs.org/):

```
https://archive.org/details/nfsug_gvr
```

It can install successfully inside a virtual machine such as VirtualBox or VMware, but the hardware configuration matters.

If the VM configuration is too modern or too powerful, the recovery disc may freeze on a black screen either during boot or after installation.

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

## Game Startup in a VM

The game itself could not be started successfully inside a virtual machine on the XP route — a working NVIDIA driver on real hardware is required. See [Technical Notes — GPU Driver Requirement](technical-notes.md#gpu-driver-requirement).

For the Windows 7 game-only route, VirtualBox testing worked with the `VBoxVGA` display adapter (`VBoxSVGA` caused misleading .NET/cordbg crash behavior). See the [Windows 7 32-bit guide](install-windows-7-32bit.md).

> 💡 Fun detail: after installing the original recovery disc and opening `regedit`, it opens directly at the `Session Manager\Environment` registry path — likely the last thing checked before the restore image was created.

---

[← Back to main README](../README.md)
