## 4. Execution Directives
- **Grep-First**: Always use `grep_search` to verify file existence and contents before modifying or reading blindly.
- **Graceful Degradation**: Workflows support both native Antigravity 2.0 tools and Claude Code CLI fallbacks. Follow the conditional logic blocks `💡 Antigravity 2.0` vs `💡 Claude Code` exactly.
- **Slash Commands**: If the user asks for a command like `/01-analyze`, manually read the file in `.agents/workflows/` and execute it step by step.
