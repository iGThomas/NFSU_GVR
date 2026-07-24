# GvrInputEmu — game-controller support for UndergroundGVR.exe

A drop-in replacement for the OEM `GVRInputRaw.dll` that lets a normal **Xbox (XInput)** or
**PS4/DS4 (raw HID)** controller drive the game natively, replacing the arcade cabinet's
Immersion force-feedback wheel + CUSBIO pedal/button board (which no longer exist).

## What it does (all confirmed working)
| Input | Control |
|---|---|
| Left stick | **Steering** — analog/progressive (like the wheel, not full-lock) |
| R2 / right trigger | **Throttle** (analog) |
| L2 / left trigger | **Brake** (analog) |
| Square / Triangle | **Shift up / down** — clean 6-speed sequential |
| R1 | **Change camera** (cycles POV) |
| L1 | **Look back** |
| Circle | **Nitrous** |
| Cross | **E-brake** |
| Options | **Start / reset car** |
| Keyboard | still works alongside the pad (Numpad drive, N/E/S, etc.) |

Manual transmission (for the shifter) is the shell's normal `-trans 1` (select Manual in UniverShell2).

## How it works
- Reimplements the 15 `GVRInputRaw*` exports the game imports; reads XInput + DS4 HID and fills the
  game's input buffer (steer = signed byte centered 0, throttle/brake bytes, button bitmask).
- Two tiny, byte-verified inline patches on the game (fixed base 0x400000, no ASLR), **on by default**
  (opt-out env `GVR_NOGEARHOOK`):
  - **GearSelector** (0x4276c0) → our sequential value.
  - **SetGear** (0x422910) → forces the player car's engaged gear to our value, bypassing the
    RPM/traction-gated transmission FSM that otherwise rounds it (AI cars untouched).
- **Camera**: R1 calls the game's own no-arg camera-cycle `FUN_0058f740()` directly (keyboard V is
  suppressed in this input mode).

Full reverse-engineering notes: `Decompiled/NativeFunctionMap.md` in the project root.

## Build
32-bit, static CRT. Needs VS 2022 (`vcvars32.bat`).
```
build.cmd    ->    build\GVRInputRaw.dll
```
Deploy next to `UndergroundGVR.exe` (the installer's `DLLs\GVRInputRaw.dll`). The OEM DLL is kept
alongside as `GVRInputRaw.dll.orig` — restore it to disable controller support.
