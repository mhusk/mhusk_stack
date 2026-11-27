---
name: skill-author
description: >-
  Use when the user wants to add or update a skill (`SKILL.md`), add a standing
  rule (`AGENTS.md`), or save a reusable pattern into `mhusk_stack`—whether
  working inside `mhusk_stack`, from another local repository, or from a cloud
  harness (GrokBot / Cursor Cloud Agents). Do not trigger for session/chat
  retrospectives that first need to discover candidate skills
  (`session-skill-retro`), general project feature planning
  (`implementation-plan-and-docs`), or canary pings (`stack-ping`).
---

# `mhusk_stack` Skill & Rule Authoring (From Anywhere)

Use this workflow whenever the user wants to add a new skill, update an existing skill, or add a portable rule to `mhusk_stack`—even if the current session is open in a completely different repository or cloud harness.

At the start of execution, reply with:
`SKILL_OK: skill-author@0.1.0`
and the exact path to this `SKILL.md` file that you read, then proceed through the steps below.

---

## Step 1: Locate `mhusk_stack` (Update From Anywhere)

**Never edit installed copies** under `$HOME/.cursor/skills/`, `$HOME/.agents/skills/`, or `$HOME/.gemini/config/plugins/`. Always edit the `mhusk_stack` git repository so GitHub remains the single source of truth.

Detect which environment you are in:

1. **Case A — Already inside `mhusk_stack`:**
   - Current working directory contains `AGENTS.md`, `skills/`, and `scripts/validate.sh`.
   - Edit directly in place.
2. **Case B — In another local repository (Antigravity / Cursor Desktop Local):**
   - Check `$HOME/Code/mhusk_stack` (or ask the user for their local clone path if it is not there).
   - Confirm before modifying files outside the current workspace if the harness requires permission.
   - Make all edits inside `$HOME/Code/mhusk_stack`, then run its scripts from there.
3. **Case C — In a cloud harness without a local clone (GrokBot / Cursor Cloud Agents):**
   - Use GitHub tools/connector (or `gh`) to create a branch and Pull Request against `mhusk/mhusk_stack` (or commit to `main` only if the user explicitly asks).
   - Remember: GitHub Actions runs `./scripts/validate.sh` and tests `scripts/install.sh` automatically on every push and PR.
   - After creating the PR/commit, always remind the user to refresh their local machine next time:
     ```bash
     git -C "$HOME/Code/mhusk_stack" pull && "$HOME/Code/mhusk_stack/scripts/install.sh"
     ```

---

## Step 2: Confirm Type, Name & Public-Safety Scope

Before writing files, confirm any open edge with 1–3 concise questions (with recommended defaults):
- **Skill vs. Rule:**
  - Prefer a **Skill** (`skills/<name>/SKILL.md`) for repeatable multi-step workflows—skills are the universal layer that works across Antigravity, Cursor Desktop, Cursor Cloud Agents, and GrokBot.
  - Use a **Standing Rule** (`AGENTS.md`) only for short, universal engineering constraints (remember: GrokBot imports skills only, not `AGENTS.md`).
- **Skill name:** Lowercase hyphenated (`^[a-z0-9]+(-[a-z0-9]+)*$`), matching the folder name under `skills/<name>/`.
- **Collision-free trigger:** Pick a clear `description` that won't collide with live infrastructure checks, `stack-ping` (`mhusk-ping`), or `implementation-plan-and-docs`.
- **Public-safety check:** `mhusk_stack` is public. Never include personal paths (`/Users/<name>/`, `/home/<name>/`), personal emails, tokens/keys, or private/internal company details. Use `$HOME` and relative paths; put private overrides in gitignored `AGENTS.local.md` or `local/`.

---

## Step 3: Make the Edit

### If adding or updating a Skill:
1. Read `docs/CONTRIBUTING_SKILLS.md` inside `mhusk_stack` if available for full standards.
2. Create/edit `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) and a concise procedural body (`< 16 KB`).
3. **Cross-harness portability rule:** Keep core instructions self-contained in `SKILL.md` and optional `references/*.md` so the skill works in all four harnesses—including GrokBot, where plugin files are readable but not mounted on the shell filesystem. Treat `scripts/` as optional accelerators written in pure `bash` + POSIX utilities (avoid `/usr/bin/python3` on macOS sandboxes), set `chmod +x`, and include a graceful fallback when scripts cannot be executed.
4. If adding a brand-new skill, add a row for it in `mhusk_stack`'s `README.md` skills table using a relative link (`./skills/<name>/SKILL.md`).

### If updating `AGENTS.md`:
1. Keep `AGENTS.md` concise (`< 20 KB`).
2. Run `./scripts/sync-rules.sh` so `rules/mhusk-stack.mdc` stays byte-for-byte in sync with `AGENTS.md` (enforced by `validate.sh`).

---

## Step 4: Validate, Install & Ship

### In local environments (Case A or Case B):
1. Run static validation from `mhusk_stack`:
   ```bash
   ./scripts/validate.sh
   ```
   Do not proceed until it exits `0` with `VALIDATE_OK`.
2. Refresh all local harness links and Cursor copies:
   ```bash
   ./scripts/install.sh
   ./scripts/install.sh --check
   ```
   *(Default `--mode auto` updates symlinks for Antigravity/Grok and copies for Cursor so **Sync Skills for Cloud Agents** picks up the change.)*
3. Ask the user (or follow their explicit instruction) to commit and push to `origin/main` so GitHub Actions CI, GrokBot, and Cursor Cloud Agents receive the update.

### In cloud environments (Case C):
1. Double-check YAML frontmatter (`name` == folder name, `description` >= 15 chars), relative links, `rules/mhusk-stack.mdc` parity (if `AGENTS.md` changed), and public-hygiene rules before pushing/opening the PR.
2. Point the user to the GitHub Actions `Validate mhusk_stack` check on the PR/branch and include the local pull/reinstall one-liner.

---

## Step 5: Provide Live Verification Prompts

Close out by giving the user two exact prompts to test in a **fresh session** (and a brand-new Cloud Agent VM if testing Cursor Cloud Agents):
1. **Trigger prompt:** A concrete prompt that should activate the new/updated skill (and the expected observable result).
2. **Non-trigger prompt:** A nearby prompt (e.g., `mhusk-ping`) that should *not* activate the new skill.
