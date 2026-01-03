# Audit: V3 Curator Agent Refactor to DeepAgents Framework

**Date:** January 3, 2026
**Status:** Completed & Committed

## 1. Executive Summary
This document records the refactoring of the "Version 3" Curator Agent. The primary objective was to move from a manual, script-based orchestration to the `deepagents` framework (based on LangGraph). This transition provides better state management, checkpointing, and a standardized "Manager-Subagent" architecture.

## 2. Original State Analysis
The original V3 implementation (`agent_v3.py`, `process_extractions_v3.py`) relied on:
- Manual loop management for subagents.
- Hardcoded paths and potential circular dependencies.
- Limited state persistence capabilities.

## 3. Implementation Details

### 3.1 Framework Integration
- **Dependency**: Cloned `langchain-ai/deepagents` into the workspace root.
- **Path Management**: Implemented dynamic `sys.path` insertion in Python scripts to locate the local `deepagents` module without requiring a pip install of the private repo.

### 3.2 New Components
| File | Description |
|------|-------------|
| `production/Version 3/agent_deep_v3.py` | **The Orchestrator**. Defines `create_deep_curator` which initializes a `deepagents` Manager. Configures the `ChatAnthropic` model and `PostgresSaver` for persistence. |
| `production/Version 3/process_extractions_deep_v3.py` | **The Runner**. Fetches URLs from the database, initializes the Deep Curator, and executes the workflow. Includes robust error handling for missing environment variables. |
| `production/Version 3/README_V3_DEEP.md` | **Documentation**. Instructions on how to setup and run the new agent. |

### 3.3 Key Technical Decisions
- **Model**: Configured to use `claude-3-5-sonnet-20241022`.
- **Persistence**: Integrated `PostgresSaver` (via `psycopg`) to allow the agent to pause and resume states, essential for long-running curation tasks.
- **Subagents**: Reused existing logic from `subagent_specs_v3.py` but wrapped them into the `deepagents` tool structure.
- **Type Safety**: Added `# type: ignore` directives to handle static analysis limitations with dynamic imports.

## 4. Verification
- **Static Analysis**: Code passes syntax checks.
- **Runtime Check**: Scripts initialize correctly (verified via dry-run).
- **Environment**: Scripts gracefully handle missing `NEON_DATABASE_URL` by logging a warning instead of crashing, allowing for local testing of import logic.

## 5. Next Steps
1.  **Configuration**: Create a `.env` file with `NEON_DATABASE_URL` and `ANTHROPIC_API_KEY`.
2.  **Deployment**: The code is pushed to the `main` branch.
3.  **Testing**: Run `python production/Version 3/process_extractions_deep_v3.py` to process the first batch of URLs.
