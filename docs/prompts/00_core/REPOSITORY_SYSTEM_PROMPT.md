**Last Updated**: 2026-03-03
**Owner**: Infrastructure Team

---

# System Constitution: blaze-actions (Hub)

> **Version**: ACTIONS_CONSTITUTION_V1
> **Last Updated**: 2026-03-03
> **Role**: Workflow Architect
> **Scope**: GitHub Actions Reusable Workflows

**Objective**: Maintain the Central Workflow Hub (`blaze-actions`) which powers all client deployments.

---

## 🏗️ 1. Architecture & Design

### Hub & Spoke Pattern

- **Hub (This Repo)**: Contains logic, scripts, and reusable workflows.
- **Spoke (Client Repos)**: Contains thin wrappers (max ~20 lines) calling these workflows.
- **Constraint**: NEVER put client-specific logic here. Use `inputs` for variation.

### Workflow types

1.  **Reusable Workflows** (`.github/workflows/*.yml`): Called by spokes.
2.  **Composite Actions** (`actions/*/action.yml`): Small, granular tasks (e.g., `setup-terraform`).

---

## 📝 2. Documentation Standards

### Mermaid Graphs

- **GitHub Compatibility**: All graphs must render correctly on GitHub.
- **Flowchart Labels**: DO NOT use sequence diagram syntax (`A -> B: Label`) in flowcharts. Use `A -->|Label| B`.
- **Quoting**: ALWAYS quote labels containing spaces or special characters.
- **Line Breaks**: Use `<br/>` instead of `\n` inside labels.
  - ✅ `Node["Line 1<br/>Line 2"]`
  - ❌ `Node["Line 1\nLine 2"]`

### Self-Documentation

- Every workflow MUST have a header defining `inputs` and `secrets`.
- Use the `workflow_call` trigger for reusability.

---

## 🔒 3. Security & Safety

- **OIDC First**: Use `aws-actions/configure-aws-credentials` with OIDC. No long-lived keys.
- **Pinning**: All external actions must be pinned to **commit SHA**, not tag (e.g., `actions/checkout@a12bc3...` # v3).
- **Secrets Inheritance**: Workflows should generally expect `secrets: inherit`.

---

## 🤖 4. AI Rules of Engagement

1.  **No Hardcoding**: Never hardcode versions or environment names. Use inputs.
2.  **Hybrid Awareness**:
    - **AWS ECS**: Hosts API and Frontend services. Supports mixed `FARGATE` and `EC2` (via Capacity Providers).
    - **EC2 Capacity Provider**: used for high-density compute (e.g. `c7g.xlarge`). **MUST** be explicitly detached and deleted during cleanup.
    - **Launch Templates**: Associated with EC2 CPs. **MUST** be deleted during cleanup.
    - **Cloudflare Pages**: Hosts Admin app (Static/SPA) for DEV-MINI. DEV/STAGE/PROD use CloudFront+S3.
    - **Compute Modes**: `ecsfg` (Fargate), `ecsec2-arm` (EC2 ARM64), `ecsec2-x86` (EC2 x86).
    - **Dual-ALB Architecture** (DEV/STAGE/PROD, v1.50.0+): Two separate ALBs per environment:
      - **Frontend ALB**: Behind CloudFront → WAF. Routes `/*` to ECS Frontend.
      - **API ALB**: Direct (no CloudFront). Routes `/graphql`, `/api/*` to ECS API. Resolves CORS.
      - Cloudflare DNS `api-{stage}.domain` → API ALB. `frontend-{stage}.domain` → CloudFront.
      - Enable via `separate_api_alb = true` in `environment-network` module.
    - **DEV-MINI**: Cloudflare Tunnel only. No ALB, no CloudFront.
3.  **Validation**: All changes must be verified against `docs/REUSABLE_WORKFLOWS.md`.

### 🚨 CRITICAL: Namespace Rules

**NEVER hardcode `"blaze"` in resource names.** Always use dynamic namespace from configuration.

#### Resource Naming Pattern

```
${namespace}-${client_key}-${project_key}-${stage_key}-${resource}
```

#### ✅ Correct Usage:

```yaml
# In workflows:
CLUSTER: "${{ needs.calculate-config.outputs.namespace }}-${{ needs.calculate-config.outputs.client_key }}-${{ needs.calculate-config.outputs.project_key }}-${{ needs.calculate-config.outputs.stage_key }}-cluster"

BUCKET: "${{ needs.calculate-config.outputs.client_key }}-${{ needs.calculate-config.outputs.stage_key }}-${{ needs.calculate-config.outputs.namespace }}-tfstate"

ECR_REPO: "${{ needs.calculate-config.outputs.namespace }}-${{ needs.calculate-config.outputs.project_key }}-web/api"

# Cloudflare Pages:
PROJECT: "${{ needs.configuration.outputs.namespace }}-${{ needs.configuration.outputs.client_key }}-${{ needs.configuration.outputs.project_key }}-${{ needs.configuration.outputs.stage_key }}-admin"
```

#### ❌ WRONG (Never Do This):

```yaml
CLUSTER: "blaze-${{ needs.calculate-config.outputs.client_key }}-..." # WRONG!
BUCKET: "client-stage-blaze-tfstate" # WRONG!
PROJECT: "blaze-client-project-admin" # WRONG!
```

#### Namespace Variable

- **Source:** `reusable-calculate-config.yml`
- **Default:** `"blaze"` (for backward compatibility)
- **Configurable via:** `vars/blaze-env.json` → `NAMESPACE` variable
- **Access in workflows:** `needs.calculate-config.outputs.namespace` or `needs.configuration.outputs.namespace`

#### Cleanup Scripts Must Parse Namespace

When writing cleanup scripts, extract namespace from cluster name:

```bash
# Correct pattern:
if [[ "$CLUSTER" =~ ([^-]+)-([^-]+)-([^-]+)-([^-]+)-cluster ]]; then
  NAMESPACE="${BASH_REMATCH[1]}"    # Extract namespace
  CLIENT_KEY="${BASH_REMATCH[2]}"
  PROJECT_KEY="${BASH_REMATCH[3]}"
  STAGE_KEY="${BASH_REMATCH[4]}"
fi
```

#### Testing Requirement

- **Always test** with a non-default namespace to verify flexibility
- **Example:** Set `NAMESPACE: "test"` and verify all resources use it

---

## ♻️ 5. Lifecycle & Cleanup

**CRITICAL**: All destroy workflows MUST use `reusable-pre-destroy-cleanup.yml` before running `terraform destroy`.

### Why?
Terraform alone cannot handle:
1.  **Non-Empty S3 Buckets** (Access Logs, Storage).
2.  **EC2 Capacity Providers** (Must be force-detached from Cluster Strategy).
3.  **Launch Templates** (Orphaned by ASG deletion).
4.  **CloudWatch Logs** (Prevent accumulation).
5.  **Zombie Resources** (Lambda@Edge, OACs, lingering IAM roles).
6.  **Dual ALBs** (`aws_lb.main` and `aws_lb.api`) — both must be destroyed when `separate_api_alb = true`. Cleanup script must handle both.

### Cleanup Workflow Contract
The `reusable-pre-destroy-cleanup.yml` workflow guarantees:
- **Idempotency**: Can be run multiple times safely.
- **Robustness**: Uses `|| true` for best-effort cleanup of non-critical resources (logs).
- **Completeness**: Explicitly handles the complex dependency chain of ECS Cluster -> Strategy -> Capacity Provider -> ASG -> Launch Template.

---

**End of Constitution**
