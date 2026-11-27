# Cloud Primitive Gate Checklist

For each primitive: what commonly breaks, and a smoke check. Examples are GCP-flavored. Equivalent AWS/provider concepts apply.

| Primitive | Commonly missing | Smoke check |
|---|---|---|
| Secret binding (`defineSecret`, Secret Manager, KMS) | `Secret Manager Secret Accessor` on the runtime service account; secret version not created | Deploy, invoke the function, confirm the secret value is read |
| Event trigger (Eventarc, Firestore/Storage, Pub/Sub) | Eventarc/Pub/Sub service-agent roles (e.g. `Pub/Sub Publisher`, `Eventarc Event Receiver`); API not enabled; first-deploy propagation delay | Write a test document or object; check the function logs for the event |
| Scheduled job (Cloud Scheduler) | Scheduler API disabled; invoker role for the scheduler service account | Force-run the job; check logs |
| Object storage / signed URLs | Bucket CORS on the actual app Storage bucket (not internal upload buckets such as `gcf-v2-uploads-*`); `Service Account Token Creator` on the signing identity | Generate a signed URL, then upload and download with it from a browser origin |
| Webhooks / external callbacks | Signature/auth mismatch (Standard Webhooks `whsec_` vs Bearer vs custom HMAC); silent 4xx/5xx failures with no visible delivery status | Trigger a real event to the receiver; confirm 2xx response and surface `lastDelivery` status/error in UI or logs |
| New provider API | API not enabled; quota; billing | Make one real call from the deployed environment |
| OAuth / redirect config | Redirect URI mismatch; authorized domains; consent screen; production session persistence across reload; missing Dynamic Client Registration (`/.well-known/*`) for MCP/API clients | Complete a real login and reload on the deployed URL; confirm token/API-key auth works for MCP/headless clients |

## Propagation delays
IAM and service-agent changes can take minutes to apply. Retry before assuming a misconfiguration, and record observed delays in the deployment guide.

## Local Admin SDK / CLI credential overrides
When working across multiple GCP or Firebase projects locally, remember:
- `firebase login` authenticates the **Firebase CLI** only; Node/Python Admin SDKs (`firebase-admin`, `google-cloud-*`) read `GOOGLE_APPLICATION_CREDENTIALS` first and default `gcloud` ADC second.
- If `GOOGLE_APPLICATION_CREDENTIALS` is exported in your shell for a different project, Admin SDK scripts fail with `7 PERMISSION_DENIED` even when `--project` or `.firebaserc` points to the right project.
- **Fix:** Clear it inline (`GOOGLE_APPLICATION_CREDENTIALS= <command>`) to use default ADC (run `gcloud auth application-default login` if expired), or pass a short-lived token from `gcloud auth print-access-token` if the CLI supports an explicit token env var.
