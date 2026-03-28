**Last Updated**: 2026-03-28
**Owner**: Infrastructure Team

---

# AI Context Governance: The Blaze Standard

**STATUS: MANDATORY**
**TARGET AUDIENCE: AI AGENTS, DEVELOPERS, ARCHITECTS**
**REPO ROLE**: Reusable GitHub Actions Workflows

## 1. The Prime Directive

**NEVER ASSUME HARDCODED NAMES.**
In the Blaze ecosystem, "blaze" is just a default. Real-world deployments use dynamic namespaces (e.g., `mybrand`, `client-x`).

- ❌ **Bad Assumption**: Resource is named `blaze-api-cluster` (assumes 'blaze' namespace).
- ✅ **Correct Logic**: Resource is named `${NAMESPACE}-api-cluster`. Always use placeholders like `{namespace}`, `{client}`, `{project}`, `{stage}` in analysis.

### 1.5. Public Repository Sanitization

**CRITICAL POLICY**: Several of our repositories (such as `blaze-actions`) are **PUBLIC**. For consistency across the ecosystem:

- NEVER write or commit actual company URLs (e.g. `*.thisisblaze.uk` or client-specific variations) in shared workflows or documentation.
- NEVER include real AWS Account IDs, ARNs, or exact server IP addresses in documentation.
- ALWAYS use sanitized placeholders (e.g., `app.example.com`, `123456789012`) when producing examples in the Knowledge Library or AI workflows.

### 1.6. The Signature Tag Rule

**CRITICAL POLICY**: Generic tags like `Stage`, `Client`, and `Project` are heavily overloaded by legacy tools and other CI/CDs. 
When verifying infrastructure teardown, checking for orphaned resources, or listing active systems via raw CLI (like `aws cloudfront list-distributions`), you **MUST** filter exclusively by our unified signature tags:
- `Blaze:Architecture=two-pillar-v2`
- `Blaze:Provisioner=blaze-actions`

"Orphan hunting" using string matching on domains (e.g., `dev.b9`) without checking these exact tags or Terraform State is strictly forbidden.

## 2. The Golden Rule of Context

Before writing a single line of code or answering a complex architectural question, you **MUST** ground yourself in the current environment's reality.
**"Hallucination" of resource names is the #1 cause of deployment failure.**

## 3. The Protocol

### A. Start of Session (Bootstrapping)

**Command**: `/init-context`
_(Source: [.agent/workflows/slash-init-context.md](.agent/workflows/slash-init-context.md))_

**Action**:

1.  Read the **Constitution**: `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md`
2.  View the **Territory**: `docs/graphs/aws_resource_topology.mermaid` (AWS), `.github/gcp/` (GCP), `.github/azure/` (Azure)
3.  View the **Dependencies**: `docs/graphs/module_dependency_map.mermaid`
4.  **Ack**: "Context Loaded. I am ready to work on the Multi-Cloud (AWS/GCP/Azure) Blaze stack."

### B. During Execution (Navigation)

If you are unsure where a resource lives or how data flows:

1.  **Don't Guess.**
2.  **Consult the Visual Hub**: Look at `docs/graphs/`.
3.  **Trace the Config**: Look at `reusable-calculate-config.yml`.

### C. End of Cycle (Maintenance)

**Command**: `/weekly-graph`
_(Source: [.agent/workflows/slash-weekly-graph.md](.agent/workflows/slash-weekly-graph.md))_

**Trigger**: Weekly or after significant architectural changes.
**Action**:

1.  Compare actual Code vs. Visual Graphs.
2.  Update Graphs to reflect reality.
3.  This ensures the _next_ agent has accurate maps.

## 4. Data Retention Policy

| Provider | Storage                   | Logs/Ephemeral            | Persistent Data                             |
| :------- | :------------------------ | :------------------------ | :------------------------------------------ |
| AWS      | S3 Lifecycle Rules        | ✅ 30-90 day retention OK | ⚠️ RESTRICTED — "Data Loss Check" required  |
| GCP      | GCS Lifecycle             | ✅ 30-90 day retention OK | ⚠️ `force_destroy_storage = false` for Prod |
| Azure    | Storage Account Lifecycle | ✅ 30-90 day retention OK | ⚠️ RESTRICTED — lock policies required      |

## 5. Operational Workflows (Standard Procedures)

Consult these approved workflows for specific operational tasks:

- **Add Workflow**: `/01-add-workflow` → `.agent/workflows/01-add-workflow.md`
- **Add Sharp Layer**: `/02-add-sharp-layer` → `.agent/workflows/02-add-sharp-layer.md`
- **Deep CICD Maintenance**: `/13-deep-cicd-maintenance` → `.agent/workflows/13-deep-cicd-maintenance.md`
- **Troubleshoot CloudFront**: `/troubleshoot-cloudfront` → `.agent/workflows/troubleshoot-cloudfront.md`
- **Troubleshoot TF Locks**: `/troubleshoot-terraform-locks` → `.agent/workflows/troubleshoot-terraform-locks.md`
- **Debug CICD Workflows**: `/debug-cicd-workflows` → `.agent/workflows/debug-cicd-workflows.md`
- **Docs Maintenance**: `/09-maintain-docs` → `.agent/workflows/09-maintain-docs.md`

## 6. Key References

- **Naming Standard**: `docs/reference/NETWORK_STACK_RESOURCES.md`
- **Visual Hub**: `docs/graphs/`
- **Maintenance Prompt**: `docs/prompts/02_weekly/WEEKLY_VISUALIZATION_UPDATE.md`

## 7. Stage Safety Protocol (Cost Control)

**Status: MANDATORY**

To prevent runaway costs in non-production environments, all Agents MUST verify the following constraints when analyzing or modifying **Stage/Dev** infrastructure:

| Rule                | AWS                                  | GCP                                         | Azure                       |
| :------------------ | :----------------------------------- | :------------------------------------------ | :-------------------------- |
| Compute Scaling     | `ec2_max_size` MUST be `1`           | `min_instances` MUST be `0` (scale-to-zero) | `min_replicas` MUST be `0`  |
| NAT Strategy        | `NONE` (Public IPs) or `INSTANCE`    | Cloud NAT (shared, low cost)                | VNet Integration (built-in) |
| Deletion Protection | `enable_deletion_protection = false` | `force_destroy_storage = true` (Dev only)   | Resource locks removed      |
| VPC Connector       | N/A                                  | `e2-micro`, max 3 instances                 | N/A                         |

**Constraint Violation**: If you see scaling above these limits in Stage/Dev, you MUST flag it as a "Cost Anomaly".

## 8. Transient Artifact Cleanup (Zero Trace Policy)

**Status: MANDATORY**

When creating temporary resources for debugging, you **MUST** ensure they are removed before completing the task.

### The Protocol:

1.  **Creation**: It is acceptable to create `temp/`, `debug/`, or `*_src/` folders for analysis.
2.  **Exclusion**: These MUST be ignored by `.gitignore` if they persist for more than one step.
3.  **Destruction**: You **MUST** delete these artifacts before declaring "Task Complete".
4.  **Verification**: Run `git status` before finishing to ensure no temporary junk is being committed.
5.  **Output Location**: ALWAYS output temporary logs to `scratch/` (e.g., `gh run view ... > scratch/debug.log`).

**Anti-Pattern (Do Not Do):**

- Leaving `lambda_src/`, `logs/`, or `config_dump.json` in the root directory.
- Committing `*.log`, `*.out`, or debugging scripts that contain hardcoded values.

## 9. Cleanup Protocol (The Law of Zero Waste)

**Status: MANDATORY**

Terraform Destroy is **NOT** enough. You MUST use the `reusable-pre-destroy-cleanup.yml` workflow before destroying any environment.

**Why?**

- **EC2 Capacity Providers**: Will hang Terraform indefinitely if not forcefully detached.
- **Launch Templates**: Will be orphaned and clutter the account.
- **Logs**: Terraform does not delete CloudWatch Log Groups by default.
- **S3 Buckets**: Non-empty buckets will cause destroy failures.

**The Rule**:

> "If you provision it, you must ensure it can be destroyed. If Terraform can't destroy it, you must script the cleanup."

## 10. Cross-Repository Architecture

| Repository                          | Role                                         | Owner         |
| :---------------------------------- | :------------------------------------------- | :------------ |
| `blaze-terraform-infra-core`        | Terraform module Source of Truth             | `thisisblaze` |
| `blaze-actions`                     | Reusable GitHub Actions workflows            | `thisisblaze` |
| `blaze-template-deploy` (This Repo) | Application deployment & infra instantiation | `thebyte9`    |


## 11. Deployment Architecture Facts (2026-03-25)

**Status: MANDATORY — agents must not assume older patterns**

| Fact                               | Detail                                                                                             |
| :--------------------------------- | :------------------------------------------------------------------------------------------------- |
| **Core Architecture Paradigm**     | **Multi-Site V2 (The Two-Pillar Strategy)**: Day 0 Shared Foundation, Day 1 Data Pods, Day 2 Tenants|
| **ECS API Deployment**             | **Native ECS Blue/Green** — no CodeDeploy, no `appspec.yml`, no deployment group                   |
| **CloudFront Topologies**          | **3 Distributions per Tenant** (Admin, API, Frontend). Allows extreme Blue/Green isolation         |
| **Database Strategy**              | **Shared Pods** (e.g. `db-pod-alpha`) utilizing native MongoDB Atlas Autoscaling (M10-M30)         |
| **Dev Environment (Foundation)**   | `dev-network` Foundation utilizes VPC `10.4.0.0/16` and decoupled Dual ALBs                        |
| **VPC CIDRs**                      | PILLAR 1: DEV=10.0.0.0/16, STAGE=10.1.0.0/16, PROD=10.2.0.0/16. PILLAR 2 (V2): DEV=10.4.0.0/16, STAGE=10.5.0.0/16, PROD=10.6.0.0/16 |
| **Module Version**                 | `blaze-terraform-infra-core` @ **Multi-Site V2 Default**                                           |
| **CodeDeploy**                     | **REMOVED**. No `aws deploy create-deployment` calls. If you see one — it is a bug                 |

---

_This document governs the interaction between Human Intent and AI Execution. Deviation results in broken pipelines._
