**Last Updated**: 2026-01-18
**Owner**: Infrastructure Team

---

# Cloudflare Pages Operations Guide

**Version**: 1.4.0  
**Last Updated**: 2026-01-11

This guide documents the Cloudflare Pages lifecycle management operations available in the `99 - Ops Utility` workflow.

---

## Overview

The Cloudflare Pages operations provide comprehensive lifecycle management:

1. **Project Provisioning** - via Terraform (Container & Config)
2. **Content Deployment** - via Wrangler (Code & Assets)
3. **Cleanup/Destruction** - via Ops Utility (Project & Deployments)

### ⚠️ IMPORTANT: The Hybrid Model

We use a **Hybrid Deployment Model** for Cloudflare Pages to ensure stability and Infrastructure-as-Code compliance:

| Component     | Tool          | Responsibility                                                                                        |
| :------------ | :------------ | :---------------------------------------------------------------------------------------------------- |
| **Container** | **Terraform** | Creates the Project, binds custom domains, sets production branch, and manages Environment Variables. |
| **Content**   | **Wrangler**  | Deploys the actual HTML/JS/CSS assets into the project during CI/CD.                                  |

**Critical Rule**: You **MUST** provision the project via Terraform (Workflow `01 - Provision Infrastructure`) **BEFORE** the first Wrangler deployment. Attempts to deploy code to a non-existent project will fail with `Project not found`.

---

## Operations

### 1. Delete Single Cloudflare Pages Project

**Action**: `destroy-cloudflare-pages`

Deletes a single Cloudflare Pages project based on the environment and configuration.

#### Usage

```yaml
Workflow: 99 - Ops Utility
Action: destroy-cloudflare-pages
Environment: DEV | STAGE | PROD
confirmation: DESTROY
```

#### Features

- ✅ Dynamic project naming from configuration (no hardcoded values)
- ✅ Enhanced error handling with retry logic
- ✅ Handles HTTP 403 (permissions), 429 (rate limit), 404 (not found)
- ✅ Exponential backoff on rate limits (3 retries: 2s → 4s → 8s)

#### Project Name Resolution

The project name is calculated automatically:

```
PROD:  {namespace}-{project}-admin
       Example: ${NAMESPACE}-thisisblaze-admin

OTHER: {namespace}-{project}-{stage}-admin
       Example: ${NAMESPACE}-thisisblaze-dev-admin
```

#### Error Handling

| HTTP Code | Behavior      | Action Required                        |
| :-------- | :------------ | :------------------------------------- |
| **200**   | Success ✅    | None - project deleted                 |
| **404**   | Not Found ⚠️  | None - already deleted                 |
| **403**   | Forbidden ❌  | Check CLOUDFLARE_API_TOKEN permissions |
| **429**   | Rate Limit ⚠️ | Auto-retry with backoff                |

#### Example

Delete the DEV admin Pages project:

```
1. Go to Actions → 99 - Ops Utility
2. Select Action: destroy-cloudflare-pages
3. Select Environment: DEV
4. Type confirmation: DESTROY
5. Run workflow
```

---

### 2. Cleanup Old Deployments

**Action**: `cleanup-cloudflare-deployments`

Removes old Cloudflare Pages deployments while keeping recent ones based on retention policies.

#### Usage

```yaml
Workflow: 99 - Ops Utility
Action: cleanup-cloudflare-deployments
Environment: DEV | STAGE | PROD
retention_count: 5 # Keep latest N deployments
retention_days: 30 # Keep deployments newer than N days
dry_run: true # Preview mode (default)
```

#### Retention Policy

A deployment is **kept** if it meets **ANY** of these criteria:

1. **Within retention count** - Among the latest N deployments (sorted by creation date)
2. **Newer than retention days** - Created within the last N days

A deployment is **deleted** if it meets **BOTH** conditions:

- NOT in the latest N deployments
- AND older than N days

#### Examples

**Example 1: Preview cleanup**

```yaml
retention_count: 5
retention_days: 30
dry_run: true # Safe preview
```

Output:

```
📊 Total deployments: 25
🎯 Retention: Keep 5 latest OR newer than 30 days

✅ Keeping: abc123 (production, 2d old) - within retention count
✅ Keeping: def456 (production, 5d old) - within retention count
...
🔍 [DRY RUN] Would delete: xyz789 (preview, 45d old) - outside retention
```

**Example 2: Execute cleanup**

```yaml
retention_count: 10
retention_days: 60
dry_run: false # Actually delete
```

**Example 3: Age-only cleanup**

```yaml
retention_count: 100 # Keep many recent deployments
retention_days: 7 # But delete anything older than 1 week
dry_run: false
```

#### Best Practices

1. **Always preview first**: Run with `dry_run: true` to see what would be deleted
2. **Balance retention**: Consider both count and age for comprehensive cleanup
3. **Production caution**: Use higher retention for PROD (e.g., 10 deployments, 60 days)
4. **Dev/Test aggressive**: Can be more aggressive (e.g., 3 deployments, 14 days)

#### Cost Savings

Typical deployment size: ~50-100 MB  
Storage cost: ~$0.15/GB/month

Example savings:

- 20 old deployments × 75 MB = 1.5 GB
- Savings: ~$0.23/month or $2.76/year per project

---

### 3. Bulk Delete Pages Projects

**Action**: `destroy-cloudflare-pages-bulk`

Delete multiple Cloudflare Pages projects matching a pattern.

#### Usage

```yaml
Workflow: 99 - Ops Utility
Action: destroy-cloudflare-pages-bulk
bulk_pattern: "${NAMESPACE}-*-test*-admin" # Shell glob pattern
dry_run: true # Preview mode (default)
confirmation: BULK_DESTROY # Required
```

#### Safety Features

1. **Pattern Required**: Must specify `bulk_pattern` input
2. **Special Confirmation**: Requires `BULK_DESTROY` (not `DESTROY`)
3. **Safety Limit**: Maximum 10 projects per run
4. **Dry-Run Default**: Defaults to preview mode

#### Pattern Examples

| Pattern                                | Matches                                | Use Case                     |
| :------------------------------------- | :------------------------------------- | :--------------------------- |
| `${NAMESPACE}-*-dev-*`                 | All dev projects                       | Cleanup all dev environments |
| `${NAMESPACE}-thisisblaze-test*-admin` | Test environments for specific project | Cleanup test branches        |
| `*-preview-*`                          | All preview deployments                | Cleanup PR previews          |
| `${NAMESPACE}-*-jira-*-admin`          | Feature branches with JIRA tags        | Cleanup completed features   |

#### Usage Examples

**Example 1: Preview what would be deleted**

```yaml
Action: destroy-cloudflare-pages-bulk
bulk_pattern: "${NAMESPACE}-thisisblaze-test*-admin"
dry_run: true
confirmation: BULK_DESTROY
bulk_pattern: "${NAMESPACE}-thisisblaze-test*-admin"
dry_run: true
confirmation: BULK_DESTROY
```

Output:

```
🔍 Finding projects matching: ${NAMESPACE}-thisisblaze-test*-admin
📊 Found 3 projects
🔍 DRY RUN - Would delete:
  ${NAMESPACE}-thisisblaze-test1-admin
  ${NAMESPACE}-thisisblaze-test2-admin
  ${NAMESPACE}-thisisblaze-test-deploy-admin
```

**Example 2: Delete feature branch projects**

```yaml
bulk_pattern: "${NAMESPACE}-*-jira-123-*"
dry_run: false
confirmation: BULK_DESTROY
```

**Example 3: Cleanup all dev projects**

```yaml
bulk_pattern: "${NAMESPACE}-*-dev-*"
dry_run: true # ALWAYS preview first!
confirmation: BULK_DESTROY
```

#### Safety Limit Handling

If more than 10 projects match:

```
❌ Safety limit exceeded: Found 15 projects, max allowed is 10
   Please narrow your pattern or delete in smaller batches
```

**Solution**: Use more specific patterns:

```
Instead of: ${NAMESPACE}-*-*
Use:        ${NAMESPACE}-thisisblaze-dev-*   (more specific)
Or run:     Multiple batches with different patterns
```

#### Error Handling

The workflow continues even if individual deletions fail, providing a summary:

```
📊 Bulk Deletion Summary:
   Successfully deleted: 8
   Failed: 2
```

---

### 4. Sync Cloudflare Configuration

**Action**: `sync-cloudflare-config`

Syncs environment variables from `vars/blaze-env.json` to Cloudflare Pages project secrets.

_Note: This operation is less frequently used. Refer to the workflow file for detailed usage._

---

## Workflow Integration

### Independent Operations

All Cloudflare operations can be run independently:

```
99 - Ops Utility
├── destroy-cloudflare-pages       (Single deletion)
├── cleanup-cloudflare-deployments (Deployment cleanup)
├── destroy-cloudflare-pages-bulk  (Pattern deletion)
└── sync-cloudflare-config         (Config sync)
```

### Nuke Environment Sequence

**Current**: The `nuke-environment` action does NOT include Cloudflare cleanup

**Future**: Will be enhanced to include:

1. Stop services
2. Cleanup deployments → **NEW**
3. Destroy app stack
4. Delete Pages project → **NEW**
5. Destroy tunnel
6. Destroy network

---

## Best Practices

### 1. Always Preview First

```yaml
# STEP 1: Preview
dry_run: true
confirmation: DESTROY | BULK_DESTROY

# STEP 2: Review output in workflow summary

# STEP 3: Execute if satisfied
dry_run: false
```

### 2. Use Appropriate Retention Policies

| Environment | Retention Count | Retention Days | Rationale                                |
| :---------- | --------------: | -------------: | :--------------------------------------- |
| **PROD**    |              10 |             60 | Keep more history for rollback           |
| **STAGE**   |               7 |             30 | Balance between history and cost         |
| **DEV**     |               3 |             14 | Aggressive cleanup for test environments |

### 3. Pattern Matching Tips

- **Be specific**: `${NAMESPACE}-thisisblaze-dev-*` > `${NAMESPACE}-*-*`
- **Test patterns**: Use dry-run to verify matches
- **Batching**: If > 10 projects, use multiple targeted patterns

### 4. Scheduling Recommendations

Consider automating cleanup:

```yaml
# Example: Weekly deployment cleanup
# (Requires workflow modification to add schedule trigger)
schedule:
  - cron: "0 2 * * 0" # Sunday 2 AM UTC
```

---

## Troubleshooting

### Issue: "Permission denied (HTTP 403)"

**Cause**: `CLOUDFLARE_API_TOKEN` lacks required permissions

**Solution**:

1. Go to Cloudflare Dashboard → API Tokens
2. Ensure token has: `Cloudflare Pages:Edit` permission
3. Update `CLOUDFLARE_API_TOKEN` secret in GitHub

### Issue: "Rate limited (HTTP 429)"

**Cause**: Too many API requests

**Solution**: The workflow automatically retries with exponential backoff. If it persists:

1. Reduce bulk operations size
2. Add delay between operations
3. Wait 10-15 minutes before retrying

### Issue: "Project not found (404)"

**Cause**: Project was already deleted or name doesn't match

**Solution**:

1. Verify project name in Cloudflare Dashboard
2. Check environment selection (DEV vs STAGE vs PROD)
3. Review configuration outputs

### Issue: Safety limit exceeded

**Cause**: Pattern matched > 10 projects

**Solution**:

1. Use more specific pattern
2. Delete in batches
3. Example: `${NAMESPACE}-*-test1*` then `${NAMESPACE}-*-test2*`

---

## API Reference

### Cloudflare Pages API Endpoints Used

1. **Delete Project**: `DELETE /accounts/{account_id}/pages/projects/{project_name}`
2. **List Deployments**: `GET /accounts/{account_id}/pages/projects/{project_name}/deployments`
3. **Delete Deployment**: `DELETE /accounts/{account_id}/pages/projects/{project_name}/deployments/{deployment_id}`
4. **List Projects**: `GET /accounts/{account_id}/pages/projects`

### Authentication

All operations use:

- `CLOUDFLARE_API_TOKEN` - Bearer token authentication
- `CLOUDFLARE_ACCOUNT_ID` - Account identifier

---

## Related Documentation

- [Cloudflare Pages API Documentation](https://developers.cloudflare.com/api/operations/pages-project)
- [99 - Ops Utility Workflow](../.github/workflows/99-ops-utility.yml)
- [Cloudflare Pages Creation (02-deploy-app.yml)](../.github/workflows/02-deploy-app.yml#L516-L538)

---

## Version History

### v1.4.0 (2026-01-11)

- ✅ Added deployment cleanup operation
- ✅ Added bulk deletion operation
- ✅ Enhanced error handling with retry logic
- ✅ Replaced hardcoded values with dynamic configuration
- ✅ Added dry-run support for all destructive operations

### v1.0.0 (2026-01-06)

- Initial `destroy-cloudflare-pages` operation
