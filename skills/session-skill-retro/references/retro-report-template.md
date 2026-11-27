# Session Skill Retro Report: `<Session / Topic>`

## Retro Scope & Baseline
- **Session Source:** `<current chat | pasted transcript | path/to/file | Antigravity conversation ID>`
- **Coverage:** `<Full inspection | Sampled segments + what was prioritized/omitted>`
- **Baseline Checked:** `<path or GitHub repo checked for AGENTS.md + skills/*/SKILL.md>`
- **Summary:** `<1–2 sentence overview of what happened in the session and the main leverage areas>`

---

## Updates to Existing Skills
| ID | Target Skill | Proposed Change | Session Evidence | Priority |
| :--- | :--- | :--- | :--- | :--- |
| `C1` | `<existing-skill-name>` | `<Concise summary of step/guardrail/trigger update>` | `<Exact moment, error, or user correction in session>` | High |

*(If none: "No updates needed for existing skills.")*

---

## New Skill Candidates
*(Propose only if the workflow does not fit cleanly into an existing skill.)*

### `C2` — `<proposed-kebab-case-name>` (`<High | Medium>` Priority)
- **Why not merge into an existing skill:** `<Concrete reason existing skills don't cover this boundary>`
- **Trigger sketch:** `<When it should trigger — and what nearby skills it must NOT collide with>`
- **Core workflow:**
  1. `<Step 1>`
  2. `<Step 2>`
  3. `<Validation / close-out step>`
- **Session evidence:** `<Exact workflow/failure from the session that proved the need>`

*(If none: "No brand-new skills proposed; existing skills cover the workflow.")*

---

## Standing Rule Candidates (`AGENTS.md`)
*(Reserve for short, universal always-on constraints; note that GrokBot loads skills only, not `AGENTS.md`.)*

| ID | Proposed Rule | Session Evidence | Why Always-On (vs. Skill) |
| :--- | :--- | :--- | :--- |
| `C3` | `<1–3 sentence generalized rule>` | `<Exact moment or correction>` | `<Applies across all tasks/repos>` |

*(If none: "No new always-on `AGENTS.md` rules proposed.")*

---

## Intentionally Skipped / Repo-Local Only
- `<Pattern or fix observed>` — `<Why skipped: one-off fix / already covered by X / belongs in target repo's AGENTS.md / private preference for AGENTS.local.md>`

---

## Triage Decision
Reply with the candidate IDs you want to apply (for example: *"Apply C1 and C2, skip C3"* or *"Apply C1, tweak C2's name to ..."*). Once approved, I will hand them off to `skill-author` to implement, validate (`./scripts/validate.sh`), and refresh your local harness installs.
