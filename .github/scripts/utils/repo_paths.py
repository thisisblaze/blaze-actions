#!/usr/bin/env python3
"""
Shared repo path resolver for all Blaze utility scripts.

Automatically discovers the 3 repos (blaze-template-deploy, blaze-actions,
blaze-terraform-infra-core) based on the calling script's location.

Supports two workspace layouts:
  - Symlinked (_shared/): repos are symlinked siblings
  - Flat: repos are direct siblings of the calling script's repo

Usage:
    from repo_paths import get_repos
    repos = get_repos()
    # repos["deploy"]  -> /abs/path/to/blaze-template-deploy
    # repos["actions"] -> /abs/path/to/blaze-actions
    # repos["infra"]   -> /abs/path/to/blaze-terraform-infra-core
"""
import os
import subprocess

# Canonical repo directory names
_REPO_NAMES = {
    "deploy": "blaze-template-deploy",
    "actions": "blaze-actions",
    "infra": "blaze-terraform-infra-core",
}

def _find_git_root(start_path):
    """Walk up from start_path to find the git repo root."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=start_path, capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

def get_repos(caller_file=None):
    """
    Auto-discover repo paths based on the calling script's location.
    
    Resolution order:
    1. Environment variables (BLAZE_DEPLOY_DIR, BLAZE_ACTIONS_DIR, BLAZE_INFRA_DIR)
    2. Sibling directories of the calling script's git root's parent
    3. For deploy specifically: search common workspace patterns
    
    Args:
        caller_file: __file__ of the calling script. If None, uses this file's location.
    """
    if caller_file is None:
        caller_file = __file__

    # Start from the git root of wherever this script lives
    script_dir = os.path.dirname(os.path.abspath(caller_file))
    git_root = _find_git_root(script_dir)
    
    if git_root:
        # The parent of the git root should contain sibling repos
        # For symlinked layout: git_root might be _shared/blaze-actions,
        # but the symlink parent has the workspace siblings
        workspace_root = os.path.dirname(git_root)
    else:
        workspace_root = os.path.dirname(script_dir)

    # Build candidate roots to search.
    # workspace_root is the parent of the git root (e.g. _shared/).
    # The Antigravity root (parent of _shared/) may contain the other repos.
    search_roots = [workspace_root]
    parent = os.path.dirname(workspace_root)
    if parent != workspace_root:
        search_roots.append(parent)

    repos = {}
    
    for key, dir_name in _REPO_NAMES.items():
        # 1. Check environment variable override
        env_key = f"BLAZE_{key.upper()}_DIR"
        env_val = os.environ.get(env_key)
        if env_val and os.path.isdir(env_val):
            repos[key] = env_val
            continue
        
        found = False
        for root in search_roots:
            if not os.path.isdir(root):
                continue
                
            # 2. Check as direct child of search root
            candidate = os.path.join(root, dir_name)
            if os.path.isdir(candidate):
                repos[key] = os.path.realpath(candidate)
                found = True
                break
            
            # 3. Search up to 2 levels deep
            #    e.g., thebyte9/thebyte9-blaze-template-deploy/blaze-template-deploy
            try:
                for subdir in os.listdir(root):
                    sub_path = os.path.join(root, subdir)
                    if not os.path.isdir(sub_path) or subdir.startswith('.'):
                        continue
                    nested = os.path.join(sub_path, dir_name)
                    if os.path.isdir(nested):
                        repos[key] = os.path.realpath(nested)
                        found = True
                        break
                    # One more level
                    try:
                        for subsubdir in os.listdir(sub_path):
                            deep = os.path.join(sub_path, subsubdir, dir_name)
                            if os.path.isdir(deep):
                                repos[key] = os.path.realpath(deep)
                                found = True
                                break
                    except PermissionError:
                        continue
                    if found:
                        break
            except PermissionError:
                continue
            if found:
                break
        
        if key not in repos:
            repos[key] = None
    
    return repos


def get_repo_dirs(caller_file=None):
    """
    Convenience: return (deploy_dir, actions_dir, infra_dir) tuple.
    Raises if any repo is not found.
    """
    repos = get_repos(caller_file)
    missing = [k for k, v in repos.items() if v is None]
    if missing:
        raise FileNotFoundError(
            f"Could not auto-discover repos: {missing}. "
            f"Set BLAZE_DEPLOY_DIR, BLAZE_ACTIONS_DIR, or BLAZE_INFRA_DIR env vars."
        )
    return repos["deploy"], repos["actions"], repos["infra"]


def get_all_repo_list(caller_file=None):
    """Return list of all discovered repo paths (for iteration)."""
    repos = get_repos(caller_file)
    return [v for v in repos.values() if v is not None]


if __name__ == "__main__":
    # Self-test
    repos = get_repos()
    print("Discovered repos:")
    for key, path in repos.items():
        status = "✅" if path and os.path.isdir(path) else "❌"
        print(f"  {status} {key}: {path}")
