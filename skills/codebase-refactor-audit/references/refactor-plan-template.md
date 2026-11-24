# Refactor Plan: <Title>

- **Date:** YYYY-MM-DD
- **Status:** Draft | In Progress | Complete
- **Scope:** `<Approved finding IDs and affected directories/modules>`
- **Constraints:** `<No-break zones, behavior-preservation rules>`

## Goal
<1–3 sentences summarizing the approved refactoring objectives and expected improvements.>

## Approved vs. Deferred Findings
- **In Scope:** `<F1, F2, ...>`
- **Deferred / Dropped:** `<F3, ...>`

---

## Phase 0: Baseline Verification
**Objective:** Confirm the current test, lint, typecheck, and build status before changing any code.
- [ ] Run baseline commands and record results.

**Baseline Gate:**
- Command / check: `<exact test / lint / typecheck / build command>`
- Expected result: `<clean pass; if pre-existing failures exist, STOP and confirm with user before proceeding>`

---

## Phase 1: <Finding ID — Short Phase Title>
**Safety Net:**
- [ ] `<Add characterization test(s) covering current behavior before editing, or note existing test coverage>`

**Changes:**
- [ ] `<Concrete, scoped file/module refactor>`

**Behavioral Delta:** `None (strictly behavior-preserving)` | `<Explicit description of intentional bug/security behavior change>`

**Validation Gate 1:**
- Command / check: `<exact runnable command or observable check>`
- Expected result: `<pass criteria>`
- If it fails: `<first thing to inspect or rollback step>`

---

## Phase 2: <Finding ID — Short Phase Title>
**Safety Net:**
- [ ] `<Characterization test(s) or existing coverage check>`

**Changes:**
- [ ] `<Concrete, scoped file/module refactor>`

**Behavioral Delta:** `None (strictly behavior-preserving)` | `<Explicit description>`

**Validation Gate 2:**
- Command / check: `<exact runnable command or observable check>`
- Expected result: `<pass criteria>`

---

## Final Phase: Documentation & Onboarding Update
**Changes:**
- [ ] Update `README.md` or relevant `docs/` with architectural changes, updated commands, or new checks.
- [ ] Record any non-obvious pitfalls or gotchas discovered during refactoring.
- [ ] Mark completed checkboxes in this plan and set **Status** to `Complete`.

**Final Validation Gate:**
- Command / check: `<full test / lint / typecheck / build command + git status>`
- Expected result: `<clean pass with no unintended diffs or stale docs>`
