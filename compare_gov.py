import re

repos = [
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-actions",
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-conductor",
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-terraform-infra-core",
  "/Users/marek/Workspace/00-Google-Antigravity/thebyte9/thebyte9-blaze-template-deploy/blaze-template-deploy"
]

sections = [
  "1. The Prime Directive",
  "2. The Golden Rule of Context",
  "4. Data Retention Policy",
  "7. Stage Safety Protocol (Cost Control)",
  "8. Transient Artifact Cleanup (Zero Trace Policy)",
  "9. Cleanup Protocol (The Law of Zero Waste)",
  "10. Cross-Repository Architecture",
]

def extract_sections(text):
    out = {}
    for i, s in enumerate(sections):
        start = text.find("## " + s)
        if start == -1:
            out[s] = ""
            continue
        # Find next ##
        end = text.find("## ", start + 1)
        if end == -1:
            out[s] = text[start:]
        else:
            out[s] = text[start:end]
    return out

base = None
base_repo = None
mismatch = False

for r in repos:
    try:
        with open(r + "/docs/AI_CONTEXT_GOVERNANCE.md", "r") as f:
            content = f.read()
            ext = extract_sections(content)
            if base is None:
                base = ext
                base_repo = r
            else:
                for k in sections:
                    if base[k] != ext[k]:
                        print(f"Mismatch in section '{k}' between {base_repo} and {r}")
                        mismatch = True
    except Exception as e:
        print(f"Error reading {r}: {e}")
        mismatch = True

if not mismatch:
    print("All shared sections match perfectly across all 4 repos.")
