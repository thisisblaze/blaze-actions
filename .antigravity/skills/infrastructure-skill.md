---
name: Infrastructure Skill
description: Enforces cross-environment consistency, naming conventions, and security best practices.
---

# Infrastructure Skill

This skill ensures that all infrastructure changes are safe, consistent, and compliant with the Blaze Architecture Standards.

## 0. Context Loading (Mandatory)

Before proceeding, you **MUST** read the governance context:
`view_file .antigravity/context/GOVERNANCE.md`

## 1. Cross-Environment Consistency (The "Mirror Rule")

-   **Stage <-> Prod**: If you fix a bug in `live/stage-network`, you MUST check `live/prod-network` and apply the equivalent fix.
-   **Dev <-> Feature**: Changes to `dev-app` must be tested with `branch_name=""` (Host) AND `branch_name="test"` (Feature Branch).

## 2. Naming Conventions

-   **Standard**: `namespace-client-project-stage-resource`
-   **Variables**:
    -   Use `var.namespace`, `var.client_key`, `var.project_key`, `var.stage_key`.
    -   **NEVER** hardcode "blaze" or "thisisblaze" unless defining the variable itself.
    -   **NEVER** hardcode regions (use `var.aws_region` or `data.aws_region.current`).

## 3. Security & Governance

-   **Secrets**:
    -   **Strict Ban**: No secrets in `*.tf`, `*.tfvars`, `*.sh`, or `*.yml`.
    -   **Allowed**: `data.aws_ssm_parameter`, `var.my_secret` (input only), or GitHub Secrets.
-   **IAM**:
    -   No `*:*` permissions.
    -   Least Privilege: Scope resources by ARN.

## 4. Pre-Commit Checklist

Before applying any Terraform change:
1.  **Validate**: `terraform validate`
2.  **Format**: `terraform fmt -recursive`
3.  **Scan**: Run `.antigravity/scripts/find-secrets.sh` to check for leaked credentials.
4.  **Plan**: Review `terraform plan` output for unintended destructions.
