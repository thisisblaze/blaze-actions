# Session Handoff State

**Date/Time**: 2026-02-28T13:45:00Z

## 1. The Exact Objective

All environments (DEV, STAGE, PROD) now use a **separate API ALB** that bypasses CloudFront, resolving CORS header issues. The `dev-mini` environment is unchanged (Cloudflare Tunnel). The DEV environment is stable and mirrors STAGE/PROD.

## 2. Current Progress & Modified Files

- `blaze-terraform-infra-core`: Added `separate_api_alb` variable, dedicated API ALB resources, updated DNS wiring. Released as `v1.50.0` → `v1.50.3`.
- `blaze-template-deploy`: Enabled `separate_api_alb = true` in `dev-network`, `stage-network`, `prod-network`. Bumped module ref to `v1.50.3`. Wired `api_alb_listener_arn` in `dev-app`, `stage-app`, `prod-app`.
- All network applies completed: ✅ DEV · ✅ STAGE · ✅ PROD.
- Documentation updated across all repos.

## 3. Important Context

- `api-{stage}.domain` (Cloudflare) now points directly to the API ALB — no CloudFront.
- CORS headers from the API are no longer altered by CloudFront.
- Frontend traffic flow unchanged: CloudFront → WAF → Frontend ALB → ECS Frontend.
- `separate_api_alb = false` (default) maintains backward compatibility.

## 4. The Immediate Next Steps

1. **App stack re-deploy**: Trigger `01-provision-infra` (`stack=app`) for DEV, STAGE, PROD to wire services to `api_alb_listener_arn`.
2. **Stress test**: Run `stress-test.yml` on DEV to validate end-to-end under the new architecture.
3. **Monitor**: Check API CORS errors in browser devtools to confirm resolution.
