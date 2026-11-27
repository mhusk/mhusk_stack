---
name: session-skill-retro
description: >-
  Use when the user wants to review, audit, or run a retrospective on the
  current chat or a past session/transcript to discover patterns that should
  become new skills, update existing skills, or add standing rules in
  `mhusk_stack`. Guides transcript gathering, inventorying existing stack
  skills, evidence-based signal extraction with a hard-stop triage gate, and
  handoff to `skill-author`. Do not trigger when the user already knows the
  exact skill or rule change to make (`skill-author`), for codebase
  refactoring audits (`codebase-refactor-audit`), feature planning
  (`implementation-plan-and-docs`), or canary pings (`stack-ping`).
---

# Session-to-Skill Retrospective

Mine the current chat or a past session transcript for repeatable workflows, non-obvious gotchas, user corrections, and missing guardrails—then turn only high-signal, generalized findings into `mhusk_stack` updates via a strict triage gate.

---

## Step 1: Acquire the Session Source

Determine which session to inspect (see [extraction-rubric.md](./references/extraction-rubric.md) for source-specific handling):

1. **Current conversation (default):** When the user does not specify an external transcript or ID, inspect the active conversation history directly.
2. **Pasted transcript or local file/export:** Read the pasted text or the user-provided file path (`.md`, `.txt`, `.json`, `.jsonl`).
3. **Antigravity conversation transcript (by ID or recent session):**
   - When given a conversation ID (or when filesystem access to `$HOME/.gemini/antigravity/brain/` is available), read `$HOME/.gemini/antigravity/brain/<conversation-id>/.system_generated/logs/transcript.jsonl` first (compact log).
   - Read matching lines in `transcript_full.jsonl` only where `truncated_fields` hides key evidence.
   - If the user asks about a recent session without giving an ID and local `$HOME/.gemini/antigravity/brain/` is accessible, list recent conversation directories (e.g., by modified time) and ask which one to inspect.
   - In cloud or sandboxed harnesses without local `$HOME` access (e.g., GrokBot, Cursor Cloud Agents), ask the user to paste the relevant transcript excerpt or provide an accessible log file.

**Long-session sampling rule:** For very long transcripts, prioritize high-signal segments—user corrections, retries, failing commands/deploys, repeated tool sequences, and final summaries—and explicitly record what was inspected in full vs. sampled.

---

## Step 2: Inventory the Current `mhusk_stack` Baseline

Before proposing anything, check what `mhusk_stack` already covers so you refine existing skills instead of duplicating them:

1. Locate `mhusk_stack`:
   - Current workspace (if `AGENTS.md`, `skills/`, and `scripts/validate.sh` are present),
   - `$HOME/Code/mhusk_stack` in local harnesses, or
   - Installed plugin/skill files or `mhusk/mhusk_stack` on GitHub in cloud harnesses.
2. Read `AGENTS.md` and the `name` + `description` of every `skills/*/SKILL.md`.
3. Read the full `SKILL.md` (and relevant `references/`) of any existing skill that overlaps the session's domain.
4. Record the exact baseline source inspected (and note any skills whose full body could not be read).

---

## Step 3: Extract & Classify Candidates

Inspect the session against the 5 signal lenses in [extraction-rubric.md](./references/extraction-rubric.md):

1. **User corrections & redirections** — moments the user corrected an assumption, stopped premature edits, or asked for a different workflow.
2. **Painful failures, retries, & non-obvious gotchas** — IAM/cloud permissions, sandbox quirks, CI failures, flaky tool behaviors, or ordering dependencies.
3. **Repeatable multi-step workflows** — a sequence invented or refined during the session that would help on future projects.
4. **Existing-skill gaps or trigger issues** — missing guardrails, unclear steps, or trigger collisions/misses in `mhusk_stack` skills used during the session.
5. **Cross-harness, hygiene, or verification lessons** — portability gaps, public-safety near-misses, or missing validation checks.

Classify every candidate into one of four buckets:
- **Update Existing Skill** *(strongly preferred whenever an existing skill already owns that workflow or domain)*
- **New Skill** (`skills/<kebab-case-name>/SKILL.md`) — only for distinct, repeatable multi-step workflows that do not fit an existing skill
- **`AGENTS.md` Standing Rule** — only for short (1–3 sentence), universal always-on constraints *(remember: GrokBot imports skills only, not `AGENTS.md`, so prefer skills unless truly global)*
- **Intentionally Skipped / Repo-Local Only** — one-off bugfixes, project-specific architecture/conventions (belong in that repo's `AGENTS.md` or docs), already-covered rules, or private/internal details (belong in gitignored `AGENTS.local.md` or `local/`)

### Evidence, Anti-Noise & Public-Safety Rules
- **Cite concrete evidence:** Every candidate must reference the exact session moment, failing command, or user prompt—never invent generic best practices unsupported by the session.
- **Keep the signal bar high:** Aim for **1–5 high-leverage candidates** rather than a noisy laundry list; merge closely related lessons into a single cohesive proposal.
- **Public-safety by default:** Draft every proposal for a public repo. Strip personal paths (`/Users/<name>/`, `/home/<name>/` → use `$HOME` or relative paths), emails, tokens/keys, secret-shaped literals, and private repo/company/product details. If a lesson cannot be generalized safely, route it to **Intentionally Skipped / Repo-Local Only** (`AGENTS.local.md`).

---

## Step 4: Present the Ranked Retro Report & Triage Gate (Hard Stop)

Present the report in chat using [retro-report-template.md](./references/retro-report-template.md), assigning short IDs (`C1`, `C2`, …) across:
- **Updates to Existing Skills**
- **New Skill Candidates**
- **Standing Rule Candidates (`AGENTS.md`)**
- **Intentionally Skipped / Repo-Local Only**

### Self-Check Before Sending Step 4
- [ ] Every candidate cites specific evidence from the inspected session.
- [ ] Every candidate was checked against the actual `mhusk_stack` baseline (no duplicates).
- [ ] Zero personal paths, secrets, emails, or private details appear in any draft text.
- [ ] Zero files in `mhusk_stack` or the active workspace were modified yet.

**Hard Stop:** Pause here and ask the user which candidate IDs (`C1`, `C2`, …) to apply, modify, or skip. **Do not create or edit any files until the user approves.**

---

## Step 5: Hand Off Approved Items to `skill-author`

Once the user approves a subset of candidates, follow [skill-author](../skill-author/SKILL.md) end-to-end:

1. Edit the `mhusk_stack` git repository directly (locally or via branch/PR in cloud harnesses)—**never** edit installed copies under `$HOME/.cursor/skills/`, `$HOME/.agents/skills/`, or `$HOME/.gemini/config/plugins/`.
2. For new skills, add a row to `mhusk_stack`'s `README.md` skills table. If `AGENTS.md` changed, run `./scripts/sync-rules.sh`.
3. In local harnesses, run `./scripts/validate.sh` until it prints `VALIDATE_OK`, then run `./scripts/install.sh` and `./scripts/install.sh --check`. In cloud harnesses, point to the GitHub Actions validation check and share the local pull/reinstall one-liner.
4. Ask the user before committing or pushing to `origin/main` unless they already instructed you to push.

---

## Step 6: Close Out with Verification Prompts

Summarize:
- Approved candidates applied (with file paths) and validation/install results.
- Any skipped, deferred, or repo-local items (noting where repo-local or private notes should go).
- Concrete **fresh-session trigger and non-trigger verification prompts** per `skill-author` so the user can verify discovery in their target harness(es).
