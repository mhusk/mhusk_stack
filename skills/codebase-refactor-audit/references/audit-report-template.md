# Codebase Refactor Audit Report: <Repo or Subsystem>

## Audit Scope & Assumptions
- **Target:** `<whole repo | specific paths>`
- **Constraints / No-Break Zones:** `<e.g., public API and DB schema frozen>`
- **Priority Lenses:** `<all 7 lenses | weighted subset>`
- **Read-Only Checks Run:** `<commands run and high-level pass/fail summary, or "None (static code inspection only)">`
- **Coverage Note:** `<Full inspection | Sampled modules + what was left uninspected>`

---

## Quick Wins (High/Medium Impact, Low Effort)
| ID | Lens | Finding | Evidence | Why It Matters | Risk |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `F1` | Security | `<Short title>` | `path/to/file:42` | `<Concrete impact>` | Low |

## High-Leverage Refactors (High Impact, Medium/High Effort)
| ID | Lens | Finding | Evidence | Why It Matters | Risk |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `F2` | Maintainability | `<Short title>` | `path/to/file:10-180` | `<Concrete impact>` | Medium |

## Strategic / Deferred (Large Scope or Lower Urgency)
| ID | Lens | Finding | Evidence | Why It Matters | Suggested Timing |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `F3` | Architecture | `<Short title>` | `path/to/dir/` | `<Concrete impact>` | Next major cycle |

## Leave Alone / Out of Scope
- `<Area or pattern inspected that is healthy or low-ROI to churn—explicitly explaining why it is left untouched.>`

---

## Triage Decision
Reply with the finding IDs you want to tackle now (for example: *"Execute F1 and F2, defer F3"*), or say *"Plan only"* if you want the phased plan without editing code yet.
