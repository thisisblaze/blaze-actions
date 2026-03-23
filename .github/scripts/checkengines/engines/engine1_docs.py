import subprocess

def run_cmd(cmd, cwd=None):
    try:
        res = subprocess.run(cmd, shell=True, cwd=cwd, text=True, capture_output=True)
        return res.stdout.strip()
    except Exception:
        return ""

def run(repos):
    docs_issues = 0
    for r_name, path in repos.items():
        res = run_cmd('grep -rn "Last Updated" docs/ --include="*.md" | grep -v "archive" | grep -v "reports"', cwd=path)
        if "2025" in res or "2024" in res:  # simplistic check for > 30 days
            print(f"⚠️  [Engine 1] {r_name} docs may be stale.")
            docs_issues += 1
    return docs_issues
