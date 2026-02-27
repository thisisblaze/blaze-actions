# Analysis: Current Blue/Green Implementations & Room for Improvement

**Date:** February 2026

## 1. How Blue/Green is Currently Used

Our infrastructure achieves Blue/Green deployments by bridging **Terraform** provisioning with **GitHub Actions** orchestration, heavily relying on the classic **AWS CodeDeploy** service.

### Infrastructure Layer (Terraform `blaze-terraform-infra-core`)
- **CodeDeploy Specific Resources:** If an ECS service is attached to an ALB (i.e. `alb_listener_arn` != ""), Terraform provisions a dedicated `aws_codedeploy_app` and `aws_codedeploy_deployment_group` (`codedeploy.tf`).
- **Deployment Controller:** Inside `main.tf`, the `deployment_controller { type = "CODE_DEPLOY" }` is actively bound to the service.
- **Rollback Mechanics:** The old CodeDeploy block uses its own fallback definitions (`auto_rollback_configuration`) instead of the native ECS feature. In fact, in `main.tf`, the native `deployment_circuit_breaker` is conditionally disabled whenever `CODE_DEPLOY` is active.

### Orchestration Layer (GitHub Actions `blaze-actions`)
- **AppSpec Generation:** Inside `reusable-ecs-deploy.yml` (lines 550+), if the action detects `CODE_DEPLOY` is the controller type, it triggers a custom bash script that manually generates a raw `appspec.json` file.
- **Dangling State Cleanup:** The workflow features a brittle bash block titled `Check & Stop Active CodeDeploy` because CodeDeploy has a known issue where failed deployments can get permanently stuck in an `InProgress` state, silently blocking all future deployments. To mitigate this, our pipeline forcefully invokes `aws deploy stop-deployment` and explicitly waits for clearance.
- **Action Provider:** All this is passed to the `aws-actions/amazon-ecs-deploy-task-definition@v2` action relying directly on CodeDeploy arguments (`codedeploy-appspec`, `codedeploy-application`, etc.).

---

## 2. Room for Improvement

By leveraging the new **built-in Amazon ECS Blue/Green deployment engine (July 2025)**, practically all the custom orchestration and wrapper code can be eliminated, dramatically simplifying the CI/CD pipeline and reducing infrastructure state complexity.

### Improvement 1: Eliminate External CodeDeploy State Management
**Current:** Terraform provisions `aws_codedeploy_app`, `aws_codedeploy_deployment_group`, and `codedeploy_role_arn` mapped to discrete IAM permissions.
**Proposed:** Using the native ECS capability, we can delete the `codedeploy.tf` file completely and remove the specific CodeDeploy IAM roles. The ECS service itself will natively govern the Blue/Green target group swaps directly via its own native configurations.

### Improvement 2: Consolidate the ECS Circuit Breaker
**Current:** The ECS Circuit Breaker (which instantly rolls back failed container boots) is disabled for all Blue/Green workloads because it classically only supported rolling (`ECS`) deployments.
**Proposed:** The built-in ECS Blue/Green engine natively interacts with the deployment circuit breaker. We can merge these configurations, removing the conditional `local.controller_type == "ECS"` logic and allowing all services to safely rely on ECS's native fast-fail mechanisms.

### Improvement 3: Delete Brittle Bash Scripts `appspec.json`
**Current:** We maintain generic bash loops that generate an `appspec.json`.
**Proposed:** Native ECS Blue/Green configurations completely bypass the need for an AppSpec file (`appspec.json`) or manual CodeDeploy identifiers in GitHub Actions. The workflow can revert to a straightforward `run: aws ecs update-service` payload, removing technical debt.

### Improvement 4: Eliminate "Stuck Deployment" Pipelines
**Current:** A multi-step `aws deploy stop-deployment` script guards every single push.
**Proposed:** Because ECS Built-In Blue/Green natively executes its own timeout and CloudWatch rollback alarms within the core ECS fleet logic, "stuck" external controllers become a problem of the past. We can delete the 21 lines of custom Bash recovery code from our reusable workflow `reusable-ecs-deploy.yml`.

### Summary
Transitioning to the ECS native built-in feature cuts roughly ~150 lines of custom infrastructure and CI/CD "glue" code out of our repositories, making Blue/Green deployments behave exactly like standard rolling deployments from an operational overhead perspective.
