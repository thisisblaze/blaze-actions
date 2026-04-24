import re

def add_version(path, version_text):
    with open(path, 'r') as f:
        content = f.read()
    if '## Version History' in content and 'v2.1.74' not in content:
        content = content.replace('## Version History\n\n', '## Version History\n\n' + version_text + '\n')
        with open(path, 'w') as f:
            f.write(content)
        print(f"Added version to {path}")

v_text = """**v2.1.74 & v2.4.8** (2026-04-24):
- Deep CI/CD maintenance sync: Resolved checkengines workflow parity errors.
- Hardened teardown scripts: Enforced native `jq` type safety (`type=="array"`) to elegantly handle AWS CLI `null` capacityProviders during ECS cluster deletion.
- ALB naming collision fix: Enforced strict `trimsuffix("-")` to prevent AWS validation errors when 32-character project prefixes truncate at a hyphen.
- Global Tag Normalization: Systematically bumped all nested internal workflow tags to `v2.1.74` and terraform core refs to `v2.4.8` to definitively seal the pipeline from referencing stale, buggy logic during the stress tests.
"""

add_version('/Users/marek/Workspace/thisisblaze/blaze-actions/docs/WORKFLOW_CATALOG.md', v_text)
