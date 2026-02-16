**Last Updated**: 2026-02-16
**Owner**: Infrastructure Team

---

# Cross-Organization Secret Propagation in GitHub Actions

## Problem Statement

When using GitHub Actions reusable workflows across different organizations, the `secrets: inherit` pattern does not work. This causes workflows to fail due to missing credentials and configuration.

## Root Cause

GitHub Actions' `secrets: inherit` only propagates secrets within the same organization. When a workflow in one organization calls a reusable workflow in another organization:

```
Organization A (thebyte9) → Organization B (thisisblaze)
```

Secrets are **not** automatically inherited, even with `secrets: inherit`.

## Solution

**Always use explicit secret passing** when calling workflows across organizations:

### ❌ Incorrect (Cross-Org)

```yaml
jobs:
  deploy:
    uses: other-org/repo/.github/workflows/workflow.yml@main
    secrets: inherit # Does NOT work cross-org!
```

### ✅ Correct (Cross-Org)

```yaml
jobs:
  deploy:
    uses: other-org/repo/.github/workflows/workflow.yml@main
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
      GH_PAT: ${{ secrets.GH_PAT }}
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
      # ... all required secrets
```

## Implementation Pattern

### 1. Define Secrets in Reusable Workflow

```yaml
# other-org/repo/.github/workflows/reusable.yml
on:
  workflow_call:
    secrets:
      AWS_ROLE_ARN:
        required: true
      GH_PAT:
        required: false
      # ... all secrets
```

### 2. Pass Secrets from Caller

```yaml
# your-org/repo/.github/workflows/caller.yml
jobs:
  execute:
    uses: other-org/repo/.github/workflows/reusable.yml@main
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
      GH_PAT: ${{ secrets.GH_PAT }}
```

### 3. Propagate Through Nested Calls

If a reusable workflow calls another reusable workflow, secrets must be passed again:

```yaml
# Reusable workflow calling another reusable workflow
jobs:
  internal-job:
    uses: ./.github/workflows/another-reusable.yml
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
      # ... propagate all secrets
```

## Secret Categories

Organize secrets by purpose to ensure complete coverage:

### Infrastructure Provisioning

```yaml
AWS_ROLE_ARN              # OIDC authentication
GH_PAT                    # Private repos/modules
CLOUDFLARE_API_TOKEN      # DNS/CDN management
CLOUDFLARE_ZONE_ID
CLOUDFLARE_ACCOUNT_ID
MONGODB_ATLAS_PUBLIC_KEY  # MongoDB provisioning
MONGODB_ATLAS_PRIVATE_KEY
MONGODB_ATLAS_PROJECT_ID
MONGODB_ATLAS_ORG_ID
EC_API_KEY                # Elasticsearch provisioning
ACM_CERTIFICATE_ARN       # SSL certificates

# GCP
GCP_PROJECT_ID
GCP_WORKLOAD_IDENTITY_PROVIDER
GCP_SERVICE_ACCOUNT

# Azure
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

### Build-Time

```yaml
NPM_TOKEN # Private npm packages
```

### Application Runtime (ECS)

```yaml
BLAZE_CONNECTION_STRING         # MongoDB Atlas
BLAZE_AUTH_JWT_PRIVATE_KEY      # JWT signing
BLAZE_AUTH_ADMIN_EMAIL          # Admin seeding
BLAZE_AUTH_ADMIN_PASSWORD
BLAZE_ELASTICSEARCH_USERNAME    # Search service
BLAZE_ELASTICSEARCH_PASSWORD
BLAZE_FILES_S3_ACCESS_KEY      # File storage
BLAZE_FILES_S3_SECRET_ACCESS_KEY
BLAZE_GRAPHQL_CACHE_SETTINGS
BLAZE_CLIENT_HEADER
```

### Observability

```yaml
BLAZE_SENTRY_AUTH_TOKEN   # Error tracking
BLAZE_SENTRY_DSN
```

## Common Pitfalls

### 1. Forgetting Nested Propagation

```yaml
# ❌ Caller passes secrets, but reusable workflow doesn't propagate to nested call
# Caller workflow
jobs:
  job1:
    uses: org/repo/.github/workflows/reusable1.yml@main
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}

# Reusable1 workflow
jobs:
  job2:
    uses: ./.github/workflows/reusable2.yml
    secrets: inherit  # ❌ Will fail if called from external org!
```

**Fix:** Always use explicit passing in reusable workflows:

```yaml
# ✅ Reusable1 workflow
jobs:
  job2:
    uses: ./.github/workflows/reusable2.yml
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
```

### 2. Missing Secret Definitions

```yaml
# ❌ Caller passes secret, but reusable workflow doesn't define it
# Caller
secrets:
  MY_SECRET: ${{ secrets.MY_SECRET }}

# Reusable - missing definition!
on:
  workflow_call:
    secrets: {} # ❌ MY_SECRET not defined!
```

**Fix:** Define all secrets in `workflow_call`:

```yaml
# ✅ Reusable
on:
  workflow_call:
    secrets:
      MY_SECRET:
        required: false
```

### 3. Wrong Secret for Service Type

```yaml
# ❌ Using self-hosted MongoDB secrets with managed Atlas
secrets:
  MONGO_INITDB_ROOT_PASSWORD: ${{ secrets.MONGO_INITDB_ROOT_PASSWORD }}

# ✅ Use Atlas connection string instead
secrets:
  BLAZE_CONNECTION_STRING: ${{ secrets.BLAZE_CONNECTION_STRING }}
```

## Debugging Tips

### 1. Check Secret Availability

Add debug step (secrets are masked):

```yaml
- name: Debug Secrets
  run: |
    echo "AWS_ROLE_ARN is set: ${{ secrets.AWS_ROLE_ARN != '' }}"
    echo "GH_PAT is set: ${{ secrets.GH_PAT != '' }}"
```

### 2. Trace Secret Flow

Map the flow through each layer:

```
Caller Org Secrets
  ↓ (explicit passing)
Caller Workflow
  ↓ (explicit passing)
Reusable Workflow (workflow_call secrets)
  ↓ (explicit passing to nested)
Nested Reusable Workflow
  ↓ (passed to action as inputs)
Composite Action
```

### 3. Compare Working vs Broken

Find a working workflow and compare secret passing:

```bash
# Show secrets in working workflow
grep -A 20 "secrets:" working-workflow.yml

# Compare with broken workflow
grep -A 20 "secrets:" broken-workflow.yml
```

## Best Practices

1. **Document Required Secrets:** Add comments listing all secrets needed
2. **Use Consistent Naming:** Match caller secret names to reusable workflow expectations
3. **Group by Purpose:** Organize secrets by category (infra, build, runtime)
4. **Validate Early:** Add checks at the start of workflows to verify secrets
5. **Avoid Duplicates:** Don't pass secrets for services you're not using
6. **Use Fallbacks Carefully:** `${{ secrets.A || secrets.B }}` can hide missing secrets

## Migration Checklist

When moving to cross-org reusable workflows:

- [ ] Identify all workflows calling across organizations
- [ ] List all secrets used in reusable workflows
- [ ] Add secrets to `workflow_call` definitions
- [ ] Replace `secrets: inherit` with explicit lists in callers
- [ ] Check nested workflow calls (reusable → reusable)
- [ ] Verify environment-specific secrets are passed
- [ ] Test each workflow in isolation
- [ ] Document secret requirements

## References

- [GitHub Actions: Reusing Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [GitHub Actions: Using secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [Cross-Organization Workflow Calls](https://docs.github.com/en/actions/using-workflows/reusing-workflows#calling-a-reusable-workflow)
