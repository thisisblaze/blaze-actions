# Blaze Actions - Mirror Sync Setup

This repository (`thisisblaze/blaze-actions`) is the **source of truth** for all Blaze workflows and actions.

## Mirror Architecture

```
thisisblaze/blaze-actions (private)
    ↓ auto-sync on push
thebyte9/blaze-actions (private mirror)
    ↑ consumed by
thebyte9/blaze-template-deploy
```

**Why**: GitHub's reusable workflow limitation - private repos can only call workflows from same organization (without Enterprise).

## Auto-Sync Workflow

Every push to `dev` or `main` (and every tag) automatically syncs to `thebyte9/blaze-actions`.

**Workflow**: `.github/workflows/sync-to-mirror.yml`

## Setup Requirements

### 1. Create Deploy Key

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "mirror-sync" -f mirror_deploy_key -N ""

# Add PUBLIC key to thebyte9/blaze-actions
# Settings → Deploy keys → Add deploy key
# Title: "Mirror sync from thisisblaze"
# Key: [paste mirror_deploy_key.pub]
# ✅ Allow write access

# Add PRIVATE key to thisisblaze/blaze-actions
# Settings → Secrets → Actions → New repository secret
# Name: THEBYTE9_MIRROR_DEPLOY_KEY
# Value: [paste mirror_deploy_key contents]
```

### 2. Initial Mirror Sync

```bash
# Clone this repo
cd /path/to/thisisblaze/blaze-actions

# Add mirror remote
git remote add mirror git@github.com:thebyte9/blaze-actions.git

# Initial push
git push mirror dev --force
git push mirror --tags --force
```

### 3. Verify Auto-Sync

```bash
# Make a test change
echo "# Test" >> README.md
git add README.md
git commit -m "test: verify auto-sync"
git push origin dev

# Check GitHub Actions in thisisblaze/blaze-actions
# Should see "Sync to thebyte9 Mirror" workflow running

# Verify in thebyte9/blaze-actions
# Should have the same commit
```

## Usage in Template

In `thebyte9/blaze-template-deploy`, reference workflows from mirror:

```yaml
name: Deploy Infrastructure

on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, stage, prod]

jobs:
  provision:
    # ✅ Uses mirror in same org (thebyte9)
    uses: thebyte9/blaze-actions/.github/workflows/provision-infra.yml@v1
    with:
      environment: ${{ inputs.environment }}
    secrets: inherit
```

## Maintaining the Mirror

### Normal Workflow

1. Develop in `thisisblaze/blaze-actions`
2. Push to dev/main
3. Auto-sync happens automatically
4. Template uses mirror from `thebyte9/blaze-actions`

### Manual Sync (if needed)

```bash
cd /path/to/thisisblaze/blaze-actions
git push mirror dev --force
git push mirror --tags --force
```

### Troubleshooting

**Sync fails?**

1. Check deploy key has write access in thebyte9/blaze-actions
2. Verify secret `THEBYTE9_MIRROR_DEPLOY_KEY` exists in thisisblaze/blaze-actions
3. Check workflow logs in thisisblaze/blaze-actions Actions tab

**Mirror out of sync?**

```bash
# Force sync from source
cd /path/to/thisisblaze/blaze-actions
git push mirror dev --force
git push mirror main --force
git push mirror --tags --force
```

## Benefits

✅ **Keep IP private**: Source of truth in thisisblaze (your org)  
✅ **Enable reuse**: Mirror in thebyte9 (client org) for workflow calls  
✅ **Automatic**: No manual sync needed  
✅ **Version control**: Tags sync automatically  
✅ **No Enterprise needed**: Works with free GitHub
