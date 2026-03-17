---
description: 🧹 Deep CI/CD Maintenance — strictly align ops code, documentation, agent workflows, and timestamps across all 3 repos.
---

**Last Updated**: 2026-03-16

# Deep CI/CD Maintenance Sync

This is a master command to actively perform deep maintenance across all three infrastructure repositories. Unlike `/checkengines` (which is read-only) and `/allstop` (which is a fast daily sync), this workflow **actively analyzes** CI/CD definitions and forces documentation, AI prompts, and agent workflows to match reality perfectly.

**STRICT RULE 1: YOU MUST NOT TOUCH ANY APPLICATION CODE. Do NOT modify any files within the `blaze-` project folders (e.g., `blaze-frontend`, `blaze-api`, `blaze-admin`) under any circumstances.**
**STRICT RULE 2: ABSOLUTELY NO MASS DATE BUMPING. Do NOT write scripts that blindly update `Last Updated` strings across all files. You MUST read the file contents, compare them with the actual `.github/workflows/*.yml` code, identify architectural or input drift, and fix the content. You may only update the timestamp of a file AFTER you have actively analyzed its content and confirmed it matches the true CI/CD state.**

## Repositories in Scope

- `blaze-template-deploy`: `/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy`
- `blaze-actions`: `/Users/marek/Workspace/thisisblaze/blaze-actions`
- `blaze-terraform-infra-core`: `/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core`

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
   - Scan `.agent/workflows/*.md` across all 3 repos.
   - **Deep Analysis Required**: Read the agent workflow files and compare them against the actual GitHub Actions. Are the `gh workflow run` commands still passing the correct inputs? Are they referencing workflows that still exist? Fix any drift.
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
   - If the file is genuinely perfectly up to date, you may update the timestamp manually to certify it was audited today.
   - Treat "Last Updated: 2026-03-17

## Phase 4: Global Changelog Compilation

1. **Scan Recent Commits**: Use `git log` to find unreleased CI/CD changes across the 3 repositories.
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
