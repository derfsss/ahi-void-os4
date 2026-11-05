# ahi-void-os4

A dummy AHI sound driver for AmigaOS 4: `void.audio` and its mode file `VOID`. Programs that
play sound through `ahi.device` work on a machine with no sound card.

The driver accepts the sound, discards it, and takes as long as playing it would have taken,
paced by `timer.device`. A program's sound thread therefore blocks at the real rate, as it
would with a card. Without a working unit, a program whose sound thread retries a failed
write spins and starves everything at a lower priority. Super Star Blast's loading screen did
this on an X5000 with no sound card (derfsss/Mesa-os4#445).

It is AROS's AHI Void driver (`UPSTREAM.md`), built native for PowerPC with two small patches.

## Build

From PowerShell, in Docker (`walkero/amigagccondocker:os4-gcc15-3.6.1`):

```
.\make.ps1               build\void.audio and build\VOID
.\make.ps1 check         the gates: upstream identity, patches apply, no address-4 ExecBase,
                         the driver's resident tag and gates, nothing undefined, the mode file
.\make.ps1 deployables   stripped files in build\deploy\
```

## Install

1. Copy `void.audio` to `DEVS:AHI/` and `VOID` to `DEVS:AudioModes/`.
2. Power cycle, or run `AddAudioModes REFRESH`.
3. In AHI prefs, set the Music unit and units 0-3 to a `VOID:` mode, for example
   `VOID:HiFi 32 bit stereo++`.

The modes are `0x001f0001` (HiFi 32-bit mono), `0x001f0002` (HiFi 32-bit stereo++),
`0x001f0003` (16-bit mono), `0x001f0004` (16-bit stereo++) and `0x001f0005` (HiFi 32-bit 7.1).
