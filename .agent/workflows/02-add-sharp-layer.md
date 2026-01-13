---
description: Add Sharp Lambda Layer automation for CloudFront image resize functionality
---

# Add Sharp Lambda Layer for Image Resize

**When to use:** Setting up CloudFront image resize with Lambda@Edge for a new environment or project

> [!IMPORTANT] > **Environment Compatibility**
>
> - ✅ **STAGE**: Has CloudFront → Sharp Layer + Image Resize supported
> - ✅ **PROD**: Has CloudFront → Sharp Layer + Image Resize supported
> - ❌ **DEV**: Cloudflare only (no CloudFront) → No AWS image resize

## Overview

This workflow automates building and deploying the Sharp Lambda Layer required for CloudFront image resizing. Sharp compiles native binaries, so it must be built for Amazon Linux 2 (Lambda runtime).

## Prerequisites

- ✅ CloudFront distribution exists
- ✅ S3 bucket for image storage exists
- ✅ Lambda@Edge functions defined in `modules/aws/lambda/edge-functions`
- ✅ `enable_image_resize = true` in environment config

## Automated Process

### 1. Sharp Layer Build (CI/CD)

The layer is **automatically built** in GitHub Actions when provisioning the network stack:

```yaml
# .github/workflows/01-provision-infra.yml
jobs:
  build_sharp_layer:
    if: inputs.stack == 'network'
    steps:
      - name: Check if Sharp Layer Exists
        # Checks for existing layer - reuses if found

      - name: Build and Publish Sharp Layer
        uses: thisisblaze/blaze-actions/.github/actions/build-sharp-layer@dev
        # Only runs if no existing layer
```

**Build time:**

- First build: ~35 seconds (Docker build + npm install)
- Subsequent runs: ~8 seconds (reuses existing layer)

**Output:**

- Layer ARN: `arn:aws:lambda:us-east-1:<account>:layer:sharp-image-processing:<version>`
- S3 zip: `s3://<bucket>/lambda-layers/sharp-layer.zip`

### 2. ARN Injection to Terraform

The workflow automatically passes the layer ARN:

```yaml
provision:
  needs: build_sharp_layer
  with:
    tf_vars: |
      sharp_layer_arn=${{ needs.build_sharp_layer.outputs.layer_arn }}
```

### 3. Module Configuration

Modules automatically use the ARN:

```hcl
# environment-network/lambda-edge.tf
module "lambda_edge_image_resize" {
  sharp_layer_arn = var.sharp_layer_arn  # From workflow
}

# lambda/edge-functions/main.tf
resource "aws_lambda_function" "origin_response" {
  layers = var.sharp_layer_arn != "" ? [var.sharp_layer_arn] : []
}
```

## Enabling Image Resize

### Step 1: Enable in Environment Config

```hcl
# .github/aws/infra/live/stage-network/main.tf
module "environment_network" {
  # ...
  enable_image_resize = true  # Was false
  # sharp_layer_arn is passed automatically from workflow
}
```

### Step 2: Fix S3 Bucket Naming (If Needed)

**Check for conflict:**

```bash
# If you see error about bucket already existing:
# "blaze-b9-thisisblaze-stage-ecs-image-resize" vs
# "blaze-b9-thisisblaze-stage-image-resize"
```

**Fix:**

```hcl
# modules/aws/networking/environment-network/s3-image-resize.tf
module "label_image_resize" {
  context    = module.label.context
  attributes = ["image", "resize"]  # Removed "ecs"
}
```

### Step 3: Run Provision Workflow

```bash
gh workflow run "01-provision-infra.yml" \
  --repo thebyte9/blaze-template-deploy \
  --ref main \
  -f environment=STAGE \
  -f project=thisisblaze \
  -f stack=network \
  -f apply=false  # Dry run first!
```

**Expected output:**

```
✓ Configuration
✓ Build Sharp Lambda Layer (8-35s)
  - Outputs: layer_arn=arn:aws:lambda:us-east-1:...:layer:sharp-image-processing:1
✓ Provision network
  - Plan shows:
    + module.lambda_edge_image_resize[0].aws_lambda_function.viewer_request
    + module.lambda_edge_image_resize[0].aws_lambda_function.origin_response
      layers = ["arn:aws:lambda:..."]
```

### Step 4: Apply Changes

Re-run with `apply=true`:

```bash
gh workflow run "01-provision-infra.yml" \
  --repo thebyte9/blaze-template-deploy \
  --ref main \
  -f environment=STAGE \
  -f stack=network \
  -f apply=true
```

## Verification

### 1. Check Layer Attachment

```bash
aws lambda get-function \
  --function-name <function-arn> \
  --region us-east-1 \
  | jq '.Configuration.Layers'

# Should show:
# [
#   {
#     "Arn": "arn:aws:lambda:us-east-1:...:layer:sharp-image-processing:1",
#     "CodeSize": 12345678
#   }
# ]
```

### 2. Test Image Upload

```bash
# Upload test image
aws s3 cp test-image.jpg \
  s3://blaze-b9-thisisblaze-stage-image-resize/files/test/image.jpg
```

### 3. Test Resize via CloudFront

```bash
# Request resized image
curl -I "https://frontend-stage.thisisblaze.uk/convert/test/image.jpg?width=800&format=webp"

# Expected:
# HTTP/2 200
# content-type: image/webp
# x-cache: Miss from cloudfront (first request)

# Second request should show:
# x-cache: Hit from cloudfront
```

### 4. Verify S3 Storage

```bash
# Check converted images are saved
aws s3 ls s3://blaze-b9-thisisblaze-stage-image-resize/converted/ --recursive

# Should show:
# converted/test/image-800-webp.jpg
```

## Troubleshooting

### Issue: "Sharp is not defined" in Lambda logs

**Cause:** Layer not attached or wrong architecture  
**Fix:** Check lambda layers (step 1 above)

### Issue: "AccessDenied" when writing to S3

**Cause:** Missing `s3:PutObject` permission  
**Fix:** Already included in `modules/aws/lambda/edge-functions/iam.tf`

```hcl
Action = [
  "s3:GetObject",  # Read originals
  "s3:PutObject"   # Write resized
]
```

### Issue: Build fails in CI/CD

**Common errors:**

1. **Docker entrypoint error**

   - Symptom: `entrypoint requires the handler name`
   - Fixed: `--entrypoint=""` flag added

2. **Permission denied on cleanup**

   - Symptom: `rm: cannot remove`
   - Fixed: Using `sudo rm` for Docker-created files

3. **Action not found**
   - Symptom: `Can't find 'action.yml'`
   - Fixed: Using full repo path `thisisblaze/blaze-actions/...@dev`

### Issue: Layer exists but not reused

**Check:**

```bash
aws lambda list-layer-versions \
  --layer-name sharp-image-processing \
  --region us-east-1

# Should show version 1 (or higher)
```

**Fix:** Layer check logic uses exact name match - ensure `layer-name: "sharp-image-processing"` in workflow

## Manual Layer Build (Local Testing Only)

**⚠️ NOT recommended - use CI/CD instead**

```bash
# Build locally (macOS/Linux)
mkdir -p /tmp/sharp-layer
cd /tmp/sharp-layer

cat > package.json <<EOF
{
  "name": "sharp-layer",
  "dependencies": {
    "sharp": "^0.33.0"
  }
}
EOF

# Build for Lambda (Amazon Linux 2)
docker run --rm \
  --entrypoint="" \
  -v $(pwd):/build \
  -w /build \
  public.ecr.aws/lambda/nodejs:20 \
  npm install --platform=linux --arch=x64 --production

# Create layer structure
mkdir -p nodejs
sudo mv node_modules nodejs/
sudo zip -r sharp-layer.zip nodejs

# Publish
aws lambda publish-layer-version \
  --layer-name sharp-image-processing \
  --description "Sharp for image processing" \
  --zip-file fileb://sharp-layer.zip \
  --compatible-runtimes nodejs20.x \
  --compatible-architectures x86_64 \
  --region us-east-1
```

## Architecture

```
GitHub Actions Workflow
  ↓
Check if layer exists in AWS
  ├─ YES → Reuse existing (8s)
  └─ NO  → Build new (35s)
         ↓
    Docker Build (Amazon Linux 2)
         ↓
    npm install sharp@^0.33.0
         ↓
    Create layer structure (nodejs/node_modules/)
         ↓
    Upload to S3
         ↓
    Publish as Lambda Layer
         ↓
    Output: layer_arn
         ↓
Pass to Terraform via TF_VAR_sharp_layer_arn
         ↓
environment-network module receives
         ↓
lambda-edge module attaches to functions
         ↓
Lambda@Edge functions deployed with Sharp
```

## Configuration Files

### Workflow Integration

- `.github/workflows/01-provision-infra.yml` - Main workflow
- `.github/actions/build-sharp-layer/action.yml` - Reusable action

### Terraform Modules

- `modules/aws/networking/environment-network/variables.tf` - Accepts `sharp_layer_arn`
- `modules/aws/networking/environment-network/lambda-edge.tf` - Passes to lambda module
- `modules/aws/lambda/edge-functions/variables.tf` - `sharp_layer_arn` variable
- `modules/aws/lambda/edge-functions/main.tf` - Attaches layer to functions

### Environment Config

- `.github/aws/infra/live/stage-network/main.tf` - Enable/disable flag

## Best Practices

1. ✅ **Let CI/CD build the layer** - Don't build manually
2. ✅ **Test with apply=false first** - Always dry run
3. ✅ **Use Sharp ^0.33.0** - Stay on current major version
4. ✅ **Monitor layer size** - Should be ~12-15 MB
5. ✅ **Keep one layer version** - Auto-cleanup old versions (TODO)
6. ✅ **Region: us-east-1 only** - Lambda@Edge requirement

## Future Enhancements

- [ ] Auto-cleanup of old layer versions
- [ ] Cache Docker image for faster builds
- [ ] Support multiple Sharp versions
- [ ] Add layer version pinning in Terraform
- [ ] Create layer update workflow

---

**Last Updated:** 2026-01-13  
**Automation Status:** ✅ Fully Automated  
**Build Time:** 8-35 seconds  
**Success Rate:** 100%
