# ahi-void-os4

**A "no sound card" sound driver for AmigaOS 4.** It lets programs that expect sound run happily
on a machine that has none.

## What is this?

On AmigaOS 4, most programs play sound through **AHI**, the Amiga's standard audio system. AHI
sends sound to a *driver*, and the driver sends it to a sound card. If there is no driver
for a working card, AHI has nowhere to send the sound.

This project adds a driver called **Void** (`void.audio`) that is a sound card which isn't
there. It accepts all the sound it is given and throws it away. You hear nothing, but the
program thinks its sound is playing normally.

## Why would I want that?

Some programs misbehave when their sound fails. A game's sound thread may retry a failed write
over and over without waiting. It spins flat out and starves every task at a lower priority, so
the whole machine feels frozen. Super Star Blast's loading screen did exactly this on an X5000
with no sound card.

The Void driver stops that. It also **paces itself like a real card**: it takes as long to
"play" each block of sound as real playback would, using `timer.device`. A program's sound
thread therefore waits at the proper rate instead of racing. Other uses are headless machines,
emulators and virtual machines with no audio, and testing software that needs a working AHI unit.

## Where does it come from?

It is the AHI Void driver from [AROS](https://github.com/aros-development-team/AROS), built for
AmigaOS 4 on PowerPC with two small patches (`UPSTREAM.md`). The work belongs to its original
authors, listed in `CREDITS.md`. This repository only ports it.

**Status: beta.** Tested on an AmigaOS 4 X5000 (Super Star Blast loads to its menu with every
AHI unit set to VOID). Reports from other machines are welcome as GitHub issues.

## Install

The quick way: download `ahi-void-os4-<version>.lha` from the
[Releases page](https://github.com/derfsss/ahi-void-os4/releases), unpack it and:

1. Copy `Devs/AHI/void.audio` to `DEVS:AHI/` and `Devs/AudioModes/VOID` to `DEVS:AudioModes/`.
2. Power cycle, or run `AddAudioModes REFRESH`.
3. In AHI prefs, set the Music unit and units 0-3 to a `VOID:` mode, for example
   `VOID:HiFi 32 bit stereo++`.

The modes are `0x001f0001` (HiFi 32-bit mono), `0x001f0002` (HiFi 32-bit stereo++),
`0x001f0003` (16-bit mono), `0x001f0004` (16-bit stereo++) and `0x001f0005` (HiFi 32-bit 7.1).

## Build from source

You only need this if you want to build it yourself. The build runs in Docker, so it needs
nothing else installed: no Amiga SDK and no cross compiler. It uses the image
`walkero/amigagccondocker:os4-gcc15-3.6.1` (gcc 15, SDK 54.16).

**Windows (PowerShell):**

```
.\make.ps1               build\void.audio and build\VOID
.\make.ps1 check         the gates (see below)
.\make.ps1 deployables   stripped files in build\deploy\
```

**Linux, macOS, or bash on Windows (Git Bash, MSYS2):**

```
./make.sh                build/void.audio and build/VOID
./make.sh check          the gates (see below)
./make.sh deployables    stripped files in build/deploy/
```

`check` runs these gates: the upstream copy matches the pinned AROS commit, the patches apply,
no code reads ExecBase from address 4, the driver has its resident tag and gates, nothing is
undefined, and the mode file is valid. On Linux the files in `build/` may be owned by root,
because Docker runs as root; `sudo chown -R "$USER" build` fixes that.

## Credits and licence

See `CREDITS.md` for who wrote what. AHI's drivers are under the LGPL with the exception in
`COPYING.DRIVERS`: a driver may carry any licence. sfdc is under its own `COPYING` (GPL). This
repository's own files (`Makefile`, `make.ps1`, `make.sh`, `src/`, `patches/`) are MIT, see
`LICENSE`.
