---
Last Updated: 2026-03-17
Owner: Infrastructure Team
---

# GitHub Actions OIDC Credentials in Environments

## Topic

Reusable workflows (e.g., `check-stack-exists.yml`, `stress-test.yml`) failing with:
`Could not load credentials from any providers` in `aws-actions/configure-aws-credentials`.

## Root Cause

### Case 1: secrets: inherit + environment scoping

When `environment:` is set on a calling job, GitHub scopes secrets to that environment. Using `secrets: inherit` fails to pass secrets that aren't mirrored into that GitHub environment.

### Case 2: Triggering blaze-actions workflows directly ❌

`blaze-actions` is a **source-only reusable workflow library**. It has no AWS secrets. Workflows like `stress-test.yml` must **always be triggered from `blaze-template-deploy`** (or the project repo), which holds all secrets and acts as the thin wrapper.

Running `gh workflow run stress-test.yml --repo thisisblaze/blaze-actions` bypasses all secret injection → credentials always empty.

## The Fix

### Case 1: Explicit Permissions + Secrets Mapping

```yaml
check-app-exists:
  permissions:
    id-token: write
    contents: read
  uses: ./.github/workflows/check-stack-exists.yml
  with:
    environment: ${{ inputs.environment }}
  secrets:
    AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }} # explicit mapping
```

### Case 2: Always trigger from the project repo ✅

```bash
# ✅ Correct — secrets flow from blaze-template-deploy environments
gh workflow run "stress-test.yml" \
  --repo thebyte9/blaze-template-deploy \
  --ref dev \
  --field environment=dev \
  --field mode=full-circle \
  --field target_type=host \
  --field include_third_party=false \
  --field preserve_host=false

# ❌ Wrong — no AWS secrets exist in blaze-actions
gh workflow run "stress-test.yml" --repo thisisblaze/blaze-actions ...
```

## Architectural Rule

> **blaze-actions is a library, not a deployment runner.**
> All secrets (AWS_ROLE_ARN, Cloudflare tokens, etc.) live in the project repo's GitHub environments.
> Always trigger operational workflows from the project repo's thin wrapper.
