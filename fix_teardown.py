import yaml
import sys

def fix_workflow(filepath):
    with open(filepath, 'r') as f:
        data = yaml.safe_load(f)

    # 1. Add top-level permissions
    if 'permissions' not in data:
        data['permissions'] = {
            'id-token': 'write',
            'contents': 'read',
            'actions': 'write'
        }

    # 2. Fix missing inputs in uses jobs
    jobs = data.get('jobs', {})
    for job_name, job in jobs.items():
        if 'uses' in job and 'reusable-terraform-operations.yml' in job['uses']:
            if 'with' not in job:
                job['with'] = {}
            w = job['with']
            if 'aws_region' not in w:
                w['aws_region'] = "${{ needs.config.outputs.aws_region }}"
            if 'bucket' not in w and job_name != 'destroy-app': # destroy-app already has it now
                w['bucket'] = "${{ needs.config.outputs.bucket }}"

    with open(filepath, 'w') as f:
        yaml.dump(data, f, sort_keys=False, default_flow_style=False)

fix_workflow('.github/workflows/reusable-stress-test-teardown.yml')
