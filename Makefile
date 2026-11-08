# SPDX-License-Identifier: MIT
#
# ahi-void-os4: AHI's Void driver (aros-development-team/AROS
# workbench/devs/AHI/Drivers/Void, pinned in UPSTREAM.md) built for
# AmigaOS 4 as a native void.audio, with its mode file DEVS:AudioModes/VOID.
# The driver discards the sound it is given but takes as long as playing it
# would (AROS #1882), so a program's sound thread blocks at the real rate on
# a machine with no sound card.
#
# Run through make.ps1 (Windows) or make.sh (Linux, macOS, bash), inside the
# cross image; never the host's make.
#
#   make               void.audio and VOID into build/
#   make check         the gates (upstream identity, patch applies, no
#                      address-4 ExecBase, the built driver's shape)
#   make deployables   stripped void.audio and VOID into build/deploy/

CROSS    ?= ppc-amigaos-
CC        = $(CROSS)gcc
STRIP     = $(CROSS)strip
OBJCOPY   = $(CROSS)objcopy
NM        = $(CROSS)nm

BUILD     = build
TREE      = $(BUILD)/tree
AHI       = $(TREE)/upstream/ahi
COMMON    = $(AHI)/Drivers/Common
VOIDDIR   = $(AHI)/Drivers/Void
SFDC      = $(BUILD)/sfdc
DRIVER    = void.audio
MODEFILE  = VOID
PATCHES   = $(sort $(wildcard patches/*.patch))

# configure.in's powerpc-unknown-amigaos arm: -mcpu=603 for the code,
# -m603 -mregnames for the assembler (the mode file only).
CPPFLAGS  = -Isrc -I$(BUILD) -I$(AHI) -I$(COMMON) -I$(VOIDDIR) \
            -DDRIVER="\"$(DRIVER)\""
CFLAGS    = -mcpu=603 -O2 -Wall -Wno-pointer-sign
ASFLAGS   = -Wa,-m603 -Wa,-mregnames
LDFLAGS   = -mcpu=603 -nostartfiles

OBJECTS   = $(BUILD)/library.o $(BUILD)/gatestubs.o \
            $(BUILD)/void-init.o $(BUILD)/void-main.o \
            $(BUILD)/void-playslave.o $(BUILD)/void-accel.o

.PHONY: all check deployables clean upstreamcheck patchcheck exec4check drivercheck

all: $(BUILD)/$(DRIVER) $(BUILD)/$(MODEFILE)

# The tree: the pinned upstream copy, with this repository's patches applied.
$(BUILD)/tree.stamp: $(shell find upstream -type f) $(PATCHES)
	rm -rf $(TREE); mkdir -p $(TREE)
	cp -r upstream $(TREE)/
	for p in $(PATCHES); do patch -d $(TREE) -p1 --no-backup-if-mismatch < $$p || exit 1; done
	touch $@

# sfdc, assembled the way its own Makefile does (main.pl, the classes, the pod).
$(SFDC): $(shell find upstream/sfdc -name '*.pl' -o -name '*.pod')
	mkdir -p $(BUILD)
	cat upstream/sfdc/main.pl $(sort $(wildcard upstream/sfdc/[A-Z]*.pl)) upstream/sfdc/SFDCompile.pod \
	    | sed -e "s/SFDC_VERSION/$$(cat upstream/sfdc/sfdc.readme | sed -n 's/^Version: *//p' | head -1)/g" \
	          -e "s/SFDC_DATE/pinned/g" > $@
	chmod a+x $@

# The gate stubs, as Drivers/Common/Makefile.common.in makes them.
$(BUILD)/gatestubs.c: $(BUILD)/tree.stamp $(SFDC)
	perl $(SFDC) --mode=gatestubs --gateprefix=gw --libprefix=_ --libarg=last \
	    --addvectors=library --target=powerpc-unknown-amigaos \
	    $(AHI)/Include/SFD/ahi_sub_lib.sfd -o $@
$(BUILD)/gatestubs.h: $(BUILD)/tree.stamp $(SFDC)
	perl $(SFDC) --mode=gateproto --gateprefix=gw --libprefix=_ --libarg=last \
	    --addvectors=library --target=powerpc-unknown-amigaos \
	    $(AHI)/Include/SFD/ahi_sub_lib.sfd -o $@

# version.h, as Makefile.common.in makes it, from the Void driver's own files.
$(BUILD)/version.h: $(BUILD)/tree.stamp
	{ echo "#define VERSION $$(cat $(VOIDDIR)/version.ver)"; \
	  echo "#define REVISION $$(cat $(VOIDDIR)/version.rev)"; \
	  echo "#define VERS \"$$(cat $(VOIDDIR)/version.ver).$$(cat $(VOIDDIR)/version.rev) ($$(cat $(VOIDDIR)/version.date))\""; } > $@

GEN = $(BUILD)/gatestubs.h $(BUILD)/version.h

$(BUILD)/library.o: $(BUILD)/tree.stamp $(GEN)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $(COMMON)/library.c -o $@
$(BUILD)/gatestubs.o: $(BUILD)/gatestubs.c $(GEN)
	$(CC) $(CFLAGS) $(CPPFLAGS) -D__CLIB_TYPES__ -include config.h -include interfaces/exec.h -c $< -o $@
$(BUILD)/void-%.o: $(BUILD)/tree.stamp $(GEN)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $(VOIDDIR)/void-$*.c -o $@

$(BUILD)/$(DRIVER): $(OBJECTS)
	$(CC) $^ $(LDFLAGS) -o $@

# The mode file: MODEFILE.s's macros, then VOID.s's records, assembled and
# copied out as raw bytes (Makefile.common.in's rule).
$(BUILD)/$(MODEFILE): $(BUILD)/tree.stamp
	cat $(COMMON)/MODEFILE.s $(VOIDDIR)/VOID.s | $(CC) $(ASFLAGS) -x assembler-with-cpp -c - -o $(BUILD)/$(MODEFILE).o
	$(OBJCOPY) --output-target=binary $(BUILD)/$(MODEFILE).o $@

# --------------------------------------------------------------------------
# Gates

check: upstreamcheck patchcheck exec4check drivercheck

# The upstream copy is the pinned commit's bytes: every file's git blob id
# matches UPSTREAM.sha (written when the copy was taken).
upstreamcheck:
	@mkdir -p $(BUILD)
	@cd upstream && find . -type f | LC_ALL=C sort | while read f; do \
	    printf '%s  %s\n' "$$(git hash-object "$$f")" "$$f"; done > ../$(BUILD)/upstream.now
	@diff -u UPSTREAM.sha $(BUILD)/upstream.now || { echo "upstreamcheck: REFUSED: upstream/ differs from the pinned copy; changes belong in patches/" >&2; exit 1; }
	@echo "upstreamcheck: $$(wc -l < UPSTREAM.sha) files match the pinned AROS commit"

patchcheck: $(BUILD)/tree.stamp
	@echo "patchcheck: $(words $(PATCHES)) patch(es) apply to the pinned copy"

# No unit this repository builds takes ExecBase from address 4 on AmigaOS 4.
exec4check: $(BUILD)/void-playslave.o
	@$(CC) $(CFLAGS) $(CPPFLAGS) -E $(VOIDDIR)/void-playslave.c | grep -n 'struct ExecBase \*\*) 4' \
	  && { echo "exec4check: REFUSED: the slave reads ExecBase from address 4" >&2; exit 1; } || true
	@echo "exec4check: the slave takes ExecBase from its entry"

# The built driver has its resident tag, its gate stubs and no stray import.
drivercheck: $(BUILD)/$(DRIVER) $(BUILD)/$(MODEFILE)
	@$(NM) $(BUILD)/$(DRIVER) | grep -q ' RomTag$$' || { echo "drivercheck: no RomTag" >&2; exit 1; }
	@$(NM) $(BUILD)/$(DRIVER) | grep -q ' gwAHIsub_AllocAudio$$' || { echo "drivercheck: no gwAHIsub_AllocAudio" >&2; exit 1; }
	@! $(NM) -u $(BUILD)/$(DRIVER) | grep . || { echo "drivercheck: REFUSED: undefined symbols above" >&2; exit 1; }
	@head -c 4 $(BUILD)/$(MODEFILE) | grep -q FORM || { echo "drivercheck: the mode file is not an IFF FORM" >&2; exit 1; }
	@strings $(BUILD)/$(MODEFILE) | grep -q 'VOID:HiFi 32 bit stereo++' || { echo "drivercheck: the mode file names no VOID mode" >&2; exit 1; }
	@echo "drivercheck: $(DRIVER) $$(stat -c %s $(BUILD)/$(DRIVER)) bytes, RomTag and gates present, nothing undefined; $(MODEFILE) $$(stat -c %s $(BUILD)/$(MODEFILE)) bytes, 5 modes"

deployables: all drivercheck
	mkdir -p $(BUILD)/deploy
	$(STRIP) -o $(BUILD)/deploy/$(DRIVER) $(BUILD)/$(DRIVER)
	cp $(BUILD)/$(MODEFILE) $(BUILD)/deploy/$(MODEFILE)
	@sha256sum $(BUILD)/deploy/$(DRIVER) $(BUILD)/deploy/$(MODEFILE)

clean:
	rm -rf $(BUILD)
