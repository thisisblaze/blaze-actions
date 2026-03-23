---
description: execute deep-dive troubleshooting and root cause analysis
expected_output: Root cause analysis report detailing the exact failure point and proposed fix.
exclusions: Do NOT deploy speculative fixes without user approval or moving to the fix phase.

---

> **System Context**: BEFORE executing this workflow, you MUST read and adopt the persona defined in [AGENT_PERSONA_SRE_DAEMON.md](file:///docs/prompts/AGENT_PERSONA_SRE_DAEMON.md).

1.  **Isolate Failure Layer**: Identify if the issue is in Terraform, network ingress, ECS container, or application code.
2.  **Analyze Drift**: Run `terraform plan` to identify discrepancies between code and reality.
3.  **Review System Guidelines**: Use the `grep_search` AI tool to check `docs/development_guidelines.md` for known error patterns.
4.  **Confirm Infrastructure state**:
    - **AWS**: Use `aws ecs describe-tasks` and `aws elbv2 describe-target-health` to inspect runtime state.
    - **GCP**: Use `gcloud run revisions list` and `gcloud run services describe` to inspect Cloud Run state.
    - **Azure**: Use `az containerapp revision list` to inspect Container App state.
5.  **Root Cause Identification**: Synthesize findings and identify the specific fix required.
6.  **Transition**: Hand off the diagnosis to Step 05 (Fix).
