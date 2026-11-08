# Credits

This repository is a port. Almost all of the code is other people's work, and it is credited
here.

## AHI

**Martin Blom** wrote AHI, the Amiga audio system, including the driver interface and the
do-nothing example driver this project is built from. AHI is at
<http://www.lysator.liu.se/ahi/>.

## AROS

The Void driver and the other AHI sources here come from the
[AROS Research Operating System](https://github.com/aros-development-team/AROS), maintained by
the **AROS Development Team**. The sources were taken at commit
`90510e807f0fb3deead918ac3722513c7319844f` (see `UPSTREAM.md`).

Contributors to the AROS copy of the Void driver (`workbench/devs/AHI/Drivers/Void`), from its
public history:

- **Bo Ståle Kopperud**: made the driver take as long as playing the buffer would (AROS
  [#1882](https://github.com/aros-development-team/AROS/pull/1882)). The pacing that this
  project's sound-thread fix depends on.
- **neil**
- **Kalamatee**
- **schulz**
- **mattrust**

## sfdc

`upstream/sfdc/` is **sfdc**, the SFD compiler by **Martin Blom**, as carried in AROS
(`tools/sfdc`), with changes by other AROS contributors, among them falemagn, mattrust,
verhaegs, Kalamatee, stegerg, lcs, sonic, neil, ezrec and chodorowski. It generates the gate
stubs for the driver.

## This repository

**Richard Gibbs** ported the driver to AmigaOS 4 (the two patches in `patches/`, the build and
the gates).

If you contributed to any of the above and are missing or named wrongly, please open an issue.
