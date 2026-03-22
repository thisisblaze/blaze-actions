# 99-Ops Workflows: Bulletproof Redesign Plan

## Objective
The recent incident where destroying the `third-party-mongodb` stack triggered a broad AWS ECS cleanup highlighted a critical flaw in the `99-*` ops workflows: **lack of strict scoping in destructive pre-cleanup scripts**.

This plan outlines a comprehensive, bulletproof approach to analyzing and hardening all `99-ops-*.yml` and `reusable-*.yml` utility workflows to ensure operations are strictly confined to their intended blast radius.

## 1. Audit Current Workflow Routing
- **Map the execution paths**: Map every `action` input (e.g., `destroy-resources`, `nuke-environment`, `manage-environment`) from `99-ops-utility.yml` through its respective sub-workflow (`99-ops-aws.yml`, `99-ops-terraform.yml`, etc.).
- **Identify implicit logic**: Find all steps using `always()`, `if: inputs.action == ...`, or missing `inputs.stack` guards.

## 2. Harden `reusable-pre-destroy-cleanup.yml`
- **Parameterize by Stack**: The cleanup script currently runs generically based on cluster name. It MUST be parameterized by stack type.
  - *App/CDN Stacks*: Safe to run heavy ECS/Lambda teardowns.
  - *Data/Network Stacks*: Must skip heavy compute teardowns entirely.
- **Resource Ownership Tagging**: Enforce that the script only deletes resources explicitly tagged or associated with the stack being destroyed, rather than doing broad regex/grep searches for `-dev-` or `-prod-`.
- **Pre-flight Checks**: Introduce a dry-run/discovery mode for `reusable-pre-destroy-cleanup.yml` to list what *would* be destroyed before executing.

## 3. Strict State Verification
- Ensure `wipe-state` and `unlock-state` are strongly verified.
- Implement explicit checks in `reusable-terraform.yml` to fail fast if it detects a cross-stack dependency before running `terraform destroy` (e.g., refusing to destroy a data stack if the app stack is still active).

## 4. Enhanced Logging and Blast Radius Warnings
- Create a reusable `blast-radius-estimator` step that runs before any `destroy-*` or `nuke-*` actions.
- Output a strict summary of targeted ARNs / Services to the GitHub Actions workflow summary, requiring an explicit `EXECUTE` confirmation override for high-impact sweeps.

## Next Steps
1. Execute a line-by-line review of `99-ops-terraform.yml` and `99-ops-nuke.yml`.
2. Refactor `reusable-pre-destroy-cleanup.yml` to accept a `target_stack` input.
3. Test the updated workflow using harmless stacks (e.g., `tunnel` or a generic `dev-mini`) with dry-run enabled.
