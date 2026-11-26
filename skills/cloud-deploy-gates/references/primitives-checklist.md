# Cloud Primitive Gate Checklist

For each primitive: what commonly breaks, and a smoke check. Examples are GCP-flavored. Equivalent AWS/provider concepts apply.

| Primitive | Commonly missing | Smoke check |
|---|---|---|
| Secret binding (`defineSecret`, Secret Manager, KMS) | `Secret Manager Secret Accessor` on the runtime service account; secret version not created | Deploy, invoke the function, confirm the secret value is read |
| Event trigger (Eventarc, Firestore/Storage, Pub/Sub) | Eventarc/Pub/Sub service-agent roles (e.g. `Pub/Sub Publisher`, `Eventarc Event Receiver`); API not enabled; first-deploy propagation delay | Write a test document or object; check the function logs for the event |
| Scheduled job (Cloud Scheduler) | Scheduler API disabled; invoker role for the scheduler service account | Force-run the job; check logs |
| Object storage / signed URLs | Bucket CORS; `Service Account Token Creator` on the signing identity | Generate a signed URL, then upload and download with it from a browser origin |
| New provider API | API not enabled; quota; billing | Make one real call from the deployed environment |
| OAuth / redirect config | Redirect URI mismatch; authorized domains; consent screen | Complete a real login on the deployed URL |

## Propagation delays
IAM and service-agent changes can take minutes to apply. Retry before assuming a misconfiguration, and record observed delays in the deployment guide.
