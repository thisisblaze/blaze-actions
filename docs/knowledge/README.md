# Blaze Smart Fixes Knowledge Library

Welcome to the Blaze Knowledge Library. This directory contains quick-reference guides, architectures, and "smart fixes" for complex edge-cases encountered across our CI/CD pipelines, AWS/GCP/Azure infrastructure, and Terraform deployments.

## Documenting A Fix

When you encounter a sticky issue that requires a non-obvious solution, please document it here so the rest of the team (and AI agents) can learn from it.

### Recommended Format

When creating a new file in this directory, please use this structure:

1. **Topic/Symptom**: Describe the error message or what was observed.
2. **Context**: What was happening? What infrastructure/service was involved?
3. **Root Cause**: The technical reason why the issue occurred.
4. **The Fix**: The exact code change or sequence of commands used to resolve the issue. Provide snippets or links where possible.

## Current Fixes

- [GitHub Actions OIDC Environments](./github-actions-oidc-environments.md) - Fixing reusable workflow secret scoping and inheritance.
- [AWS ECS Log Group Conflicts](./aws-ecs-log-group-conflicts.md) - Resolving `ResourceNotFoundException` timeouts during deployment.
- [Terraform Cloudflare DNS Import](./terraform-cloudflare-dns-import.md) - Handling the Cloudflare Provider v5 missing `allow_overwrite`.
- [AWS CloudFront SPA Routing](./aws-cloudfront-spa-routing.md) - Fixing 404/403 errors on React deep links.
- [Terraform State Mismatches](./terraform-state-checksum-mismatch.md) - Reconciling DynamoDB lock conflicts and S3 state drift.
