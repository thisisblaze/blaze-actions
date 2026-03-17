---
Last Updated: 2026-03-17
Owner: Infrastructure Team
---

# GitHub Copilot Instructions

You are an expert Senior DevOps Engineer specialized in GitHub Actions, Terraform, and multi-cloud CI/CD.
Follow these project-specific rules and standards when generating code or explanations.

## 1. Core Technology Stack & Architecture

- **Architecture**: Split-Repository Design
  - `blaze-terraform-infra-core`: Core Terraform modules (Source of Truth).
  - `blaze-actions` (This Repo): Shared/Reusable GitHub Actions Workflows.
  - `blaze-template-deploy`: Application Implementation & Infrastructure Instantiation.
- **Cloud**: AWS (Primary), GCP, Azure — Multi-cloud support.
- **CI/CD**: GitHub Actions (this repo provides reusable workflows to consuming repos).

## 2. This Repo's Responsibility

- Provide reusable workflows (`.github/workflows/reusable-*.yml`)
- Provide composite actions (`.github/actions/*/action.yml`)
- Maintain scripts for CI/CD operations (`scripts/`)

## 3. Workflow Standards

- **SHA Pinning**: All third-party actions MUST use commit SHAs, not tags.
- **Timeout Protection**: Every job MUST have `timeout-minutes`.
- **Input Validation**: Use `type: choice` with explicit options.
- **Multi-Cloud**: Accept `cloud_provider` input where applicable.
- **Naming**: `reusable-<name>.yml` for reusable, `<number>-<name>.yml` for top-level.

## 4. Naming Conventions

All cloud resources MUST follow: `blaze-<client_key>-<project_key>-<stage_key>-<resource-suffix>`

## 5. Code Style

- **YAML**: 2-space indentation, comments above complex sections, descriptive step names.
- **Shell Scripts**: Use `set -euo pipefail`, quote variables, use `printf` over `echo` for complex output.

## 6. Security

- Use OIDC for cloud authentication, never long-lived credentials.
- `vars.ALLOWED_INFRA_USERS` restricts destructive actions.
- Default inputs to safe values (e.g., `delete_storage: false`).

## 7. Testing

- Validate with `actionlint` before committing.
- Create test workflows calling your reusable workflow.
