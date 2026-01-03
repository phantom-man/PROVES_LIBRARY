# Deep Curator Agent (Version 3)

This directory contains the refactored Curator Agent using the `deepagents` framework.

## Files

* **`agent_deep_v3.py`**: The main entry point. Defines the `create_deep_curator` function which constructs the Deep Agent with the Manager -> Subagents architecture.
* **`process_extractions_deep_v3.py`**: A script to process the extraction queue using the new Deep Agent.
* **`subagent_specs_v3.py`**: Defines the specifications (prompts, tools) for the Extractor, Validator, and Storage subagents.
* **`extractor_v3.py`, `validator_v3.py`, `storage_v3.py`**: Implement the tools and logic for each subagent.

## Setup

1. Ensure `deepagents` is cloned into `PROVES_LIBRARY/deepagents`.
2. Install dependencies:
    ```bash
    pip install -r requirements-local.txt
    pip install wcmatch langchain-google-genai
    ```
3. Ensure `.env` file exists in `PROVES_LIBRARY/` with `NEON_DATABASE_URL` and `ANTHROPIC_API_KEY`.

## Usage

To process the next URL in the queue:

```bash
python "production/Version 3/process_extractions_deep_v3.py" --limit 1
```

## Architecture

The system uses a **Manager Agent** that orchestrates three **Subagents**:

1. **Extractor**: Fetches content and extracts architecture using FRAMES methodology.
2. **Validator**: Verifies lineage and checks for duplicates.
3. **Storage**: Merges epistemic metadata and commits to the database.

This replaces the explicit control flow of the previous version with a more flexible, agentic workflow.
