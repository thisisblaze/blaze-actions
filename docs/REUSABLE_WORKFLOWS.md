**Last Updated**: 2026-05-09
**Owner**: Infrastructure Team

---

> [!TIP]
> **Status: SCALED (Multi-Tenant V2)**. Agent workflow instructions adhere strictly to the Phase 1 Foundation / Phase 2 Tenant orchestrated layers.


# Reusable Workflows Guide

**Repository**: blaze-actions  
**Pattern**: Hub & Spoke  
**Last Updated**: 2026-05-08

---

## Overview

Reusable workflows allow you to call workflows from other repositories, enabling code reuse and centralized maintenance.

---

## How to Call Reusable Workflows

### From Same Organization

```yaml
# In thebyte9/blaze-template-deploy/.github/workflows/deploy.yml
name: Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        required: true
        type: choice
        options: ["dev-mini", "dev", "stage", "prod"]

jobs:
  deploy:
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@main
    with:
      environment: ${{ inputs.environment }}
      target_services: "Blaze all"
    secrets: inherit
```

### Version Pinning

**Latest (recommended for development)**:

```yaml
uses: thebyte9/blaze-actions/.github/workflows/stress-test.yml@main
```

**Stable (recommended for production)**:

```yaml
uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@v2.5.7
```

**Specific commit (maximum stability)**:

```yaml
uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@a24d7b4
```

---

## Wrapper Pattern

Create thin wrappers in your repository that call remote workflows:

### Example: Provision Wrapper

```yaml
# .github/workflows/01-provision-infra.yml (in your repo)
name: "01 - Provision Infrastructure"

on:
  workflow_dispatch:
    # Inputs passed through from source workflow

permissions:
  id-token: write
  contents: read

jobs:
  execute:
    name: "Execute Provision"
    uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@main
    secrets: inherit
```

**Benefits**:

- Workflow logic centralized in blaze-actions
- Update once, affects all projects
- ~16 lines vs hundreds of lines
- Easy to maintain

---

## Best Practices

### 1. Always Inherit Secrets

```yaml
jobs:
  deploy:
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@main
    secrets: inherit # Pass all secrets to remote workflow
```

### 2. Pass Inputs Explicitly

```yaml
with:
  environment: ${{ inputs.environment }}
  target_services: ${{ inputs.target_services }}
```

### 3. Use Semantic Versioning

```yaml
# Development
@dev

# Stable (production)
@v2.5.7

# Specific commit (maximum pinning)
@<sha>
```

> **Governance Rule**: Never use shifting tags like `@main` or `@dev` in production caller workflows. Always pin to a stable semantic release tag (e.g. `@v2.5.7`).

### 4. Set Proper Permissions

```yaml
permissions:
  id-token: write # For AWS OIDC
  contents: read # For checkout
```

---

## Multi-Cloud Support

The `01-provision-infra` workflow supports deploying to AWS, GCP, and Azure.

### Inputs for Multi-Cloud

```yaml
jobs:
  provision:
    uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@main
    with:
      environment: dev
      stack: network
      # Cloud Provider specific inputs:
      cloud_provider: "aws" # or "gcp", "azure" (Default: "aws")
```

---

## Hybrid ECS (EC2 & Fargate)

The `02-deploy-app` workflow supports mixed compute strategies on AWS.

### Inputs for Hybrid ECS

```yaml
jobs:
  deploy:
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@main
    with:
      environment: prod
      # Deployment Strategy:
      launch_type: "EC2" # or "FARGATE"
      capacity_provider_strategy: "FARGATE_SPOT" # or "EC2"
```

---

## Native ECS Blue/Green (AWS)

Since 2026-02-27, the API service uses **Native ECS Blue/Green** — no CodeDeploy required.

### How It Works

ECS manages the task set swap and traffic shift natively:
1. New task set created with updated image
2. ECS shifts traffic from Blue → Green task set
3. Old task set drained and terminated
4. `ecs wait services-stable` confirms completion

### Pipeline Usage

```yaml
jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v2.5.7
    with:
      environment: prod
      target_services: "api"  # Native B/G triggered automatically
    secrets: inherit
```

> No `appspec.yml`, no CodeDeploy application, no deployment group needed.

---

## Admin SPA Deploy (AWS)

For AWS `DEV`/`STAGE`/`PROD`, `02-deploy-app` also syncs the Admin SPA build to S3 and invalidates CloudFront.

```yaml
jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v2.5.7
    with:
      environment: prod
      target_services: "Blaze all"  # Includes admin SPA sync
      cloud_provider: aws
    secrets: inherit
```

> DEV-MINI: Admin continues to deploy to Cloudflare Pages — no S3 sync step runs.

Before destroying any environment, you **MUST** run `reusable-pre-destroy-cleanup.yml`.

### Why?
Terraform cannot destroy non-empty S3 buckets, attached Capacity Providers, or orphaned Launch Templates.

### Usage

```yaml
jobs:
  cleanup:
    uses: thebyte9/blaze-actions/.github/workflows/reusable-pre-destroy-cleanup.yml@main
    with:
      environment: dev
      dry_run: false
      stack_id: "your-stack-uuid" # Recommended: Use STACK_ID from calculate-config
    secrets: inherit

  destroy:
    needs: cleanup
    uses: thebyte9/blaze-actions/.github/workflows/99-ops-nuke.yml@main
    with:
      action: destroy
    secrets: inherit
```

---

## Common Patterns

### Pattern 1: Simple Wrapper

```yaml
name: My Workflow

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  call-remote:
    uses: thebyte9/blaze-actions/.github/workflows/workflow-name.yml@main
    secrets: inherit
```

### Pattern 2: Chained Workflows

```yaml
jobs:
  provision:
    uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@main
    with:
      environment: dev
      stack: network
    secrets: inherit

  deploy:
    needs: provision
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@main
    with:
      environment: dev
    secrets: inherit
```

### Pattern 3: Conditional Execution

```yaml
jobs:
  test:
    if: github.event_name == 'pull_request'
    uses: thebyte9/blaze-actions/.github/workflows/05_ci_no_cloud.yml@main
    secrets: inherit

  deploy:
    if: github.ref == 'refs/heads/main'
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@main
    with:
      environment: prod
    secrets: inherit
```

---

## Troubleshooting

### Error: "Workflow file not found"

**Cause**: Remote workflow doesn't exist or path is wrong

**Solution**:

```yaml
# Correct path format:
uses: thebyte9/blaze-actions/.github/workflows/stress-test.yml@main
#     └─ org/repo ─┘  └──────── path ────────────┘ └─ ref ─┘
```

**Solution**: Use proper permissions or public repositories.

### Error: "Required input not provided"

**Cause**: Missing required inputs

**Solution**: Check workflow definition for required inputs

```yaml
with:
  environment: dev # Required
  stack: network # Required
```

### Error: "secrets not accessible"

**Cause**: Missing `secrets: inherit`

**Solution**:

```yaml
jobs:
  deploy:
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@main
    secrets: inherit # Add this line
```

---

## Migration Guide

### Converting Local Workflow to Wrapper

**Before** (local workflow, 791 lines):

```yaml
name: Stress Test

on:
  workflow_dispatch:

jobs:
  config:
    runs-on: ubuntu-latest
    steps:
      - name: Calculate config
        # ... 50 lines ...

  provision:
    needs: config
    # ... 100 lines ...

  deploy:
    needs: provision
    # ... 200 lines ...

  # ... 400 more lines ...
```

**After** (wrapper, 16 lines):

```yaml
name: Stress Test

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  execute:
    uses: thebyte9/blaze-actions/.github/workflows/stress-test.yml@main
    secrets: inherit
```

**Reduction**: 775 lines removed (97%)

---

## Limitations

### What Can't Be Done

❌ **Override workflow logic** - Logic is in hub, can't modify from spoke  
❌ **Add new inputs** - Inputs defined in hub workflow  
❌ **Access job outputs directly** - Outputs handled by hub

### Workarounds

✅ **Custom logic** - Add separate jobs before/after remote call  
✅ **New inputs** - Update hub workflow, then all spokes get them  
✅ **Outputs** - Hub workflow can output to artifacts or GitHub outputs

---

## Examples

### Example 1: Full Deployment

```yaml
name: Production Deployment

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  provision:
    uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@v2.5.7
    with:
      environment: prod
      stack: app
      apply: true
    secrets: inherit

  deploy:
    needs: provision
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@v2.5.7
    with:
      environment: prod
      target_services: "Blaze all"
    secrets: inherit

  verify:
    needs: deploy
    uses: thebyte9/blaze-actions/.github/workflows/90-daily-health-check.yml@v2.5.7
    with:
      environment: prod
    secrets: inherit
```

### Example 2: Development Workflow

```yaml
name: Dev Deployment

on:
  push:
    branches: [dev]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@main
    with:
      environment: dev
      target_services: "api frontend"
    secrets: inherit
```

---

## Elastic Beanstalk Deploy

For legacy EB environments, use `reusable-elastic-beanstalk-deploy.yml` to package and deploy an application version.

```yaml
jobs:
  deploy-eb:
    uses: thisisblaze/blaze-actions/.github/workflows/reusable-elastic-beanstalk-deploy.yml@v2.1.77
    with:
      environment: prod                          # GitHub environment (for OIDC)
      application_name: my-app                   # EB Application name
      environment_name: my-app-prod              # EB Environment name
      aws_region: eu-west-1
      build_command: "composer install --no-dev" # Optional pre-package build
      php_version: "8.4"                         # Optional PHP setup
      s3_bucket: ""                              # Optional; uses EB default if blank
    secrets: inherit
```

**What it does**: Checks out code → sets up PHP (if `php_version` set) → runs `build_command` (if set) → zips source excluding `.git/.github/.agent/tests` → uploads bundle to S3 → creates EB Application Version → deploys to EB environment.

---

## FAQ

**Q: Can I call workflows from other organizations?**  
A: Only with GitHub Enterprise.

**Q: What's the best ref to use?**  
A: `@dev` for development, `@v2.1.77` (or current stable tag) for production. **Never use `@main` in production** — it is a shifting ref and breaks governance pinning.

**Q: How do I update all client projects?**  
A: Bump the stable tag in all caller workflows. Governance rule: all caller workflows in `blaze-template-deploy` must pin to the same `@vX.Y.Z` tag.

**Q: Can I test changes before they affect production?**  
A: Yes — use `@dev` for local testing. When ready, release a new tag and bump all caller pins via `/13-deep-cicd-maintenance`.

**Q: What if the hub workflow breaks?**  
A: Version pinning protects you. Clients on `@v1.0.0` unaffected. Test fixes on `@dev` first.

---

## 🏷️ Namespace Configuration

All workflows automatically receive a **namespace** output from `calculate-config` for resource naming.

### Namespace Output

The `calculate-config` composite action provides a `namespace` output:

| Output         | Description               | Example                            | Default   |
| -------------- | ------------------------- | ---------------------------------- | --------- |
| `namespace`    | Resource namespace prefix | `blaze`, `mycompany`               | `"blaze"` |
| `client_key`   | Client identifier         | `b9`                               | -         |
| `project_key`  | Project identifier        | `thisisblaze`                      | -         |
| `stage_key`    | Environment stage         | `dev`, `stage`, `prod`             | -         |
| `cluster_name` | Full ECS cluster name     | `blaze-b9-thisisblaze-dev-cluster` | -         |
| `project_slug` | Subdomain tenant slug     | `support` or empty                 | -         |

### Usage Example

```yaml
jobs:
  config:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6.0.2
      - id: config
        uses: thisisblaze/blaze-actions/.github/actions/calculate-config@main
        with:
          environment: dev
          terraform_stack: app
          deploy_infra: 'false'
          build_images: 'false'
          deploy_services: 'false'
          event_name: 'test'

  deploy:
    needs: config
    runs-on: ubuntu-latest
    steps:
      - name: Deploy with namespace
        env:
          NAMESPACE: ${{ needs.config.outputs.namespace }}
          CLUSTER: ${{ needs.config.outputs.cluster_name }}
          SLUG: ${{ needs.config.outputs.project_slug }}
        run: |
          echo "Deploying to cluster: $CLUSTER"
          # Cluster name will be: ${namespace}-${client}-${project}-${stage}-cluster
```

### Configuration

Set in `vars/{project}/blaze-env.json` (e.g., `vars/thisisblaze/blaze-env.json`):

```json
{
  "common": {
    "NAMESPACE": "blaze" // Default, or use custom value
  }
}
```

**Result:**

- S3 Buckets: `${client}-${stage}-${namespace}-tfstate`
- ECR Repos: `${namespace}-${project}-web/*`
- ECS Clusters: `${namespace}-${client}-${project}-${stage}-cluster`

> **Note:** Changing namespace for an existing environment requires a rebuild. See [README.md](../README.md#namespace-configuration).

---

## Resources

- [GitHub Docs: Reusing Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Workflow Catalog](WORKFLOW_CATALOG.md) - All available workflows

---

**Last Updated**: 2026-05-08  
**Maintainer**: thisisblaze/blaze-actions  
**License**: Apache 2.0
