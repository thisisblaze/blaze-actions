#!/usr/bin/env python3
"""
Generate Terraform import blocks for external resources (CloudWatch log groups).

This is a thin wrapper around AWS CLI to avoid bespoke bash loops. It creates an
imports file Terraform 1.5+ can consume to sync state before apply/destroy.
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, Optional


def run_command(cmd: list) -> Dict:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {' '.join(cmd)}\n{result.stderr}"
        )
    return json.loads(result.stdout or "{}")


def find_log_group(region: str, name: str) -> bool:
    """Return True if the log group exists."""
    cmd = [
        "aws",
        "logs",
        "describe-log-groups",
        "--log-group-name-prefix",
        name,
        "--query",
        "logGroups[?logGroupName==`" + name + "`].logGroupName",
        "--output",
        "text",
        "--region",
        region,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        # If permission or throttling issues occur, surface the error
        raise RuntimeError(
            f"describe-log-groups failed ({result.returncode}): {result.stderr}"
        )
    return bool(result.stdout.strip())


def pick_log_group(
    region: str, project: str, client: str, stage: str, branch: str, namespace: str
) -> Optional[str]:
    """Return the log group name to import (prefers new naming, supports branch suffix)."""
    env_handle = f"{stage}-{branch}" if branch else stage
    new_name = f"/ecs/{namespace}-{project}-{env_handle}"
    old_name = f"/ecs/{namespace}-{client}-{project}-{env_handle}"

    if find_log_group(region, new_name):
        return new_name
    if find_log_group(region, old_name):
        return old_name
    return None


def render_import_block(resource_addr: str, import_id: str) -> str:
    return f'import {{\n  to = {resource_addr}\n  id = "{import_id}"\n}}\n'


def write_import_file(path: Path, block: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(block)


def config_has_resource(tf_dir: Path, resource_addr: str) -> bool:
    """
    Heuristic: check if the resource address prefix appears in any .tf file.
    This avoids generating imports for resources not in config (e.g., feature cluster absent).
    """
    # strip any index to detect module name
    prefix = resource_addr.split(".")[0]
    for tf in tf_dir.glob("*.tf"):
        content = tf.read_text()
        if prefix in content:
            return True
    return False


def main(argv: list) -> None:
    args = parse_args(argv)

    # Pick default resource address based on branch presence when not provided
    resource_address = (
        args.resource_address
        if args.resource_address
        else (
            "module.feature_cluster[0].aws_cloudwatch_log_group.main"
            if args.branch_name
            else "module.environment_network.module.cluster.aws_cloudwatch_log_group.main"
        )
    )

    import_target = pick_log_group(
        region=args.region,
        project=args.project_key,
        client=args.client_key,
        stage=args.stage_key,
        branch=args.branch_name,
        namespace=args.namespace,
    )

    tf_dir = Path(args.output_path).parent
    if args.require_config and not config_has_resource(tf_dir, resource_address):
        print(
            f"⚠️  Skipping import generation; resource {resource_address} not found in config under {tf_dir}",
            file=sys.stderr,
        )
        return

    if not import_target:
        message = (
            f"No CloudWatch log group found for project={args.project_key}, "
            f"client={args.client_key}, stage={args.stage_key} in {args.region}"
        )
        if args.allow_missing:
            print(f"⚠️  {message}. Skipping import generation.", file=sys.stderr)
            return
        raise SystemExit(message)

    block = render_import_block(resource_address, import_target)
    write_import_file(Path(args.output_path), block)
    print(
        f"✅ Wrote import block for {import_target} -> {resource_address} "
        f"to {args.output_path}"
    )


def parse_args(argv: list) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate Terraform import blocks for log groups"
    )
    parser.add_argument("--region", required=True, help="AWS region")
    parser.add_argument("--project-key", required=True, help="Project key")
    parser.add_argument("--client-key", required=True, help="Client key")
    parser.add_argument("--stage-key", required=True, help="Stage key (e.g. dev)")
    parser.add_argument("--branch-name", default="", help="Feature branch name (optional)")
    parser.add_argument("--namespace", required=True, help="Namespace (e.g. blaze)")
    parser.add_argument(
        "--resource-address",
        default="",
        help="Terraform address to import into (auto-selects if empty)",
    )
    parser.add_argument(
        "--output-path",
        default="imports.auto.tf",
        help="Where to write the import blocks",
    )
    parser.add_argument(
        "--allow-missing",
        action="store_true",
        help="Do not fail if log group is missing; skip writing",
    )
    parser.add_argument(
        "--require-config",
        action="store_true",
        help="If set, skip writing imports when target resource is not in config",
    )
    return parser.parse_args(argv)


if __name__ == "__main__":
    main(sys.argv[1:])
