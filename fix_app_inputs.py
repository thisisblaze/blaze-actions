with open(".github/workflows/02-deploy-app.yml", "r") as f:
    lines = f.readlines()

new_lines = []
in_gcp_azure_pages = False

for line in lines:
    if line.strip() == "dispatch-gcp:" or line.strip() == "dispatch-azure:" or line.strip() == "dispatch-pages:":
        in_gcp_azure_pages = True
    
    if line.strip() == "summary:":
        in_gcp_azure_pages = False
        
    if in_gcp_azure_pages:
        # Ignore these lines
        if "api_launch_type:" in line or "api_cpu_architecture:" in line or "frontend_launch_type:" in line or "frontend_cpu_architecture:" in line or "skip_stability_wait:" in line:
            continue
            
    new_lines.append(line)

with open(".github/workflows/02-deploy-app.yml", "w") as f:
    f.writelines(new_lines)
