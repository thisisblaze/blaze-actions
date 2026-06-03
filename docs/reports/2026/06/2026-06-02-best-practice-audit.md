# Best Practice Audit — 2026-06-02
**Scope**: blaze-actions reusable workflows | **Library**: docs/learning/REFERENCE_SOURCE_LIBRARY.md

## Summary
8 checks performed. 4 aligned ✅. 2 gaps (2 critical 🔴). 2 partial ⚠️.

## Findings
### ✅ Aligned
- **P2 Actionlint coverage**: All workflow files (`.github/workflows/*.yml`) are strictly gated by `actionlint` in `05_ci_no_cloud.yml` protecting the main branch.
- **P4 Concurrency groups**: Implemented across the board. Validated over 30 distinct workflows (including all terraform and utility ones) which enforce proper `concurrency:` groups.
- **P6 Timeout limits**: Strict `timeout-minutes` (ranging from 5 to 30 mins) exists on all jobs, protecting against stalled runner billing.
- **P7 Destructive workflow gates**: The `thisisblaze/blaze-actions/.github/actions/check-access` action properly gates `01-provision-infra.yml`, `99-ops-nuke.yml`, and other critical workflows.

### ⚠️ Partial
- **P1 OIDC role scoping**: Checked local repo for trust policies; AWS trust policies appear to be managed externally via Terraform (`blaze-terraform-infra-core`), so this cannot be fully verified inside `blaze-actions` alone.
- **P3 SHA/stable pins on external actions**: Some actions are pinned to major/minor versions (e.g., `actions/checkout@v6.0.2`, `actions/cache@v5`) rather than specific immutable SHAs, though critical AWS authentication actions correctly use SHAs (e.g., `aws-actions/configure-aws-credentials@ec61189d14ec14c8efccab744f656cffd0e33f37`).

### 🔴 Gap (Action Required)
- **P5 Secret inheritance**: Many wrapper workflows (`99-ops-*.yml`) have `TODO: Refactor to use secrets: inherit pattern` and are explicitly passing secrets instead of utilizing the simpler `secrets: inherit` standard for `workflow_call`.
- **P8 Pre-destroy ECS scale-to-0**: The `reusable-pre-destroy-cleanup.yml` workflow aggressively cleans up S3, CloudWatch, Service Discovery, OACs, and CloudFront distributions, but **completely lacks** any logic to scale ECS desired counts down to zero before a destroy operation.

## Knowledge Base Freshness
- **Still valid**: Checked `docs/knowledge/aws-ecs-capacity-provider-reconciliation.md` which is updated for V2 (April 2026 context) and accurately reflects current mitigations.
- **Needs update**: Review of remaining `docs/knowledge/*.md` is recommended to verify any underlying actions haven't deprecated the documented workarounds.

## Next Audit Due: 2026-07-02
