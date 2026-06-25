import yaml
import os

def check_workflow(filepath):
    with open(filepath, 'r') as f:
        wf = yaml.safe_load(f)

    for job_name, job in wf.get('jobs', {}).items():
        if 'uses' not in job: continue
        
        callee = job['uses'].split('/')[-1].split('@')[0]
        try:
            with open(f".github/workflows/{callee}", 'r') as f:
                callee_yaml = yaml.safe_load(f)
        except Exception as e:
            print(f"Could not open {callee}: {e}")
            continue

        declared_secrets = callee_yaml.get(True, {}).get('workflow_call', {}).get('secrets', {})
        if not declared_secrets:
            declared_secrets = callee_yaml.get('on', {}).get('workflow_call', {}).get('secrets', {})
            
        passed_secrets = job.get('secrets', {})
        if isinstance(passed_secrets, dict):
            for s in passed_secrets:
                if s not in declared_secrets:
                    print(f"FAILED: {filepath} job {job_name} passes secret {s} to {callee} but it's not declared!")

check_workflow('.github/workflows/reusable-stress-test-deploy.yml')
