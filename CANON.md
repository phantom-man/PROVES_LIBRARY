# CANON - Permanent Knowledge Repository

> **Purpose:** This file preserves critical lessons, design principles, and ontology that must NEVER be lost during documentation updates, refactoring, or agent handoffs. Treat this as institutional memory.

**Last Updated:** December 2025  
**Status:** Living Document

---

## 1. Core Design Principles

### 1.1 Autonomous Intelligence, Not Automation

> "Give goals, not instructions."

The curator agent is designed to be **intelligent**, not just automated. The difference:

| Automation | Intelligence |
|------------|-------------|
| Follow script exactly | Understand goal, decide approach |
| Fail if unexpected input | Adapt to new situations |
| Do what you said | Do what you meant |
| No learning | Gets smarter over time |

**Pattern:** Provide rich context and clear goals → Let the agent decide HOW to achieve them.

### 1.2 Criticality is Metadata, Not a Gate

> "All dependencies should be stored. Criticality describes importance for querying."

**Critical Design Decision:** The agent stores ALL discovered dependencies in the knowledge graph. Criticality levels (HIGH/MEDIUM/LOW) are metadata that describe each dependency's importance - they are NOT filters for whether something gets stored.

**Why This Matters:**
- LOW criticality today might become HIGH tomorrow
- Complete extraction enables better analysis
- Filtering happens at query time, not storage time

**Query Example:**
```cypher
// Get only HIGH criticality dependencies
MATCH (a)-[r:DEPENDS_ON {criticality: "HIGH"}]->(b)
RETURN a.name, b.name, r.description
```

### 1.3 Four Pillars of Trustworthy AI Agents

1. **Rich Context** - Domain knowledge + examples → Better decisions
2. **Clear Goals** - Well-defined objectives → Focused execution
3. **Transparency** - Show all reasoning → Human can verify
4. **Human Oversight** - Approve before executing → Safety guaranteed

---

## 2. Human-in-the-Loop (HITL) Patterns

### 2.1 Data-Level vs Action-Level Approval

| Type | When | Use For |
|------|------|---------|
| **Data-Level** | Before storing data | "Should this dependency be added to the graph?" |
| **Action-Level** | Before any execution | "Should I run this extraction plan?" |

**Current Implementation:** Data-level HITL for HIGH criticality dependencies.

### 2.2 Plan-Then-Execute Pattern

> "The agent should plan autonomously but execute with approval."

**Workflow:**
1. Agent analyzes task and creates plan
2. Agent shows plan to human
3. Human approves/modifies plan
4. Agent executes approved plan
5. Agent reports results

**Why:** Humans are good at judging plans, agents are good at executing them.

### 2.3 Trust-Building Phases

```
Phase 1: Supervised      → Agent asks approval for EVERY action
Phase 2: Semi-Autonomous → Agent handles LOW/MEDIUM automatically
Phase 3: Autonomous      → Agent works independently, human reviews after
Phase 4: Full Autonomy   → Human spot-checks periodically
```

Each phase builds confidence in agent judgment before granting more autonomy.

---

## 3. Transfer Learning Methodology

### 3.1 Learning from Examples

> "The agent learns methodology from examples, not just copies content."

**Pattern:** Show the agent good examples → Agent extracts the methodology → Agent applies methodology to new content.

**Example Flow:**
```
Input: Student work showing good dependency extraction
Agent learns: How to identify dependencies, assess criticality, describe relationships
Output: Agent extracts new dependencies using learned methodology
```

### 3.2 What Gets Transferred

- **Methodology:** HOW to analyze documents
- **Ontology:** Relationship types, criticality levels, component categories
- **Quality Standards:** What makes a good extraction
- **Domain Context:** Satellite systems, F´ framework, PROVES Kit specifics

---

## 4. Transparency Stack

```
┌─────────────────────────────────────┐
│  USER: Sees decisions in real-time  │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│  CONSOLE: Live progress updates     │
│  [CURATOR] Thinking...              │
│  [CURATOR] Planning to call...      │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│  CHECKPOINTS: Full conversation     │
│  Every message, decision, result    │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│  LOGS: Detailed reasoning           │
│  Why each decision was made         │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│  DATABASE: Final stored results     │
│  Knowledge graph with provenance    │
└─────────────────────────────────────┘
```

**Console Output Patterns:**
```
[CURATOR] Starting analysis of {document}...
[CURATOR] Found {n} potential dependencies
[CURATOR] Requesting approval for HIGH criticality: {description}
[CURATOR] Stored {n} dependencies successfully
```

---

## 5. Sub-Agent Architecture

### 5.1 Specialization Pattern

Each sub-agent has ONE focused responsibility:

| Sub-Agent | Responsibility | Model | Tools |
|-----------|---------------|-------|-------|
| **Extractor** | Read docs, identify dependencies | Claude Sonnet | `read_documentation_file` |
| **Validator** | Check for duplicates | Claude Haiku | `check_if_dependency_exists` |
| **Storage** | Write to database | Claude Haiku | `store_dependency_relationship` |

### 5.2 Why Sub-Agents?

1. **Single Responsibility** - Each agent is expert at one thing
2. **Model Optimization** - Use expensive models only where needed
3. **Testability** - Test each capability independently
4. **Composability** - Coordinator decides when to invoke each

---

## 6. ERV Ontology (Entity-Relationship-Value)

### 6.1 Relationship Types

| Type | Meaning | Example |
|------|---------|---------|
| `depends_on` | A needs B to function | I2C_Driver depends_on HAL |
| `requires` | A must have B present | Component requires specific config |
| `enables` | A makes B possible | Framework enables rapid development |
| `conflicts_with` | A and B cannot coexist | Two drivers conflict on same bus |
| `mitigates` | A reduces risk from B | Watchdog mitigates lockup risk |
| `causes` | A leads to B happening | Power surge causes reset |

### 6.2 Criticality Levels

| Level | Definition | HITL Behavior |
|-------|------------|---------------|
| **HIGH** | Mission/safety critical | Requires human approval |
| **MEDIUM** | Important for functionality | Auto-approved, logged |
| **LOW** | Nice to have, minimal impact | Auto-approved, logged |

### 6.3 Component Categories

- `software` - Code, drivers, libraries
- `hardware` - Physical components, boards
- `interface` - Communication protocols, APIs
- `system` - Complete systems, assemblies
- `documentation` - Specs, guides, references

---

## 7. Operational Patterns

### 7.1 Monitoring Setup

**Where data lives:**
1. **Conversation State:** PostgreSQL (checkpointer tables)
2. **Knowledge Graph:** PostgreSQL (nodes, edges, etc.)
3. **Debug Logs:** Console output + optional log files

**Quick health checks:**
```bash
# See recent agent activity
python run_with_approval.py

# Check database contents
SELECT COUNT(*) FROM nodes;
SELECT COUNT(*) FROM edges;
```

### 7.2 Error Handling Philosophy

> "Fail visibly, recover gracefully."

- All errors must be logged and visible
- Partial progress should be saved
- Human can resume or retry
- Never silently drop data

### 7.3 GitHub API Sync Pattern

**For external repos (F´, etc.):**
- Use API instead of local clones (saves disk space)
- Track commit SHA for incremental updates
- Rate limit: 5000 requests/hour authenticated
- Daily sync recommended

---

## 8. Key Takeaways (Summary)

### For Building Intelligent Agents:

1. **Context is Intelligence** - Rich domain knowledge + good examples = better decisions
2. **Transparency Enables Trust** - Show all decisions so humans can verify
3. **HITL is About Control** - Gate on execution, not thinking
4. **Learning Compounds** - Each session improves the system

### For Users/Operators:

1. **Give Context, Not Commands** - "Here's what good looks like" > "Do exactly this"
2. **Ask "Why?" Not Just "What?"** - Understand agent reasoning
3. **Review Sessions, Improve Prompts** - Each run teaches lessons
4. **Trust, But Verify** - Spot-check stored dependencies

---

## 9. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | December 2025 | Initial extraction from archived documentation |

---

## 10. Related Documents

**Current Documentation:**
- [README.md](README.md) - Project overview
- [GETTING_STARTED.md](GETTING_STARTED.md) - Setup guide
- [docs/ROADMAP.md](docs/ROADMAP.md) - Development roadmap

**Archived Sources (lessons extracted from):**
- `archive/curator-agent-old/AGENT_INTELLIGENCE_GUIDE.md`
- `archive/curator-agent-old/DESIGN_ACTION_LEVEL_HITL.md`
- `archive/curator-agent-old/OPTION_REMOVE_HITL.md`
- `archive/curator-agent-old/README_MONITORING.md`
- `archive/outdated-docs/LANGSMITH_INTEGRATION.md`
- `archive/outdated-docs/GITHUB_API_SYNC_QUICKSTART.md`
