import os
import glob
import re

SECRETS_LIST = [
    "MONGO_INITDB_ROOT_PASSWORD", "BLAZE_ELASTICSEARCH_USERNAME", "BLAZE_ELASTICSEARCH_PASSWORD", "BLAZE_ELASTICSEARCH_ENDPOINT", "AWS_ROLE_ARN", "GCP_WORKLOAD_IDENTITY_PROVIDER", "GCP_SERVICE_ACCOUNT",
    "AZURE_CLIENT_ID", "AZURE_TENANT_ID", "AZURE_SUBSCRIPTION_ID",
    "CLOUDFLARE_API_TOKEN", "CLOUDFLARE_ACCOUNT_ID", "CLOUDFLARE_ZONE_ID",
    "GH_PAT", "NPM_TOKEN", "INFRACOST_API_KEY", "BLAZE_CONNECTION_STRING",
    "BLAZE_AUTH_JWT_PRIVATE_KEY", "BLAZE_AUTH_ADMIN_EMAIL", "BLAZE_AUTH_ADMIN_PASSWORD",
    "BLAZE_FILES_S3_ACCESS_KEY", "BLAZE_FILES_S3_SECRET_ACCESS_KEY",
    "BLAZE_GRAPHQL_CACHE_SETTINGS", "BLAZE_CLIENT_HEADER", "EC_API_KEY",
    "MONGODB_ATLAS_PUBLIC_KEY", "MONGODB_ATLAS_PRIVATE_KEY", "MONGODB_ATLAS_ORG_ID",
    "MONGODB_ATLAS_PROJECT_ID", "ACM_CERTIFICATE_ARN", "BLAZE_SENTRY_AUTH_TOKEN", "BLAZE_SENTRY_DSN",
    "SLACK_WEBHOOK_URL", "DEPLOY_KEY"
]

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find workflow_call block
    match = re.search(r"^([ \t]+)workflow_call:\s*\n", content, re.MULTILINE)
    if not match:
        return
        
    base_indent_str = match.group(1)
    base_indent = len(base_indent_str)
    wf_start = match.end()
    
    # Find end of workflow_call block
    lines = content[wf_start:].splitlines()
    end_idx = 0
    for line in lines:
        if not line.strip() or line.strip().startswith('#'):
            end_idx += len(line) + 1
            continue
        line_indent = len(line) - len(line.lstrip())
        if line_indent <= base_indent:
            break
        end_idx += len(line) + 1
        
    wf_block = content[wf_start:wf_start+end_idx]
    
    # Detect what indentation to use for `secrets:`
    key_indent = base_indent + 2
    inputs_match = re.search(r"^([ \t]+)inputs:\s*\n", wf_block, re.MULTILINE)
    secrets_match = re.search(r"^([ \t]+)secrets:\s*\n", wf_block, re.MULTILINE)
    
    if secrets_match:
        key_indent = len(secrets_match.group(1))
    elif inputs_match:
        key_indent = len(inputs_match.group(1))

    ind1 = " " * key_indent
    ind2 = " " * (key_indent + 2)
    ind3 = " " * (key_indent + 4)
    
    full_secrets = f"{ind1}secrets:\n" + "\n".join([f"{ind2}{s}:\n{ind3}required: false" for s in SECRETS_LIST]) + "\n"
    
    if secrets_match:
        # Replace existing
        s_start = secrets_match.start()
        s_lines = wf_block[s_start+len(secrets_match.group(0)):].splitlines()
        s_end_offset = len(secrets_match.group(0))
        for line in s_lines:
            if not line.strip() or line.strip().startswith('#'):
                s_end_offset += len(line) + 1
                continue
            line_indent = len(line) - len(line.lstrip())
            if line_indent <= key_indent:
                break
            s_end_offset += len(line) + 1
            
        new_wf_block = wf_block[:s_start] + full_secrets + wf_block[s_start+s_end_offset:]
    else:
        # Insert
        if inputs_match: # insert before inputs
            new_wf_block = wf_block[:inputs_match.start()] + full_secrets + wf_block[inputs_match.start():]
        else: # insert at start
            new_wf_block = full_secrets + wf_block
            
    if new_wf_block != wf_block:
        new_content = content[:wf_start] + new_wf_block + content[wf_start+end_idx:]
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated secrets block in {filepath}")

for filepath in glob.glob(".github/workflows/*.yml"):
    process_file(filepath)

print("Done")
