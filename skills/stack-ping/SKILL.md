---
name: stack-ping
description: >-
  Use when the user asks to ping, verify, or smoke-test the mhusk_stack context
  stack or check whether agent skills and bundled helper scripts are working in
  the current harness.
---

# Stack Ping (Canary Verification Skill)

This is a lightweight diagnostic skill used to prove that the current agent harness:
1. Discovered the `mhusk_stack` skills directory.
2. Activated and read this `SKILL.md` file via progressive disclosure.
3. Can resolve and execute a bundled helper script via a relative path.

## Steps

1. Run the bundled verification script [check.sh](./scripts/check.sh).
2. Reply concisely with:
   - `SKILL_OK: stack-ping@0.1.0`
   - The exact path to this `SKILL.md` file that you read.
   - The stdout output from `check.sh`.

## Troubleshooting

- If `check.sh` fails with `Permission denied`, report the exact error and suggest running `chmod +x` or re-running `scripts/validate.sh`.
- If the script cannot be executed because the environment has no shell tool, still report `SKILL_OK: stack-ping@0.1.0` along with the path read and explicitly note `SCRIPT_SKIPPED: no shell access`.
