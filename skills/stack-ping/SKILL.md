---
name: stack-ping
description: >-
  Use when the user prompts `mhusk-ping`, asks to run `stack-ping`, or asks to
  verify or smoke-test the mhusk_stack agent skills setup in the current
  harness. Do not trigger for general infrastructure, website, or application
  health checks.
---

# Stack Ping (Canary Verification Skill)

This is a lightweight diagnostic skill used to prove that the current agent harness:
1. Discovered the `mhusk_stack` skills directory or plugin.
2. Activated and read this `SKILL.md` file via progressive disclosure.
3. Can resolve and execute a bundled helper script via a relative path (when the harness mounts plugin files on its shell filesystem).

## Steps

1. Attempt to run the bundled verification script [check.sh](./scripts/check.sh).
2. Reply concisely with:
   - `SKILL_OK: stack-ping@0.1.0`
   - The exact path to this `SKILL.md` file that you read.
   - The stdout output from `check.sh`.

## Troubleshooting & Fallbacks

- If `check.sh` fails with `Permission denied`, report the exact error and suggest running `chmod +x` or `./scripts/validate.sh`.
- If the environment has no shell tool, still report `SKILL_OK: stack-ping@0.1.0`, the path read, and `SCRIPT_SKIPPED: no shell access`.
- If the harness can read this plugin's files but does not mount plugin directories onto the shell filesystem (e.g., Grok Bot plugin sandboxes), still report `SKILL_OK: stack-ping@0.1.0`, the path read, and `SCRIPT_UNMOUNTED: plugin directory not mounted on shell filesystem` (never fabricate `SKILL_SCRIPT_OK`).
