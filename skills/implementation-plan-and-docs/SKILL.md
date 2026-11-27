---
name: implementation-plan-and-docs
description: >-
  Use when the user wants to design an implementation plan, break down a new
  feature, migration, or repo setup into validatable steps, or establish
  repository documentation alongside a phased rollout. Guides an interactive
  Q&A to rough out edge cases, writes a step-by-step plan with validation gates,
  and ensures repo docs are updated after execution.
---

# Collaborative Implementation Planning & Repo Docs

Use this workflow when planning non-trivial work so every phase is small, independently verifiable, easy to root-cause when something breaks, and leaves the repository's documentation better than you found it.

---

## Step 1: Ground Yourself in the Repo First

Before asking the user questions, do a fast, targeted read of the workspace:
- Check `AGENTS.md` (or `GEMINI.md`), `README.md`, and any existing `docs/` or `docs/plans/` folder.
- Identify existing conventions (tech stack, test/lint commands, doc locations, CI checks).
- **Never ask questions the repo already answers.**

---

## Step 2: Rough Out the Edges (Interactive Q&A)

Ask **3–5 focused, high-leverage questions** to resolve real ambiguities before drafting the plan. Good questions cover:
- **Scope & non-goals:** What is explicitly in Phase 1 vs. deferred?
- **Interfaces & locations:** Where should new files, configs, or docs live?
- **Constraints & environments:** Which runtimes, platforms, or deployment targets must be supported?
- **Verification expectations:** What counts as "working" (unit test, smoke test, live check)?

Format tips:
- Offer a concise **recommended default** for each question so the user can approve quickly or override only what matters.
- If the user skips some questions or says "just proceed," adopt your recommended defaults, list them explicitly under **Assumptions & Open Decisions**, and keep moving.

---

## Step 3: Draft a Phased Plan with Validation Gates

Use the structure in [plan-template.md](./references/plan-template.md).

### Plan Location
1. Check `AGENTS.md` or existing repo conventions first.
2. Default to `docs/plans/YYYY-MM-DD-<slug>.md` when the plan should live in the repository (and ensure `docs/README.md` indexes it if `docs/` exists).
3. If the user asks for an ephemeral plan only, present it in chat/artifact without committing it.

### Non-Negotiable Plan Qualities
- **Small, isolated phases:** Each phase should deliver one testable slice (e.g., foundation → validator → core logic → integration → docs) so failures pinpoint the exact step that broke.
- **Concrete Validation Gate per phase:** Every phase ends with a runnable command, assertion, or observable check—never vague "verify it works."
- **Troubleshooting / root-cause focus:** Call out likely failure modes or isolation checks when a phase touches external environments, permissions, or multiple tools.
- **Deploy gates for cloud primitives:** If a phase introduces a cloud primitive (secrets, event triggers, scheduled jobs, storage/signed URLs, new provider APIs or OAuth config), end it with a live deploy-and-verify gate per [cloud-deploy-gates](../cloud-deploy-gates/SKILL.md) rather than deferring deployment to the last phase.
- **Human-guided QA walkthrough before launch:** For user-facing apps or multi-integration systems, include a penultimate `[HUMAN]` walkthrough phase split into discrete functional areas—work one area at a time (report → fix + regression test → CI verify → deploy → confirm live → check off) to catch real-world browser, mobile, and cloud quirks emulators cannot reproduce.
- **Mandatory final Docs Update phase:** Always include a final phase dedicated to updating `README.md` and `docs/` with verified commands, gotchas discovered during execution, and setup instructions so future onboarding is effortless.

Pause for user sign-off on the plan before starting execution (unless the user explicitly asked to plan and execute immediately).

---

## Step 4: Execute with Gated Validation

When executing the approved plan:
1. Work **one phase at a time**.
2. Run that phase's **Validation Gate** immediately after completing its changes.
3. **Never skip a failing gate.** If validation fails:
   - Root-cause the failure right there before touching the next phase.
   - Fix the issue and re-run the gate until it passes.
   - Capture any non-obvious pitfall (e.g., platform quirk, sandbox limitation, missing flag) as a note for the Docs Update phase.
4. Check off completed items in the plan file as each phase passes.

---

## Step 5: Update Repo Docs & Close Out

Before declaring the task done:
- Update relevant repo docs (`README.md`, setup guides, `docs/` index) with exact verified commands and troubleshooting notes for any issues hit during execution.
- Confirm the final Validation Gate passes cleanly (lint, tests, status check).
- Summarize what passed, any open follow-ups, and where the updated docs live.
