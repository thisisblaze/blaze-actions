#!/usr/bin/env python3
import os
import re
import subprocess
import sys

def get_latest_tag():
    repo_url = "https://github.com/thisisblaze/blaze-terraform-infra-core.git"
    gh_pat = os.getenv("GH_PAT")
    if gh_pat:
        repo_url = f"https://x-access-token:{gh_pat}@github.com/thisisblaze/blaze-terraform-infra-core.git"
    try:
        output = subprocess.check_output(["git", "ls-remote", "--tags", repo_url], text=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running git ls-remote: {e}", file=sys.stderr)
        sys.exit(1)

    tags = []
    for line in output.strip().split("\n"):
        if not line:
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        ref = parts[1]
        if ref.startswith("refs/tags/") and not ref.endswith("^{}"):
            tag = ref.replace("refs/tags/", "")
            if re.match(r"^v?\d+\.\d+\.\d+$", tag):
                tags.append(tag)

    if not tags:
        print("No valid semver tags found.", file=sys.stderr)
        sys.exit(1)

    def semver_key(tag):
        cleaned = tag.lstrip('v')
        return [int(x) for x in cleaned.split('.')]

    tags.sort(key=semver_key)
    return tags[-1]

def bump_files(latest_version):
    print(f"Latest version found: {latest_version}")
    
    pattern = re.compile(
        r'(github\.com/thisisblaze/blaze-terraform-infra-core(?:\.git)?//modules/[^\s"?]+)\?ref=(v\d+\.\d+\.\d+)'
    )

    updated_files = []

    for root, _, files in os.walk("."):
        # Skip dot-directories
        if any(part.startswith('.') and part not in ('.', '.github') for part in root.split(os.sep)):
            continue
        
        for file in files:
            if not file.endswith(".tf"):
                continue
            
            filepath = os.path.join(root, file)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
            except Exception as e:
                print(f"Error reading {filepath}: {e}", file=sys.stderr)
                continue

            new_content = content
            matches = pattern.findall(content)
            
            if not matches:
                continue

            changed = False
            for base_url, current_version in matches:
                if current_version != latest_version:
                    old_str = f"{base_url}?ref={current_version}"
                    new_str = f"{base_url}?ref={latest_version}"
                    new_content = new_content.replace(old_str, new_str)
                    print(f"Updating {filepath}: {current_version} -> {latest_version}")
                    changed = True

            if changed:
                try:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    updated_files.append(filepath)
                except Exception as e:
                    print(f"Error writing to {filepath}: {e}", file=sys.stderr)

    if not updated_files:
        print("All files are already up-to-date.")
    else:
        print(f"Successfully updated {len(updated_files)} file(s).")

if __name__ == "__main__":
    latest = get_latest_tag()
    bump_files(latest)
