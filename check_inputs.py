import yaml

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

        declared_inputs = callee_yaml.get(True, {}).get('workflow_call', {}).get('inputs', {})
        if not declared_inputs:
            declared_inputs = callee_yaml.get('on', {}).get('workflow_call', {}).get('inputs', {})
            
        passed_inputs = job.get('with', {})
        if isinstance(passed_inputs, dict):
            for i in passed_inputs:
                if i not in declared_inputs:
                    print(f"FAILED: {filepath} job {job_name} passes input {i} to {callee} but it's not declared!")

check_workflow('.github/workflows/reusable-stress-test-deploy.yml')
check_workflow('.github/workflows/reusable-dns-verify.yml')
