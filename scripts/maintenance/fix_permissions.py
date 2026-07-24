import os
import re

dir_path = '.github/workflows'

def process_file(filepath):
    with open(filepath, 'r') as f:
        lines = f.readlines()

    out_lines = []
    i = 0
    changed = False

    while i < len(lines):
        line = lines[i]
        
        # Detect start of a job
        if re.match(r'^  [a-zA-Z0-9_-]+:$', line):
            job_start_idx = i
            has_uses = False
            has_permissions = False
            permissions_start = -1
            permissions_end = -1
            
            # Scan the job block
            j = i + 1
            while j < len(lines):
                if re.match(r'^[a-zA-Z0-9_-]+:', lines[j]) or re.match(r'^  [a-zA-Z0-9_-]+:$', lines[j]):
                    break # end of job block
                
                if re.match(r'^    uses:', lines[j]):
                    has_uses = True
                
                if re.match(r'^    permissions:$', lines[j]):
                    has_permissions = True
                    permissions_start = j
                    # find end of permissions block
                    k = j + 1
                    while k < len(lines):
                        if not re.match(r'^      ', lines[k]) and lines[k].strip() != '':
                            break
                        k += 1
                    permissions_end = k
                j += 1
                
            if has_uses and has_permissions:
                changed = True
                print(f"Fixing {filepath}: removing permissions block at line {permissions_start + 1}")
                # Remove the permissions block from the lines array for this job
                # We need to do this carefully
                for idx in range(i, j):
                    if idx >= permissions_start and idx < permissions_end:
                        pass # skip these lines
                    else:
                        out_lines.append(lines[idx])
                i = j
                continue
                
        out_lines.append(line)
        i += 1
        
    if changed:
        with open(filepath, 'w') as f:
            f.writelines(out_lines)

for filename in os.listdir(dir_path):
    if filename.endswith('.yml'):
        process_file(os.path.join(dir_path, filename))

