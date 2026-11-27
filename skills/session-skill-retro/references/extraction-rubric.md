# Session Skill Retro — Extraction Rubric & Decision Guide

Use this reference during Steps 1–3 of `session-skill-retro` to gather session evidence cleanly, avoid noisy proposals, place findings in the right layer, and keep `mhusk_stack` public-safe.

---

## 1. Session Source Acquisition Notes

| Source Type | How to Read | Practical Tips |
| :--- | :--- | :--- |
| **Current Chat** | Inspect the active conversation history directly | Focus on user redirections, tool failures/retries, and final lessons learned before context compaction |
| **Pasted Text / Local File** | Read the pasted excerpt or supplied `.md` / `.txt` / `.json` / `.jsonl` path | For large files, scan headings/roles/errors first, then read surrounding context lines |
| **Antigravity Transcript** | Read `$HOME/.gemini/antigravity/brain/<conversation-id>/.system_generated/logs/transcript.jsonl` | Start with compact `transcript.jsonl`; read matching line numbers in `transcript_full.jsonl` only when `truncated_fields` hides needed details |
| **Cloud Harness (GrokBot / Cursor Cloud)** | No local `$HOME` filesystem access to past Mac sessions | Ask the user to paste the session excerpt, upload/link a transcript, or run `session-skill-retro` locally |

### Long-Transcript Sampling Strategy
When a transcript exceeds comfortable reading limits, sample deliberately instead of skimming blindly:
1. Read the opening user request and any clarifying Q&A.
2. Search/filter for **user messages** (especially corrections, "no", "don't", "instead", "always", "why did").
3. Search/filter for **errors/failures** (`FAIL`, `Error`, `denied`, `403`, `timeout`, non-zero exit codes, retries).
4. Read the closing summary, verification commands, and final commits/diffs.
5. State clearly in **Retro Scope & Baseline** which parts were read in full vs. sampled.

---

## 2. Five Signal Lenses (High-Signal vs. Noise)

| Lens | High-Signal Examples (Extract) | Noise / Skip Examples (Do Not Extract) |
| :--- | :--- | :--- |
| **1. User Corrections & Redirections** | User had to tell the agent: *"Clarify edge cases before coding"*, *"Don't use mock fixtures with real-looking key prefixes"*, *"Always deploy-check after adding an Eventarc trigger"* | One-off preference on variable naming, copy wording, or color choice in a single app |
| **2. Painful Failures & Gotchas** | Non-obvious platform/sandbox trap (e.g., `/usr/bin/python3` shim failure, symlink skipped by Cursor Cloud Sync, IAM propagation delay) that will recur across repos | Typo in a file path, forgotten semicolon, or transient network blip resolved in one retry |
| **3. Repeatable Multi-Step Workflows** | A multi-step pattern the user and agent built ad-hoc (e.g., pre-release checklist, webhook debugging flow, migration dry-run + rollback gate) likely to repeat in other projects | One-time setup specific to a single proprietary service or throwaway script |
| **4. Existing-Skill Gaps & Trigger Issues** | An existing `mhusk_stack` skill missed an edge case, lacked a verification step, triggered falsely on an unrelated prompt, or failed to trigger when expected | Cosmetic rewording of an existing skill that worked fine |
| **5. Cross-Harness, Hygiene & Verification** | Lesson about Antigravity vs. Cursor vs. GrokBot behavior, public-hygiene near-miss, or missing smoke test that caught a real bug after unit tests passed | Generic textbook advice (*"write clean code"*, *"add unit tests"*) not grounded in a concrete gap from the session |

---

## 3. Placement Decision Matrix

| Destination | When to Choose It | Portability & Maintenance Notes |
| :--- | :--- | :--- |
| **Update Existing Skill** *(Default preference)* | The insight extends, clarifies, or hardens a workflow already owned by an existing skill (e.g., `implementation-plan-and-docs`, `cloud-deploy-gates`, `codebase-refactor-audit`, `teach-me-the-codebase`, `skill-author`) | Keeps skill count tight, avoids trigger overlap, and improves an already-installed skill across all harnesses |
| **New Skill** (`skills/<name>/SKILL.md`) | The session revealed a distinct, repeatable multi-step workflow (3+ steps or checklist + validation) with clear trigger boundaries that does not belong inside any existing skill | Must use lowercase hyphenated name (`^[a-z0-9]+(-[a-z0-9]+)*$`), stay `< 16 KB`, and work in all 4 harnesses (pure Markdown preferred; optional POSIX `bash` scripts with fallback) |
| **`AGENTS.md` Standing Rule** | A crisp, universal constraint (1–3 sentences) that applies to *every* task regardless of which skill triggers (e.g., public-safety rule, never commit secrets) | **GrokBot caveat:** GrokBot imports `skills/`, not `AGENTS.md`. If a rule is critical in GrokBot too, put it in relevant skills instead. Requires `./scripts/sync-rules.sh` when edited |
| **Skip / Repo-Local Only** | Specific to one repository's stack/schema, a one-off bugfix, already covered in `mhusk_stack`, or contains private/internal context | Recommend placing in that target repo's `AGENTS.md`/`docs/` or in gitignored `AGENTS.local.md` / `local/` |

---

## 4. Public-Safety & Generalization Checklist

Before proposing any candidate in Step 4, verify:
- [ ] **No personal paths:** Replace `/Users/<name>/...` or `/home/<name>/...` with `$HOME/...` or repo-relative paths.
- [ ] **No personal or private identifiers:** Remove personal emails, internal company/team names, private URLs, or proprietary product schemas.
- [ ] **No secret-shaped literals:** Never include real or realistic static tokens (`ghp_...`, `sk-...`, `AKIA...`, `whsec_...`) even in examples.
- [ ] **Generalized trigger & steps:** Abstract repo-specific filenames/frameworks into reusable patterns unless the skill explicitly targets a public tool/platform.
- [ ] **Private fallback:** If a lesson is valuable personally but cannot be safely generalized for a public repo, mark it **Repo-Local / Private (`AGENTS.local.md`)** instead of proposing it for tracked `mhusk_stack` files.
