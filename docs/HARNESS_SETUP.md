# Harness Setup & Verification Guide

This document tracks how `mhusk_stack` is installed, validated, and troubleshot across supported harnesses. Update this file whenever live testing reveals a quirk or better setup pattern.

---

## Supported Harnesses

| Harness | Skills Path(s) | Rules Path(s) | Status |
| :--- | :--- | :--- | :--- |
| **Google Antigravity** | `$HOME/.gemini/config/plugins/mhusk_stack/skills/` (plugin bundle) | `$HOME/.gemini/config/plugins/mhusk_stack/rules/AGENTS.md`, repo `AGENTS.md` | **Verified** |
| **Cursor Desktop** | Native Cursor Plugin (`mhusk/mhusk_stack`) and/or `$HOME/.agents/skills/` + `$HOME/.cursor/skills/` | Plugin `rules/mhusk-stack.mdc` (`alwaysApply: true`), repo `AGENTS.md` | **Verified** |
| **Cursor Cloud Agents** | Cursor **Sync Skills for Cloud Agents** (requires `--mode copy` for `~/.cursor/skills/`) | Cursor **User Rules** (`Customize → Rules → + New`) + repo `AGENTS.md` | **Verified** |
| **GrokBot** | Native GitHub plugin import (`mhusk_stack` → `mhusk-stack@mhusk-mhusk-stack/skills/`) + local `$HOME/.grok/skills/` | Bot instructions/memory (Grok Bot imports skills, not `AGENTS.md`); repo `AGENTS.md` for local Grok CLI | **Verified** |

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
- `--mode <auto|symlink|copy>` — Default `auto` uses `copy` for Cursor (`$HOME/.cursor/skills/`, `$HOME/.agents/skills/`) so **Sync Skills for Cloud Agents** works out of the box, and `symlink` for Antigravity/Grok so `git pull` updates immediately.
- `--check` — Read-only verification of installed harness links/copies.

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
| 1 | `mhusk-check` | Always-on rules loaded | Replies `RULES_OK: mhusk_stack@0.1.0` + loaded rule path *(coding harnesses / User Rules)* |
| 2 | `mhusk-ping` | Skill discovery + `SKILL.md` read + script execution (or fallback) | Activates `stack-ping`, replies `SKILL_OK: stack-ping@0.1.0`, and outputs `SKILL_SCRIPT_OK` *(or `SCRIPT_UNMOUNTED` in Grok Bot)* |
| 3 | `Help me plan adding a new feature to this repo` | `implementation-plan-and-docs` triggers naturally | Asks clarifying questions first before drafting a phased plan |

---

## Verification Log & Troubleshooting Notes

*(Updated during Phase 5 live validation.)*

### Google Antigravity
- **Status:** Verified (2026-11-23)
- **Verified results:**
  - Prompt 1 (`mhusk-check`): Passed (`RULES_OK: mhusk_stack@0.1.0`).
  - Prompt 2 (`ping my stack`): Passed (`SKILL_OK: stack-ping@0.1.0` + `SKILL_SCRIPT_OK`).
  - Skill discovery: `stack-ping`, `implementation-plan-and-docs`, and `skill-author` (`SKILL_OK: skill-author@0.1.0`) discovered automatically under `$HOME/.gemini/config/plugins/mhusk_stack/skills/`.
- **Gotchas & Fixes Found:**
  - **Standalone rules vs. plugin bundle:** Symlinking plain `AGENTS.md` to `$HOME/.gemini/config/rules/mhusk_stack.md` did *not* auto-load because standalone rule files require `trigger: always_on` YAML frontmatter. Installing `mhusk_stack` as a native plugin bundle (`$HOME/.gemini/config/plugins/mhusk_stack/` with `plugin.json`, `rules/AGENTS.md`, and `skills/`) loads plain `AGENTS.md` cleanly with zero frontmatter changes and deduplicates automatically by resolved symlink path.
  - **macOS sandbox `/usr/bin/python3` shim:** Inside strict macOS sandboxes, `/usr/bin/python3` invokes `xcode-select` and can fail with `Operation not permitted`. Keep helper scripts (`validate.sh`, `install.sh`, `check.sh`) in pure `bash` + POSIX utilities (`awk`, `grep`, `find`, `wc`).

### Cursor Desktop
- **Status:** Verified (2026-11-23)
- **Verified results:**
  - Prompt 1 (`mhusk-check`): Passed both inside `mhusk_stack` and in a separate repo (Local Agent mode) via the imported `mhusk-stack` Cursor Plugin (`rules/mhusk-stack.mdc`).
  - Prompt 2 (`ping my stack`): Passed in a separate repo (`SKILL_OK: stack-ping@0.1.0` + `SKILL_SCRIPT_OK`).
  - Prompt 3 (`implementation-plan-and-docs`): Verified naturally generating a phased plan (`docs/plans/2026-11-23-skill-author.md`).
- **Gotchas & Fixes Found:**
  - Make sure you are in **Local Agent** mode (not a ☁️ Cloud Agent chat) when testing Cursor Desktop local plugin/skill installs.
  - Importing `mhusk/mhusk_stack` via `.cursor-plugin/plugin.json` + `rules/mhusk-stack.mdc` (`alwaysApply: true`) makes both rules and skills available across *all* local repos without per-repo config.

### Cursor Cloud Agents
- **Status:** Verified (2026-11-23)
- **Verified results:**
  - Prompt 2 (`ping my stack`): Passed in a brand-new Cloud Agent session on a separate repo (`agent-kanban`) once `~/.cursor/skills/` used real copied directories (`--mode copy`) with **Settings → Agents → Sync Skills for Cloud Agents** enabled.
- **Gotchas & Fixes Found:**
  - **Symlinks do not sync to Cloud Agents:** Even with **Sync Skills for Cloud Agents** turned ON, Cursor's sync skips symlinks in `$HOME/.cursor/skills/`. `scripts/install.sh` now defaults to `--mode auto`, which installs real copies for Cursor (`$HOME/.cursor/skills/`, `$HOME/.agents/skills/`) and symlinks for Antigravity/Grok. After updating skills, re-run `./scripts/install.sh` (and toggle Sync Skills OFF/ON if you need an immediate push).
  - **Fresh VM required:** Existing Cloud Agent threads keep their startup VM snapshot—always open a **brand-new** Cloud Agent session after updating skills or rules.
  - **Global rules (`mhusk-check`) in Cloud Agents:** Local/custom GitHub plugins do not automatically mount in personal Cloud Agent VMs (only Marketplace/Team Marketplace plugins do). For global always-on rules across all Cloud Agent repos, add `AGENTS.md` under Cursor **Customize → Rules → + New** (**User Rule**).

### GrokBot
- **Status:** Verified (2026-11-23)
- **Verified results:**
  - Plugin discovery: Grok Bot natively imported `mhusk_stack` (via `.cursor-plugin/plugin.json` + `skills/`) as `mhusk_stack (2 skills)` under `$HOME/agent-data/plugins/mhusk-stack@mhusk-mhusk-stack/skills/`.
  - Skill activation (`stack-ping`): Passed (`SKILL_OK: stack-ping@0.1.0`).
- **Gotchas & Fixes Found:**
  - **Skills only, not `AGENTS.md`:** Grok Bot imports `skills/*/SKILL.md` from the plugin repo, not `AGENTS.md` (so `mhusk-check` is not auto-loaded unless added to a bot's custom instructions/memory). Keep portable workflows inside `skills/` so they work across all four harnesses.
  - **Plugin scripts are readable, not shell-mounted:** Grok Bot can read files under `$HOME/agent-data/plugins/.../scripts/`, but running them directly fails with `working directory does not exist`. Keep core skill logic self-contained in `SKILL.md` + `references/` and include a fallback when bundled scripts aren't mounted.
  - **Avoid ambiguous trigger phrases:** Generic prompts like `"ping my stack"` collide with Chief of Staff's live infrastructure checks; use unmistakable trigger tokens like `mhusk-ping`.
