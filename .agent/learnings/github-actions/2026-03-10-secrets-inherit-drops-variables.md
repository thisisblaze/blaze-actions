---
title: "GitHub Actions Anti-Pattern: secrets: inherit drops Context Variables"
date: "2026-03-10"
tags: ["github-actions", "secrets", "variables", "reusable-workflows"]
---

# `secrets: inherit` Drops Repository Variables

## The Problem
When calling nested reusable workflows in GitHub Actions, using `secrets: inherit` is a common shortcut to pass all repository secrets down the execution chain. However, **`secrets: inherit` ONLY passes secrets, not variables**. 

If a required context value (like `AWS_ROLE_ARN`) is defined as a **Repository Variable** rather than a **Repository Secret**, the initial workflow might correctly substitute it (e.g., `${{ secrets.AWS_ROLE_ARN || vars.AWS_ROLE_ARN }}`), but when that workflow then calls *another* nested reusable workflow using `secrets: inherit`, the variable is silently dropped. 

This results in the innermost workflow receiving an empty string or null for that input, leading to obscure failures like AWS credentials failing to load.

## Example Anti-Pattern (What NOT to do)

In a routing orchestrator (e.g., `02-deploy-app.yml`):

```yaml
  dispatch-aws:
    uses: ./.github/workflows/02-deploy-aws.yml
    with:
      environment: ${{ inputs.environment }}
    # ❌ ANTI-PATTERN: If AWS_ROLE_ARN was passed as a var to this orchestrator,
    # it gets dropped here because it's not a secret in the calling context!
    secrets: inherit
```

## The Solution (What TO do)

Always explicitly pass secrets down the workflow chain when there is any possibility that the source of truth is a variable mapped to a secret input.

```yaml
  dispatch-aws:
    uses: ./.github/workflows/02-deploy-aws.yml
    with:
      environment: ${{ inputs.environment }}
    # ✅ CORRECT: Explicitly map the secret/var down to the next level
    secrets:
      AWS_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN || vars.AWS_ROLE_ARN }}
      GCP_WORKLOAD_IDENTITY_PROVIDER: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
      GH_PAT: ${{ secrets.GH_PAT }}
      # ... other required secrets
```

## Key Takeaway
For robust CI/CD pipelines, especially in mono-repo or complex modular setups like `thisisblaze/blaze-actions`:
1. **Never use `secrets: inherit` in multi-layer workflow calls.**
2. Expose the exact secrets the child workflow needs.
3. Use the fallback pattern `${{ secrets.MY_KEY || vars.MY_KEY }}` explicitly at the call site if the value might come from a repository variable.
