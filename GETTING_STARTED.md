# Getting Started with PROVES Library Development

**Welcome!** This guide will get you up and running with the PROVES Library development environment in under 30 minutes.

---

## Prerequisites

Before you begin, ensure you have:

- **Python 3.9+** ([Download](https://www.python.org/downloads/))
- **Node.js 16+** ([Download](https://nodejs.org/)) - for VS Code extension
- **Git** ([Download](https://git-scm.com/))
- **Neo4j Desktop** ([Download](https://neo4j.com/download/)) - Recommended for graph database
- **VS Code** ([Download](https://code.visualstudio.com/)) - Recommended IDE

**Hardware Requirements:**
- 8GB RAM minimum (16GB recommended)
- 10GB free disk space
- Modern CPU (for LLM inference if running locally)

---

## Quick Start (5 Minutes)

### 1. Clone the Repository

```bash
git clone https://github.com/Lizo-RoadTown/PROVES_LIBRARY.git
cd PROVES_LIBRARY
```

### 2. Set Up Python Environment

```bash
# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (macOS/Linux)
source venv/bin/activate

# Install dependencies (when available)
pip install -r requirements.txt
```

### 3. Explore the Structure

```bash
# View documentation
cat docs/ARCHITECTURE.md
cat docs/KNOWLEDGE_GRAPH_SCHEMA.md
cat ROADMAP.md

# Check example entry
cat library/software/example-i2c-conflict.md
```

---

## Development Environment Setup

### Option A: Full Stack (Graph + MCP + Agents)

**For Phase 2+ development - complete system**

#### 1. Install Neo4j Desktop

1. Download from https://neo4j.com/download/
2. Create a new project: "PROVES Library"
3. Create a database: "proves-dev"
   - Password: `proves-dev-123` (change for production!)
   - Version: Latest (5.x)
4. Start the database
5. Open Neo4j Browser: http://localhost:7474

#### 2. Load Initial Schema

```bash
# Install Neo4j Python driver
pip install neo4j

# Run schema setup script (coming soon)
python scripts/setup_graph_schema.py

# Verify
# Open Neo4j Browser, run: MATCH (n) RETURN count(n)
# Should see 0 nodes initially
```

#### 3. Set Up MCP Server

```bash
cd mcp-server

# Install dependencies
pip install fastapi uvicorn pydantic python-dotenv neo4j sentence-transformers

# Create .env file
cat > .env << EOF
LIBRARY_PATH=../library
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=proves-dev-123
EMBEDDING_MODEL=all-MiniLM-L6-v2
LOG_LEVEL=INFO
EOF

# Run server
python server.py

# Test (in another terminal)
curl http://localhost:8000/health
```

#### 4. Set Up Risk Scanner

```bash
cd risk-scanner

# Install dependencies
pip install click rich pyyaml

# Run test scan
python scanner.py --help

# Scan example repo (when available)
python scanner.py --repo /path/to/test-repo --output report.json
```

#### 5. Set Up LangGraph Agents (Phase 3+)

```bash
# Install LangGraph dependencies
pip install langgraph langchain langchain-anthropic

# Set API keys
export ANTHROPIC_API_KEY="your-key-here"  # Get from https://console.anthropic.com

# Test agent (when available)
python agents/curator/agent.py --test
```

### Option B: Documentation Only

**For Phase 1 - understanding and planning**

```bash
# Just read the docs!
cat docs/ARCHITECTURE.md | less
cat docs/KNOWLEDGE_GRAPH_SCHEMA.md | less
cat ROADMAP.md | less

# View diagrams in VS Code with Markdown Preview
code docs/ARCHITECTURE.md
# Press Ctrl+Shift+V for preview
```

### Option C: Frontend Only (VS Code Extension)

**For VS Code extension development**

```bash
cd vscode-extension  # (when created)

# Install dependencies
npm install

# Run extension in development mode
npm run dev

# This opens a new VS Code window with the extension loaded
```

---

## Your First Contribution

### 1. Add a New Library Entry

**Goal:** Create a new risk pattern or lesson entry

```bash
# 1. Create file
touch library/software/my-new-pattern.md

# 2. Use this template
cat > library/software/my-new-pattern.md << 'EOF'
---
entry_id: software-XXX  # Get next ID from maintainers
type: risk-pattern | lesson | config
domain: software
observed: Brief description of what you observed
sources:
  - citation: "Source name"
    url: "https://..."
    excerpt: "Relevant quote"
artifacts:
  - type: component | repo | doc | test
    path: "Path or URL"
    description: "What this artifact is"
resolution: How it was resolved
verification: How to verify the fix works
tags: [tag1, tag2, tag3]
created: 2024-12-20
updated: 2024-12-20
---

# Title of Your Entry

## Problem

Describe the problem you encountered...

## Context

What was the specific situation?...

## Resolution

How did you solve it?...

## Verification

How can someone verify this works?...

## Related Patterns

- `software-001`: Related pattern
- `build-042`: Related build issue
EOF

# 3. Validate (when validator available)
python scripts/validate_entry.py library/software/my-new-pattern.md

# 4. Submit PR
git checkout -b add-software-XXX
git add library/software/my-new-pattern.md
git commit -m "Add software-XXX: [brief description]"
git push origin add-software-XXX
# Open PR on GitHub
```

### 2. Add a Graph Node

**Goal:** Add a component/port/resource to the knowledge graph

```bash
# 1. Define node in CSV format
cat >> data/nodes.csv << EOF
id,type,name,namespace,version,category
comp_new,SoftwareComponent,MyComponent,MyNamespace,v1.0.0,software
EOF

# 2. Define edges
cat >> data/edges.csv << EOF
source,target,relation,forward,reverse,strength,mechanism,knownness,scope
comp_new,existing_comp,REQUIRES,true,false,always,protocol,known,fprime@v3.4.3
EOF

# 3. Ingest into graph (when script available)
python scripts/ingest_nodes.py data/nodes.csv data/edges.csv

# 4. Verify in Neo4j Browser
# Run: MATCH (n {id: 'comp_new'}) RETURN n
```

### 3. Add a Risk Pattern to Scanner

**Goal:** Detect a new type of risk

```bash
# 1. Create pattern file
cat > risk-scanner/patterns/my_pattern.py << 'EOF'
def detect_my_pattern(ast_tree, config):
    """
    Detect [describe your pattern]

    Pattern: [what to look for]
    Severity: HIGH | MEDIUM | LOW
    Library Reference: software-XXX
    """
    # Your detection logic here
    # Return Risk(...) if found, None otherwise
    return None
EOF

# 2. Register pattern in scanner.py
# Add: from patterns.my_pattern import detect_my_pattern
# Add to pattern list

# 3. Test
python risk-scanner/scanner.py --repo test-repos/my-test --pattern my_pattern

# 4. Submit PR
```

---

## Development Workflows

### Workflow 1: Building a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Develop
# ... make changes ...

# 3. Test
pytest tests/  # When tests exist
python -m mypy .  # Type checking

# 4. Commit
git add .
git commit -m "feat: Add my feature

Detailed description of what this does and why."

# 5. Push and PR
git push origin feature/my-feature
# Open PR on GitHub
```

### Workflow 2: Testing Cascade Analysis

```bash
# 1. Start Neo4j
# Open Neo4j Desktop, start database

# 2. Load test data
python scripts/load_test_cascade.py  # Loads RadioTX → Brownout example

# 3. Run cascade query
curl -X POST http://localhost:8000/graph/cascade \
  -H "Content-Type: application/json" \
  -d '{
    "start_node": "RadioTX_Component",
    "resource_type": "power",
    "max_depth": 5
  }'

# 4. Visualize in Neo4j Browser
# Run: MATCH p=(n {id: 'RadioTX_Component'})-[*1..5]->(m) RETURN p
```

### Workflow 3: Running Sweeps

```bash
# 1. Configure sweep
cat > sweep_config.yaml << EOF
sweep: cascade
start_nodes:
  - RadioTX_Component
  - PowerMonitor_Component
resource_type: power
max_depth: 5
EOF

# 2. Run sweep
python scripts/run_sweep.py sweep_config.yaml --output cascade_report.md

# 3. Review results
cat cascade_report.md
```

---

## Testing

### Unit Tests

```bash
# Run all tests
pytest tests/

# Run specific test file
pytest tests/test_mcp_server.py

# Run with coverage
pytest --cov=mcp-server --cov-report=html
# Open htmlcov/index.html
```

### Integration Tests

```bash
# Test MCP server + Graph DB
pytest tests/integration/test_mcp_graph.py

# Test Scanner + MCP server
pytest tests/integration/test_scanner_mcp.py
```

### End-to-End Tests

```bash
# Full workflow test
pytest tests/e2e/test_full_workflow.py
```

---

## Common Tasks

### Task: Update Documentation

```bash
# Edit docs
code docs/ARCHITECTURE.md

# Preview mermaid diagrams in VS Code
# Install extension: "Markdown Preview Mermaid Support"
# Press Ctrl+Shift+V

# Commit
git add docs/
git commit -m "docs: Update architecture diagrams"
```

### Task: Add a New MCP Endpoint

```bash
# 1. Edit server.py
code mcp-server/server.py

# 2. Add endpoint
@app.post("/graph/my-new-endpoint")
async def my_new_endpoint(params: MyParams):
    # Implementation
    return result

# 3. Add tests
code mcp-server/tests/test_endpoints.py

# 4. Test
pytest mcp-server/tests/test_endpoints.py::test_my_new_endpoint

# 5. Update API docs
code docs/MCP_API.md  # When created
```

### Task: Query the Knowledge Graph

```bash
# Using Neo4j Browser (http://localhost:7474)

# Find all components
MATCH (n:SoftwareComponent) RETURN n

# Find all REQUIRES edges
MATCH (a)-[r:REQUIRES]->(b) RETURN a, r, b

# Find cascade paths from RadioTX
MATCH p=(start {id: 'RadioTX_Component'})-[*1..5]->(end)
WHERE ALL(r IN relationships(p) WHERE r.relation IN ['CONSUMES', 'CONSTRAINS', 'COUPLES_TO'])
RETURN p

# Find all unknown edges
MATCH (a)-[r]->(b)
WHERE r.knownness = 'unknown'
RETURN a, r, b
```

---

## Troubleshooting

### Problem: Neo4j won't start

**Solution:**
```bash
# Check if port 7687 is in use
netstat -an | grep 7687

# Kill conflicting process
# Windows: taskkill /F /PID [PID]
# Linux/Mac: kill -9 [PID]

# Try different port in Neo4j Desktop settings
```

### Problem: MCP server import errors

**Solution:**
```bash
# Ensure virtual environment is activated
which python  # Should point to venv/bin/python

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Check Python version
python --version  # Should be 3.9+
```

### Problem: Graph queries are slow

**Solution:**
```bash
# Create indexes in Neo4j Browser
CREATE INDEX component_id FOR (n:SoftwareComponent) ON (n.id);
CREATE INDEX edge_relation FOR ()-[r]->() ON (r.relation);

# Check query execution plan
EXPLAIN MATCH (n {id: 'comp_001'}) RETURN n
```

### Problem: LangGraph agents timeout

**Solution:**
```bash
# Increase timeout in config
export LANGCHAIN_TIMEOUT=120  # seconds

# Use faster model for testing
# In agent code: model = "claude-haiku-3-5-20250929"

# Check API key is valid
echo $ANTHROPIC_API_KEY
```

---

## Learning Resources

### Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture with diagrams
- **[KNOWLEDGE_GRAPH_SCHEMA.md](docs/KNOWLEDGE_GRAPH_SCHEMA.md)** - ERV schema specification
- **[AGENTIC_ARCHITECTURE.md](docs/AGENTIC_ARCHITECTURE.md)** - LangGraph + agents design
- **[ROADMAP.md](ROADMAP.md)** - Implementation roadmap

### External Resources

- [Neo4j Documentation](https://neo4j.com/docs/)
- [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [F´ Documentation](https://fprime.jpl.nasa.gov/)
- [PROVES Kit Documentation](https://github.com/proveskit)

### Example Queries

See [docs/EXAMPLE_QUERIES.md](docs/EXAMPLE_QUERIES.md) (coming soon) for common graph queries and MCP API examples.

---

## Getting Help

- **Issues:** Open an issue on [GitHub](https://github.com/Lizo-RoadTown/PROVES_LIBRARY/issues)
- **Discussions:** Use [GitHub Discussions](https://github.com/Lizo-RoadTown/PROVES_LIBRARY/discussions)
- **Email:** eosborn@cpp.edu (for urgent matters)

---

## Next Steps

Now that you're set up:

1. **Read the architecture docs** to understand the system
2. **Explore the example library entry** to see the format
3. **Try adding a new entry** following the contribution guide
4. **Join a dev discussion** on GitHub

Welcome to the team! 🚀

---

**Last Updated:** December 19, 2024
