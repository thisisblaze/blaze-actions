import yaml
import os
with open('.github/workflows/reusable-stress-test-verify.yml', 'r') as f:
    verify = yaml.safe_load(f)

for job_name in ['verify-aws', 'verify-gcp', 'verify-azure']:
    job = verify['jobs'][job_name]
    callee = job['uses'].split('/')[-1].split('@')[0]
    with open(f".github/workflows/{callee}", 'r') as f:
        callee_yaml = yaml.safe_load(f)
    declared_secrets = callee_yaml.get(True, {}).get('workflow_call', {}).get('secrets', {})
    if not declared_secrets:
        declared_secrets = callee_yaml.get('on', {}).get('workflow_call', {}).get('secrets', {})
        
    passed_secrets = job.get('secrets', {})
    if isinstance(passed_secrets, dict):
        for s in passed_secrets:
            if s not in declared_secrets:
                print(f"FAILED: {job_name} passes secret {s} to {callee} but it's not declared!")

