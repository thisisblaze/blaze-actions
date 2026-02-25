**Last Updated**: 2026-02-25
**Owner**: Infrastructure Team

---

# AI Context Governance: The Blaze Standard

**STATUS: MANDATORY**
**TARGET AUDIENCE: AI AGENTS, DEVELOPERS, ARCHITECTS**
**REPO ROLE**: Shared/Reusable GitHub Actions Workflows

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
## 2. The Golden Rule of Context

Before writing a single line of code or answering a complex architectural question, you **MUST** ground yourself in the current environment's reality.
**"Hallucination" of resource names is the #1 cause of deployment failure.**
## 3. The Protocol

### A. Start of Session (Bootstrapping)

**Action**:

1.  Read the **Architecture**: `docs/REUSABLE_WORKFLOWS.md`
2.  Read the **Catalog**: `docs/WORKFLOW_CATALOG.md`
3.  View the **Topology**: `docs/graphs/multi_cloud_topology.mermaid`
4.  **Ack**: "Context Loaded. I am ready to work on the Blaze Actions repository."

### B. During Execution (Navigation)

If you are unsure where a workflow lives or how data flows:

1.  **Don't Guess.**
2.  **Consult the Catalog**: `docs/WORKFLOW_CATALOG.md`.
3.  **Trace the Config**: Look at `reusable-calculate-config.yml`.

### C. End of Cycle (Maintenance)

**Trigger**: Weekly or after significant workflow changes.
**Action**:

1.  Compare actual workflows vs. catalog and topology.
2.  Update docs to reflect reality.
3.  This ensures the _next_ agent has accurate maps.

## 4. Data Retention Policy

| Provider | Storage                   | Logs/Ephemeral            | Persistent Data                             |
| :------- | :------------------------ | :------------------------ | :------------------------------------------ |
| AWS      | S3 Lifecycle Rules        | ✅ 30-90 day retention OK | ⚠️ RESTRICTED — "Data Loss Check" required  |
| GCP      | GCS Lifecycle             | ✅ 30-90 day retention OK | ⚠️ `force_destroy_storage = false` for Prod |
| Azure    | Storage Account Lifecycle | ✅ 30-90 day retention OK | ⚠️ RESTRICTED — lock policies required      |
## 5. Operational Workflows (Standard Procedures)

Consult these approved workflows for specific operational tasks:

- **Add Workflow**: `.agent/workflows/01-add-workflow.md`
- **Add Sharp Layer**: `.agent/workflows/02-add-sharp-layer.md`
- **Docs Maintenance**: `.agent/workflows/09-maintain-docs.md`
- **Debug CI/CD**: `.agent/workflows/debug-cicd-workflows.md`
- **Troubleshoot CloudFront**: `.agent/workflows/troubleshoot-cloudfront.md`
- **Troubleshoot TF Locks**: `.agent/workflows/troubleshoot-terraform-locks.md`

## 6. Key References

- **Workflow Catalog**: `docs/WORKFLOW_CATALOG.md`
- **Reusable Workflows**: `docs/REUSABLE_WORKFLOWS.md`
- **Cross-Org Secrets**: `docs/cross-org-secrets.md`
- **Cloudflare Operations**: `docs/cloudflare-operations.md`
- **Visual Topology**: `docs/graphs/multi_cloud_topology.mermaid`

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

---

_This document governs the interaction between Human Intent and AI Execution. Deviation results in broken pipelines._