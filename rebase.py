import sys
import re

with open(sys.argv[1], 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if not line.startswith('pick ') and not line.startswith('drop '):
        new_lines.append(line)
        continue
    
    parts = line.split(' ', 2)
    sha = parts[1]
    msg = parts[2].strip()
    
    # Drop end-of-day governance sync
    if 'chore: end-of-day governance sync' in msg:
        new_lines.append(f"drop {sha} {msg}\n")
    # Fixup cloudflare iteration commits into the earliest cloudflare commit
    # Actually, if we just use fixup in place, it will squash into the commit immediately preceding it.
    elif 'chore: add debug for cloudflare secrets' in msg:
        new_lines.append(f"fixup {sha} {msg}\n")
    elif 'use tr -cd to strictly sanitize Cloudflare secrets' in msg:
        new_lines.append(f"fixup {sha} {msg}\n")
    elif 'Trim whitespace from CLOUDFLARE API tokens' in msg:
        new_lines.append(f"fixup {sha} {msg}\n")
    else:
        new_lines.append(line)

with open(sys.argv[1], 'w') as f:
    for line in new_lines:
        f.write(line)

