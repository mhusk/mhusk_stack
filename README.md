# mhusk_stack

A portable, public-safe context stack of agent rules (`AGENTS.md`) and modular skills (`skills/*/SKILL.md`) designed to move seamlessly across **Google Antigravity**, **Cursor Desktop**, **Cursor Cloud Agents**, and **GrokBot**.

## Quickstart

```bash
git clone https://github.com/mhusk/mhusk_stack.git "$HOME/Code/mhusk_stack"
cd "$HOME/Code/mhusk_stack"
./scripts/validate.sh
./scripts/install.sh
./scripts/install.sh --check
```

For ephemeral cloud VMs (such as **Cursor Cloud Agents**), use `--mode copy`:

```bash
git clone --depth 1 https://github.com/mhusk/mhusk_stack.git "$HOME/.mhusk_stack" \
  && "$HOME/.mhusk_stack/scripts/install.sh" --harness cursor --mode copy
```

## Included Skills

| Skill | Purpose |
| :--- | :--- |
| [stack-ping](./skills/stack-ping/SKILL.md) | Canary skill + helper script to smoke-test skill discovery and execution in any harness. |
| [implementation-plan-and-docs](./skills/implementation-plan-and-docs/SKILL.md) | Interactive Q&A → phased implementation plan with per-step validation gates → mandatory repo docs update. |

## Documentation

- [docs/HARNESS_SETUP.md](./docs/HARNESS_SETUP.md) — Per-harness installation paths, 3-prompt smoke-test matrix, verification status, and troubleshooting notes.
- [docs/CONTRIBUTING_SKILLS.md](./docs/CONTRIBUTING_SKILLS.md) — Standards, public-safety checklist, and workflow for adding new skills.
- [docs/plans/2026-11-23-mhusk-stack-setup.md](./docs/plans/2026-11-23-mhusk-stack-setup.md) — Phased implementation plan tracking the rollout of this repository.

## Local Overrides

Keep machine-specific or personal instructions out of git by placing them in `AGENTS.local.md` or `local/` (both gitignored).
