#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_MAX_BYTES=20480
SKILL_WARN_BYTES=16384
SKILL_MAX_BYTES=24000

ERRORS=0
WARNINGS=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  ERRORS=$((ERRORS + 1))
}

warn() {
  printf 'WARN: %s\n' "$1"
  WARNINGS=$((WARNINGS + 1))
}

file_bytes() {
  wc -c < "$1" | tr -d '[:space:]'
}

# Extract a YAML frontmatter scalar (supports single-line and multi-line > / >- / | / |-).
extract_fm_field() {
  local file="$1"
  local field="$2"
  awk -v key="${field}" '
    NR == 1 {
      if ($0 != "---") exit 2
      in_fm = 1
      next
    }
    in_fm && $0 == "---" {
      found_end = 1
      exit 0
    }
    in_fm {
      if (collecting) {
        if ($0 ~ /^[[:space:]]+/ || $0 ~ /^[[:space:]]*$/) {
          line = $0
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
          if (line != "") {
            val = (val == "" ? line : val " " line)
          }
          next
        } else {
          collecting = 0
        }
      }
      if (match($0, "^" key ":[[:space:]]*")) {
        rest = substr($0, RLENGTH + 1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", rest)
        if (rest == ">" || rest == ">-" || rest == "|" || rest == "|-") {
          collecting = 1
          val = ""
        } else {
          gsub(/^["'\'']|["'\'']$/, "", rest)
          val = rest
        }
        found_key = 1
      }
    }
    END {
      if (!found_end) exit 2
      if (found_key) print val
    }
  ' "$file"
}

check_links() {
  local md_file="$1"
  local md_dir
  md_dir="$(cd "$(dirname "$md_file")" && pwd)"
  local rel_md="${md_file#${REPO_ROOT}/}"

  # Strip fenced code blocks and extract markdown link targets (...).
  local targets
  targets="$(
    awk '
      /^[[:space:]]*```/ { in_fence = !in_fence; next }
      !in_fence {
        line = $0
        gsub(/`[^`]*`/, "", line)
        while (match(line, /\]\([^)]+\)/)) {
          token = substr(line, RSTART + 2, RLENGTH - 3)
          print token
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$md_file"
  )"

  while IFS= read -r raw; do
    [ -z "$raw" ] && continue
    # Trim optional link title after whitespace
    local target="${raw%% *}"
    case "$target" in
      \#*|http://*|https://*|mailto:*|file://*) continue ;;
    esac
    # Strip #anchor suffix
    local path_part="${target%%#*}"
    [ -z "$path_part" ] && continue
    if [ ! -e "${md_dir}/${path_part}" ]; then
      fail "Broken relative link in ${rel_md}: '${target}'"
    fi
  done <<< "$targets"
}

# 1. Check AGENTS.md
AGENTS_MD="${REPO_ROOT}/AGENTS.md"
if [ ! -f "$AGENTS_MD" ]; then
  fail "Missing root AGENTS.md"
else
  agents_size="$(file_bytes "$AGENTS_MD")"
  if [ "$agents_size" -gt "$AGENTS_MAX_BYTES" ]; then
    fail "AGENTS.md is ${agents_size} bytes (max ${AGENTS_MAX_BYTES})"
  fi
  check_links "$AGENTS_MD"
fi

# 2. Check skills/
SKILLS_DIR="${REPO_ROOT}/skills"
if [ ! -d "$SKILLS_DIR" ]; then
  fail "Missing skills/ directory"
else
  skill_count=0
  for sdir in "${SKILLS_DIR}"/*; do
    [ -d "$sdir" ] || continue
    skill_count=$((skill_count + 1))
    sname="$(basename "$sdir")"
    skill_md="${sdir}/SKILL.md"

    if [ ! -f "$skill_md" ]; then
      fail "Missing SKILL.md in skills/${sname}/"
      continue
    fi

    ssize="$(file_bytes "$skill_md")"
    if [ "$ssize" -gt "$SKILL_MAX_BYTES" ]; then
      fail "skills/${sname}/SKILL.md is ${ssize} bytes (max ${SKILL_MAX_BYTES})"
    elif [ "$ssize" -gt "$SKILL_WARN_BYTES" ]; then
      warn "skills/${sname}/SKILL.md is ${ssize} bytes (recommended <= ${SKILL_WARN_BYTES})"
    fi

    fm_name=""
    fm_desc=""
    if ! fm_name="$(extract_fm_field "$skill_md" "name")"; then
      fail "skills/${sname}/SKILL.md is missing valid YAML frontmatter (--- ... ---)"
    else
      fm_desc="$(extract_fm_field "$skill_md" "description" || true)"
      if [ -z "$fm_name" ]; then
        fail "skills/${sname}/SKILL.md missing required frontmatter field: name"
      elif ! printf '%s' "$fm_name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        fail "skills/${sname}/SKILL.md invalid name '${fm_name}' (must be lowercase hyphenated)"
      elif [ "$fm_name" != "$sname" ]; then
        fail "skills/${sname}/SKILL.md name '${fm_name}' does not match directory '${sname}'"
      fi

      if [ "${#fm_desc}" -lt 15 ]; then
        fail "skills/${sname}/SKILL.md description is missing or too short (< 15 chars)"
      fi
    fi

    check_links "$skill_md"

    if [ -d "${sdir}/scripts" ]; then
      for script in "${sdir}/scripts"/*; do
        [ -f "$script" ] || continue
        case "$script" in
          *.sh|*.py)
            if [ ! -x "$script" ]; then
              fail "Script is not executable (+x): ${script#${REPO_ROOT}/}"
            fi
            ;;
        esac
      done
    fi
  done

  if [ "$skill_count" -eq 0 ]; then
    fail "No skill directories found under skills/"
  fi
fi

# 3. Check markdown links in README.md and docs/
if [ -f "${REPO_ROOT}/README.md" ]; then
  check_links "${REPO_ROOT}/README.md"
fi
if [ -d "${REPO_ROOT}/docs" ]; then
  while IFS= read -r md; do
    [ -f "$md" ] && check_links "$md"
  done < <(find "${REPO_ROOT}/docs" -type f -name '*.md' | sort)
fi

# 4. Check top-level scripts/ executable bit
if [ -d "${REPO_ROOT}/scripts" ]; then
  for script in "${REPO_ROOT}/scripts"/*; do
    [ -f "$script" ] || continue
    case "$script" in
      *.sh|*.py)
        if [ ! -x "$script" ]; then
          fail "Script is not executable (+x): ${script#${REPO_ROOT}/}"
        fi
        ;;
    esac
  done
fi

# 5. Public hygiene scan across repository files
HYGIENE_REGEX='(/Users/[a-zA-Z0-9._-]+/|/home/[a-zA-Z0-9._-]+/|[A-Za-z0-9._%+-]+@(gmail|icloud|yahoo|hotmail)\.com|ghp_[A-Za-z0-9]{16,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16})'

while IFS= read -r fpath; do
  rel="${fpath#${REPO_ROOT}/}"
  case "$rel" in
    .git/*|local/*|dist/*|.tmp/*|scripts/validate.sh|*.local.md) continue ;;
  esac
  if grep -nE "$HYGIENE_REGEX" "$fpath" >/dev/null 2>&1; then
    match_line="$(grep -nE "$HYGIENE_REGEX" "$fpath" | head -n 1)"
    fail "Public-hygiene violation in ${rel}: ${match_line}"
  fi
done < <(find "${REPO_ROOT}" -type f | sort)

if [ "$ERRORS" -gt 0 ]; then
  printf '\nValidation failed with %d error(s) and %d warning(s).\n' "$ERRORS" "$WARNINGS" >&2
  exit 1
fi

printf 'VALIDATE_OK: all schema, budget, link, script, and public-hygiene checks passed (%d warning(s)).\n' "$WARNINGS"
