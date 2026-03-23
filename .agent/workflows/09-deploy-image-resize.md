---
description: Deploy and verify CloudFront image resize functionality
expected_output: Verified Lambda@Edge distribution logic for CloudFront image resizing.
exclusions: Do NOT modify root DNS or other independent CDN settings.

---

# Deploy Image Resize

Quick guide for deploying or troubleshooting CloudFront image resize in STAGE environment.

## Current Working Configuration (v30)

- **CloudFront Distribution**: `{distribution_id}` (`cdn-stage.example.com`)
- **Lambda Version**: v30 (18.5MB with Linux Sharp binaries)
- **S3 Bucket**: `blaze-{client}-{project}-stage-image-resize`
- **Path Pattern**: `/convert/*`
- **Status**: ✅ WORKING

## Quick Test

```bash
# Test image resize
curl "https://cdn-stage.example.com/convert/sample.jpg?w=400&h=400" -o test.webp
file test.webp
# Expected: Web/P image data
```

## Prerequisites

```bash
# 1. Check module version in blaze-terraform-infra-core
cd /Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core
git branch
# Should be on: dev (with latest fixes)

# 2. Verify Lambda code has callback pattern
Use the `view_file` AI tool on `modules/aws/lambda/edge-functions/functions/resize-image/index.js` to read the `exports.handler` configuration.
# Should see: (event, context, callback) =>
```

## Deploy from Scratch

### 1. Enable Feature in Terraform

```hcl
# In stage-network/main.tf
enable_image_resize = true
# sharp_layer_arn removed (handled automatically)
```

### 2. Run Provision Workflow

```bash
gh workflow run 01-provision-infra.yml \
  --repo thebyte9/blaze-template-deploy \
  -f environment=STAGE \
  -f stack=network \
  -f action=apply
```

This workflow will **automatically**:

1. Build Sharp dependencies for Linux x64 in a Docker container.
2. Package the Lambda function.
3. Deploy the CloudFront distribution with **OAC** (Origin Access Control).
4. Apply the correct S3 bucket policies.

### 3. Clear Cache and Test

```bash
# Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id E2KX2LJ3H7LDMZ \
  --paths "/convert/*" \
  --profile {client}-blaze-dev-admin

# Test (wait 10 seconds for propagation)
sleep 10
# Arbitrary dimensions now allowed!
curl "https://cdn-stage.example.com/convert/media/sample.jpg?w=123" -o test.webp

# Verify
file test.webp
# Expected: Web/P image data
```

## Troubleshoot Common Issues

### Issue 1: 503 ERROR - "Lambda function is invalid"

**Cause**: Sharp binaries missing or wrong architecture.
**Fix**: Re-run the `01-provision-infra.yml` workflow. It self-heals by rebuilding valid Linux binaries.

### Issue 2: S3 Access Denied (403)

**Cause**:

1. CloudFront Origin missing OAC.
2. Lambda role missing `s3:ListBucket`.

**Fix**: Re-run `01-provision-infra.yml`. It applies the correct `environment-network` module policies automatically.

### Issue 4: Slow First Request (12-15s)

**This is normal!** Lambda cold start.

## Verification Checklist

- [ ] CloudFront distribution uses OAI/OAC
- [ ] Lambda v31+ with Linux Sharp binaries
- [ ] Lambda uses callback pattern
- [ ] S3 permissions configured (including ListBucket)
- [ ] Logic strips `/convert/` prefix correctly
- [ ] Test URL returns WebP image

## Allowed Dimensions

**Dynamic!** (Arbitrary WxH allowed)

## Rollback

```hcl
# In stage-network/main.tf
enable_image_resize = false
```

```bash
terraform apply
# Note: Lambda deletion takes 2-6 hours (AWS edge replication)
```

## Related Documentation

- **Troubleshooting**: [blaze-terraform-infra-core/docs/architecture/TROUBLESHOOTING-IMAGE-RESIZE.md](file:///Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core/docs/architecture/TROUBLESHOOTING-IMAGE-RESIZE.md)
- **Architecture**: [blaze-terraform-infra-core/docs/architecture/CLOUDFRONT-IMAGE-RESIZE.md](file:///Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core/docs/architecture/CLOUDFRONT-IMAGE-RESIZE.md)
- **Lambda README**: [blaze-terraform-infra-core/modules/aws/lambda/edge-functions/functions/resize-image/README.md](file:///Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core/modules/aws/lambda/edge-functions/functions/resize-image/README.md)
- **Walkthrough**: [Session Artifacts walkthrough.md](file:///Users/marek/.gemini/antigravity/brain/d4c2c52b-4949-4c22-99cf-51e966c76706/walkthrough.md)
