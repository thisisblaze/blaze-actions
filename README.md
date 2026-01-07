# Blaze Actions

Reusable GitHub Actions workflows and composite actions for Blaze deployments - CI/CD Hub.

## Overview

Centralized CI/CD workflows and actions used across all Blaze projects. All workflows support `workflow_call` for reusability.

## Workflows Catalog

### Main Workflows

| Workflow | Purpose | Inputs |
|:---------|:--------|:-------|
| `00_setup_environment.yml` | Environment setup and validation | environment |
| `01-provision-infra.yml` | Terraform infrastructure provisioning | environment, component |
| `02-deploy-app.yml` | Application deployment to ECS | environment, service |
| `stress-test.yml` | Full environment lifecycle test | - |

### Operations Workflows

| Workflow | Purpose |
|:---------|:--------|
| `99-ops-utility.yml` | Multi-purpose ops tool (backup, restore, etc.) |
| `90-daily-health-check.yml` | Automated health monitoring |
| `sync-secrets-from-ssm.yml` | Sync secrets from AWS SSM to GitHub |
| `smart-dashboard.yml` | Infrastructure dashboard generation |

### Testing & Validation

| Workflow | Purpose |
|:---------|:--------|
| `05_ci_no_cloud.yml` | CI tests (no cloud resources) |
| `10_security_scan.yml` | Security scanning (Semgrep, Gitleaks) |
| `terraform-tests.yml` | Terraform module tests |

### Utility Workflows

| Workflow | Purpose |
|:---------|:--------|
| `debug-lock.yml` | Terraform state lock debugging |
| `force-unlock.yml` | Force unlock Terraform state |
| `fix-state-integrity.yml` | Fix Terraform state issues |
| `fix-cname-conflict.yml` | Resolve CloudFront CNAME conflicts |
| `nuke-cloudfront.yml` | Delete CloudFront distributions |
| `check-stack-exists.yml` | Check if Terraform stack exists |

### Reusable Workflows

| Workflow | Purpose |
|:---------|:--------|
| `reusable-calculate-config.yml` | Load configuration from vars/*.json |
| `reusable-terraform.yml` | Terraform init/plan/apply |
| `reusable-terraform-operations.yml` | Advanced Terraform operations |
| `reusable-docker-build.yml` | Build and push Docker images |
| `reusable-ecs-deploy.yml` | Deploy to ECS |
| `reusable-ecs-service-management.yml` | ECS service operations |
| `reusable-pre-destroy-cleanup.yml` | Pre-destroy cleanup (scale down, etc.) |

## Composite Actions

| Action | Purpose |
|:-------|:--------|
| `calculate-config` | Load and merge configuration files |
| `deploy-ecs-service` | Deploy ECS service with task definition |
| `setup-terraform` | Configure Terraform with backend |
| `aws-credentials` | Configure AWS credentials via OIDC |
| `docker-buildx-setup` | Setup Docker Buildx for multi-arch |

## Scripts

| Script | Purpose |
|:-------|:--------|
| `health-check.sh` | Service health verification |

## Usage

### Calling a Reusable Workflow

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/02-deploy-app.yml@v1
    with:
      environment: prod
      service: frontend
    secrets: inherit
```

### Using a Composite Action

```yaml
steps:
  - uses: thisisblaze/blaze-actions/.github/actions/calculate-config@v1
    with:
      project: myproject
      environment: prod
```

## Versioning

**Always pin to a specific version**:
```yaml
uses: thisisblaze/blaze-actions/.github/workflows/deploy-app.yml@v1.0.0  # ✅ Immutable
uses: thisisblaze/blaze-actions/.github/workflows/deploy-app.yml@v1      # ❌ Mutable
```

## Development

### Testing Workflows Locally

```bash
# Use act for local testing
act -j deploy -s AWS_ROLE_ARN=arn:aws:iam::...
```

### Adding a New Workflow

1. Create workflow file in `.github/workflows/`
2. Add `workflow_call` trigger
3. Document inputs/outputs
4. Update this README
5. Submit PR

## License

Apache License 2.0

## Auto-Sync Test

This line added on 2026-01-07T12:14:01Z to test auto-sync to thebyte9/blaze-actions mirror.
