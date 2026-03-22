# Session Handoff State

**Date/Time**: 2026-03-22T22:55:47Z

## 1. The Exact Objective

Analyze and resolve the bug where destroying non-compute stacks (`third-party-mongodb`, `third-party-elastic`) inadvertently destroys ECS services and broader environment infrastructure. Also, formulate and add a comprehensive plan to make the `99-ops-*` workflows bulletproof.

## 2. Current Progress & Modified Files

- `.github/workflows/99-ops-terraform.yml`: Successfully scoped `reusable-pre-destroy-cleanup` to ONLY execute for `app`, `cdn`, and `network` stacks. Changes have been committed and pushed to `dev`.
- `docs/analysis/99_ops_bulletproof_plan.md`: [NEW] Created and pushed a detailed blueprint for bulletproofing and auditing all `99-ops-*` workflows (covering stack restrictions, dry-run discovery checks, UI summary warnings, and strict dependencies).

## 3. Important Context

- Pre-destroy cleanup logic in `reusable-pre-destroy-cleanup.yml` is fundamentally a broad cluster cleanup tool. We recognized it should never be run blindly on data and third-party infrastructure.
- The user is currently executing actions manually via the GitHub interface (Workflow Dispatches) for the `dev` environment.
- Any future operations targeting `.github/workflows/reusable-pre-destroy-cleanup.yml` must utilize the strict scoping criteria mapped out in `docs/analysis/99_ops_bulletproof_plan.md`.

**ENV Comparison Report Status** (`docs/reports/ENV_COMPARISON_AWS.md`):

- Open 🔴 action items: Implement the scoping rules in `reusable-pre-destroy-cleanup` and `99-ops-nuke`.
- WAF policy: CloudFront-only (stage/prod). ALBs are internal.
- NAT policy: GATEWAY when >5 services, NONE otherwise.
- Redis: prod-only. Prod Redis must be on private subnets (not public).

## 4. The Immediate Next Steps

1. Review and execute the action items out of `docs/analysis/99_ops_bulletproof_plan.md` to harden `reusable-pre-destroy-cleanup.yml`.
2. Add explicit blast-radius estimator blocks to AWS ops workflows.
