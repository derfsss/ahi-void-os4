#!/bin/sh
# SPDX-License-Identifier: MIT
#
# Run this repository's make inside the cross image (the bash/sh twin of
# make.ps1). Needs Docker. Works on Linux, macOS and Git Bash/MSYS2 on Windows.
#
#   ./make.sh                build/void.audio and build/VOID
#   ./make.sh check          the gates
#   ./make.sh deployables    stripped files in build/deploy/
#
# IMAGE can be overridden: IMAGE=other/image:tag ./make.sh
set -eu
IMAGE="${IMAGE:-walkero/amigagccondocker:os4-gcc15-3.6.1}"
HERE="$(cd "$(dirname "$0")" && pwd)"
# MSYS_NO_PATHCONV stops Git Bash on Windows rewriting /src into a Windows path.
MSYS_NO_PATHCONV=1 exec docker run --rm --name ahi-void-os4-make \
    -v "$HERE:/src" -w /src "$IMAGE" make "$@"
