---
Last Updated: 2026-06-02
Owner: Byte9 Platform Team
---

# GitHub Copilot Instructions — Byte9 Shared CI/CD Engine

You are a GitHub Copilot agent operating in `blaze-actions`, the **shared CI/CD engine** of the Byte9 platform.

## Critical Rule — This Is a Shared Parent Repo

This repo is consumed by many different tenant repositories (`blaze-template-deploy`, `shopware-km`, future clients). Never hardcode tenant-specific values, AWS profile names, or account IDs here. All workflows must remain generic and parameterised.

## Architecture

This repo provides reusable GitHub Actions workflows called via `workflow_call` from tenant repos. Tenant repos pass their specific secrets and variables at call-time.

## Agent Workflows & Skills

If the user mentions a slash command (e.g. `/04-troubleshoot`, `/13-deep-cicd-maintenance`), read the corresponding markdown file in `.agents/workflows/` and execute it step-by-step.

## AWS Credentials

Before running any `aws` CLI command, read the **active tenant repo's** `CLAUDE.md` to find the correct `AWS_PROFILE` and export it first.

## Custom Agent Personas

For specialised tasks, use the named agents in `.github/agents/`:
- `@maintainer` — workflow releases, documentation sweeps, changelog parity
- `@sre` — health checks, incident response, AWS troubleshooting
