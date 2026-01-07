---
description: Manage the auto-sync mirror to thebyte9/blaze-actions
---

# Mirror Sync Management

Auto-sync keeps `thebyte9/blaze-actions` in sync with ` this blaze/blaze-actions`.

## How It Works

```
thisisblaze/blaze-actions (push to dev/main or tag)
    ↓ triggers
.github/workflows/sync-to-mirror.yml
    ↓ pushes via SSH
thebyte9/blaze-actions (< 15 seconds)
```

## Check Sync Status

```bash
# View recent sync runs
gh run list --workflow=sync-to-mirror.yml --limit 5

# Check specific run
gh run view <run-id>
```

## Manual Sync (if needed)

// turbo

```bash
cd /path/to/this repo
git remote add mirror git@github.com:thebyte9/blaze-actions.git 2>/dev/null || true
git push mirror dev --force
git push mirror --tags --force
```

## Troubleshooting

### Sync Failed

**Check workflow logs**:

```bash
gh run view --log
```

**Common issues**:

1. **SSH key expired**

   - Regenerate deploy key
   - Update secret `THEBYTE9_MIRROR_DEPLOY_KEY`

2. **Mirror repo not accessible**

   - Check deploy key has write access
   - Verify repo exists

3. **Branch doesn't exist on mirror**
   - First push creates it automatically

### Verify Sync

```bash
# Check local commit
git log -1 --oneline

# Check mirror commit
git ls-remote git@github.com:thebyte9/blaze-actions.git dev

# Should match!
```

## Setup (if starting fresh)

See [MIRROR_SYNC.md](../MIRROR_SYNC.md) for complete setup instructions.

**Quick setup**:

1. Generate SSH key pair
2. Add public key to thebyte9/blaze-actions (deploy key, write access)
3. Add private key to thisisblaze/blaze-actions secret `THEBYTE9_MIRROR_DEPLOY_KEY`
4. Push to dev to trigger first sync

## Notes

- **Automatic on push** - No manual intervention needed
- **Fast** - Typically < 15 seconds
- **Force push** - Mirror always matches source
- **Tags sync automatically** - New releases propagate
