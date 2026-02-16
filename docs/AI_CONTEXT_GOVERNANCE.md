**Last Updated**: 2026-02-16
**Owner**: Infrastructure Team

---

# AI Context Governance: The Blaze Standard

**STATUS: MANDATORY**
**TARGET AUDIENCE: AI AGENTS, DEVELOPERS, ARCHITECTS**

## 1. The Prime Directive

**NEVER ASSUME HARDCODED NAMES.**
In the Blaze ecosystem, "blaze" is just a default. Real-world deployments use dynamic namespaces (e.g., `mybrand`, `client-x`).

- ❌ **Bad Assumption**: Resource is named `blaze-api-cluster` (assumes 'blaze' namespace).
- ✅ **Correct Logic**: Resource is named `${NAMESPACE}-api-cluster`. Always use placeholders like `{namespace}`, `{client}`, `{project}`, `{stage}` in analysis.

## 2. The Golden Rule of Context

Before writing a single line of code or answering a complex architectural question, you **MUST** ground yourself in the current environment's reality.
**"Hallucination" of resource names is the #1 cause of deployment failure.**

## 3. The Protocol

### A. Start of Session (Bootstrapping)

**Command**: `/init-context`  
_(Source: [.agent/workflows/slash-init-context.md](file:///Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.agent/workflows/slash-init-context.md))_

**Action**:

1.  Read the **Constitution**: `docs/prompts/00_core/REPOSITORY_SYSTEM_PROMPT.md`
2.  View the **Territory**: `docs/graphs/multi_cloud_topology.mermaid` (AWS/GCP/Azure structure)
3.  View the **Dependencies**: `docs/graphs/module_dependency_map.mermaid`
4.  **Ack**: "Context Loaded. I am ready to work on the Multi-Cloud stack."

### B. During Execution (Navigation)

If you are unsure where a resource lives or how data flows:

1.  **Don't Guess.**
2.  **Consult the Visual Hub**: Look at `docs/graphs/`.
3.  **Trace the Config**: Look at `reusable-calculate-config.yml`.

### C. End of Cycle (Maintenance)

**Command**: `/weekly-graph`  
_(Source: [.agent/workflows/slash-weekly-graph.md](file:///Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.agent/workflows/slash-weekly-graph.md))_

**Trigger**: Weekly or after significant architectural changes.
**Action**:

1.  Compare actual Code vs. Visual Graphs.
2.  Update Graphs to reflect reality.
3.  This ensures the _next_ agent has accurate maps.

## 4. Data Retention Policy

- **S3 Lifecycle Rules**:
  - **Logs/Ephemeral**: ✅ APPROVED (e.g., maintain 30-90 days of logs then delete).
  - **Data Storage**: ⚠️ RESTRICTED. Do not apply expiration rules to persistent data buckets (e.g., user uploads) without explicit "Data Loss Check" sign-off.

## 5. Operational Workflows (Standard Procedures)

Consult these approved workflows for specific operational tasks:

- **Security Audit**: `/08-audit` -> `[.agent/workflows/08-audit.md](file:///Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.agent/workflows/08-audit.md)`
- **Consistency Check**: `/cross-environment-consistency` -> `[.agent/workflows/cross-environment-consistency.md](file:///Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.agent/workflows/cross-environment-consistency.md)`
- **Image Resize Deploy**: `/09-deploy-image-resize` -> `[.agent/workflows/09-deploy-image-resize.md](file:///Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.agent/workflows/09-deploy-image-resize.md)`
- **Troubleshooting**: `/04-troubleshoot` -> `[.agent/workflows/04-troubleshoot.md](file:///Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.agent/workflows/04-troubleshoot.md)`

## 5. Key References

- **Naming Standard**: `docs/reference/NETWORK_STACK_RESOURCES.md`
- **Visual Hub**: `docs/graphs/`
- **Maintenance Prompt**: `docs/prompts/02_weekly/WEEKLY_VISUALIZATION_UPDATE.md`

## 6. Stage Safety Protocol (Cost Control)

**Status: MANDATORY**

To prevent runaway costs in non-production environments, all Agents MUST verify the following "Power of One" constraints when analyzing or modifying **Stage/Dev** infrastructure:

1.  **EC2 Capacity**: `ec2_max_size` MUST be `1` (unless running a specific temporary stress test).
2.  **NAT Strategy**: `nat_strategy` SHOULD be `NONE` (Use Public Subnets). If EC2/Private networking is required, `INSTANCE` (NAT Instance) is allowed. `GATEWAY` remains restricted.
3.  **Retention**: `enable_deletion_protection` MUST be `false`.

**Constraint Violation**: If you see `ec2_max_size > 1` in Stage, you MUST flag it as a "Cost Anomaly".

## 7. Transient Artifact Cleanup (Zero Trace Policy)

**Status: MANDATORY**

When creating temporary resources for debugging (e.g., extracting source code, dumping JSON configs, creating temp test scripts), you **MUST** ensure they are removed before completing the task.

### The Protocol:

1.  **Creation**: It is acceptable to create `temp/`, `debug/`, or `*_src/` folders for analysis.
2.  **Exclusion**: These MUST be ignored by `.gitignore` if they persist for more than one step.
3.  **Destruction**: You **MUST** delete these artifacts before declaring "Task Complete".
4.  **Verification**: Run `git status` before finishing to ensure no temporary junk is being committed.

- Committing `*.log`, `*.out`, or debugging scripts that contain hardcoded values.

## 8. Cleanup Protocol (The Law of Zero Waste)

**Status: MANDATORY**

Terraform Destroy is **NOT** enough. You MUST use the `reusable-pre-destroy-cleanup.yml` workflow before destroying any environment.

**Why?**
- **EC2 Capacity Providers**: Will hang Terraform indefinitely if not forcefully detached.
- **Launch Templates**: Will be orphaned and clutter the account.
- **Logs**: Terraform does not delete CloudWatch Log Groups by default.
- **S3 Buckets**: Non-empty buckets will cause destroy failures.

**The Rule**:
> "If you provision it, you must ensure it can be destroyed. If Terraform can't destroy it, you must script the cleanup."

---

_This document governs the interaction between Human Intent and AI Execution. Deviation results in broken pipelines._
