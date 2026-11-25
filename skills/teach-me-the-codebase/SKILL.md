---
name: teach-me-the-codebase
description: >-
  Use when the user wants to learn a repository's technical concepts, tech
  stack, or architecture, get quizzed on how the codebase works, submit quiz
  answers for grading, or receive a prioritized learning plan with hands-on
  exercises to close technical gaps. Do not trigger for refactoring audits
  (`codebase-refactor-audit`), greenfield feature planning
  (`implementation-plan-and-docs`), skill authoring (`skill-author`), or
  canary pings (`stack-ping`).
---

# Teach Me the Codebase

Use this workflow to turn any repository into a calibrated diagnostic quiz and a prioritized, repo-grounded learning plan—without modifying project source files.

---

## Step 1: Ground Yourself in the Repo (Read-Only Recon)

Inspect the repository before asking questions or writing a quiz. Never modify tracked source files during recon.

1. **Read orientation and stack manifests:** Check `README.md`, `AGENTS.md` (or `GEMINI.md`), package/build manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`), infra/CI configs, entry points, and representative core modules.
2. **Build a Concept & Tech Inventory** across 4 layers:
   - **Languages, Runtimes & Build/Tooling**
   - **Frameworks, Libraries & APIs**
   - **Architecture & System Patterns** (routing, state, concurrency, auth, boundaries)
   - **Data, Persistence & Ops/Testing** (schemas, migrations, caching, CI, test harnesses)
3. **Right-size for large repos:** For large codebases or monorepos, sample entry points, boundary layers, and representative modules rather than skimming everything superficially—and explicitly note what was sampled vs. uninspected.
4. **Filter out noise:** Include only concepts genuinely required to read, debug, and modify *this* repo safely. Skip unused dependencies, boilerplate, and generic syntax trivia.

---

## Step 2: Quick Scope & Delivery Check (Optional, 0–3 Questions)

- **Small or focused repos with clear intent:** Skip straight to Step 3 and state your chosen defaults briefly at the top of the output.
- **Large repos, monorepos, or ambiguous requests:** Ask **1–3 concise questions** with recommended defaults before generating the quiz:
  1. **Scope:** Whole repo, or a specific package/directory? *(Default: whole repo for small/medium repos; core app/service path for monorepos.)*
  2. **Background / focus:** Any technologies you already know well to skip, or specific areas to probe deeper? *(Default: balanced diagnostic across the core stack.)*
  3. **Delivery mode:** **Chat (default)** with a copy-pasteable answer template, or a **fillable local markdown file** (e.g., `.tmp/teach-me-quiz-YYYY-MM-DD.md` or a user-chosen path)?
     - *File-mode rule:* Never overwrite existing files without asking, warn the user not to commit temporary quiz files, and automatically fall back to **Chat** in read-only or non-mounted harnesses (such as GrokBot).

---

## Step 3: Present Concept Map & Diagnostic Quiz (Hard Stop)

Use the structure in [quiz-template.md](./references/quiz-template.md). Deliver three parts:

1. **Part A — Concept & Technology Map:** Grouped 4-layer inventory citing concrete `file` or `file:line` anchors and explaining what role each concept plays in this repo.
2. **Part B — Quick Familiarity Self-Check:** List 5–8 top concept areas and ask the user to tag each as `Confident`, `Shaky`, or `New to me`.
3. **Part C — Diagnostic Quiz (8–15 questions, scaled to repo complexity):**
   - **Balanced mix:**
     - **~40–50% Conceptual / Tech-Stack questions:** Core mechanisms, trade-offs, and failure modes of the repo's languages, frameworks, and patterns.
     - **~50–60% Repo-Grounded questions:** Trace a real execution path, explain why a specific abstraction/config exists, or predict what breaks if a behavior changes—always citing exact `file:line` anchors.
   - **Question design:** Prefer short-answer, predict-the-behavior, and explain-why prompts over trivia or easy multiple-choice guessing.
   - **Calibration prompt:** Explicitly encourage honest `"I don't know"` or partial answers without looking things up, so the learning plan targets real gaps.
   - **Answer submission block:** Provide a clean numbered template (inline in chat, or written to the requested fillable `.md` file with `> Your Answer:` placeholders).

### Self-Check Before Sending Step 3
- Every repo-grounded question cites real `file:line` references you directly inspected.
- Question count is between 8 and 15 (mixed conceptual + repo-grounded).
- Zero answers or answer keys are leaked in the quiz.
- No repository source files were modified.

**Hard Stop:** Do **not** reveal the answers or generate the learning plan yet. Wait for the user to reply with their filled-out quiz (or point back to their completed local file).

---

## Step 4: Grade & Diagnose Knowledge Gaps

When the user sends back their quiz (or confirms they edited the local quiz file):

1. **Grade every question** using a clear 3-tier rubric:
   - **Solid:** Accurate core mental model and correct repo reasoning.
   - **Partial:** Right direction, but missing an important mechanism, edge case, or repo-specific nuance.
   - **Gap:** Incorrect, incomplete, or `"I don't know"`.
2. **Calibrate against the Self-Check:** Cross-reference quiz results with Part B ratings to surface:
   - **Hidden Gaps:** Marked `Confident`, scored `Partial` or `Gap`.
   - **Unexpected Strengths / Quick Wins:** Marked `Shaky` or `New to me`, scored `Solid`.
3. **Give concise corrective feedback:** For every `Partial` or `Gap` item, explain the key concept clearly and ground it in exact `file:line` references from the repository.

---

## Step 5: Generate the Prioritized Learning Plan

Use the structure in [learning-plan-template.md](./references/learning-plan-template.md).

1. **Prioritize gaps into 3 tiers** based on how critical they are for working safely in *this* repository:
   - **Tier 1 — Core Foundations (Do First):** Blockers for understanding main flows, core tech, or making safe edits.
   - **Tier 2 — Supporting Concepts (Do Next):** Important for debugging, testing, performance, or secondary subsystems.
   - **Tier 3 — Deeper Mastery (Optional):** Advanced internals, edge patterns, or nice-to-know tooling.
2. **For every gap (`G1`, `G2`, …), include:**
   - **Why it matters here:** Concrete connection to this repo and the missed quiz question(s).
   - **Repo anchors:** Exact `file:line` places to read or trace.
   - **What to study:** Focused concept checklist and official documentation topics / search keywords *(never fabricate or guess URLs)*.
   - **Hands-on repo exercise:** A small, concrete task—such as tracing a request/data flow, writing a temporary scratch test, or running a safe read-only experiment *(explicitly remind the user to keep experiments untracked or revert them afterward)*.
   - **Exit check:** 1–2 concrete self-test questions or outcomes proving the gap is closed.
3. **Delivery:** Present in chat by default, or write to a local untracked file (e.g., `.tmp/learning-plan-YYYY-MM-DD.md`) when file mode was used or requested.

### Self-Check Before Sending Step 5
- Every `Partial` and `Gap` question maps to a learning-plan item (or is explicitly merged into a parent gap).
- Every Tier 1 and Tier 2 item has real inspected `file:line` anchors and a concrete hands-on exercise.
- Zero unverified or invented URLs appear in study resources.

---

## Step 6: Offer Interactive Tutoring & Re-Quiz Follow-Through

Close the learning plan with a direct next step:
- Offer to **start interactive tutoring on Tier 1, Gap #1 (`G1`) right now** (explain using the repo's actual code → walk through the hands-on exercise → run a quick 1–2 question mastery check before moving to `G2`).
- Alternatively, let the user study independently and reply later with **"Re-quiz me on Tier 1"** (or specific gap IDs) to verify mastery.
