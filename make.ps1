# SPDX-License-Identifier: MIT
<#
.SYNOPSIS
Run this repository's make inside the cross image.

.DESCRIPTION
The repository is mounted at /src and make runs there, inside
walkero/amigagccondocker:os4-gcc15-3.6.1 (gcc 15, SDK 54.16). Nothing from
the host's MSYS2 is used. Outputs land in build\.

.EXAMPLE
.\make.ps1
.\make.ps1 check
.\make.ps1 deployables
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter()][string]$Image = "walkero/amigagccondocker:os4-gcc15-3.6.1",
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$Targets = @()
)
$ErrorActionPreference = "Stop"
docker run --rm --name ahi-void-os4-make -v "${PSScriptRoot}:/src" -w /src $Image make @Targets
exit $LASTEXITCODE
