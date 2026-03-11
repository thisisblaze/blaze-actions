# Session Handoff State

**Date/Time**: 2026-03-11T11:29:43Z

## 1. The Exact Objective

Resolve critical `02-deploy-app.yml` pipeline failures across AWS and standard environments due to (1) Lerna workspace environments dropping NPM private registry auth (`404 Not Found`) and (2) GitHub Actions cancelling pipelines due to Node 20 runner deprecations inside internal AWS plugins.

## 2. Current Progress & Modified Files

- `blaze-actions/.github/workflows/reusable-docker-build.yml`: Refactored `docker/build-push-action` to supply `.npmrc` as a `secret-file` rather than a standard string array, guaranteeing physical file propagation.
- `blaze-template-deploy/packages/*/Dockerfile.*`: Restored explicit `COPY --from` and `.npmrc` injection logic directly preceding `lerna bootstrap` in the `builder` blocks.
- `blaze-template-deploy/docs/operations/development_guidelines.md`: Added standard backstop documenting why Node 24 Action enforcement is now required.
- **Global Actions YAML Patch**: Injected `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` natively into the `env:` blocks of > 80 workflow files across `blaze-actions`, `blaze-template-deploy`, and `blaze-terraform-infra-core` to forcefully suppress the Node 20 deprecation aborts.

## 3. Important Context

- *Context on Bug:* The original `npm 404 Not Found` errors for `@blaze-cms` packages happened because Docker build containers lost the `.npmrc` environment. Fixing it required injecting the registry token natively. The pipeline cancel issue was traced separately to GitHub enforcing Node 20 deprecations (June 2026) early on un-patched actions like `amazon-ecr-login` and `download-artifact`.
- *Testing Context:* The `02-deploy-app.yml` pipeline (`22949446303`) just successfully ran from end to end. The Docker images `amd64` and `arm64` successfully built via Lerna, multi-arch manifests merged, and ECS services stabilized perfectly.
- A final `/06-finalize` execution produced a thorough `/walkthrough.md` report of the incident. The workspace temporary files have been cleaned.

**ENV Comparison Report Status** (`docs/reports/ENV_COMPARISON_AWS.md`):

- Open 🔴 action items: None checked in this session.
- WAF policy: CloudFront-only (stage/prod). ALBs are internal.
- NAT policy: GATEWAY when >5 services, NONE otherwise.
- Redis: prod-only. Prod Redis must be on private subnets (not public).

## 4. The Immediate Next Steps

1. Review the successfully deployed environments (Dev ECS/Pages) from the latest `22949446303` execution.
2. Proceed with normal infrastructure feature development or initiate `/checkengines` to verify the state of the workspace on a new day.
