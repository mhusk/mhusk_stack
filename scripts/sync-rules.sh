#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_SRC="${REPO_ROOT}/AGENTS.md"
MDC_DST="${REPO_ROOT}/rules/mhusk-stack.mdc"

if [ ! -f "$AGENTS_SRC" ]; then
  printf 'Error: missing %s\n' "$AGENTS_SRC" >&2
  exit 1
fi

mkdir -p "$(dirname "$MDC_DST")"

{
  cat <<'EOF'
---
description: Core portable engineering patterns and mhusk-check verification canary from mhusk_stack.
alwaysApply: true
---

EOF
  cat "$AGENTS_SRC"
} > "$MDC_DST"

printf 'SYNC_OK: generated %s from AGENTS.md\n' "${MDC_DST#${REPO_ROOT}/}"
