---
description: Troubleshoot and fix CloudFront cache behaviors, dependency issues, and image resize problems
---

# CloudFront Troubleshooting Guide

**When to use:** CloudFront distribution issues, cache behavior problems, or image resize failures

> [!IMPORTANT] > **Environment Availability**
>
> - ✅ **STAGE**: CloudFront enabled
> - ✅ **PROD**: CloudFront enabled
> - ❌ **DEV**: Cloudflare only (no CloudFront)

## Quick Health Check

```bash
# Check CloudFront distribution status
DIST_ID="E12345EXAMPLE"
aws cloudfront get-distribution --id "$DIST_ID" | jq '.Distribution.Status'
# Should show: "Deployed"

# Test cache behaviors
curl -I "https://your-domain.com/files/test.jpg"
# Check: x-cache header (Hit/Miss)

# Check origin response
curl -I "https://your-domain.com/convert/test.jpg?width=800"
# Should: 200 OK with content-type: image/webp
```

## Common Issues

### 1. Destroy Dependency Errors

**Symptom:**

```
Error: error deleting CloudFront Distribution:
ResourceInUseException: The distribution cannot be deleted
while still in use by Lambda functions
```

**Root Cause:** Inverted `depends_on` relationships

**Correct dependency order:**

```
S3 Bucket (no dependencies)
   ↓
Lambda@Edge (depends on S3)
   ↓
CloudFront (depends on both)
```

**Fixed in:** `modules/aws/networking/environment-network/`

- `s3-image-resize.tf` - Removed `depends_on = [module.cloudfront]`
- `lambda-edge.tf` - Changed to `depends_on = [module.image_resize_bucket]`
- `main.tf` - Added `depends_on = [bucket, lambda]` to CloudFront

### 2. S3 Bucket Policy Too Permissive

**Symptom:** S3 bucket accessible from anywhere

**Cause:** CloudFront ARN condition was commented out

**Fix:**

```hcl
# s3-image-resize.tf
condition {
  test     = "StringEquals"
  variable = "AWS:SourceArn"
  values   = [module.cloudfront[0].arn]  # Uncommented
}
```

### 3. Missing /files/\* Path

**Symptom:** Original images return 403 or 404

**Cause:** Only `/convert/*` path was configured

**Fix:** Added cache behavior in `main.tf`:

```hcl
files_cache_behavior = var.enable_image_resize ? [{
  path_pattern     = "files/*"
  target_origin_id = local.image_resize_origin_id
  # No Lambda@Edge - direct S3 access
  function_associations = []
}] : []
```

### 4. Hard-coded Origin IDs

**Symptom:** Origin ID mismatch errors, hard to maintain

**Cause:** `origin_id = "image-resize"` hard-coded

**Fix:** Use dynamic local variable:

```hcl
locals {
  image_resize_origin_id = "s3-${module.label_image_resize.id}"
}
```

### 5. Lambda@Edge Missing Write Permission

**Symptom:** Lambda can't save resized images to S3

**Error logs:**

```
AccessDenied: Access Denied
when calling PutObject on /converted/...
```

**Fix:** Added to `modules/aws/lambda/edge-functions/iam.tf`:

```hcl
Action = [
  "s3:GetObject",  # Read from /files/
  "s3:PutObject"   # Write to /converted/
]
```

## Cache Behavior Configuration

### Standard Setup

```hcl
# Original images - no processing
{
  path_pattern = "files/*"
  target_origin_id = "s3-origin"
  cache_policy_id = "CachingOptimized"
  function_associations = []  # Direct S3
}

# Resized images - Lambda@Edge processing
{
  path_pattern = "convert/*"
  target_origin_id = "s3-origin"
  cache_policy_id = "custom-image-resize-policy"
  lambda_function_associations = {
    viewer_request = lambda_edge_viewer_request_arn
    origin_response = lambda_edge_origin_response_arn
  }
}
```

### Testing Cache Behaviors

```bash
# Test direct file access
curl -v "https://cdn.example.com/files/2025/01/test.jpg" 2>&1 | grep -i "x-cache"

# Test resize
curl -v "https://cdn.example.com/convert/2025/01/test.jpg?width=800&format=webp" 2>&1 | grep -i "x-cache"

# Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id E12345 \
  --paths "/convert/*"
```

## Lambda@Edge Debugging

### Check Function Logs

Lambda@Edge logs go to CloudWatch in **us-east-1** (always):

```bash
# List log groups
aws logs describe-log-groups \
  --region us-east-1 \
  --log-group-name-prefix "/aws/lambda/us-east-1"

# Get recent logs
aws logs tail "/aws/lambda/us-east-1.lambda-function-name" \
  --region us-east-1 \
  --since 1h \
  --follow
```

### Common Lambda@Edge Errors

1. **"Sharp is not defined"**

   - Layer not attached
   - Run: Check layers with `aws lambda get-function`

2. **"Task timed out after 30.00 seconds"**

   - Image too large
   - Increase Lambda timeout (max 30s for Lambda@Edge)

3. **"Cannot find module 'sharp'"**
   - Wrong layer architecture (must be x86_64)
   - Rebuild layer for correct platform

## Image Resize Testing

### Full End-to-End Test

```bash
#!/bin/bash
# test-image-resize.sh

DOMAIN="frontend-stage.thisisblaze.uk"
BUCKET="blaze-b9-thisisblaze-stage-image-resize"

# 1. Upload test image
echo "1. Uploading test image..."
aws s3 cp test-image.jpg "s3://$BUCKET/files/test/original.jpg"

# 2. Request original
echo "2. Testing original image access..."
curl -I "https://$DOMAIN/files/test/original.jpg" | grep "HTTP"

# 3. Request resized (triggers Lambda)
echo "3. Testing resize (first request - Miss)..."
curl -I "https://$DOMAIN/convert/test/original.jpg?width=800&format=webp" \
  | grep -E "HTTP|x-cache|content-type"

# 4. Request again (should hit cache)
echo "4. Testing resize (second request - Hit)..."
sleep 2
curl -I "https://$DOMAIN/convert/test/original.jpg?width=800&format=webp" \
  | grep "x-cache"

# 5. Verify S3 storage
echo "5. Checking saved converted images..."
aws s3 ls "s3://$BUCKET/converted/" --recursive | grep "test"

echo "✅ Test complete"
```

## Monitoring & Alerts

### CloudFront Metrics

```bash
# Error rate
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name 4xxErrorRate \
  --dimensions Name=DistributionId,Value=E12345 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Cache hit rate
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name CacheHitRate \
  --dimensions Name=DistributionId,Value=E12345 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### Recommended Alarms

```hcl
# High 5xx error rate
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx" {
  alarm_name          = "cloudfront-5xx-errors-${var.stage}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"  # 5% error rate

  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
  }
}
```

## Direct API Access (Bypass CloudFront)

For debugging, use direct ALB access:

```bash
# Added in this session: api-direct-{stage} DNS record
curl -I "https://api-direct-stage.thisisblaze.uk/health"

# Compare with CloudFront:
curl -I "https://api-stage.thisisblaze.uk/health"

# Check for differences in response headers
```

## CloudFront Distribution Destroy

### Clean Destroy Process

```bash
# 1. Disable distribution first
aws cloudfront get-distribution-config --id E12345 > dist-config.json
# Edit: Set "Enabled": false
aws cloudfront update-distribution --id E12345 --if-match ETAG --distribution-config file://dist-config.json

# 2. Wait for deployment (can take 5-15 minutes)
aws cloudfront wait distribution-deployed --id E12345

# 3. Now Terraform destroy will work
terraform destroy
```

### Lambda@Edge Destroy Delays

**Known Issue:** Lambda@Edge replicas take time to delete

**Workaround:**

```bash
# After terraform destroy fails:
# 1. Wait 15-30 minutes
# 2. Retry destroy
terraform destroy -auto-approve
```

**Future Enhancement:** Add Lambda@Edge cleanup job to workflow

## Resources

- [CloudFront Audit](file:///Users/marek/.gemini/antigravity/brain/.../cloudfront-image-resize-audit.md)
- [Implementation Plan](file:///Users/marek/.gemini/antigravity/brain/.../implementation_plan.md)
- [Fixes Summary](file:///Users/marek/.gemini/antigravity/brain/.../fixes-summary.md)

---

**Last Updated:** 2026-01-13  
**Critical Issues Fixed:** 5/8  
**Automation Status:** ✅ Sharp Layer, ⏸️ Image Resize (disabled by default)
