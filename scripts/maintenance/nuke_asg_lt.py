#!/usr/bin/env python3
"""Delete an ASG and its Launch Template — tag-validated, no hardcoded names (plan 163 O5).

Both the ASG and the Launch Template must carry a matching Blaze:Project +
Blaze:Environment tag before anything is deleted, so a name collision across
accounts/envs can never nuke the wrong resources.

Usage:
  nuke_asg_lt.py --asg-name NAME --lt-name NAME --project PROJECT --environment ENV [--region eu-west-1]
Env fallbacks: AWS_REGION, BLAZE_ASG_NAME, BLAZE_LT_NAME, BLAZE_PROJECT, BLAZE_ENVIRONMENT
"""
import argparse
import os
import sys
import time
import boto3


def parse_args():
    p = argparse.ArgumentParser(description="Nuke a Blaze ASG + Launch Template (tag-validated).")
    p.add_argument("--asg-name", default=os.environ.get("BLAZE_ASG_NAME"))
    p.add_argument("--lt-name", default=os.environ.get("BLAZE_LT_NAME"))
    p.add_argument("--project", default=os.environ.get("BLAZE_PROJECT"))
    p.add_argument("--environment", default=os.environ.get("BLAZE_ENVIRONMENT"))
    p.add_argument("--region", default=os.environ.get("AWS_REGION", "eu-west-1"))
    a = p.parse_args()
    missing = [n for n in ("asg_name", "lt_name", "project", "environment") if not getattr(a, n)]
    if missing:
        p.error("missing required values: " + ", ".join(missing)
                + " (pass as flags or BLAZE_* env vars)")
    return a


def require_tags(found_proj, found_env, want_proj, want_env, what):
    if found_proj != want_proj or found_env != want_env:
        print(f"❌ ERROR: tag mismatch on {what} — refusing to delete (fail closed).")
        print(f"   expected Blaze:Project={want_proj} Blaze:Environment={want_env}")
        print(f"   found    Blaze:Project={found_proj} Blaze:Environment={found_env}")
        sys.exit(1)


def main():
    args = parse_args()
    autoscaling = boto3.client("autoscaling", region_name=args.region)
    ec2 = boto3.client("ec2", region_name=args.region)

    groups = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[args.asg_name]
    )["AutoScalingGroups"]

    if groups:
        asg = groups[0]
        tags = {t["Key"]: t["Value"] for t in asg.get("Tags", [])}
        require_tags(tags.get("Blaze:Project"), tags.get("Blaze:Environment"),
                     args.project, args.environment, f"ASG '{args.asg_name}'")
        print(f"✅ ASG tag check passed. Deleting ASG: {args.asg_name}")
        try:
            instance_ids = [i["InstanceId"] for i in asg.get("Instances", [])]
            if instance_ids:
                print(f"Disabling scale-in protection on {instance_ids}")
                autoscaling.set_instance_protection(
                    InstanceIds=instance_ids,
                    AutoScalingGroupName=args.asg_name,
                    ProtectedFromScaleIn=False,
                )
            print("Deleting ASG forcefully...")
            autoscaling.delete_auto_scaling_group(
                AutoScalingGroupName=args.asg_name, ForceDelete=True
            )
            print("ASG deletion initiated. Waiting for ASG to be fully deleted...")
            while autoscaling.describe_auto_scaling_groups(
                AutoScalingGroupNames=[args.asg_name]
            )["AutoScalingGroups"]:
                print("Still deleting...")
                time.sleep(10)
            print("ASG fully deleted.")
        except Exception as e:
            print(f"ASG Error: {e}")
            return 1
    else:
        print(f"ℹ️  ASG '{args.asg_name}' not found; skipping ASG delete.")

    # Validate the Launch Template's tags before deleting it.
    lts = ec2.describe_launch_templates(
        Filters=[{"Name": "launch-template-name", "Values": [args.lt_name]}]
    ).get("LaunchTemplates", [])
    if not lts:
        print(f"ℹ️  Launch Template '{args.lt_name}' not found; nothing to do.")
        return 0
    lt_tags = {t["Key"]: t["Value"] for t in lts[0].get("Tags", [])}
    require_tags(lt_tags.get("Blaze:Project"), lt_tags.get("Blaze:Environment"),
                 args.project, args.environment, f"Launch Template '{args.lt_name}'")
    print(f"✅ LT tag check passed. Deleting Launch Template: {args.lt_name}")
    try:
        ec2.delete_launch_template(LaunchTemplateName=args.lt_name)
        print("Launch template deleted.")
        return 0
    except Exception as e:
        print(f"LT Error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
