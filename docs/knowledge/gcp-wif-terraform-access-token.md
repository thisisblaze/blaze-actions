# GCP Workload Identity Federation (WIF) Terraform Backend Authentication

## Topic/Symptom
When executing `terraform init` to configure a GCS backend in GitHub Actions using Workload Identity Federation (WIF), the workflow fails with a `403 Forbidden` error:

```
Error: Failed to get existing workspaces: querying Cloud Storage failed: googleapi: Error 403: user-managed service account [SERVICE_ACCOUNT_EMAIL] does not have storage.objects.list access to the Google Cloud Storage object., forbidden

Error: error loading state: querying Cloud Storage failed: googleapi: Error 403: user-managed service account [SERVICE_ACCOUNT_EMAIL] does not have storage.objects.get access to the Google Cloud Storage object., forbidden
```

Even after verifying that the Service Account has `roles/storage.admin` permissions on the GCS bucket, the authentication failure persists.

## Context
Google Cloud uses Workload Identity Federation to securely grant GitHub Actions access to GCP resources without long-lived JSON keys. The official GitHub Action for this is `google-github-actions/auth`. 

By default, the `google-github-actions/auth` step creates a credentials file (`credentials.json`) containing the WIF federation details, not a true access token. Terraform's GCP provider expects either a standard JSON key or an explicit OAuth access token to authenticate with the GCS backend during `terraform init`. It struggles to interpret the WIF credential file natively for backend initialization, leading to impersonation failures.

## Root Cause
The `google-github-actions/auth` action outputs WIF configuration by default, which is passed into Terraform via `GOOGLE_APPLICATION_CREDENTIALS`. However, Terraform's GCS backend needs an actual *access token* to authenticate as the impersonated service account. 

If Terraform tries to use the WIF config file directly, it authenticates as the *WIF Principal* (the GitHub repo identity) instead of the *impersonated Service Account*, resulting in a `403 Forbidden` because the WIF Principal does not have direct IAM access to the GCS bucket (nor should it).

## The Fix

1. **Request an Access Token:** Modify the `google-github-actions/auth` action in your GitHub workflow to explicitly request an OAuth access token by adding `token_format: 'access_token'`.
2. **Remove Credential File Export:** Stop exporting the WIF configuration file path to the environment via `create_credentials_file: false` (or by manually unsetting `GOOGLE_APPLICATION_CREDENTIALS`).
3. **Pass the Token to Terraform:** Export the generated access token to the standard GCP Terraform token environment variable `GOOGLE_OAUTH_ACCESS_TOKEN`.

### Exact Code Change

Update your GitHub Actions step:

```yaml
- name: Google Auth
  id: auth
  uses: google-github-actions/auth@v3
  with:
    workload_identity_provider: 'projects/123456789012/locations/global/workloadIdentityPools/github/providers/my-repo'
    service_account: 'my-service-account@my-project.iam.gserviceaccount.com'
    token_format: 'access_token' # CRITICAL: Forces creation of an OAuth token
    create_credentials_file: false # CRITICAL: Prevents Terraform from using the WIF config fallback

# Export the token for the Terraform 'gcs' backend and GCP provider
- name: Setup Terraform GCP Credentials
  run: |
    echo "GOOGLE_OAUTH_ACCESS_TOKEN=${{ steps.auth.outputs.access_token }}" >> "$GITHUB_ENV"
```

### Additional Requirements
Ensure the Service Account listed in `service_account` has the `roles/iam.serviceAccountTokenCreator` IAM role granted to *itself*. It must be able to mint OAuth tokens on its own behalf.
