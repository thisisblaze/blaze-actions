# Branch Protection Rules

This document outlines the strict branch protection rules enforced across the `blaze-actions` repository.

## Protected Branches

As the central CI/CD engine for the platform, the following branches are strictly protected:
- `main` (Stable workflow releases)
- `dev` (Primary development target)

## Enforced Rules

1. **No Direct Pushes**: Direct `git push origin <branch>` is blocked for all protected branches.
2. **Pull Requests Required**: All modifications to workflows or actions must be made via a feature branch and merged through a GitHub Pull Request.
3. **Approvals**: A minimum of 1 approval is required from a maintainer.
4. **Linear History Enforced**: Merge commits are forbidden. All PRs must be **Squash Merged** to maintain a clean Git history.
5. **Admin Restrictions**: These rules apply to repository administrators as well. Force pushes are explicitly denied.

## Status Checks

While strict GitHub native status checks are currently flexible to avoid blocking documentation-only PRs, all automated CI checks (such as the `06 - CI (Validate Workflows)` timeout validation and YAML syntax checks) must pass before a maintainer will approve the merge.

## Agent Guidelines

When operating via Antigravity or any other AI tool:
- You must create a feature branch (`fix/...`, `feat/...`) before making changes.
- Automated slash workflows (e.g., `/allstop`, `/01-add-workflow`) will fail if they attempt a direct `git push` on a protected branch.
- Agents should use `gh pr create` or explicitly instruct the user to do so.
