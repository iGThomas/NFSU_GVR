# Tools

Put an InstallShield extractor here before running the AIO installer from OEM discs.

Supported names:

- `unshield.exe` preferred
- `isxunpack.exe`

`i6comp.exe` is intentionally not accepted for disc mode in this release. The tested build extracts only InstallShield engine files and then fails on these OEM cabinets with `Could not open value.shl`.
