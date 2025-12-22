# OPTION: Remove HITL Gate - Store All Dependencies Automatically

## Current Behavior
- HIGH criticality → Requires approval before storage
- MEDIUM/LOW → Auto-stored

## Your Point
"Criticality is just a descriptor. All dependencies should be stored. The level is just metadata."

You're right! Criticality should be:
- A **field** on each dependency (metadata)
- NOT a **gate** for whether to store it

## How to Change It

### Option A: Keep HITL but Make It Optional

Edit `src/curator/agent.py` around line 238-251:

```python
# Find this function:
def _is_high_criticality_storage_call(tool_call: dict[str, Any]) -> bool:
    if tool_call.get("name") != "storage_agent":
        return False
    task = (tool_call.get("args") or {}).get("task", "")
    return "HIGH" in str(task).upper()
```

**Change to**:
```python
def _is_high_criticality_storage_call(tool_call: dict[str, Any]) -> bool:
    # DISABLED: No longer gate on criticality
    return False  # <-- Just return False always
```

Now ALL dependencies are stored immediately, regardless of criticality.

### Option B: Make HITL Configurable

Better approach - add a config flag:

```python
# In create_curator(), add a parameter:
def create_curator(require_approval_for_high: bool = False):  # <-- NEW
    """
    Create the main curator agent.

    Args:
        require_approval_for_high: If True, HIGH criticality requires approval.
                                   If False, all dependencies auto-store.
    """
    # ... existing code ...

    def _is_high_criticality_storage_call(tool_call: dict[str, Any]) -> bool:
        if not require_approval_for_high:  # <-- NEW
            return False
        if tool_call.get("name") != "storage_agent":
            return False
        task = (tool_call.get("args") or {}).get("task", "")
        return "HIGH" in str(task).upper()
```

Then at the bottom:
```python
# Export the graph
graph = create_curator(require_approval_for_high=False)  # <-- Set to False
```

### Option C: Post-Storage Review Instead

Different approach - store everything immediately, but flag HIGH for review later:

```python
# In storage_agent tool definition, add logging:
@tool("storage_agent")
def call_storage_agent(task: str) -> str:
    """Call the storage sub-agent to store validated dependencies."""

    # Check if HIGH criticality
    if "HIGH" in task.upper():
        # Log for later review instead of blocking
        with open("high_criticality_review.log", "a") as f:
            f.write(f"{datetime.now()}: {task}\n")
        print("[LOGGED] HIGH criticality dependency stored - flagged for review")

    # Store immediately regardless
    storage = create_storage_agent()
    result = storage.invoke({"messages": [{"role": "user", "content": task}]})
    return result['messages'][-1].content
```

## What I Recommend

**For your use case**: Option A or B (remove the gate)

Why:
1. You want ALL dependencies extracted and stored
2. Criticality is just metadata for querying later
3. You can review the graph after extraction
4. No interruption to the extraction workflow

## After Removing Gate

Then you can:
```bash
# Extract everything from a document
python run_curator.py

# Later, query by criticality in Neo4j:
# Get all HIGH criticality dependencies
MATCH (a)-[r:DEPENDS_ON {criticality: 'HIGH'}]->(b)
RETURN a.name, b.name, r.description

# Get dependency counts by criticality
MATCH ()-[r:DEPENDS_ON]->()
RETURN r.criticality, count(r) as count
ORDER BY count DESC
```

## Should I Make This Change?

Would you like me to:
1. **Remove the HITL gate** (Option A) - simplest
2. **Make it configurable** (Option B) - more flexible
3. **Post-storage review** (Option C) - middle ground

Or just **run a full extraction** with the current system to see it work?
