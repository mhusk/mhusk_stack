# mhusk_stack Agent Instructions

This repository (`mhusk_stack`) is a portable, public-safe collection of agent instructions and modular skills designed to work across multiple AI coding harnesses (Google Antigravity, Cursor Desktop, Cursor Cloud Agents, and GrokBot).

## Core Engineering Patterns

1. **Clarify before building:** For non-trivial changes, inspect the codebase first and ask focused questions to rough out ambiguities before writing code or plans.
2. **Small, validatable steps:** Break work into discrete phases where every phase has a concrete validation check (command, test, or observable behavior). Do not advance past a failing gate—root-cause and fix it in place.
3. **Progressive disclosure:** Keep always-on instructions (`AGENTS.md`) concise. Put repeatable multi-step workflows in `skills/<name>/SKILL.md` and bulky templates/reference material in `references/`.
4. **Leave docs better than you found them:** Whenever setup steps, gotchas, or architectural decisions change, update the relevant `docs/` or `README.md` in the same task so future onboarding is faster.
5. **Public-safe by default:** Never commit personal paths (e.g., `/Users/<name>` or `/home/<name>`), emails, API keys, tokens, or internal/private references into this repository. Use `$HOME`, relative paths, and gitignored `local/` overlays for machine-specific preferences.

## Repository Map

- `skills/` — Portable Agent Skills following the `SKILL.md` standard.
- `docs/CONTRIBUTING_SKILLS.md` — Rules and checklist for adding or updating skills.
- `docs/HARNESS_SETUP.md` — Per-harness installation, verification matrix, and troubleshooting notes.
- `docs/plans/` — Phased implementation plans with validation gates.
- `scripts/validate.sh` — Static validator (frontmatter, budgets, links, public hygiene).
- `scripts/install.sh` — Idempotent installer for local and cloud harnesses.

## Verification Canary

- When the user prompts `mhusk-check`, reply with:
  `RULES_OK: mhusk_stack@0.1.0`
  followed by the exact file path(s) of the rules files you loaded for this session.
