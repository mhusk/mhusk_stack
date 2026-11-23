#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
UTC_NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

printf 'SKILL_SCRIPT_OK | skill=%s | utc=%s\n' "$(basename "${SKILL_ROOT}")" "${UTC_NOW}"
