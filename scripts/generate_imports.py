import argparse
import boto3
import sys
import os

def generate_import_block(resource_address, resource_id):
    """
    Generates a Terraform 1.5+ import block.
    """
    return f"""
import {{
  to = {resource_address}
  id = "{resource_id}"
}}
"""

def main():
    parser = argparse.ArgumentParser(description="Generate Terraform imports for existing CloudWatch Log Groups")
    parser.add_argument("--region", required=True, help="AWS Region")
    parser.add_argument("--project-key", required=True, help="Project Key (e.g. b9)")
    parser.add_argument("--client-key", required=True, help="Client Key (e.g. thisisblaze)")
    parser.add_argument("--stage-key", required=True, help="Stage Key (dev, stage, prod)")
    parser.add_argument("--branch-name", help="Feature Branch Name (optional)")
    parser.add_argument("--namespace", required=True, help="Namespace (e.g. blaze)")
    parser.add_argument("--resource-address", required=True, help="Terraform Resource Address")
    parser.add_argument("--allow-missing", action="store_true", help="Don't fail if log group doesn't exist")
    parser.add_argument("--require-config", action="store_true", help="Legacy flag (ignored)")

    args = parser.parse_args()

    # Determine Environment Handle
    # Logic: If branch_name is set, env_handle = "{stage_key}-{branch_name}"
    #        Else, env_handle = "{stage_key}"
    if args.branch_name:
        env_handle = f"{args.stage_key}-{args.branch_name}"
    else:
        env_handle = args.stage_key

    # Construct Log Group Name matches modules/aws/ecs/cluster behavior
    # name = "/ecs/{namespace}-{project}-{env_handle}"
    log_group_name = f"/ecs/{args.namespace}-{args.project_key}-{env_handle}"

    print(f"🔍 Checking for Log Group: {log_group_name} in {args.region}...")

    # Check existence in AWS
    logs_client = boto3.client("logs", region_name=args.region)
    
    try:
        # describe_log_groups returns a list, filter by specific namePrefix
        # We use exact match check after retrieval because namePrefix is a prefix
        response = logs_client.describe_log_groups(
            logGroupNamePrefix=log_group_name,
            limit=1
        )
        
        exists = False
        if "logGroups" in response:
            for lg in response["logGroups"]:
                if lg["logGroupName"] == log_group_name:
                    exists = True
                    break
        
        if exists:
            print(f"✅ Log Group found: {log_group_name}")
            import_block = generate_import_block(args.resource_address, log_group_name)
            
            # Write to imports.tf
            with open("imports.tf", "a") as f:
                f.write(import_block)
            
            print(f"📝 Added import block to imports.tf for {args.resource_address}")
            
        else:
            print(f"ℹ️  Log Group {log_group_name} does not exist. Terraform will create it.")
            if not args.allow_missing:
                # If we strictly expected it, we could exit 1, but usually for imports 
                # we just want to import IF it exists to avoid collision.
                pass

    except Exception as e:
        print(f"❌ Error checking Log Group: {str(e)}")
        # If allow-missing/soft-fail is preferred
        if not args.allow_missing:
            sys.exit(1)

if __name__ == "__main__":
    main()
