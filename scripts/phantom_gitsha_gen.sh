#!/bin/sh
#
# Write the Fortran include that gitinfo.f90 compiles in: the commit of the phantom tree being built, with
# "-dirty" when tracked files differ from it, or "unknown" outside a git checkout. The file is rewritten only
# when that value changes, so make rebuilds gitinfo.o exactly when the commit does.
#
# Usage (from build/Makefile, run in the build directory): sh ../scripts/phantom_gitsha_gen.sh gitsha.inc
#
out=${1:-gitsha.inc}
sha=$(git rev-parse --short=9 HEAD 2>/dev/null)
if [ -z "$sha" ]; then
   sha="unknown"
elif ! git diff --quiet HEAD -- 2>/dev/null; then
   sha="$sha-dirty"
fi
printf " character(len=*), parameter :: compiled_gitsha = '%s'\n" "$sha" > "$out.tmp"
if cmp -s "$out.tmp" "$out"; then
   rm -f "$out.tmp"
else
   mv -f "$out.tmp" "$out"
fi
