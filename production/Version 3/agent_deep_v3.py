"""
Curator Deep Agent (v3) - Refactored using DeepAgents Framework

This module implements the Curator Agent using the `deepagents` library.
It replaces the explicit control flow of `agent_v3.py` with an agentic workflow
where a Manager Agent orchestrates subagents (Extractor, Validator, Storage).

Architecture:
- Manager Agent: The main entry point. Receives the URL and orchestrates the process.
- Subagents:
    - Extractor: Fetches and analyzes content.
    - Validator: Verifies lineage and checks for duplicates.
    - Storage: Merges epistemic metadata and commits to database.
"""
import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from langchain_anthropic import ChatAnthropic
from psycopg_pool import ConnectionPool
from langgraph.checkpoint.postgres import PostgresSaver

# ==========================================
# PATH SETUP
# ==========================================
# 1. Setup project root
version3_folder = Path(__file__).parent
project_root = version3_folder.parent.parent
production_root = project_root / 'production'

# 2. Add DeepAgents to path
# The deepagents package is located at: deepagents/libs/deepagents
deepagents_path = project_root / 'deepagents' / 'libs' / 'deepagents'
if str(deepagents_path) not in sys.path:
    sys.path.insert(0, str(deepagents_path))

# 3. Add production/Version 3 to path (for local imports)
if str(version3_folder) not in sys.path:
    sys.path.insert(0, str(version3_folder))

# 4. Add production root to path
if str(production_root) not in sys.path:
    sys.path.insert(0, str(production_root))

# Load environment
load_dotenv(project_root / '.env')

# Import DeepAgents
try:
    from deepagents import create_deep_agent  # type: ignore
except ImportError as e:
    print(f"CRITICAL ERROR: Could not import deepagents. Path was: {deepagents_path}")
    raise e

# Import Subagent Specs
from subagent_specs_v3 import (
    get_extractor_spec,
    get_validator_spec,
    get_storage_spec,
)

# ==========================================
# MANAGER AGENT PROMPT
# ==========================================
MANAGER_SYSTEM_PROMPT = """You are the Curator Manager Agent.
Your goal is to orchestrate the knowledge extraction pipeline for the PROVES Library.

## The Pipeline
You have access to three specialized subagents. You MUST use them in this specific order:

1.  **Extractor Agent** (`extractor`):
    *   Task: "Extract architecture from [URL]"
    *   Input: The target URL.
    *   Output: A list of extracted couplings with evidence and a snapshot ID.

2.  **Validator Agent** (`validator`):
    *   Task: "Validate these extractions..."
    *   Input: The output from the Extractor.
    *   Output: Validation results (Approved/Rejected), lineage verification, and duplicate checks.
    *   Constraint: If the Validator REJECTS the extractions, you must STOP and report the failure.

3.  **Storage Agent** (`storage`):
    *   Task: "Store these validated extractions..."
    *   Input: The original extraction data AND the validation results.
    *   Output: Confirmation of storage (extraction IDs).

## Your Responsibilities
*   **Orchestration**: Call the agents in order. Pass the output of one as input to the next.
*   **Error Handling**: If an agent reports an error or rejection, stop and report it to the user.
*   **Reporting**: When finished, provide a summary of what was extracted, validated, and stored.

## Important
*   Do NOT try to do the extraction yourself. Use the `extractor` subagent.
*   Do NOT try to validate yourself. Use the `validator` subagent.
*   Do NOT try to store yourself. Use the `storage` subagent.
*   Use the `task` tool to delegate these jobs.
"""

def create_deep_curator():
    """
    Create the Deep Curator Agent.

    Returns:
        CompiledStateGraph: The compiled agent application.
    """
    # 1. Setup Checkpointer (Postgres)
    db_url = os.getenv('NEON_DATABASE_URL')
    if not db_url:
        raise ValueError("NEON_DATABASE_URL is not set")

    pool = ConnectionPool(
        conninfo=db_url,
        min_size=1,
        max_size=5,
        kwargs={
            "keepalives": 1,
            "keepalives_idle": 30,
            "keepalives_interval": 10,
            "keepalives_count": 5,
        }
    )
    checkpointer = PostgresSaver(pool)  # type: ignore
    checkpointer.setup()

    # 2. Get Subagent Specs
    # We use the existing v3 specs, which return dicts compatible with DeepAgents
    extractor_spec = get_extractor_spec()
    validator_spec = get_validator_spec()
    storage_spec = get_storage_spec()

    subagents = [extractor_spec, validator_spec, storage_spec]

    # 3. Configure Model
    # DeepAgents defaults to Claude Sonnet, but we can be explicit
    model = ChatAnthropic(  # type: ignore
        model_name="claude-3-5-sonnet-20241022", # Use latest Sonnet
        temperature=0.1,
        max_tokens_to_sample=8192
    )

    # 4. Create the Deep Agent
    agent = create_deep_agent(
        model=model,
        system_prompt=MANAGER_SYSTEM_PROMPT,
        subagents=subagents,
        checkpointer=checkpointer,
        # We don't need extra tools for the manager, just the subagents
        tools=[], 
    )

    return agent

# Export for use
try:
    graph = create_deep_curator()
except ValueError as e:
    print(f"WARNING: Could not create Deep Curator Agent: {e}")
    graph = None
except Exception as e:
    print(f"ERROR: Failed to create Deep Curator Agent: {e}")
    graph = None
