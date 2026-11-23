# Implementation Plan: `skill-author`

- **Date:** 2026-11-23
- **Status:** Draft
- **Scope:** New skill `skills/skill-author/`. Live checks on Google Antigravity, Cursor Desktop, Cursor Cloud Agents, and GrokBot.

## Goal

Add a portable `skill-author` skill that walks an agent through creating one new `mhusk_stack` skill which passes `./scripts/validate.sh` and the public-safety checklist in [docs/CONTRIBUTING_SKILLS.md](../CONTRIBUTING_SKILLS.md). The first slice is a single `SKILL.md`. Harness coverage is a later, separate check on all four supported harnesses.

## Assumptions & Open Decisions

- **Name:** `skill-author` (directory matches frontmatter `name`).
- **Phase 1 is the smallest slice:** `skills/skill-author/SKILL.md` only. No helper script and no `references/` file. The procedure points at existing docs and `./scripts/validate.sh`.
- **Trigger phrases stay narrow** so this skill activates for authoring a skill, and `implementation-plan-and-docs` keeps prompts about planning a feature, migration, or repo setup.
- **Suggested trigger prompt:** `Add a new skill to mhusk_stack`.
- **Suggested non-trigger prompt:** `ping my stack` (must stay on `stack-ping`).
- **Live proof:** after `./scripts/install.sh`, a fresh session on each harness. Cursor Desktop can be checked from this machine. Antigravity, Cursor Cloud Agents, and GrokBot are recorded in [docs/HARNESS_SETUP.md](../HARNESS_SETUP.md) when those sessions are run.
- **Out of scope for this plan:** new validator rules, installer changes, and generating a second example skill as part of the rollout.
- **Execution:** this file is the plan only. Implementation starts after sign-off.

---

## Phases & Validation Gates

### Phase 1: `SKILL.md` only

**Changes:**

- [ ] Create `skills/skill-author/SKILL.md` with `name: skill-author` and a description that names concrete triggers: add a skill, author a `SKILL.md`, make a skill pass `./scripts/validate.sh`.
- [ ] Keep the body procedural and under 16 KB. Steps cover: read [docs/CONTRIBUTING_SKILLS.md](../CONTRIBUTING_SKILLS.md), confirm the skill name, write `skills/<name>/SKILL.md` (optional `scripts/` and `references/` only if the workflow needs them), run `./scripts/validate.sh`, refresh with `./scripts/install.sh` and `./scripts/install.sh --check`, then state the live trigger prompt and the non-trigger prompt for a fresh session.
- [ ] Tell the agent to reply with `SKILL_OK: skill-author@0.1.0` and the exact `SKILL.md` path it read, then continue the authoring steps.
- [ ] Use only relative links and `$HOME` paths. No personal paths, emails, or secrets.

**Validation Gate 1:**

- Command / check: `./scripts/validate.sh`
- Expected result: exit `0` and a line `VALIDATE_OK: all schema, budget, link, script, and public-hygiene checks passed (0 warning(s)).`
- If it fails: read the first `FAIL:` line. Frontmatter or name mismatch points at `skills/skill-author/SKILL.md`. A broken relative link points at a path that does not exist beside that file. A public-hygiene failure points at a hardcoded home path or secret in the new file.

---

### Phase 2: Index the skill

**Changes:**

- [ ] Add `skill-author` to the skills table in `README.md` with a relative link to `skills/skill-author/SKILL.md`.
- [ ] Add a one-line pointer in `docs/CONTRIBUTING_SKILLS.md` under "Workflow for Adding a New Skill" so agents and humans land on the same procedure.

**Validation Gate 2:**

- Command / check: `./scripts/validate.sh`
- Expected result: exit `0`, `VALIDATE_OK`, `0 warning(s)`. The new README link resolves.
- If it fails: the new README or docs link target is missing or the path is not relative to the file that contains it.

---

### Phase 3: Cursor Desktop live trigger and non-trigger

**Changes:**

- [ ] Run `./scripts/install.sh` and `./scripts/install.sh --check` so the new skill is visible to Cursor Desktop.
- [ ] In a **fresh** Cursor Desktop session, send `Add a new skill to mhusk_stack`.
- [ ] In that same fresh session, or a second fresh one, send `ping my stack`.

**Validation Gate 3:**

- Command / check: observe the two replies. No extra repo command beyond install `--check` exiting `0`.
- Expected result:
  - Trigger reply includes `SKILL_OK: skill-author@0.1.0`, the path of `skills/skill-author/SKILL.md` (or the installed path the agent actually read), and the authoring steps from that file.
  - Non-trigger reply includes `SKILL_OK: stack-ping@0.1.0` and `SKILL_SCRIPT_OK`, and does not follow the `skill-author` workflow.
- If it fails:
  - Install `--check` fails: re-run `./scripts/install.sh` and compare the reported skill path with `skills/skill-author`.
  - Trigger hits `implementation-plan-and-docs` instead: narrow the `skill-author` description and drop words like "plan", "feature", and "migration".
  - Non-trigger also activates `skill-author`: the description is too broad. Remove generic verbs ("help", "check", "verify") that overlap `stack-ping`.
  - Skill is invisible: the session was started before install. Open a new session and retry.

---

### Phase 4: Antigravity, Cursor Cloud Agents, and GrokBot

**Changes:**

- [ ] On Google Antigravity, Cursor Cloud Agents (`--mode copy`), and GrokBot, install or refresh `mhusk_stack`, then run the same trigger and non-trigger prompts in a fresh session on each harness.
- [ ] Record pass or fail, the reply markers, and any harness quirk in [docs/HARNESS_SETUP.md](../HARNESS_SETUP.md).

**Validation Gate 4:**

- Command / check: three fresh-session pairs, one per remaining harness. There is no single local command that covers all three.
- Expected result: each harness shows the same two markers as Gate 3 (`skill-author@0.1.0` on the trigger, `stack-ping` plus `SKILL_SCRIPT_OK` on the non-trigger).
- If it fails:
  - Antigravity does not see the skill: confirm the plugin bundle under `$HOME/.gemini/config/plugins/mhusk_stack/skills/skill-author/` after install (see the existing Antigravity note in `docs/HARNESS_SETUP.md`).
  - Cloud Agents do not see the skill: confirm the environment setup script cloned with `--mode copy` and that the VM was created after that script included `skill-author`.
  - GrokBot does not see the skill: confirm that harness's install path from `docs/HARNESS_SETUP.md` contains `skills/skill-author/SKILL.md`.
  - One harness false-triggers: adjust the description once, re-run Gate 1, reinstall, and re-check that harness only.

---

### Final Phase: Documentation & Onboarding Update

**Changes:**

- [ ] Update `docs/HARNESS_SETUP.md` with the Gate 3 and Gate 4 results and any quirk found while installing or triggering `skill-author`.
- [ ] Update `README.md` quickstart only if a new command was required beyond `./scripts/validate.sh` and `./scripts/install.sh`.
- [ ] Mark completed checkboxes in this plan and set **Status** to `Complete`.

**Final Validation Gate:**

- Command / check: `./scripts/validate.sh`
- Expected result: exit `0`, `VALIDATE_OK`, `0 warning(s)`, and every new relative link in `README.md`, `docs/`, and `skills/skill-author/SKILL.md` resolves.
