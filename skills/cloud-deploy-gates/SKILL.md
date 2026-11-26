---
name: cloud-deploy-gates
description: >-
  Use when planning, building, or debugging work that introduces cloud or hosted
  backend primitives (secrets, event triggers, scheduled jobs, storage/signed
  URLs, new provider APIs or OAuth redirects). Adds a deploy-and-verify gate
  after each milestone that adds a primitive, so IAM and service-agent failures
  surface immediately instead of stacking up at the end.
---

# Deploy at Infrastructure Boundaries

Local emulators and unit tests do **not** validate cloud control-plane state: IAM roles, Secret Manager bindings, service-agent identities (Eventarc, Pub/Sub, Cloud Scheduler), bucket CORS, or managed-service propagation delays.

## Workflow

1. **Identify new cloud primitives** in each milestone or step. Treat any of these as one (details in [primitives-checklist.md](./references/primitives-checklist.md)):
   - Secret bindings (`defineSecret`, KMS/Secret Manager access)
   - Event-driven triggers (Eventarc, Firestore/Storage triggers, Pub/Sub)
   - Scheduled jobs (Cloud Scheduler)
   - Object storage transfers, bucket CORS, `getSignedUrl` signing permissions (Service Account Token Creator)
   - New GCP/AWS/provider APIs, or OAuth/redirect configurations
2. **Plan a deploy-and-verify gate right after that milestone**, not only in the final one. The live deploy plus a smoke check is the exit criterion for that boundary. Do not build the next infrastructure layer on top until it passes.
   - Catching one missing role or API on the step that introduces it takes minutes. Debugging four stacked IAM/service-agent failures at the end wastes hours.
3. **If a gate fails**, root-cause it there. Check IAM, enabled APIs, and propagation delay (retry after a few minutes) before changing code.
4. **Document immediately** every newly discovered IAM role, service agent, API, or propagation delay in the repo's deployment guide, so a fresh self-hosted install works first try.

## Validation

Before closing a milestone, confirm:
- [ ] The live deploy succeeded and the smoke check (invoke the trigger, read the secret, hit the endpoint) passed.
- [ ] The deployment guide lists every role, API, and service agent added in this step.

Related: [implementation-plan-and-docs](../implementation-plan-and-docs/SKILL.md) for phased plans with validation gates.
