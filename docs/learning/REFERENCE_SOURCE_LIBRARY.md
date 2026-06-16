---
Last Updated: 2026-05-12
Owner: Infrastructure Team
Used By: .agents/workflows/12-best-practice-audit.md
---

# blaze-actions — Reference Source Library

> Focus: GitHub Actions reusable workflow design, OIDC, multi-cloud CI/CD.
> Tiers: 🔴 Critical / 🟡 Important / 🟢 Informational.

---

## Domain 1 — Reusable Workflow Patterns

| Tier | Source | URL | What to Check Against |
|---|---|---|---|
| 🔴 | GH Docs: Reusable Workflows | https://docs.github.com/en/actions/sharing-automations/reusing-workflows | `workflow_call` inputs/secrets inheritance |
| 🔴 | GH Docs: OIDC Hardening | https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect | OIDC token audience, `permissions: id-token: write` |
| 🔴 | `rhysd/actionlint` | https://github.com/rhysd/actionlint | CI gate — track new rules vs our 54 workflows |
| 🟡 | GH Docs: Workflow Security | https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions | expression injection, `CODEOWNERS` |
| 🟡 | GH Docs: Environments | https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment | Protection rules + required reviewers |
| 🟡 | `slsa-framework/slsa-github-generator` | https://github.com/slsa-framework/slsa-github-generator | Supply chain provenance |
| 🟢 | `sdras/awesome-actions` | https://github.com/sdras/awesome-actions | Curated list for new tooling |

### Top GitHub Actions Repos

| Rank | Repo | URL | Relevance |
|---|---|---|---|
| 1 | `actions/checkout` | https://github.com/actions/checkout | SHA pinning convention |
| 5 | `actions/cache` | https://github.com/actions/cache | Terraform provider caching |
| 6 | `docker/build-push-action` | https://github.com/docker/build-push-action | ARM64 native Buildx |
| 12 | `rhysd/actionlint` | https://github.com/rhysd/actionlint | Version pin check |
| 16 | `slsa-framework/slsa-github-generator` | https://github.com/slsa-framework/slsa-github-generator | Future consideration |

---

## Domain 2 — AWS OIDC & Credentials

| Tier | Source | URL | What to Check Against |
|---|---|---|---|
| 🔴 | `aws-actions/configure-aws-credentials` | https://github.com/aws-actions/configure-aws-credentials | OIDC role assumption — version pin |
| 🔴 | AWS Docs: OIDC Provider | https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html | Trust policy `sub` claim — repo vs env scoped |
| 🟡 | `known fix: github-actions-oidc-environments` | docs/knowledge/github-actions-oidc-environments.md | Reusable workflow secret scoping |

---

## Domain 3 — Terraform in CI/CD

| Tier | Source | URL | What to Check Against |
|---|---|---|---|
| 🔴 | Terraform Docs: S3 Backend | https://developer.hashicorp.com/terraform/language/backend/s3 | State bucket + DynamoDB locking |
| 🔴 | `known fix: terraform-state-checksum-mismatch` | docs/knowledge/terraform-state-checksum-mismatch.md | Lock conflict handling |
| 🟡 | `known fix: terraform-cloudflare-dns-import` | docs/knowledge/terraform-cloudflare-dns-import.md | Provider v5 `allow_overwrite` |
| 🟡 | GH Docs: Concurrency Groups | https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/control-the-concurrency-of-workflows-and-jobs | Terraform race conditions |

---

## Domain 4 — AWS Deployment Patterns

| Tier | Source | URL | What to Check Against |
|---|---|---|---|
| 🔴 | `known fix: aws-ecs-capacity-provider-reconciliation` | docs/knowledge/aws-ecs-capacity-provider-reconciliation.md | `ResourceInUseException` in pre-destroy |
| 🔴 | `known fix: aws-ecs-log-group-conflicts` | docs/knowledge/aws-ecs-log-group-conflicts.md | `ResourceNotFoundException` during deploy |
| 🟡 | `known fix: aws-cloudfront-spa-routing` | docs/knowledge/aws-cloudfront-spa-routing.md | 404/403 on deep links |
| 🟡 | `known fix: gcp-wif-terraform-access-token` | docs/knowledge/gcp-wif-terraform-access-token.md | GCS backend WIF auth |
| 🟡 | `aws-actions/amazon-ecs-deploy-task-definition` | https://github.com/aws-actions/amazon-ecs-deploy-task-definition | ECS deploy action patterns |

---

## Domain 5 — Access Control & Security

| Tier | Source | URL | What to Check Against |
|---|---|---|---|
| 🔴 | `known fix: github-actions-allowed-infra-users` | docs/knowledge/github-actions-allowed-infra-users.md | `check-access` action logic |
| 🔴 | `known fix: github-actions-nested-relative-paths` | docs/knowledge/github-actions-nested-relative-paths.md | Cross-repo `uses:` path resolution |
| 🟡 | GH Docs: Encrypted Secrets | https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions | `add-mask` for dynamic secrets |
| 🟡 | GH Docs: GITHUB_TOKEN Permissions | https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication | Least-privilege `permissions:` blocks |

---

## Audit Key Checks

1. **OIDC role scoping** — env-scoped trust policies (not `repo:*`)?
2. **Actionlint coverage** — all 54 workflow files covered by CI gate?
3. **SHA pinning** — `actions/checkout`, `docker/build-push-action` pinned?
4. **Concurrency groups** — every Terraform-touching workflow has `concurrency:`?
5. **Secret inheritance** — `secrets: inherit` or explicit mappings in all `workflow_call`?
6. **`timeout-minutes`** — every job capped to prevent 6-hour billing runaway?
7. **`check-access` coverage** — every destructive workflow gated?
8. **Pre-destroy cleanup** — ECS services scaled to 0 before `terraform destroy`?
