# Codebase Diagnostic Quiz: <Repo or Subsystem>

- **Scope:** `<whole repo | target directories>`
- **Coverage Note:** `<Full inspection | Sampled modules + what was left uninspected>`
- **Delivery Mode:** `<Chat | Local file (.tmp/teach-me-quiz-YYYY-MM-DD.md — keep untracked)>`

---

## Part A: Concept & Technology Map

| Layer | Concept / Technology | Repo Anchors | Role in This Repo |
| :--- | :--- | :--- | :--- |
| Language & Runtime | `<e.g., TypeScript / Node 20>` | `package.json:1-40` | `<Brief role>` |
| Frameworks & APIs | `<e.g., Express / React Query>` | `src/server.ts:12` | `<Brief role>` |
| Architecture & Patterns | `<e.g., Event bus / Middleware chain>` | `src/core/bus.ts:25` | `<Brief role>` |
| Data, Ops & Testing | `<e.g., Postgres migrations / Vitest>` | `db/schema.sql:1` | `<Brief role>` |

---

## Part B: Quick Familiarity Self-Check

Tag each core area below as **`Confident`**, **`Shaky`**, or **`New to me`** before answering the quiz:

| Area | Concept / Technology | Your Rating (`Confident` / `Shaky` / `New to me`) |
| :--- | :--- | :--- |
| 1 | `<Core area 1>` | `<Rating>` |
| 2 | `<Core area 2>` | `<Rating>` |
| 3 | `<Core area 3>` | `<Rating>` |
| 4 | `<Core area 4>` | `<Rating>` |
| 5 | `<Core area 5>` | `<Rating>` |

---

## Part C: Diagnostic Quiz

> **Instructions:** Answer from your current understanding without looking things up—`"I don't know"` or partial guesses are completely fine and help target your learning plan accurately.

### Section 1: Core Concepts & Tech Stack

**Q1.** *(`[Concept / Tech]`)* `<Conceptual question about mechanism, trade-off, or failure mode>`
> Your Answer:

**Q2.** *(`[Concept / Tech]`)* `<Conceptual question>`
> Your Answer:

### Section 2: Repo-Grounded Code & Architecture

**Q3.** *(`[file:line]`)* `<Trace a flow, explain why an abstraction/config exists, or predict what breaks if X changes>`
> Your Answer:

**Q4.** *(`[file:line]`)* `<Repo-grounded question>`
> Your Answer:

*(Scale total questions to 8–15 across Sections 1 and 2 based on repository size and complexity.)*

---

## How to Submit

- **In Chat:** Reply with your Part B ratings and numbered answers (`Q1:` … `Qn:`).
- **In File Mode:** Save your answers inline under each `> Your Answer:` block (do not commit this file), then reply `"Quiz ready for grading"` with the file path.
