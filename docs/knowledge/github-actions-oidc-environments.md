# GitHub Actions OIDC Credentials in Environments

## Topic

Reusable workflows (e.g., `check-stack-exists.yml`) failing with:
`Could not load credentials from any providers` in `aws-actions/configure-aws-credentials`.

## Context

Occurs in two distinct scenarios:

1. **Secrets inherit scoping** — caller uses `secrets: inherit` across environment boundaries.
2. **Cross-repo execution** — workflow runs in a _different_ repo from where environment secrets are stored (e.g., `stress-test.yml` in `blaze-actions`, secrets in `blaze-template-deploy`).

## Root Cause

### Case 1: secrets: inherit + environment scoping

When `environment: ${{ inputs.environment }}` is set on a job, GitHub aggressively scopes secrets. `secrets: inherit` from within that environment-scoped job fails to pass down organization-level secrets (like `AWS_ROLE_ARN`) if those secrets aren't explicitly mirrored into that GitHub environment.

### Case 2: vars.AWS_ROLE_ARN fallback (cross-repo)

When `stress-test.yml` runs inside `blaze-actions`, caller jobs for `check-*` have **no `environment:` set at the caller level** — only the callee sets it. `AWS_ROLE_ARN` is environment-scoped in the deployment repo, so `secrets.AWS_ROLE_ARN` resolves to empty string at the caller level. `vars.AWS_ROLE_ARN` is a **repo-level variable** (not environment-scoped) and resolves correctly regardless.

## Fixes

### Fix 1: Explicit Permissions + Secrets Mapping (Case 1)

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
  secrets:
    AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }} # <--- Explicit mapping
```

### Fix 2: vars fallback in role-to-assume (Case 2 — preferred pattern)

In reusable workflows that may be called from a different repo context:

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@...
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN || vars.AWS_ROLE_ARN }}
    aws-region: ${{ inputs.aws_region }}
    audience: sts.amazonaws.com
```

`vars.AWS_ROLE_ARN` must be set as a **repository variable** (Settings → Variables → Actions) in `blaze-actions`. This is safe — the ARN is just an identifier; the OIDC trust policy enforces actual access control.

## Files Fixed (2026-02-23)

- `.github/workflows/check-stack-exists.yml` — `role-to-assume` fallback added
- `.github/workflows/stress-test.yml` — `verify` and `deployment-summary` inline job fallbacks added

## Affected Workflows

`stress-test.yml` → `check-stack-exists.yml`, inline `verify`, inline `deployment-summary`
