#!/bin/bash
# Syncs the LaTeX/MathJax macro preamble from a master copy into the repo,
# so docs/conf.py can read a git-tracked file instead of an absolute path
# that only exists on one machine (and would break CI).
#
# Usage: sync-preamble.sh [PATH_TO_MASTER_PREAMBLE]
# The master path may also be given in the PREAMBLE_MASTER environment variable.
# With neither set, or if the file does not exist, nothing is done.
set -euo pipefail
cd "${0%/*}"

MASTER="${1:-${PREAMBLE_MASTER:-}}"
VENDORED="../_static/preamble.md"

if [ -z "$MASTER" ] || [ ! -f "$MASTER" ]; then
  echo "sync-preamble: no master copy (pass a path or set PREAMBLE_MASTER), skipping" >&2
  exit 0
fi

if ! diff -q "$MASTER" "$VENDORED" >/dev/null 2>&1; then
  cp "$MASTER" "$VENDORED"
  git add "$VENDORED"
  echo "sync-preamble: updated $VENDORED from master copy"
fi
