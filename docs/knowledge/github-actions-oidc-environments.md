# GitHub Actions OIDC Credentials in Environments

## Topic

Reusable workflows (e.g., `check-stack-exists.yml`) failing with the error:
`Could not load credentials from any providers` during the `aws-actions/configure-aws-credentials` step.

## Context

This typically happens when a caller job (in a workflow like `stress-test.yml`) sets an `environment` context and uses `secrets: inherit` to pass secrets down to the reusable workflow.

## Root Cause

When an `environment: ${{ inputs.environment }}` context is defined on a job, GitHub aggressively scopes secrets. Using `secrets: inherit` on a reusable workflow call from within that environment-scoped job fails to pass down organization-level secrets (like `AWS_ROLE_ARN`) if those secrets aren't explicitly mirrored into that specific GitHub environment.

Furthermore, reusable workflows require explicit OIDC `permissions` on the _calling_ job in order to successfully assume roles, even if the workflow itself declares the permissions globally.

## The Fix

Do not rely on `secrets: inherit` when crossing environment boundaries with Organization secrets.

1. **Explicit Permissions**: Add `permissions: id-token: write, contents: read` directly to the caller job.
2. **Explicit Secrets Mapping**: Map the secret explicitly using `with` or `secrets`.

```yaml
check-app-exists:
  name: "🔍 Check App State"
  needs: config
  permissions:
    id-token: write # <--- Required for caller jobs
    contents: read
  uses: ./.github/workflows/check-stack-exists.yml
  with:
    environment: ${{ inputs.environment }}
    # ...
  secrets:
    AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }} # <--- Explicit mapping overrides environment isolation
```
