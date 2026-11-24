# 7-Lens Codebase Refactor Audit Checklist

Use this checklist during **Step 3** of `codebase-refactor-audit`. Focus on high-signal, evidence-backed issues; skip lenses or items that do not apply to the target stack.

---

## 1. Long-Term Maintainability & Architecture
- **Oversized / god modules:** Files or classes mixing unrelated responsibilities (e.g., transport, business logic, persistence, and formatting in one place).
- **Tight coupling & circular dependencies:** Modules reaching into private internals of other layers, or cycles that block isolated testing.
- **Duplicated business logic:** Divergent copies of the same rule/calculation that create bug-fix drift (ignore trivial 3-line syntactic similarity).
- **Dead code & zombie flags:** Unused exports, unreachable branches, commented-out blocks, deprecated code paths, or stale feature flags.
- **Cognitive complexity:** Deep nesting, long parameter lists, boolean flag traps, and misleading names that obscure intent.

## 2. Speed & Performance
- **Data access & I/O bottlenecks:** N+1 queries, unbounded queries without pagination/limits, missing indexes on hot filters, synchronous/blocking I/O on hot paths.
- **Redundant work:** Repeated parsing, serialization, network calls, or expensive recomputation inside loops without caching/memoization.
- **Memory & resource leaks:** Unbounded in-memory caches, unclosed streams/connections/file handles, lingering listeners/timers, or large payload buffering where streaming is appropriate.
- **Startup, bundle & build cost:** Heavy eager imports on cold start, oversized client bundles, or slow repeated work in CLI/server boot.

## 3. Security & Hygiene
- **Secrets & sensitive data:** Hardcoded credentials, API keys, tokens, personal paths, or secrets/PII leaked into logs, error messages, or client bundles.
- **Input validation & injection:** Unvalidated external input reaching SQL, shell commands, file paths (path traversal), templates/HTML (XSS), or regexes (ReDoS).
- **AuthN / AuthZ & trust boundaries:** Missing authentication/authorization checks, inconsistent permission enforcement across endpoints, insecure defaults (overly broad CORS, permissive rules).
- **Supply chain & crypto:** Known vulnerable dependencies, weak/deprecated hashing or randomness, unsafe deserialization, or missing integrity/TLS verification.

## 4. Reliability & Error Handling
- **Silent failures:** Swallowed exceptions (`catch {}`), ignored error return values, or fallback values that hide data corruption.
- **Resilience gaps:** External network/DB calls without timeouts, missing bounded retries/backoff where appropriate, or non-idempotent retries.
- **Concurrency & state hazards:** Race conditions, shared mutable state without synchronization, partial writes without transactions, or unhandled promise rejections.
- **Observability:** Unstructured/noisy logs lacking correlation context, missing error boundaries, or unactionable error messages.

## 5. Testability & Safety Net
- **Untested high-risk paths:** Core business rules, auth, billing/data mutations, or parsers with zero unit/integration coverage.
- **Brittle or slow tests:** Tests coupled to private implementation details, flaky timing/network dependencies, or missing determinism.
- **CI & static-check gaps:** Missing or bypassed typechecking, linting, formatting, or test runs in CI; widespread `@ts-ignore` / `noqa` / lint suppressions hiding real bugs.

## 6. Dependencies & DX Health
- **Dependency hygiene:** Unused packages, duplicate libraries solving the same problem, unpinned/drifting lockfiles, or abandoned/deprecated major versions.
- **Build & local dev friction:** Broken or undocumented setup scripts, slow/redundant build steps, environment variable drift (`.env.example` out of sync with code).
- **Documentation drift:** `README.md` or `docs/` referencing removed scripts, outdated architecture, or stale config flags.

## 7. API & Data Contracts
- **Leaky abstractions:** Internal DB models or third-party SDK types exposed directly on public APIs or UI boundaries.
- **Contract consistency:** Inconsistent error shapes, status codes, naming conventions, or nullable/optional semantics across endpoints or modules.
- **Schema & migration safety:** Destructive or non-backward-compatible schema changes, missing validation at serialization boundaries, or unversioned breaking changes.

---

## Anti-Noise Guardrails (What NOT to Flag)
- Pure formatting or style preferences already handled (or better handled) by an auto-formatter.
- Hypothetical future-proofing ("what if we swap databases someday?") with no current pain.
- Minor duplication where two code paths happen to look similar today but represent distinct domain concepts.
- Stable, well-tested legacy code that rarely changes and carries no security, reliability, or performance risk.
