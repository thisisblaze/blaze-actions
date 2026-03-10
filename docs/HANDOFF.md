# Session Handoff State

**Date/Time**: 2026-03-10T11:00:46Z

## 1. The Exact Objective

Resolve Lerna npm 404 errors during Docker build steps in Azure deployments by correctly passing `NODE_AUTH_TOKEN` from GitHub actions down to Docker `build-args`.

## 2. Current Progress & Modified Files

- `blaze-actions/.github/workflows/reusable-docker-build.yml`: Modified to pass `NODE_AUTH_TOKEN` explicitly via `build-args` for both amd64 and arm64 `docker/build-push-action` steps instead of using `--mount=type=secret,id=npmrc`.
- `blaze-actions/.github/workflows/02-deploy-[aws/azure/gcp/pages].yml`: Restored `registry-url: 'https://registry.npmjs.org/'` in `actions/setup-node` tasks and removed manual `.npmrc` creation logic. Fixed `if:` conditional syntax errors injected during refactoring.
- `blaze-template-deploy/packages/api/Dockerfile.api`: Replaced `secret` mount with `ARG NODE_AUTH_TOKEN` and `ENV NODE_AUTH_TOKEN=$NODE_AUTH_TOKEN`.
- `blaze-template-deploy/packages/frontend/Dockerfile.frontend`: Replaced `secret` mount with `ARG NODE_AUTH_TOKEN` and `ENV NODE_AUTH_TOKEN=$NODE_AUTH_TOKEN`.

## 3. Important Context

- *Context on Bug:* Lerna suppresses `NPM_CONFIG_USERCONFIG` or `~/.npmrc` files mounted during Docker builds natively. Explicitly creating an environment variable `NODE_AUTH_TOKEN` before the `lerna bootstrap` call is the only native workaround that passes NPM Auth tokens to its sub-processes.
- *Testing Context:* The Azure pipeline is currently running **Stress Test Run 19** to test the Dockerfile fixes. `dispatch-pages` (which runs on standard GitHub runners, not Docker builds) already confirmed to work properly with just `actions/setup-node`.
- *Wait state:* A running terminal command `gh run watch` is actively monitoring Run 19.

**ENV Comparison Report Status** (`docs/reports/ENV_COMPARISON_AWS.md`):

- Open 🔴 action items: None checked in this session.
- WAF policy: CloudFront-only (stage/prod). ALBs are internal.
- NAT policy: GATEWAY when >5 services, NONE otherwise.
- Redis: prod-only. Prod Redis must be on private subnets (not public).

## 4. The Immediate Next Steps

1. Wait for and review the completion of Azure Stress Test Run 19, specifically the `dispatch-azure` Docker build jobs.
2. Ensure Docker builds for `amd64` and `arm64` succeed without Lerna 404 Auth failures.
3. Verify that the subsequent Azure Container Apps deployments successfully complete.
