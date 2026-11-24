# mhusk_stack

A portable, public-safe context stack of agent rules (`AGENTS.md`, `rules/mhusk-stack.mdc`) and modular skills (`skills/*/SKILL.md`) verified across **Google Antigravity**, **Cursor Desktop**, **Cursor Cloud Agents**, and **GrokBot**.

## Verified Harness Matrix

| Harness | How `mhusk_stack` Loads | Rules (`AGENTS.md`) | Skills (`SKILL.md`) | Bundled `scripts/` |
| :--- | :--- | :---: | :---: | :---: |
| **Google Antigravity** | Local plugin bundle (`~/.gemini/config/plugins/mhusk_stack/`) via `install.sh` | ✅ Auto-loaded | ✅ Auto-discovered | ✅ Executable |
| **Cursor Desktop (Local)** | Native Cursor Plugin (`.cursor-plugin/plugin.json` + `rules/mhusk-stack.mdc`) & `~/.cursor/skills/` | ✅ Auto-loaded across repos | ✅ Auto-discovered | ✅ Executable |
| **Cursor Cloud Agents** | **Settings → Agents → Sync Skills for Cloud Agents** (requires `--mode copy`) + optional Cursor **User Rules** | ✅ Via User Rules or repo `AGENTS.md` | ✅ Synced automatically | ✅ Executable |
| **GrokBot** | Native GitHub plugin import (`mhusk-stack@mhusk-mhusk-stack`) | ⚠️ Skills-only (add to bot instructions if needed) | ✅ Auto-discovered | ⚠️ Readable, not shell-mounted |

See [docs/HARNESS_SETUP.md](./docs/HARNESS_SETUP.md) for verified paths, setup steps, and real-world troubleshooting notes for each harness.

## Quickstart

```bash
git clone https://github.com/mhusk/mhusk_stack.git "$HOME/Code/mhusk_stack"
cd "$HOME/Code/mhusk_stack"
./scripts/validate.sh
./scripts/install.sh
./scripts/install.sh --check
```

- `scripts/install.sh` defaults to `--mode auto`: symlinks for Antigravity/Grok and real copies for Cursor (`~/.cursor/skills/`, `~/.agents/skills/`) so Cursor's **Sync Skills for Cloud Agents** syncs them automatically.
- For **Cursor Desktop (across all local repos)** and **GrokBot**, also import `mhusk/mhusk_stack` as a plugin from GitHub.
- After editing `AGENTS.md`, run `./scripts/sync-rules.sh` to keep `rules/mhusk-stack.mdc` in sync (`./scripts/validate.sh` enforces parity).

## Smoke Test (Fresh Session)

1. `mhusk-check` → confirms always-on rules loaded (`RULES_OK: mhusk_stack@0.1.0`).
2. `mhusk-ping` → confirms progressive skill discovery (`SKILL_OK: stack-ping@0.1.0` + `SKILL_SCRIPT_OK` or `SCRIPT_UNMOUNTED`).
3. `Help me plan adding a new feature to this repo` → confirms `implementation-plan-and-docs` asks clarifying questions before drafting a phased plan.

## Included Skills

| Skill | Purpose |
| :--- | :--- |
| [stack-ping](./skills/stack-ping/SKILL.md) | Canary skill + helper script to smoke-test skill discovery and execution in any harness. |
| [implementation-plan-and-docs](./skills/implementation-plan-and-docs/SKILL.md) | Interactive Q&A → phased implementation plan with per-step validation gates → mandatory repo docs update. |
| [codebase-refactor-audit](./skills/codebase-refactor-audit/SKILL.md) | Scoped 7-lens codebase audit → ranked chat report with triage gate → phased refactoring plan with strict safety nets and doc updates. |
| [skill-author](./skills/skill-author/SKILL.md) | Add or update skills and rules in `mhusk_stack` from any local repository or cloud harness (with validation, rule sync, and install refresh). |

## Documentation

- [docs/HARNESS_SETUP.md](./docs/HARNESS_SETUP.md) — Per-harness setup, smoke-test matrix, and verified troubleshooting notes.
- [docs/CONTRIBUTING_SKILLS.md](./docs/CONTRIBUTING_SKILLS.md) — Standards, public-safety checklist, and workflow for adding new skills.
- [docs/plans/2026-11-23-mhusk-stack-setup.md](./docs/plans/2026-11-23-mhusk-stack-setup.md) — Completed phased implementation plan tracking this rollout.

## Local Overrides

Keep machine-specific or personal instructions out of git by placing them in `AGENTS.local.md` or `local/` (both gitignored).
