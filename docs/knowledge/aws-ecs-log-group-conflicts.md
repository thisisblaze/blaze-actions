# AWS ECS Log Group Conflicts

## Topic

ECS tasks hanging indefinitely in the `PENDING` state and deployments ultimately timing out (e.g., `api` deployment hanging).

## Context

When inspecting ECS task failures or using AWS CLI tools (`aws ecs describe-services`), you notice tasks dropping out before reaching `RUNNING`. The root cause is `ResourceNotFoundException: The specified log group does not exist.`.

## Root Cause

When the infrastructure module (e.g., `aws/ecs/cluster` or `aws/ecs/service`) dynamically provisions a CloudWatch log group based on standard contextual identifiers (like `namespace-client-project-stage`), but the `awslogs-group` value inside the task definition `.json` file passed to ECS differs slightly (missing a component like `client_key`).

Because the task definition references a log group that was never provisioned, the ECS agent on the Fargate or EC2 instance is unable to initialize logging for the container, preventing the container from starting.

## The Fix

Align the log group in both places:

1. Ensure the hardcoded `.json` container definitions reference the full, correct standard name: `"awslogs-group": "/ecs/${NAMESPACE}-${CLIENT_KEY}-${PROJECT_KEY}-${STAGE_KEY}"`.
2. Ensure Terraform references the standard identifier: `name = "/ecs/${module.label.id}"`.

Alternatively, you could dynamically query the created log group in Terraform and inject it into the ECS task execution role policies, but ensuring symmetric naming is usually the easiest path.
