# AWS VPC Internet Gateway — DependencyViolation on Destroy

**Category**: AWS / Terraform Destroy  
**Severity**: High — blocks full environment teardown  
**Fixed in**: `blaze-actions v2.1.84` (`reusable-terraform.yml`)  
**Date**: 2026-05-15

---

## Symptom

`terraform destroy` (or `99-nuke-env.yml`) hangs or fails with:

```
Error: deleting EC2 VPC (vpc-xxxxxxxx): operation error EC2: DeleteVpc,
DependencyViolation: The vpc 'vpc-xxxxxxxx' has dependencies and cannot be deleted.
```

Even after `terraform state rm` of the Internet Gateway.

---

## Root Cause

`terraform state rm 'aws_internet_gateway.this'` removes TF's knowledge of the IGW  
**but does NOT delete the physical AWS resource**. The IGW remains attached to the VPC  
at the AWS API level, causing `DependencyViolation` when TF attempts to delete the VPC.

This is triggered by crash-interrupted nuke runs where the pre-destroy cleanup  
fires but the actual destroy never completes.

---

## Fix (Permanent — v2.1.84)

`reusable-terraform.yml` → `Purge Stale Network Resources` step now performs  
**two operations** on destroy:

1. **State rm** (remove TF knowledge): `terraform state rm 'aws_internet_gateway.this'`
2. **CLI detach + delete** (remove physical resource):
   ```bash
   VPC_ID=$(terraform output -raw vpc_id)
   IGW_IDS=$(aws ec2 describe-internet-gateways \
     --filters "Name=attachment.vpc-id,Values=${VPC_ID}" \
     --query 'InternetGateways[*].InternetGatewayId' --output text)
   for IGW_ID in $IGW_IDS; do
     aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
     aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"
   done
   ```

A **VPC Force-Delete Fallback** step in `verify-destroy-complete` (`99-nuke-env.yml`)  
also catches any VPCs tagged `Blaze:Environment` that survive the main destroy and  
force-deletes them post-run (v2.1.85).

---

## Manual Remediation (if caught mid-run)

```bash
# 1. Find the attached IGW
aws ec2 describe-internet-gateways \
  --filters "Name=attachment.vpc-id,Values=<VPC_ID>" \
  --query 'InternetGateways[*].InternetGatewayId' \
  --output text --region eu-west-1

# 2. Detach
aws ec2 detach-internet-gateway \
  --internet-gateway-id <IGW_ID> --vpc-id <VPC_ID> --region eu-west-1

# 3. Delete IGW
aws ec2 delete-internet-gateway --internet-gateway-id <IGW_ID> --region eu-west-1

# 4. Delete VPC
aws ec2 delete-vpc --vpc-id <VPC_ID> --region eu-west-1
```

---

## Related

- `reusable-terraform.yml` → `Purge Stale Network Resources` step (line ~1037)
- `99-nuke-env.yml` → `VPC Force-Delete Fallback` step in `verify-destroy-complete`
- `blaze-actions` CHANGELOG v2.1.84 + v2.1.85
