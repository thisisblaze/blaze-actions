# Reusable Workflows Guide

**Repository**: blaze-actions  
**Pattern**: Hub & Spoke  
**Last Updated**: 2026-01-07

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
        options: ["dev", "stage", "prod"]

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
uses: thebyte9/blaze-actions/.github/workflows/stress-test.yml@v1.0.0
```

**Specific commit (maximum stability)**:

```yaml
uses: thebyte9/blaze-actions/.github/workflows/stress-test.yml@a24d7b4
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
@main

# Staging
@v1

# Production
@v1.0.0
```

### 4. Set Proper Permissions

```yaml
permissions:
  id-token: write # For AWS OIDC
  contents: read # For checkout
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
    uses: thebyte9/blaze-actions/.github/workflows/01-provision-infra.yml@v1.0.0
    with:
      environment: prod
      stack: app
      apply: true
    secrets: inherit

  deploy:
    needs: provision
    uses: thebyte9/blaze-actions/.github/workflows/02-deploy-app.yml@v1.0.0
    with:
      environment: prod
      target_services: "Blaze all"
    secrets: inherit

  verify:
    needs: deploy
    uses: thebyte9/blaze-actions/.github/workflows/90-daily-health-check.yml@v1.0.0
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

## FAQ

**Q: Can I call workflows from other organizations?**  
A: Only with GitHub Enterprise.

**Q: What's the best ref to use?**  
A: `@main` for development, `@v1.0.0` for production.

**Q: How do I update all client projects?**  
A: Update hub workflow once. All clients using `@main` get update immediately. Clients using `@v1.0.0` update when ready.

**Q: Can I test changes before they affect production?**  
A: Yes! Use `@dev` branch for testing, `@main` for stable, `@v1.0.0` for production.

**Q: What if the hub workflow breaks?**  
A: Version pinning protects you. Clients on `@v1.0.0` unaffected. Test fixes on `@dev` first.

---

## Resources

- [GitHub Docs: Reusing Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Workflow Catalog](WORKFLOW_CATALOG.md) - All available workflows
- [Workflow Catalog](WORKFLOW_CATALOG.md) - All available workflows

---

**Last Updated**: 2026-01-07  
**Maintainer**: thisisblaze/blaze-actions  
**License**: Apache 2.0
