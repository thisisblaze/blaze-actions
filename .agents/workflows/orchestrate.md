---
description: 🤖 Context Commander — read high-level intent prompt, chain sub-workflows, and execute autonomous multi-agent validation loops.
expected_output: Autonomous sequence execution of analysis, testing, and troubleshooting workflows culminating in a final success state or structured exception.
exclusions: Do NOT bypass user confirmation on Terraform Apply. The self-healing loop operates on Plans and Tests, but destructive writes always require consent.
role: 🧑‍💼 PM / Tech Lead
---

# /orchestrate — Context Commander

> [!TIP]
> **Status: SCALED (Multi-Tenant V2)**. This orchestrator sits at the top of the AI governance model.

This is the primary Context Commander loop. When given a declarative goal (e.g., "deploy and fix any issues", "analyse the cloudfront cache and verify"), this workflow chains the specialised 5-role sub-agents together without requiring manual re-prompting on failures.

## 1. Intent Analysis
1. Parse the user's high-level goal.
2. Determine which sub-workflows are required.
3. Map out the sequence. Example:
   - `/01-analyze` (PM)
   - `/05-fix` (Engineer)
   - `/02-test` (QA)

## 2. Execution Loop
For each sub-workflow in the sequence:
1. Load and execute the workflow instructions.
2. If the workflow succeeds, move to the next.
3. **If the workflow fails** (e.g., test fails, terraform plan fails), activate the **Self-Healing Loop**:
   - Check `.agents/config.yml` under `on_failure` for the mapping.
   - Automatically execute the recovery workflow (e.g., `/04-troubleshoot`).
   - Re-attempt the failed workflow up to 3 times.
   - If it fails 3 times, break the loop and notify the user.

## 3. Playbook Pattern Capture
If a complex orchestration sequence succeeds (especially one involving self-healing), record the sequence into the auto-learning system (`.agents/learnings/patterns/`) under the `playbook-pattern` category.

## 4. Final Notification
> 💡 **Antigravity 2.0**: Present the final orchestration summary using an artifact with `RequestFeedback=false`.
> 💡 **Claude Code**: Print the final orchestration summary to the terminal.
