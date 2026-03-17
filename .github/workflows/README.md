---
Last Updated: 2026-03-17
Owner: Infrastructure Team
---

# Blaze Actions Workflows

## ⚠️ Important Usage Warning

**DO NOT RUN THESE WORKFLOWS DIRECTLY IN THIS REPOSITORY.**

This repository (`blaze-actions`) serves as a shared library of Reusable Workflows and Actions. It **does not** contain the necessary secrets (`AWS_ROLE_ARN`, `CLOUDFLARE_API_TOKEN`, etc.) or environment configurations required to provision actual infrastructure.

## How to Deploy

All deployments should be triggered from your project repository (e.g., `blaze-template-deploy`).

### Correct Workflow:
1. Go to your project repo (e.g., `blaze-template-deploy`).
2. Navigate to **Actions**.
3. Select the **01 - Provision Infrastructure** workflow.
4. Run the workflow with the desired inputs.

That workflow will internally call the reusable workflows defined here in `blaze-actions`, passing the correct secrets from your project's environment.
