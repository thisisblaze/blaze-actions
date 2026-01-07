# Blaze Actions

Reusable GitHub Actions workflows for Blaze deployments - CI/CD Hub.

## Overview

This repository contains reusable GitHub Actions workflows and composite actions used across all Blaze projects.

## Workflows

### Reusable Workflows (`.github/workflows/`)
- **provision-infra.yml** - Infrastructure provisioning
- **deploy-app.yml** - Application deployment
- **ops-utility.yml** - Operational utilities
- (More workflows to be extracted...)

### Composite Actions (`.github/actions/`)
- **calculate-config** - Configuration calculation
- **deploy-ecs-service** - ECS service deployment
- (More actions to be extracted...)

## Usage

```yaml
jobs:
  deploy:
    uses: thisisblaze/blaze-actions/.github/workflows/deploy-app.yml@v1
    with:
      environment: prod
    secrets: inherit
```

## License

Apache License 2.0
