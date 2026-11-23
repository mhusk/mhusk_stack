#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
RULES_SRC="${REPO_ROOT}/AGENTS.md"
MANAGED_MARKER=".mhusk_stack_managed"

HARNESS="all"
MODE="auto"
CHECK_ONLY=0
TARGET_HOME="${HOME}"

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [options]

Install mhusk_stack skills and rules into supported agent harnesses.

Options:
  --harness <all|antigravity|cursor|grok>  Target harness (default: all)
  --mode <auto|symlink|copy>               Install mode (default: auto; uses copy for Cursor
                                           so Cloud Agent skill sync works, symlink elsewhere)
  --check                                  Read-only check of installed targets
  --home <dir>                             Override target home directory (default: $HOME)
  -h, --help                               Show this help message
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --harness)
      HARNESS="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --check)
      CHECK_ONLY=1
      shift
      ;;
    --home)
      TARGET_HOME="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$HARNESS" in
  all|antigravity|cursor|grok) ;;
  *)
    printf 'Invalid --harness value: %s (expected: all, antigravity, cursor, grok)\n' "$HARNESS" >&2
    exit 2
    ;;
esac

case "$MODE" in
  auto|symlink|copy) ;;
  *)
    printf 'Invalid --mode value: %s (expected: auto, symlink, copy)\n' "$MODE" >&2
    exit 2
    ;;
esac

effective_mode_for_path() {
  local path="$1"
  if [ "$MODE" != "auto" ]; then
    printf '%s' "$MODE"
    return 0
  fi
  case "$path" in
    */.cursor/*|*/.agents/*) printf 'copy' ;;
    *) printf 'symlink' ;;
  esac
}

if [ ! -d "$SKILLS_SRC" ]; then
  printf 'Error: skills directory not found at %s\n' "$SKILLS_SRC" >&2
  exit 1
fi

# Collect target skill roots, additive rule paths, and Antigravity plugin root
SKILL_TARGETS=()
RULE_TARGETS=()
ANTIGRAVITY_PLUGIN_DIR=""

add_skill_target() {
  local dir="$1"
  local existing
  for existing in "${SKILL_TARGETS[@]+"${SKILL_TARGETS[@]}"}"; do
    [ "$existing" = "$dir" ] && return 0
  done
  SKILL_TARGETS+=("$dir")
}

add_rule_target() {
  local path="$1"
  local existing
  for existing in "${RULE_TARGETS[@]+"${RULE_TARGETS[@]}"}"; do
    [ "$existing" = "$path" ] && return 0
  done
  RULE_TARGETS+=("$path")
}

if [ "$HARNESS" = "all" ] || [ "$HARNESS" = "antigravity" ]; then
  ANTIGRAVITY_PLUGIN_DIR="${TARGET_HOME}/.gemini/config/plugins/mhusk_stack"
  add_skill_target "${ANTIGRAVITY_PLUGIN_DIR}/skills"
  add_rule_target "${ANTIGRAVITY_PLUGIN_DIR}/rules/AGENTS.md"
fi

if [ "$HARNESS" = "all" ] || [ "$HARNESS" = "cursor" ]; then
  add_skill_target "${TARGET_HOME}/.agents/skills"
  add_skill_target "${TARGET_HOME}/.cursor/skills"
fi

if [ "$HARNESS" = "all" ] || [ "$HARNESS" = "grok" ]; then
  add_skill_target "${TARGET_HOME}/.agents/skills"
  add_skill_target "${TARGET_HOME}/.grok/skills"
  add_rule_target "${TARGET_HOME}/.grok/rules/mhusk_stack.md"
fi

# Discover skills
SKILLS=()
for sdir in "${SKILLS_SRC}"/*; do
  [ -d "$sdir" ] || continue
  [ -f "${sdir}/SKILL.md" ] || continue
  SKILLS+=("$(basename "$sdir")")
done

if [ "${#SKILLS[@]}" -eq 0 ]; then
  printf 'Error: no valid skills found in %s\n' "$SKILLS_SRC" >&2
  exit 1
fi

install_plugin_manifest() {
  local plugin_dir="$1"
  local manifest="${plugin_dir}/plugin.json"

  mkdir -p "$plugin_dir" || return 1
  cat > "$manifest" <<'JSON'
{
  "name": "mhusk_stack",
  "repository": "https://github.com/mhusk/mhusk_stack"
}
JSON
  printf 'WROTE   %s\n' "$manifest"
}

check_plugin_manifest() {
  local plugin_dir="$1"
  local manifest="${plugin_dir}/plugin.json"
  if [ -f "$manifest" ]; then
    printf 'OK    %s\n' "$manifest"
  else
    printf 'MISS  %s\n' "$manifest" >&2
    return 1
  fi
}

install_skill() {
  local src="$1"
  local dst="$2"
  local op_mode
  op_mode="$(effective_mode_for_path "$dst")"

  mkdir -p "$(dirname "$dst")" || return 1

  if [ "$op_mode" = "symlink" ]; then
    if [ -L "$dst" ]; then
      rm -f "$dst" || return 1
    elif [ -d "$dst" ]; then
      if [ -f "${dst}/${MANAGED_MARKER}" ]; then
        rm -rf "$dst" || return 1
      else
        printf 'SKIP (unmanaged directory exists): %s\n' "$dst" >&2
        return 1
      fi
    elif [ -e "$dst" ]; then
      printf 'SKIP (unmanaged file exists): %s\n' "$dst" >&2
      return 1
    fi
    ln -s "$src" "$dst" || return 1
    printf 'LINKED  %s -> %s\n' "$dst" "$src"
  else
    if [ -L "$dst" ]; then
      rm -f "$dst" || return 1
    elif [ -d "$dst" ]; then
      if [ -f "${dst}/${MANAGED_MARKER}" ]; then
        rm -rf "$dst" || return 1
      else
        printf 'SKIP (unmanaged directory exists): %s\n' "$dst" >&2
        return 1
      fi
    elif [ -e "$dst" ]; then
      printf 'SKIP (unmanaged file exists): %s\n' "$dst" >&2
      return 1
    fi
    cp -R "$src" "$dst" || return 1
    touch "${dst}/${MANAGED_MARKER}" || return 1
    printf 'COPIED  %s <- %s\n' "$dst" "$src"
  fi
}

install_rule() {
  local src="$1"
  local dst="$2"
  local op_mode
  op_mode="$(effective_mode_for_path "$dst")"

  mkdir -p "$(dirname "$dst")" || return 1

  if [ "$op_mode" = "symlink" ]; then
    if [ -L "$dst" ]; then
      rm -f "$dst" || return 1
    elif [ -e "$dst" ]; then
      if grep -q "mhusk_stack Agent Instructions" "$dst" 2>/dev/null; then
        rm -f "$dst" || return 1
      else
        printf 'SKIP (unmanaged rule file exists): %s\n' "$dst" >&2
        return 1
      fi
    fi
    ln -s "$src" "$dst" || return 1
    printf 'LINKED  %s -> %s\n' "$dst" "$src"
  else
    if [ -L "$dst" ]; then
      rm -f "$dst" || return 1
    elif [ -e "$dst" ]; then
      if grep -q "mhusk_stack Agent Instructions" "$dst" 2>/dev/null; then
        rm -f "$dst" || return 1
      else
        printf 'SKIP (unmanaged rule file exists): %s\n' "$dst" >&2
        return 1
      fi
    fi
    cp "$src" "$dst" || return 1
    printf 'COPIED  %s <- %s\n' "$dst" "$src"
  fi
}

check_skill() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    if [ ! -e "$dst" ]; then
      printf 'FAIL  broken symlink: %s\n' "$dst" >&2
      return 1
    fi
    local resolved_dst
    resolved_dst="$(cd "$dst" && pwd -P)"
    local resolved_src
    resolved_src="$(cd "$src" && pwd -P)"
    if [ "$resolved_dst" != "$resolved_src" ]; then
      printf 'FAIL  symlink points elsewhere: %s -> %s\n' "$dst" "$resolved_dst" >&2
      return 1
    fi
    printf 'OK    %s (symlink)\n' "$dst"
  elif [ -d "$dst" ] && [ -f "${dst}/SKILL.md" ]; then
    printf 'OK    %s (copy)\n' "$dst"
  else
    printf 'MISS  %s\n' "$dst" >&2
    return 1
  fi
}

check_rule() {
  local dst="$1"
  if [ -L "$dst" ]; then
    if [ ! -e "$dst" ]; then
      printf 'FAIL  broken rule symlink: %s\n' "$dst" >&2
      return 1
    fi
    printf 'OK    %s (symlink)\n' "$dst"
  elif [ -f "$dst" ]; then
    printf 'OK    %s (copy)\n' "$dst"
  else
    printf 'MISS  %s\n' "$dst" >&2
    return 1
  fi
}

FAILURES=0

if [ -n "$ANTIGRAVITY_PLUGIN_DIR" ]; then
  if [ "$CHECK_ONLY" -eq 1 ]; then
    check_plugin_manifest "$ANTIGRAVITY_PLUGIN_DIR" || FAILURES=$((FAILURES + 1))
  else
    install_plugin_manifest "$ANTIGRAVITY_PLUGIN_DIR" || FAILURES=$((FAILURES + 1))
  fi
fi

for target_root in "${SKILL_TARGETS[@]}"; do
  for skill in "${SKILLS[@]}"; do
    src="${SKILLS_SRC}/${skill}"
    dst="${target_root}/${skill}"
    if [ "$CHECK_ONLY" -eq 1 ]; then
      check_skill "$src" "$dst" || FAILURES=$((FAILURES + 1))
    else
      install_skill "$src" "$dst" || FAILURES=$((FAILURES + 1))
    fi
  done
done

for rule_dst in "${RULE_TARGETS[@]+"${RULE_TARGETS[@]}"}"; do
  if [ "$CHECK_ONLY" -eq 1 ]; then
    check_rule "$rule_dst" || FAILURES=$((FAILURES + 1))
  else
    install_rule "$RULES_SRC" "$rule_dst" || FAILURES=$((FAILURES + 1))
  fi
done

if [ "$FAILURES" -gt 0 ]; then
  if [ "$CHECK_ONLY" -eq 1 ]; then
    printf '\nINSTALL_CHECK_FAILED: %d issue(s) found.\n' "$FAILURES" >&2
  else
    printf '\nINSTALL_COMPLETED_WITH_ERRORS: %d issue(s).\n' "$FAILURES" >&2
  fi
  exit 1
fi

if [ "$CHECK_ONLY" -eq 1 ]; then
  printf '\nINSTALL_CHECK_OK: harness=%s targets verified.\n' "$HARNESS"
else
  printf '\nINSTALL_OK: installed %d skill(s) for harness=%s (mode=%s).\n' "${#SKILLS[@]}" "$HARNESS" "$MODE"
fi
