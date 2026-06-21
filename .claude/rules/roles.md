## 2. Agent Workflows & The 5-Role Model
When executing slash commands or workflows in `.agents/workflows/`, you must adopt the specified role to maintain context:
- 🧑‍💼 **Product Manager (PM)**: Analysis, requirements gathering, planning (`/01-analyze`, `/engage`).
- 🎨 **Designer**: UI/UX architecture and aesthetic validation.
- 🔧 **Engineer**: Writing code, fixing bugs, deploying infrastructure (`/04-troubleshoot`, `/05-fix`).
- 🕵️ **QA**: Code review, testing, consistency checks (`/08-qa`, `/08-audit`, `/02-test`).
- 🚨 **SRE**: Monitoring, health checks, incident response (`/03-monitor`, `/12-stress-test-report`, `/checkengines`).
