import yaml
import os
import glob

workflow_dir = '/Users/marek/Workspace/thisisblaze/blaze-actions/.github/workflows'
os.chdir(workflow_dir)

for file in sorted(glob.glob('*.yml')):
    try:
        with open(file, 'r') as f:
            data = yaml.safe_load(f)
            inputs = set()
            if data and 'on' in data:
                if isinstance(data['on'], dict):
                    if 'workflow_dispatch' in data['on'] and isinstance(data['on']['workflow_dispatch'], dict):
                        if 'inputs' in data['on']['workflow_dispatch'] and data['on']['workflow_dispatch']['inputs']:
                            inputs.update(data['on']['workflow_dispatch']['inputs'].keys())
                    if 'workflow_call' in data['on'] and isinstance(data['on']['workflow_call'], dict):
                        if 'inputs' in data['on']['workflow_call'] and data['on']['workflow_call']['inputs']:
                            inputs.update(data['on']['workflow_call']['inputs'].keys())
            if inputs:
                print(f"{file}: {', '.join(sorted(inputs))}")
    except Exception as e:
        print(f"Error parsing {file}: {e}")
