#!/usr/bin/env python3
import yaml
import os
import glob
import sys

# Auto-discover repos
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'scripts', 'utils'))
from repo_paths import get_repos

repos = get_repos(__file__)
workflow_dir = os.path.join(repos["actions"], ".github", "workflows")
os.chdir(workflow_dir)

for file in sorted(glob.glob('*.yml')):
    try:
        with open(file, 'r') as f:
            data = yaml.safe_load(f)
            inputs = set()
            trigger_key = 'on' if 'on' in data else True
            if data and trigger_key in data:
                triggers = data[trigger_key]
                if isinstance(triggers, dict):
                    if 'workflow_dispatch' in triggers and isinstance(triggers['workflow_dispatch'], dict):
                        if 'inputs' in triggers['workflow_dispatch'] and triggers['workflow_dispatch']['inputs']:
                            inputs.update(triggers['workflow_dispatch']['inputs'].keys())
                    if 'workflow_call' in triggers and isinstance(triggers['workflow_call'], dict):
                        if 'inputs' in triggers['workflow_call'] and triggers['workflow_call']['inputs']:
                            inputs.update(triggers['workflow_call']['inputs'].keys())
            if inputs:
                print(f"{file}: {', '.join(sorted(inputs))}")
    except Exception as e:
        print(f"Error parsing {file}: {e}")
