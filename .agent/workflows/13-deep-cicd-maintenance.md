---
description: 🧹 Deep CI/CD Maintenance — strictly align ops code, documentation, agent workflows, and timestamps across all 4 repos.
expected_output: Synchronized operations code, workflows, and action timings across all 4 repos.
exclusions: Do NOT modify the terraform modules or stack topologies during CI/CD maintenance.
role: 🔧 Engineer

---


**Last Updated**: 2026-05-27

# Deep CI/CD Maintenance Sync

This is a master command to actively perform deep maintenance across all **four** infrastructure repositories. Unlike `/checkengines` (which is read-only) and `/allstop` (which is a fast daily sync), this workflow **actively analyzes** CI/CD definitions and forces documentation, AI prompts, and agent workflows to match reality perfectly.

**STRICT RULE 1: YOU MUST NOT TOUCH ANY APPLICATION CODE. Do NOT modify any files within the `blaze-` project folders (e.g., `blaze-frontend`, `blaze-api`, `blaze-admin`) under any circumstances.**
**STRICT RULE 2: ABSOLUTELY NO MASS DATE BUMPING. Do NOT write scripts that blindly update `Last Updated` strings across all files. You MUST read the file contents, compare them with the actual `.github/workflows/*.yml` code, identify architectural or input drift, and fix the content. You may only update the timestamp of a file AFTER you have actively analyzed its content and confirmed it matches the true CI/CD state.**

## Repositories in Scope

- `blaze-template-deploy`: `blaze-template-deploy (sibling directory)` — private, Terraform state + triggers
- `blaze-actions`: `blaze-actions (this repo)` — **public**, reusable workflows
- `blaze-terraform-infra-core`: `blaze-terraform-infra-core (sibling directory)` — private, Terraform modules
- `blaze-conductor`: `blaze-conductor (sibling directory)` — private, MCP servers + orchestrators

> [!CAUTION]
> `blaze-actions` is **PUBLIC**. Do NOT add `ANTHROPIC_API_KEY`, `blaze-conductor` checkouts, or any MCP references to it. All conductor code lives in `blaze-template-deploy` only.

---

## Phase 1: Code vs. Docs Alignment (blaze-actions)

1. **Analyze True State**:
   - Scan `.github/workflows/*.yml` in `blaze-actions`.
   - Identify any added, removed, or heavily modified workflows (inputs/outputs/secrets).
2. **Sync `WORKFLOW_CATALOG.md`**:
   - Check `docs/WORKFLOW_CATALOG.md`.
   - Add missing workflows.
   - Remove deleted workflows.
   - Synchronize all YAML `inputs:` descriptions.
3. **Sync `REUSABLE_WORKFLOWS.md`**:
   - Check `docs/REUSABLE_WORKFLOWS.md`.
   - Ensure the calling patterns matching the current `inputs:` definitions of reusable `.yml` workflows are correct.

## Phase 2: Agent Workflows & Prompts Sync (All Repos)

1. **Review Agent Commands**:
   - Scan `.agent/workflows/*.md` across all 4 repos.
   - **Deep Analysis Required**: Read the agent workflow files and compare them against the actual GitHub Actions. Are the `gh workflow run` commands still passing the correct inputs? Are they referencing workflows that still exist? Fix any drift.
   - Specifically verify: all "4 repos" references have been updated to "4 repos" in agent workflows.
2. **Review AI Prompts**:
   - In `blaze-template-deploy`, review `docs/prompts/00_core/` files and other prompt directories.
   - **Deep Analysis Required**: Read the prompts. Do they accurately reflect how CI/CD currently works (e.g., native ECS blue/green, newest multi-cloud pipelines, changes to stress testing)? If the pipeline has evolved, update the prompt to teach the AI the new reality.

## Phase 3: Deep Timestamp Sync (All Repos)

Any file that receives a material update to its content during this sync MUST have its timestamp updated.

1. **Find Timestamps**: Run grep to locate files with timestamps across `docs/`, `governance/`, and `.agent/` folders:
   ```bash
   grep -riE "Last Updated|Updated:" docs/ .agent/
   ```
2. **Enforce Freshness via Verification**:
   - You are **forbidden** from writing a python or bash script to find and replace dates globally.
   - For each file you identified, you must briefly verify its claims against the codebase.
   - If the instructions or architecture described in a file have changed recently, fix the content, then update the timestamp string to today's date (`YYYY-MM-DD`).
   - Treat "Last Updated: 2026-05-09" as a hard requirement for all modified files.

## Phase 4: Global Changelog Compilation

1. **Scan Recent Commits**: Use `git log` to find unreleased CI/CD changes across all 4 repositories (`blaze-template-deploy`, `blaze-actions`, `blaze-terraform-infra-core`, `blaze-conductor`).
2. **Update `CHANGELOG.md`**: In each repository, ensure these architectural and pipeline changes are accurately summarized under the `[Unreleased]` heading.

## Phase 5: Report Output

Upon completion, generate a summary table detailing what was updated:

```
🧹 DEEP CI/CD MAINTENANCE REPORT — <YYYY-MM-DD>

| Area | Repo | Files Modified | Action Taken |
| :--- | :--- | :--- | :--- |
| CI/CD Documentation | actions | [list] | Synced inputs & catalogs |
| Agent Workflows | [repo] | [list] | Fixed outdated references |
| Timestamps | all | [list] | Updated Last Updated dates |
| Changelogs | all | [list] | Added unreleased CI/CD notes |

"A system perfectly aligned requires no force to maintain." 🖖
```

---

## Multi-Project Awareness (April 2026)

The platform now supports multiple projects on the shared ECS cluster. When performing deep CI/CD maintenance:

1. **Verify multi-project readiness** in `calculate-config` and `deploy-ecs-service` actions:
   - `calculate-config`: reads `vars/${project}/blaze-env.json` — confirm it accepts arbitrary `project` values (not just `thisisblaze`)
   - `deploy-ecs-service`: URL construction logic — verify `FRONTEND_URL` resolves correctly for `support` project (same `DOMAIN_ROOT`, different slug)

2. **Check reusable workflows** for hardcoded `thisisblaze` references:
   - `reusable-stress-test-deploy.yml`
   - `reusable-stress-test-provision.yml`

3. **Active projects**: `thisisblaze` (primary), `support` (Phase 3 active)

Reference: `docs/plans/134_multi_tenant_multi_domain_expansion_aws.md`
