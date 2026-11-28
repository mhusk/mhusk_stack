---
name: codebase-refactor-audit
description: >-
  Use when the user wants to audit a codebase or subsystem for refactoring and
  structural improvements across long-term maintainability, speed/performance,
  security, reliability, testability, dependencies/DX, and API/data contracts.
  Guides scoped recon, an evidence-based ranked report with a hard triage gate,
  and gated phased execution with strict safety nets and doc updates. Do not
  trigger for greenfield feature planning (`implementation-plan-and-docs`),
  trivial single-file renames/formatting, skill authoring (`skill-author`), or
  canary pings (`stack-ping`).
---

# Codebase Refactor Audit & Gated Execution

Use this workflow to systematically inspect a codebase for high-leverage improvements—without turning into a blanket rewrite—and execute only approved refactors behind strict safety nets and validation gates.

---

## Step 1: Ground Yourself in the Repo First

Before asking the user questions, do a fast, read-only recon of the workspace:
- Check `AGENTS.md` (or `GEMINI.md`), `README.md`, `docs/`, package manifests, and CI workflows.
- Map the tech stack, directory layout, approximate codebase size, and existing test, lint, typecheck, and build commands.
- **Never ask questions the repo already answers.**

---

## Step 2: Scope the Audit (Quick Q&A)

Ask **2–4 focused questions** (with concise recommended defaults) to prevent an unfocused or overly broad audit:
1. **Target scope:** Whole repository, or a specific package/service/directory?
2. **Constraints & no-break zones:** Are public APIs, DB schemas, CLI flags, or wire formats frozen? Any files/areas strictly off-limits?
3. **Priority lenses:** Default to all 7 lenses in [audit-checklist.md](./references/audit-checklist.md), or weight specific ones (e.g., security + performance first)?
4. **Read-only tool checks:** Confirm whether to run existing read-only checks (linter, typechecker, test suite, dependency audit) to gather hard evidence.

If the user already specified scope or says "just audit it," adopt your recommended defaults, state them explicitly under **Audit Scope & Assumptions**, and proceed.

---

## Step 3: Run the 7-Lens Evidence-Based Audit

Inspect the scoped codebase against the 7 lenses in [audit-checklist.md](./references/audit-checklist.md):
1. **Long-Term Maintainability & Architecture**
2. **Speed & Performance**
3. **Security & Hygiene**
4. **Reliability & Error Handling**
5. **Testability & Safety Net**
6. **Dependencies & DX Health**
7. **API & Data Contracts**

### Evidence & Anti-Noise Rules
- **Concrete evidence required:** Every finding must cite exact `file:line` references (or command/tool output), explain *why it matters*, and state the concrete risk or cost.
- **No blanket refactors or style nitpicks:** Do not flag purely cosmetic preferences, healthy working code, or speculative abstractions ("might need later").
- **Prefer real signals:** Where available and permitted, run existing read-only checks (lint, typecheck, test suite, dependency audit) so findings reflect actual failures, bottlenecks, or vulnerabilities.
- **Right-size for large repos:** For large codebases, sample representative modules, entry points, hot paths, and boundaries rather than skimming every file superficially—and note what was sampled vs. uninspected.

---

## Step 4: Present the Ranked Report & Triage Gate (Hard Stop)

Present the audit report **in chat first** using [audit-report-template.md](./references/audit-report-template.md):
- Group findings by **Impact vs. Effort**:
  - **Quick Wins** (High/Medium impact, Low effort)
  - **High-Leverage Refactors** (High impact, Medium/High effort)
  - **Strategic / Deferred** (Large architectural shifts or lower-urgency items)
- Include an explicit **Leave Alone / Out of Scope** section calling out healthy areas or low-ROI churn you intentionally recommend *not* touching.
- Assign each finding a short ID (`F1`, `F2`, …) so the user can approve a subset easily.

**Hard Stop:** Pause here and ask the user which findings to tackle now, defer, or drop. **Do not edit source code or write a plan file until the user approves the selection.**

---

## Step 5: Draft the Phased Refactor Plan (Approved Items Only)

Once the user selects findings to execute, draft a phased plan using [refactor-plan-template.md](./references/refactor-plan-template.md):
- **Plan location:** Default to `docs/plans/YYYY-MM-DD-refactor-<slug>.md` for general structural or performance refactors (committable after secret-hygiene checks, and indexed in `docs/README.md` if `docs/` exists). When the approved plan includes security, vulnerability, or auth-hardening findings in a public repository, store it under a gitignored path such as `docs/plans/security/YYYY-MM-DD-<slug>.md` (or `*security*.md` / `*audit*.md`)—never add a blanket `docs/plans/` git ignore that hides feature plans. If the user asks for an ephemeral plan, keep it in chat/artifact only.
- **Mandatory Phase 0 (Baseline Verification):** Record and run the existing test, lint, typecheck, and build commands *before* editing code. If the baseline is already red, stop and surface the pre-existing failures before refactoring.
- **Small, revertible phases:** Group work into one finding (or tightly coupled cluster) per phase so any regression pinpoints the exact change.
- **Safety-net tests first:** Whenever a phase refactors untested risky logic, include a sub-step to add characterization tests *before* changing the implementation.
- **Behavior-preservation rule:** Keep refactors strictly behavior-preserving; never mix in unrelated features or drive-by reformatting. If an approved security or reliability fix intentionally changes buggy behavior, explicitly document the **Behavioral Delta**.
- **Concrete Validation Gate per phase:** Every phase ends with a runnable command, assertion, or observable check.
- **Mandatory Final Phase:** Update repo docs (`README.md`, architecture/setup guides) for any changed structure, commands, or pitfalls discovered.

Pause for brief plan sign-off unless the user already told you to execute the approved items immediately.

---

## Step 6: Execute with Strict Safety Net & Gated Validation

When executing the approved plan:
1. Run **Phase 0 (Baseline)** first; do not proceed on an unexplained red baseline.
2. Execute **one phase at a time**.
3. Run that phase's **Validation Gate** immediately after completing its changes.
4. **Never skip a failing gate.** If validation fails:
   - Root-cause the failure in place before touching the next phase.
   - Fix and re-run until green (or revert the phase cleanly if blocked).
   - Note any non-obvious pitfall for the Final Docs Phase.
5. Check off completed items in the plan file (and any root-level project tracker such as `IMPLEMENTATION_PLAN.md` if the repo maintains one) as each phase passes.

---

## Step 7: Update Repo Docs & Close Out

Before declaring the task done:
- Update relevant repo docs (`README.md`, `docs/`) with any structural changes, new scripts/checks, or gotchas discovered during refactoring.
- Run the final Validation Gate (full test, lint, typecheck, build, and `git status`/diff sanity check).
- Summarize:
  - Approved findings completed and validation results.
  - Any intentional **Behavioral Deltas** (e.g., stricter validation or error handling).
  - Deferred findings left for future work and where the plan/docs live.
