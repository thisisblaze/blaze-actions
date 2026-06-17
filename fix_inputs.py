import os
import glob

files = glob.glob(".github/workflows/02-deploy-*.yml")

for file in files:
    if "02-deploy-app.yml" in file:
        continue
    
    with open(file, "r") as f:
        content = f.read()

    # check if smoke_test_url is already there
    if "smoke_test_url:" not in content.split("secrets:")[0]:
        content = content.replace(
"""    inputs:
      cloud_provider:""",
"""    inputs:
      smoke_test_url:
        required: false
        type: string
        default: ""
      cloud_provider:""")
        
        with open(file, "w") as f:
            f.write(content)
