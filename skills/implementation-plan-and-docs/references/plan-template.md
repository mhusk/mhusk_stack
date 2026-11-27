# Implementation Plan: <Title>

- **Date:** YYYY-MM-DD
- **Status:** Draft | In Progress | Complete
- **Scope:** <Systems, services, or environments covered>

## Goal
<1–3 sentences describing the desired outcome and why it matters.>

## Assumptions & Open Decisions
- <List defaults adopted during Q&A or decisions still needing confirmation.>

---

## Phases & Validation Gates

### Phase 1: <Short Phase Title>
**Changes:**
- [ ] <Concrete file, config, or behavior change>
- [ ] <Concrete file, config, or behavior change>

**Validation Gate 1:**
- Command / check: `<exact command or observable check>`
- Expected result: `<pass criteria>`
- If it fails: `<first thing to inspect to isolate root cause>`

---

### Phase 2: <Short Phase Title>
**Changes:**
- [ ] <Concrete file, config, or behavior change>

**Validation Gate 2:**
- Command / check: `<exact command or observable check>`
- Expected result: `<pass criteria>`

---

### Penultimate Phase (Optional): Human-Guided Live Walkthrough
**Changes:**
- [ ] Walk through each user-facing and integration area live against the deployed app (one area at a time).
- [ ] Fix any reported bugs with regression tests, verify CI passes, deploy, and confirm live before checking off the area.

---

### Final Phase: Documentation & Onboarding Update
**Changes:**
- [ ] Update `README.md` or relevant `docs/` with verified setup commands and architecture notes.
- [ ] Record any troubleshooting lessons or platform quirks discovered during execution.
- [ ] Mark completed checkboxes in this plan and set **Status** to `Complete`.

**Final Validation Gate:**
- Command / check: `<test / lint / validator command>`
- Expected result: `<clean pass with no stale docs or broken links>`
