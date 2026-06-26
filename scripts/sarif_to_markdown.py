#!/usr/bin/env python3
"""
Convert SARIF file to Markdown summary for GitHub PR comments.
Usage: python3 sarif_to_markdown.py <sarif_file> <title>
"""
import json
import sys
import os

def parse_sarif(sarif_path):
    try:
        with open(sarif_path, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        return []
    except json.JSONDecodeError:
        return []

    findings = []
    
    for run in data.get('runs', []):
        tool = run.get('tool', {}).get('driver', {})
        rules = {r['id']: r for r in tool.get('rules', [])}
        
        for result in run.get('results', []):
            rule_id = result.get('ruleId')
            rule = rules.get(rule_id, {})
            
            message = result.get('message', {}).get('text', 'No description')
            level = result.get('level', 'warning')
            
            # Get location
            location = "Unknown location"
            line = "?"
            if result.get('locations'):
                phys_loc = result['locations'][0].get('physicalLocation', {})
                artifact_loc = phys_loc.get('artifactLocation', {})
                uri = artifact_loc.get('uri', 'Unknown file')
                
                region = phys_loc.get('region', {})
                start_line = region.get('startLine')
                if start_line:
                    line = str(start_line)
                
                location = f"{uri}:{line}"
            
            findings.append({
                'rule_id': rule_id,
                'severity': level,
                'message': message,
                'location': location,
                'uri': uri if 'uri' in locals() else '',
                'line': line
            })
            
    return findings

def generate_markdown(findings, title):
    if not findings:
        return "" 
        
    md = [f"## {title}"]
    md.append("")
    md.append(f"Found **{len(findings)}** issues.")
    md.append("")
    md.append("| Severity | Rule | Location | Message |")
    md.append("| :--- | :--- | :--- | :--- |")
    
    for f in findings:
        severity_icon = "⚠️"
        if f['severity'] == 'error':
            severity_icon = "❌"
        elif f['severity'] == 'note':
            severity_icon = "ℹ️"
            
        # Link to file if possible (assuming GitHub)
        # We don't have the commit hash easily here, so plain text or relative link
        loc_display = f"`{f['location']}`"
        
        md.append(f"| {severity_icon} {f['severity']} | `{f['rule_id']}` | {loc_display} | {f['message']} |")
        
    md.append("")
    return "\n".join(md)

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 sarif_to_markdown.py <sarif_file> <title>")
        sys.exit(1)
        
    sarif_file = sys.argv[1]
    title = sys.argv[2]
    
    findings = parse_sarif(sarif_file)
    
    if findings:
        markdown = generate_markdown(findings, title)
        print(markdown)
    else:
        # Print nothing if no findings, so we don't comment
        pass

if __name__ == "__main__":
    main()
