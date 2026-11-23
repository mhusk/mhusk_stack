# Implementation Plan: `mhusk_stack` Portable Context Stack

- **Date:** 2026-11-23
- **Status:** In Progress
- **Scope:** Google Antigravity, Cursor Desktop, Cursor Cloud Agents, GrokBot

## Goal
Build and publish `mhusk_stack` as a clean, public-safe GitHub repository of portable agent rules and skills that works across **Google Antigravity**, **Cursor Desktop**, **Cursor Cloud Agents**, and **GrokBot**, with automated validation, per-harness verification gates, and a flagship `implementation-plan-and-docs` skill.

---

## Phases & Validation Gates

### Phase 1: Repo Foundation, Public Hygiene & Authoring Guidelines
- [x] Create `.gitignore` excluding `local/`, `AGENTS.local.md`, `dist/`, and OS clutter.
- [x] Create root `AGENTS.md` with public core patterns and `mhusk-check` canary rule.
- [x] Create `docs/README.md`, `docs/CONTRIBUTING_SKILLS.md`, `docs/HARNESS_SETUP.md`, and this tracked plan.
- **Validation Gate 1:** Clean `git status`, zero personal/secret pattern matches, `AGENTS.md` < 20 KB.

### Phase 2: Canary Skill (`stack-ping`) & Automated Validator
- [x] Create `skills/stack-ping/SKILL.md` and executable `skills/stack-ping/scripts/check.sh`.
- [x] Create `scripts/validate.sh` (frontmatter, budgets, relative links, script permissions, public hygiene).
- [x] Create `.github/workflows/validate.yml` for CI on push/PR.
- **Validation Gate 2:** `./scripts/validate.sh` exits `0`; `./skills/stack-ping/scripts/check.sh` prints `SKILL_SCRIPT_OK`; negative test confirms validator catches broken frontmatter/hygiene.

### Phase 3: First Real Skill — `implementation-plan-and-docs`
- [x] Create `skills/implementation-plan-and-docs/SKILL.md`.
- [x] Create `skills/implementation-plan-and-docs/references/plan-template.md`.
- **Validation Gate 3:** `./scripts/validate.sh` passes with zero warnings.

### Phase 4: Cross-Harness Installer (`scripts/install.sh`)
- [x] Create idempotent `scripts/install.sh` supporting `--harness`, `--mode <symlink|copy>`, and `--check`.
- **Validation Gate 4:** `./scripts/install.sh` succeeds twice (idempotent) and `./scripts/install.sh --check` passes.

### Phase 5: Per-Harness Live Verification & Troubleshooting
- [x] 5A — Google Antigravity passes 3-prompt smoke matrix.
- [ ] 5B — Cursor Desktop passes 3-prompt smoke matrix.
- [ ] 5C — Cursor Cloud Agents passes 3-prompt smoke matrix.
- [ ] 5D — GrokBot passes 3-prompt smoke matrix.
- **Validation Gate 5:** All 4 harnesses verified and any harness quirks/workarounds documented.

### Phase 6: Update Docs & Publish Readiness
- [ ] Update `docs/HARNESS_SETUP.md` with verified paths and troubleshooting notes from Phase 5.
- [ ] Update root `README.md` with quickstart, compatibility matrix, and links.
- [ ] Mark all plan checkboxes complete and confirm CI passes on GitHub.
- **Validation Gate 6:** `./scripts/validate.sh` exits `0`, full tree public-hygiene check passes.
