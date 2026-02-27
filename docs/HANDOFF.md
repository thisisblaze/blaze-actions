# Session Handoff State

**Date/Time**: 2026-02-27T01:57:58Z

## 1. The Exact Objective

The immediate goal is to successfully execute the generic `mode=standard` stress test for the `stage` AWS environment (`blaze-api-stage-app`). The environment was failing on CodeDeploy Application creation because zombie CodeDeploy applications were not being cleaned up by the pre-destroy actions, causing an `ApplicationAlreadyExistsException` on recreation.

## 2. Current Progress & Modified Files

- `.github/workflows/reusable-pre-destroy-cleanup.yml`: Fixed the pre-destroy logic to explicitly delete zombie CodeDeploy applications ending in `-${STAGE_KEY}-app` before destroying the environment's ECS cluster components (PR #4 & PR #5 fixing CLI syntax to `aws deploy`). These fixes are merged into the `dev` branch.
- `docs/HANDOFF.md`: Updated to freeze the current session state.

## 3. Important Context

- A `mode=destroy-only` stress test (#22466435280) is currently running on the `stage` environment to properly clean out existing AWS resources, including the zombie CodeDeploy application `blaze-api-stage-app`.
- The `deploy` AWS CLI command had to be used, not `codedeploy`.
- We are working on cleaning the `stage` environment before attempting the `mode=standard` stress-test. `dev` is already up and stable.

## 4. The Immediate Next Steps

1. Wait for workflow `#22466435280` (`destroy-only`) to complete and verify the tear-down of `stage` resources.
2. Run a standard `stage` stress test using `gh workflow run stress-test.yml -f environment=stage -f target_type=host -f mode=standard --ref dev` from the `blaze-template-deploy` repository.
3. Validate that the Provision App/Terraform completes successfully and the CodeDeploy application is cleanly created and deployed securely.
