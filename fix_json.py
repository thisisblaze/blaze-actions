import os
import re
import glob

def fix_package_json(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
        
    # Find anything matching "@blaze-cms/...": "0.146.0-node18-core-styles-tooltips.XYZ"
    # and replace with "@blaze-cms/...": "^0.146.0"
    
    pattern = r'("@blaze-cms/[^"]+"\s*:\s*)"0\.146\.0-node18-core-styles-tooltips\.\d+"'
    replacement = r'\1"^0.146.0"'
    
    new_content, count = re.subn(pattern, replacement, content)
    
    if count > 0:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {count} occurrences in {filepath}")
        return True
    return False

def main():
    root_dir = '/Users/marek/Workspace/Byte9/blaze-template-deploy-aws-actions/blaze-template-deploy'
    search_path = os.path.join(root_dir, 'packages', '**', 'package.json')
    
    files = glob.glob(search_path, recursive=True)
    
    # Also check root package.json just in case
    files.append(os.path.join(root_dir, 'package.json'))
    
    for filepath in files:
        if os.path.exists(filepath):
            fix_package_json(filepath)

if __name__ == '__main__':
    main()
