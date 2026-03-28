import os
import re
import shutil

REPOS = [
    "/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy",
    "/Users/marek/Workspace/thisisblaze/blaze-actions",
    "/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core"
]

def main():
    print("Replacing @dev tags with @v1.4.30 in workflows...")
    for repo in REPOS:
        for root, dirs, files in os.walk(os.path.join(repo, '.github')):
            for file in files:
                if file.endswith('.yml') or file.endswith('.yaml'):
                    p = os.path.join(root, file)
                    with open(p, 'r') as f:
                        c = f.read()

                    pattern = r'(uses:\s*thisisblaze/blaze-actions/(?:\.github/workflows|\.github/actions)/[^@\n]+)@dev'
                    new_c, cnt = re.subn(pattern, r'\1@v1.4.30', c)

                    if cnt > 0:
                        with open(p, 'w') as f:
                            f.write(new_c)
                        print(f"Updated {cnt} occurrence(s) in {p}")

    print("\nSyncing workflow parity (Engine 8)...")
    source = "/Users/marek/Workspace/thisisblaze/blaze-terraform-infra-core/.github/workflows/90-daily-health-check.yml"
    dest1 = "/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy/.github/workflows/90-daily-health-check.yml"
    dest2 = "/Users/marek/Workspace/thisisblaze/blaze-actions/.github/workflows/90-daily-health-check.yml"
    
    shutil.copy2(source, dest1)
    print(f"Synced {dest1}")
    shutil.copy2(source, dest2)
    print(f"Synced {dest2}")

if __name__ == '__main__':
    main()
