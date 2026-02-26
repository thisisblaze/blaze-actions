# Session Handoff State

**Date/Time**: 2026-02-26T16:30:00Z

## 1. The Exact Objective

Shift focus entirely to AWS tasks. We are explicitly splitting AWS from Azure and pausing all Azure work for today. The sole focus is configuring and continuing the infrastructure and automation setup for AWS.

## 2. Current Progress & Modified Files

- Previously monitored `full-circle` stress tests on `dev` for both `aws` (stage) and `azure` (dev).
- Azure showed Docker build errors, but those are suspended for now. 
- AWS stress test failed early on an AWS credentials/OIDC trust issue within GitHub Actions.

## 3. Important Context

- **AWS ONLY Mode**: Do not engage in Azure tasks today. Focus 100% on the single AWS hosting environment.
- **AWS CLI Conventions**: When interacting with AWS infrastructure from the terminal, you **MUST** use the AWS CLI with your appropriate developer profile (e.g., using `--profile YOUR_AWS_PROFILE` or exporting `AWS_PROFILE=YOUR_AWS_PROFILE`).
- **GitHub CLI Conventions**: Use the `gh` CLI strictly for querying runs, triggers, and logs.

## 4. The Immediate Next Steps

1. Continue with the AWS hosting setup on the current machine.
2. Resolve the AWS credentials/OIDC failure blocking the AWS workflows. Use `AWS_PROFILE=YOUR_AWS_PROFILE` to inspect AWS IAM OIDC roles if necessary.
3. Proceed with the planned AWS-specific deployments and tasks.
