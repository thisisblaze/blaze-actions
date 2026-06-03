# MongoDB Atlas — GROUP_NOT_FOUND on Terraform Destroy

**Category**: MongoDB Atlas / Terraform Destroy  
**Severity**: High — blocks environment teardown  
**Fixed in**: `blaze-actions v2.1.84` (`mongodb/pre-destroy.sh`)  
**Date**: 2026-05-15

---

## Symptom

`terraform destroy` on a MongoDB Atlas stack fails with:

```
Error: error reading MongoDB Atlas Project (6a065298a1c2b19656835825): GET
https://cloud.mongodb.com/api/atlas/v1.0/groups/6a065298a1c2b19656835825: 404
GROUP_NOT_FOUND Group 6a065298a1c2b19656835825 not found.
```

Or `pre-destroy.sh` fails when trying to disable termination protection.

---

## Root Cause

The Atlas project ID stored in Terraform state refers to a project that no longer  
exists in Atlas (deleted out-of-band, or reprovisioned with a new ID after a  
crash-interrupted deploy). Terraform cannot reconcile this — it tries to read  
the project via the old ID and gets a 404.

Common triggers:
- Laptop crash mid-nuke → project deleted by partial destroy but state not cleaned
- Manual Atlas console deletion
- Environment reprovision that creates a new project (new ID) while old state persists

---

## Fix (Permanent — v2.1.84)

`mongodb/pre-destroy.sh` now runs a **Stale Project Guard** before any Atlas API calls:

```bash
PROJECT_CHECK_HTTP=$(curl -s --digest -u "${PUBLIC_KEY}:${PRIVATE_KEY}" \
  "https://cloud.mongodb.com/api/atlas/v2/groups/${PROJECT_ID}" \
  -H "Accept: application/vnd.atlas.2023-01-01+json" \
  -w "%{http_code}" -o /tmp/project_check.json)

PROJECT_ERROR_CODE=$(jq -r '.errorCode // empty' /tmp/project_check.json)

if [[ "$PROJECT_CHECK_HTTP" == "404" || "$PROJECT_ERROR_CODE" == "GROUP_NOT_FOUND" ]]; then
  # Purge all Atlas + Cloudflare DNS records from state — clean no-op destroy
  terraform state list | grep 'mongodbatlas_' | while read ADDR; do
    terraform state rm "$ADDR"
  done
  terraform state list | grep 'cloudflare_dns_record\.' | while read ADDR; do
    terraform state rm "$ADDR"
  done
  exit 0  # destroy is now a clean no-op
fi
```

---

## Manual Remediation (if caught mid-run)

```bash
# 1. Confirm project 404
curl -s --digest -u "$PUBLIC_KEY:$PRIVATE_KEY" \
  "https://cloud.mongodb.com/api/atlas/v2/groups/$PROJECT_ID" \
  -H "Accept: application/vnd.atlas.2023-01-01+json" | jq .errorCode

# 2. Remove stale Atlas resources from state
terraform state list | grep 'mongodbatlas_' | while read ADDR; do
  terraform state rm "$ADDR"
done

# 3. Also remove any stale Cloudflare records
terraform state list | grep 'cloudflare_dns_record\.' | while read ADDR; do
  terraform state rm "$ADDR"
done

# 4. Re-run destroy — it will be a clean no-op
```

---

## Related

- `mongodb/pre-destroy.sh` → Stale Project Guard section
- `blaze-actions` CHANGELOG v2.1.84
- Companion issue: CF DNS 404 on multi-site-app destroy (`cloudflare_dns_record.site[*]`)
