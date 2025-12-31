# Archived Agent Versions

This folder contains archived versions of production agents that are no longer in use.

## Files

### agent_v3.py
- **Status:** Archived (unused)
- **Replaced by:** production/curator/agent_v2.py
- **Reason:** V2 is the current production version used by process_extractions.py

### subagent_specs_v3.py
- **Status:** Archived (unused)
- **Replaced by:** production/curator/subagent_specs.py
- **Reason:** V2 specs are the current production version

## Current Production Stack

```
process_extractions.py
    ↓
agent_v2.py
    ↓
subagent_specs.py
    ↓
subagents/*.py
```

## Why Keep These Files?

These v3 files are kept for reference in case we need to:
- Review previous implementation approaches
- Recover specific features that were removed
- Understand the evolution of the agent architecture

## When to Delete

These files can be safely deleted if:
- V2 has been stable in production for 6+ months
- No features from V3 need to be recovered
- The git history is sufficient for reference
