# Terraform Cloudflare DNS Provider Interoperability

## Topic

`terraform apply` fails when attempting to create network routing components (like ACM certificates or Cloudflare Pages domains) with an error resembling:
`Cloudflare DNS record already exists`

## Context

Usually happens when transitioning zones or re-provisioning test infrastructure on `stage` or `dev` domains. Terraform attempts to create a CNAME or A record that already exists on the Cloudflare dashboard manually or from a previously corrupted state.

## Root Cause

The `cloudflare_record` resource in the Cloudflare Provider v4 allowed an `allow_overwrite = true` un-documented capability that resolved these conflicts silently. In Provider v5, the resource was refactored to `cloudflare_dns_record` and explicit overwrite logic was removed.

## The Fix

You must perform a manual or automated Terraform Import prior to executing `terraform apply` when you expect a conflict.

To automate this, add logic to your deployment scripts (like `import-existing-resources.sh`) that queries the Cloudflare API for the Zone ID and Name, and directly executes a `terraform import` command on the resource address matching the state file schema if the record exists.

```bash
# General Syntax
terraform import module.frontend.cloudflare_dns_record.pages_domain_cname[0] $ZONE_ID/$RECORD_ID
```
