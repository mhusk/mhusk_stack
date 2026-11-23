# Contributing & Authoring Skills

This guide defines the standards for adding new skills to `mhusk_stack` so every skill remains portable across **Google Antigravity**, **Cursor Desktop**, **Cursor Cloud Agents**, and **GrokBot**—and safe to publish publicly.

---

## 1. Directory Layout

Each skill lives in its own folder under `skills/`:

```text
skills/<skill-name>/
├── SKILL.md          # Required: frontmatter + concise procedural instructions
├── scripts/          # Optional: executable helper scripts (+x, minimal dependencies)
├── references/       # Optional: templates, checklists, or deeper reference docs
└── examples/         # Optional: concrete input/output examples
```

### Naming Rules
- Use **lowercase alphanumeric characters and hyphens only** (`^[a-z0-9]+(-[a-z0-9]+)*$`), e.g. `implementation-plan-and-docs`.
- The directory name **must exactly match** the `name` field in `SKILL.md` YAML frontmatter.

---

## 2. `SKILL.md` Frontmatter & Body

Start every `SKILL.md` with YAML frontmatter containing `name` and `description`:

```markdown
---
name: my-skill-name
description: >-
  Third-person summary of what this skill does and exactly when an agent should
  activate it. Include concrete trigger phrases or task types.
---

# My Skill Name

Concise, actionable, step-by-step workflow instructions.
```

### Authoring Guidelines
1. **Write a crisp, collision-free `description`:** Harnesses use progressive disclosure—only `name` and `description` are loaded upfront. Make trigger conditions unambiguous and avoid generic phrases that collide with real app or infrastructure workflows (for example, `mhusk-ping` is much cleaner than `"ping my stack"` in harnesses that monitor live servers).
2. **Keep `SKILL.md` lean and self-contained:** Aim for `< 16 KB` (ideally 50–200 lines). Move large templates, schemas, or reference tables into `references/` and link them with relative paths (e.g., `` `[plan-template.md](./references/plan-template.md)` ``). Pure Markdown skills (`SKILL.md` + `references/`) work across all four harnesses, including cloud plugin sandboxes like Grok Bot.
3. **Treat `scripts/` as optional accelerators with a fallback:** Prefer pure `bash` + standard POSIX tools (`awk`, `grep`, `find`, `wc`) over `/usr/bin/python3` (which on macOS invokes an `xcode-select` shim that can fail inside strict agent sandboxes). Resolve paths relative to the script directory (`SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`), set `chmod +x`, and include a clean fallback instruction for harnesses (like Grok Bot) where plugin files are readable but not mounted on the shell filesystem.
4. **Build in validation steps:** Every procedural skill should tell the agent how to verify its own output before declaring completion.
5. **Avoid duplicating generic knowledge:** Focus on your concrete workflow, conventions, and guardrails rather than explaining basic language/tool usage.

---

## 3. Public-Safety Checklist

Because `mhusk_stack` is a public repository, **never commit**:
- Hardcoded machine paths (no `/Users/<username>/...` or `/home/<username>/...`; use `$HOME` or relative paths).
- Personal identifiers (personal emails, phone numbers, internal org/company names, private repo URLs).
- Secrets, API keys, tokens, or `.env` values.

Put personal or machine-specific overrides in gitignored local files (`AGENTS.local.md` or `local/`).

---

## 4. Workflow for Adding or Updating a Skill

1. **Create or edit the skill folder:** `skills/<skill-name>/SKILL.md` (+ optional `scripts/`, `references/`).
2. **If you also edited `AGENTS.md`, sync the Cursor rule:**
   ```bash
   ./scripts/sync-rules.sh
   ```
3. **Validate statically:**
   ```bash
   ./scripts/validate.sh
   ```
4. **Install / refresh harness links and copies:**
   ```bash
   ./scripts/install.sh
   ./scripts/install.sh --check
   ```
   *(Default `--mode auto` updates symlinks for Antigravity/Grok and copies for Cursor so Cursor's **Sync Skills for Cloud Agents** picks up your changes.)*
5. **Live-test in a fresh agent session:**
   - Start a new conversation (or brand-new Cloud Agent VM) in your target harness(es).
   - Send a natural prompt that matches the skill's `description` and confirm the agent activates the skill, reads `SKILL.md`, and follows its workflow.
   - Send an unrelated prompt and verify the skill does *not* false-trigger.
6. **Update docs if needed:** Note any harness-specific quirks in [HARNESS_SETUP.md](./HARNESS_SETUP.md).
7. **Commit & push:** GitHub Actions runs `./scripts/validate.sh` and tests `scripts/install.sh` automatically on push and pull requests.
