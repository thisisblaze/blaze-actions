# Session Handoff State

**Date/Time**: 2026-02-28T23:20:00Z

## 1. The Exact Objective

Validate the newly provisioned **separate API CloudFront distribution** for the `dev` environment by running the stress test (`🧪 Stress Test` workflow on DEV), then apply the same `v1.50.8` changes to STAGE and PROD if DEV passes.

## 2. Current Progress & Modified Files

- `blaze-terraform-infra-core @ v1.50.8`: Released. Added `module "cloudfront_api"` to `environment-network` — provisions a dedicated CloudFront distribution for API traffic when `separate_api_alb = true`. DNS record `cloudflare_dns_record.api` now points to the API CloudFront domain instead of the shared distribution.
- `blaze-template-deploy` → `dev-network/main.tf`: On `ref=v1.50.8` with `separate_api_alb = true` and `enable_cloudfront = true`. **Applied successfully** (run #426, 2026-02-28T23:13–23:17Z).
- No uncommitted local changes.

## 3. Important Context

- `dev` now has **two separate CloudFront distributions**: one for Frontend, one for API.
- The API CloudFront uses `CachingDisabled` + `AllViewer` origin request policy — no caching, all headers forwarded.
- `stage` and `prod` are NOT yet bumped to `v1.50.8` — they are still on an earlier ref. They should be updated once DEV stress test passes.
- `dev-mini` uses Cloudflare Tunnel — no CloudFront involved, do NOT touch it.
- The stress test workflow is called `🧪 Stress Test` in `blaze-template-deploy`. Its inputs likely include `environment` (use `dev`).
- Workflow history was cleared previously — there is no prior stress test run to reference for `dev` under this architecture.

## 4. The Immediate Next Steps

1. **Run stress test**: Trigger `🧪 Stress Test` workflow in `blaze-template-deploy` with `environment=dev`. Watch for all jobs to pass ("full circle").
2. **Verify AWS Console**: Confirm two CloudFront distributions exist for `dev` (one frontend, one API). Check Cloudflare DNS `api-dev.*` points to the API CloudFront `*.cloudfront.net`.
3. **Bump STAGE**: Update `stage-network/main.tf` to `ref=v1.50.8`, trigger `01 - Provision Infrastructure` (env=stage, stack=network, apply=true).
4. **Bump PROD**: Same as STAGE but for `prod-network/main.tf`.
5. **Update HANDOFF** after stress test results are known.
