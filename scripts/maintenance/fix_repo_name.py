import os
import glob

for filename in glob.glob(".github/workflows/02-deploy-*.yml"):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Replace the exact block
    old_block = """          REPO_NAME: ${{ needs.configuration.outputs.namespace }}-${{ 
            needs.configuration.outputs.project_key }}-web/${{ 
            needs.configuration.outputs.project_key }}/api"""
            
    new_block = """          REPO_NAME: ${{ needs.configuration.outputs.namespace }}-${{ 
            needs.configuration.outputs.client_key }}-web/${{ 
            needs.configuration.outputs.project_key }}/api"""
            
    if old_block in content:
        content = content.replace(old_block, new_block)
        with open(filename, 'w') as f:
            f.write(content)
        print(f"Fixed {filename}")
    else:
        print(f"Could not find block in {filename}")

