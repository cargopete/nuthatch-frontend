#!/bin/sh
# Nuthatch installer — PRE-RELEASE PLACEHOLDER
#
# This script does not install anything yet. Nuthatch is pre-release; there are
# no published binaries to fetch. When the first release is tagged, this script
# will detect your platform, download the matching static binary, verify its
# SHA-256 checksum and signature, and place `nuthatch` on your PATH.
#
# Until then, build from source:  cargo install nuthatch
# Or watch the repo:              https://github.com/cargopete/nuthatch
#
# It is deliberately readable. Piping a script to a shell asks for trust; the
# real one will stay this short and this auditable.

set -eu

printf '%s\n' ""
printf '%s\n' "  nuthatch — be your own indexer"
printf '%s\n' "  ------------------------------"
printf '%s\n' "  This installer is a pre-release placeholder and installs nothing yet."
printf '%s\n' ""
printf '%s\n' "  Build from source:  cargo install nuthatch"
printf '%s\n' "  Source & releases:  https://github.com/cargopete/nuthatch"
printf '%s\n' ""

exit 0
