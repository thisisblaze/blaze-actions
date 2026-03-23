---
description: Test Terraform modules locally before releasing
expected_output: Clear local validation and test output for discrete Terraform modules.
exclusions: Do NOT deploy the module to a live cloud environment during unit testing.

---

# Test Terraform Module Locally

Follow these steps to test changes to a Terraform module locally before pushing to GitHub.

## 1. Setup Local Environment Variables

Export the necessary `TF_VAR_` environment variables to simulate the inputs that GitHub Actions would provide.

```bash
export TF_VAR_client_key="{client}"
export TF_VAR_project_key="{project}"
export TF_VAR_stage="stage"  # or 'dev'
export TF_VAR_namespace="blaze"
export TF_VAR_aws_region="eu-west-1" # Match your target region (AWS)
# For GCP modules: export TF_VAR_gcp_region="europe-west1"
# For Azure modules: export TF_VAR_azure_location="westeurope"
export TF_VAR_domain_root="example.com"

# Mock sensitive variables if needed (or verify via 1Password if real access is needed)
export TF_VAR_cloudflare_api_token="dummyvalue"
export TF_VAR_cloudflare_account_id="dummyvalue"
export TF_VAR_cloudflare_zone_id="dummyvalue"
```

## 2. Authenticate to AWS

Ensure you are authenticated to the correct AWS account.

```bash
# Example for Stage
export AWS_PROFILE={client}-blaze-dev-admin
aws sts get-caller-identity # Verify identity
```

## 3. Initialize with Remote State (Upgrade Modules)

Go to the `live` directory that uses the module you modified.

```bash
cd .github/aws/infra/live/stage-network
# OR
cd .github/aws/infra/live/stage-app
# For GCP: cd .github/gcp/infra/live/dev-network
# For Azure: cd .github/azure/infra/live/dev-network
```

Run `init` with `-upgrade` to fetch your local changes if you are pointing to a local source, OR if you pushed to `dev` branch, this pulls the latest `dev`.

> **Tip:** To test _purely_ locally without pushing, modify the `source` in `main.tf` to point to your local directory:
> `source = "../../../../../../../../blaze-terraform-infra-core/modules/aws/networking/environment-network"`

```bash
terraform init -upgrade -reconfigure \
    -backend-config="bucket={client}-stage-blaze-tfstate" \
    -backend-config="key=infra/{project}/stage/network.tfstate" \
    -backend-config="region=eu-west-1" \
    -backend-config="dynamodb_table=" \
    -backend-config="use_lockfile=false"
```

## 4. Plan and Verify

Run `terraform plan` to see what would change.

```bash
terraform plan
```

- **Check Output:** Look for replacements (`-/+`) or changes (`~`).
- **Verify Names:** Ensure resource names matched expected patterns (e.g. `blaze-...`).
- **Validate Logic:** Ensure conditional resources are created/destroyed as expected.

## 5. (Optional) Validation

Run built-in validation.

```bash
terraform validate
```
