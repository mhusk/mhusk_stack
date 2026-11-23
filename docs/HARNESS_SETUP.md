# Harness Setup & Verification Guide

This document tracks how `mhusk_stack` is installed, validated, and troubleshot across supported harnesses. Update this file whenever live testing reveals a quirk or better setup pattern.

---

## Supported Harnesses

| Harness | Skills Path(s) | Rules Path(s) | Status |
| :--- | :--- | :--- | :--- |
| **Google Antigravity** | `$HOME/.gemini/config/plugins/mhusk_stack/skills/` (plugin bundle) | `$HOME/.gemini/config/plugins/mhusk_stack/rules/AGENTS.md`, repo `AGENTS.md` | **Verified** |
| **Cursor Desktop** | Native Cursor Plugin (`mhusk/mhusk_stack`) and/or `$HOME/.agents/skills/` + `$HOME/.cursor/skills/` | Plugin `rules/mhusk-stack.mdc` (`alwaysApply: true`), repo `AGENTS.md` | In-repo verified; testing plugin across repos |
| **Cursor Cloud Agents** | Native Cursor Plugin (`mhusk/mhusk_stack`) + Cursor **Sync Skills for Cloud Agents** (or VM bootstrap) | Plugin `rules/mhusk-stack.mdc` (`alwaysApply: true`), repo `AGENTS.md` | Ready for plugin test |
| **GrokBot** | `$HOME/.grok/skills/` and `$HOME/.agents/skills/` | `$HOME/.grok/rules/mhusk_stack.md`, repo `AGENTS.md` | Installed — ready for live check |

---

## Quick Local Install

From the root of your local `mhusk_stack` clone:

```bash
./scripts/validate.sh
./scripts/install.sh
./scripts/install.sh --check
```

Options:
- `--harness <all|antigravity|cursor|grok>` — Target a single harness (default: `all`).
- `--mode <symlink|copy>` — Use `symlink` (default) for local machines so `git pull` updates everything immediately; use `copy` for ephemeral VMs or sandboxes that disallow symlinks.
- `--check` — Read-only verification of installed harness links/configs.

---

## Cursor Cloud Agents & Cross-Repo Setup

Cursor Cloud Agents run inside isolated cloud VMs without access to your local `$HOME` (so local `$HOME/.cursor/skills/` and `$HOME/.agents/skills/` are absent unless synced or installed via plugin/VM bootstrap).

Use the native Cursor Plugin flow (syncs **both** rules and skills across all repos and Cloud Agents):

1. **Install as a Cursor Plugin from GitHub (recommended):**
   - In Cursor, open **Settings → Plugins** (or the **Plugins / Customize** panel) and import from GitHub: `mhusk/mhusk_stack`.
   - Cursor reads `.cursor-plugin/plugin.json` (and `.cursor-plugin/marketplace.json`), mounts `rules/mhusk-stack.mdc` (`alwaysApply: true`), and registers `skills/*/SKILL.md`.
   - Whenever you edit `AGENTS.md`, run `./scripts/sync-rules.sh` before committing so `rules/mhusk-stack.mdc` stays identical (`./scripts/validate.sh` enforces this).
2. **Enable Personal Skills Sync (optional, for local `~/.cursor/skills/`):**
   - In Cursor, go to **Settings → Agents** and turn on **Sync Skills for Cloud Agents**.
3. **Fallback — Cloud VM Bootstrap Script:**
   In a Cursor Cloud Agent environment setup script (`.cursor/environment.json`), pull and install `mhusk_stack` in copy mode:
   ```bash
   git clone --depth 1 https://github.com/mhusk/mhusk_stack.git "$HOME/.mhusk_stack" \
     && "$HOME/.mhusk_stack/scripts/install.sh" --harness cursor --mode copy
   ```

---

## 3-Prompt Smoke-Test Matrix

Run these three prompts in a **fresh session** per harness after installation:

| # | Prompt | What It Verifies | Expected Result |
| :--- | :--- | :--- | :--- |
| 1 | `mhusk-check` | Always-on rules loaded | Replies `RULES_OK: mhusk_stack@0.1.0` + loaded rule path |
| 2 | `ping my stack` | Skill discovery + `SKILL.md` read + script execution | Activates `stack-ping`, executes `check.sh`, reports `SKILL_SCRIPT_OK` |
| 3 | `Help me plan adding a new feature to this repo` | `implementation-plan-and-docs` triggers naturally | Asks clarifying questions first before drafting a phased plan |

---

## Verification Log & Troubleshooting Notes

*(Updated during Phase 5 live validation.)*

### Google Antigravity
- **Status:** Verified (2026-11-23)
- **Verified results:**
  - Prompt 1 (`mhusk-check`): Passed (`RULES_OK: mhusk_stack@0.1.0`).
  - Prompt 2 (`ping my stack`): Passed (`SKILL_OK: stack-ping@0.1.0` + `SKILL_SCRIPT_OK`).
  - Skill discovery: Both `stack-ping` and `implementation-plan-and-docs` discovered automatically under `$HOME/.gemini/config/plugins/mhusk_stack/skills/`.
- **Gotchas & Fixes Found:**
  - **Standalone rules vs. plugin bundle:** Symlinking plain `AGENTS.md` to `$HOME/.gemini/config/rules/mhusk_stack.md` did *not* auto-load because standalone rule files require `trigger: always_on` YAML frontmatter. Installing `mhusk_stack` as a native plugin bundle (`$HOME/.gemini/config/plugins/mhusk_stack/` with `plugin.json`, `rules/AGENTS.md`, and `skills/`) loads plain `AGENTS.md` cleanly with zero frontmatter changes and deduplicates automatically by resolved symlink path.
  - **macOS sandbox `/usr/bin/python3` shim:** Inside strict macOS sandboxes, `/usr/bin/python3` invokes `xcode-select` and can fail with `Operation not permitted`. Keep helper scripts (`validate.sh`, `install.sh`, `check.sh`) in pure `bash` + POSIX utilities (`awk`, `grep`, `find`, `wc`).

### Cursor Desktop
- **Status:** Pending
- **Notes:** _TBD_

### Cursor Cloud Agents
- **Status:** Pending
- **Notes:** _TBD_

### GrokBot
- **Status:** Pending
- **Notes:** _TBD_
