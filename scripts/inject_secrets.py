import os
import glob
import re

SECRETS_LIST = [
    "AWS_ROLE_ARN", "GCP_WORKLOAD_IDENTITY_PROVIDER", "GCP_SERVICE_ACCOUNT",
    "AZURE_CLIENT_ID", "AZURE_TENANT_ID", "AZURE_SUBSCRIPTION_ID",
    "CLOUDFLARE_API_TOKEN", "CLOUDFLARE_ACCOUNT_ID", "CLOUDFLARE_ZONE_ID",
    "GH_PAT", "NPM_TOKEN", "INFRACOST_API_KEY", "BLAZE_CONNECTION_STRING",
    "BLAZE_AUTH_JWT_PRIVATE_KEY", "BLAZE_AUTH_ADMIN_EMAIL", "BLAZE_AUTH_ADMIN_PASSWORD",
    "BLAZE_FILES_S3_ACCESS_KEY", "BLAZE_FILES_S3_SECRET_ACCESS_KEY",
    "BLAZE_GRAPHQL_CACHE_SETTINGS", "BLAZE_CLIENT_HEADER", "EC_API_KEY",
    "MONGODB_ATLAS_PUBLIC_KEY", "MONGODB_ATLAS_PRIVATE_KEY", "MONGODB_ATLAS_ORG_ID",
    "MONGODB_ATLAS_PROJECT_ID", "ACM_CERTIFICATE_ARN", "BLAZE_SENTRY_AUTH_TOKEN", "BLAZE_SENTRY_DSN"
]

REUSABLE_SECRETS_BLOCK = "\n".join([f"      {s}:\n        required: false" for s in SECRETS_LIST])

def process_reusable_workflow(filepath):
    print(f"Reading reusable workflow {filepath}")
    with open(filepath, 'r') as f:
        content = f.read()
    
    if "workflow_call:" not in content:
        return
        
    # check if secrets block already formally exists
    if re.search(r"workflow_call:\s+secrets:", content):
        # Already has it, skip or we could do something else. Most of them might not.
        pass
    else:
        # If there's no secrets block right under workflow_call, we just inject it.
        # Be careful to maintain YAML formatting. workflow_call: usually has inputs:
        # We can inject secrets: before inputs:
        if "    inputs:" in content:
            content = content.replace("    inputs:", f"    secrets:\n{REUSABLE_SECRETS_BLOCK}\n    inputs:")
        else:
            content = content.replace("  workflow_call:", f"  workflow_call:\n    secrets:\n{REUSABLE_SECRETS_BLOCK}")
        
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Injected secret definitions into reusable workflow: {filepath}")

def process_caller_workflow(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    def repl(match):
        indent = match.group(1)
        s_block = "\n".join([f"{indent}  {s}: ${{{{ secrets.{s} }}}}" for s in SECRETS_LIST])
        return f"{indent}secrets:\n{s_block}"

    new_content = re.sub(r"([ \t]+)secrets:\s*inherit", repl, content)
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Replaced secrets: inherit in caller workflow: {filepath}")

# 1. Process blaze-actions (reusable ones and any callers inside)
for filepath in glob.glob("/Users/marek/Workspace/thisisblaze/blaze-actions/.github/workflows/*.yml"):
    process_reusable_workflow(filepath)
    process_caller_workflow(filepath)

# 2. Process blaze-template-deploy (caller ones)
for filepath in glob.glob("/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.github/workflows/*.yml"):
    process_caller_workflow(filepath)

print("Done computing multi-repo injection.")
