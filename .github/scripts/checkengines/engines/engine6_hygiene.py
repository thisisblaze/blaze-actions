import subprocess

def run_cmd(cmd, cwd=None):
    try:
        res = subprocess.run(cmd, shell=True, cwd=cwd, text=True, capture_output=True)
        return res.stdout.strip()
    except Exception:
        return ""

def run(repos):
    hygiene_issues = 0
    for r_name, path in repos.items():
        res = run_cmd('find . -type d \\( -name "scratch" -o -name "temp" -o -name "debug" \\) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null', cwd=path)
        if res:
            print(f"⚠️  [Engine 6] {r_name} Temp dirs found.")
            hygiene_issues += 1
    return hygiene_issues
