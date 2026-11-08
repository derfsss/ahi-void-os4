# Upstream

`upstream/` is a byte-for-byte copy of these paths of
[aros-development-team/AROS](https://github.com/aros-development-team/AROS) at commit
`90510e807f0fb3deead918ac3722513c7319844f` (master, taken 2026-11-05):

| here | AROS path |
|---|---|
| `upstream/ahi/Drivers/Common/` | `workbench/devs/AHI/Drivers/Common/` |
| `upstream/ahi/Drivers/Void/` | `workbench/devs/AHI/Drivers/Void/` |
| `upstream/ahi/Include/SFD/` | `workbench/devs/AHI/Include/SFD/` |
| `upstream/ahi/` top-level files | `workbench/devs/AHI/` (`COPYING*`, `config.h.in`, `configure.in`, `version.*`) |
| `upstream/sfdc/` | `tools/sfdc/` |

`UPSTREAM.sha` lists each file's git blob id. `make upstreamcheck` refuses a tree that differs
from it. A change to an upstream file is a patch under `patches/`, applied to a copy in
`build/tree/`, never an edit in `upstream/`.

The Void driver's pacing is AROS commit `0a7587f3` ("AHI Void: take as long as playing the
buffer would", AROS #1882, 2026-10-27). Before it, the driver called the mixer back to back
with no wait.

## Patches

| patch | what | why it is not upstream |
|---|---|---|
| `0001-void-slave-os4-entry-and-timer.patch` | `Drivers/Void`: on AmigaOS 4 the slave process takes ExecBase from its entry's third argument instead of address 4, uses its own `IExec` from it (the shared `IExec` macro reads `AHIsubBase`, which the slave has not found yet), and gets timer.device's `main` interface for `ReadEClock` | the AmigaOS 4 arm predates the pacing, which added the timer; upstream's arm reads address 4 |
| `0002-library-no-68k-vectors-on-os4.patch` | `Drivers/Common/library.c`: the 68k vector table is built only under `AHI_DRIVER_68K_VECTORS` | sfdc's AmigaOS 4 gate class makes no 68k trampolines, and `ahi.device` calls a driver through its `main` interface (`Device/audioctrl.c`, `GetInterface`) |

Both are candidates to offer back to AROS.

## Licence

AHI is under the LGPL, with the exception in `COPYING.DRIVERS`: a driver may carry any
licence. The Void driver's source reports its own copyright as "Public Domain" (`AHIDB_Copyright`
in `void-main.c`). sfdc is under its own `COPYING` (GPL). This repository's own files are MIT.
