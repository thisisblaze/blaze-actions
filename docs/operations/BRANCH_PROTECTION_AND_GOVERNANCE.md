# Branch Protection & Governance

## Overview
As of June 2026, strict branch protection and PR-only workflows are enforced across all core repositories (`dev`, `stage`, and `main` branches). Direct pushes are actively blocked by GitHub API rules.

## Rules
1. **No Direct Pushes**: All changes must be submitted via Pull Request.
2. **Linear History**: Merge commits are banned; all PRs must be squashed or rebased.
3. **No Force Pushes**: History rewriting on protected branches is strictly prohibited.
4. **Mandatory Reviews**: All code must be reviewed and approved via the PR process before merging.

## Automated Agents
AI Coding Assistants and CI/CD tools must respect these boundaries. If a direct push fails with `GH006`, the agent must fall back to a branch-and-PR strategy using the `/submit-pr` workflow or equivalent GitHub CLI commands (`gh pr create`).

