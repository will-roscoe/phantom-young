#!/bin/bash
# Syncs the LaTeX/MathJax macro preamble from its master copy into the repo,
# so docs/conf.py can read a git-tracked file instead of an absolute path
# that only exists on one machine (and would break CI).
set -euo pipefail
cd "${0%/*}"

MASTER="/win/e/Notebooks/General Notes/preamble.md"
VENDORED="../_static/preamble.md"

if [ ! -f "$MASTER" ]; then
  echo "sync-preamble: master copy not found at $MASTER, skipping" >&2
  exit 0
fi

if ! diff -q "$MASTER" "$VENDORED" >/dev/null 2>&1; then
  cp "$MASTER" "$VENDORED"
  git add "$VENDORED"
  echo "sync-preamble: updated $VENDORED from master copy"
fi
