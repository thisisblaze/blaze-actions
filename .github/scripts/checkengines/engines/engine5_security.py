import subprocess

def run_cmd(cmd, cwd=None):
    try:
        res = subprocess.run(cmd, shell=True, cwd=cwd, text=True, capture_output=True)
        return res.stdout.strip()
    except Exception:
        return ""

def run(repos):
    sec_issues = 0
    for r_name, path in repos.items():
        res = run_cmd('grep -rn "AWS_ACCESS_KEY_ID\\|ARM_CLIENT_SECRET\\|GCP_SA_KEY" --include="*.yml" --include="*.tf" --include="*.sh" .', cwd=path)
        if res:
            print(f"🔴 [Engine 5] {r_name} Security pattern violation: \n{res}")
            sec_issues += 1
    return sec_issues
