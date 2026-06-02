import re
import os
import datetime

repos = [
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-conductor",
  "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-terraform-infra-core",
  "/Users/marek/Workspace/00-Google-Antigravity/thebyte9/thebyte9-blaze-template-deploy/blaze-template-deploy"
]
source_repo = "/Users/marek/Workspace/00-Google-Antigravity/_shared/blaze-actions"

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
        end = text.find("\n## ", start + 1)
        if end == -1:
            out[s] = text[start:]
        else:
            out[s] = text[start:end]
    return out

def replace_sections(text, shared_sections):
    new_text = text
    for s, content in shared_sections.items():
        if not content: continue
        start = new_text.find("## " + s)
        if start == -1:
             # Just append if missing
             new_text += "\n" + content + "\n"
             continue
        end = new_text.find("\n## ", start + 1)
        if end == -1:
            new_text = new_text[:start] + content
        else:
            new_text = new_text[:start] + content + new_text[end:]
    return new_text

with open(source_repo + "/docs/AI_CONTEXT_GOVERNANCE.md", "r") as f:
    src_content = f.read()

# Fix "This Repo" so it's truly shared
src_content = src_content.replace(" (This Repo)", "")

shared = extract_sections(src_content)

today = datetime.datetime.now().strftime("%Y-%m-%d")

for r in [source_repo] + repos:
    path = r + "/docs/AI_CONTEXT_GOVERNANCE.md"
    try:
        with open(path, "r") as f:
            content = f.read()
        
        new_content = replace_sections(content, shared)
        # Update date if changed
        if new_content != content:
            new_content = re.sub(r"\*\*Last Updated\*\*: \d{4}-\d{2}-\d{2}", f"**Last Updated**: {today}", new_content)
            
        with open(path, "w") as f:
            f.write(new_content)
        print(f"Synced {r}")
    except Exception as e:
        print(f"Error {r}: {e}")
