# Terraform State Checksum Mismatch and Drift

## Topic

`terraform plan` fails instantly with an error indicating an inconsistency between the AWS S3 state file and the DynamoDB lock table checksums.

`Error: checksum mismatch: state in S3 has MD5 hash <xyz>, but DynamoDB lock item has MD5 hash <abc>`

## Context

During concurrent executions, aborted CI/CD pipelines, or race-conditions where Terrafrom gets forcefully killed mid-execution, the `terraform.tfstate` might be updated in the S3 bucket, but the metadata release hook that updates the DynamoDB locking table was not executed or failed.

## Root Cause

The current contents of the state file no longer accurately reflect the metadata hashed inside the active lock object, leading Terraform to abort to prevent data corruption.

## The Fix

If the state file in S3 was definitively written successfully (no partial corruptions), the fix is to break the DynamoDB lock and allow the next clean execution to re-hash the state properly.

1. Locate the stuck lock ID from the error message.
2. Execute `terraform force-unlock -force <LOCK_ID>`.
3. If executed through automation, use a script that pulls the state file digest, pulls the DynamoDB lock digest, and explicitly invokes `force-unlock` if they do not match.

**Warning:** Always ensure no other developers or CI pipelines are actively running Terraform on this environment before unlocking, otherwise a true corruption event will occur.
