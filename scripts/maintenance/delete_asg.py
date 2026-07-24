#!/usr/bin/env python3
"""Delete an Auto Scaling Group — tag-validated, no hardcoded names (plan 163 O5).

Selection is by exact ASG name AND a mandatory Blaze:Project + Blaze:Environment
tag match, so a name collision across accounts/envs can never delete the wrong ASG.

Usage:
  delete_asg.py --asg-name NAME --project PROJECT --environment ENV [--region eu-west-1]
Env fallbacks: AWS_REGION, BLAZE_ASG_NAME, BLAZE_PROJECT, BLAZE_ENVIRONMENT
"""
import argparse
import os
import sys
import boto3


def parse_args():
    p = argparse.ArgumentParser(description="Delete a Blaze ASG (tag-validated).")
    p.add_argument("--asg-name", default=os.environ.get("BLAZE_ASG_NAME"))
    p.add_argument("--project", default=os.environ.get("BLAZE_PROJECT"))
    p.add_argument("--environment", default=os.environ.get("BLAZE_ENVIRONMENT"))
    p.add_argument("--region", default=os.environ.get("AWS_REGION", "eu-west-1"))
    a = p.parse_args()
    missing = [n for n in ("asg_name", "project", "environment") if not getattr(a, n)]
    if missing:
        p.error("missing required values: " + ", ".join(missing)
                + " (pass as flags or BLAZE_* env vars)")
    return a


def tags_to_dict(asg):
    return {t["Key"]: t["Value"] for t in asg.get("Tags", [])}


def main():
    args = parse_args()
    autoscaling = boto3.client("autoscaling", region_name=args.region)

    groups = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[args.asg_name]
    )["AutoScalingGroups"]
    if not groups:
        print(f"ℹ️  ASG '{args.asg_name}' not found in {args.region}; nothing to do.")
        return 0
    asg = groups[0]

    # Fail closed: refuse unless the ASG is tagged for the requested project + env.
    tags = tags_to_dict(asg)
    proj, env = tags.get("Blaze:Project"), tags.get("Blaze:Environment")
    if proj != args.project or env != args.environment:
        print("❌ ERROR: tag mismatch — refusing to delete (fail closed).")
        print(f"   expected Blaze:Project={args.project} Blaze:Environment={args.environment}")
        print(f"   found    Blaze:Project={proj} Blaze:Environment={env}")
        return 1

    print(f"✅ Tag check passed. Deleting ASG: {args.asg_name}")
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
        print("ASG deleted.")
        return 0
    except Exception as e:
        print(f"Error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
