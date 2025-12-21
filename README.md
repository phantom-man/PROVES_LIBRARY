# PROVES Library

**Agentic Knowledge Base for CubeSat Mission Safety**

[![GitHub Pages](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://lizo-roadtown.github.io/PROVES_LIBRARY/)
[![LangSmith](https://img.shields.io/badge/tracing-LangSmith-orange)](https://smith.langchain.com)

---

## 🎯 Overview

The PROVES Library is an **agentic knowledge graph system** that prevents catastrophic CubeSat mission failures by tracking hidden cross-system dependencies.

**The Problem We Solve:**

> *"Team A modified power management code. Tested locally - worked perfectly. Two weeks before launch, Team B's I2C sensors stopped communicating. Root cause: undocumented dependency on load switch timing. Mission delayed 6 months."*

Knowledge is fragmented across teams, repos, docs, and commits. Dependencies are hidden. Failures cascade across systems. University CubeSat programs can't learn from each other.

**Our Solution:**

LLM-powered dependency extraction + knowledge graph + continuous monitoring → Prevent "Team A changes something, Team B fails" scenarios.

---

## 🏗️ Current Architecture

```
┌──────────────────────────────────────────────────────┐
│              PROVES Library System                   │
├──────────────────────────────────────────────────────┤
│                                                      │
│  📄 Documentation Sources                            │
│     ├─ F´ Framework (NASA/JPL)                      │
│     └─ PROVES Kit (Cal Poly Pomona)                 │
│              ↓                                       │
│  🤖 LLM Dependency Extractor (GPT-4o-mini)          │
│     ├─ Chunking & Prompt Engineering                │
│     ├─ Cross-Document Analysis                      │
│     └─ LangSmith Tracing (Full Observability)       │
│              ↓                                       │
│  🗄️  Neon PostgreSQL (Cloud Knowledge Graph)        │
│     ├─ kg_nodes (Components, Hardware, Patterns)    │
│     ├─ kg_relationships (ERV Dependency Types)      │
│     ├─ library_entries (Source Documentation)       │
│     └─ pgvector (Semantic Search)                   │
│              ↓                                       │
│  🌐 GitHub Pages (Interactive Visualization)        │
│     └─ https://lizo-roadtown.github.io/             │
│        PROVES_LIBRARY/                               │
│                                                      │
│  📊 LangSmith (Observability Dashboard)             │
│     └─ https://smith.langchain.com                  │
└──────────────────────────────────────────────────────┘
```

---

## ✨ What's Built (Current State)

### ✅ Phase 1: Trial Mapping - **COMPLETE**

**Proven the Concept:**
- Manually analyzed F´ I2C Driver (411 lines) + PROVES Kit Power Management (154 lines)
- **Found 45+ dependencies** with exact line citations
- **Discovered 4 critical cross-system dependencies** (undocumented in either system!)
- **Identified 5 major knowledge gaps** (timing specs, voltage requirements, error recovery)
- **Mapped team boundaries** (F´ ↔ PROVES interface strength: 2/10 WEAK)

**Results:**
- [Comprehensive Dependency Map](trial_docs/COMPREHENSIVE_DEPENDENCY_MAP.md)
- [GitHub Pages Visualizations](https://lizo-roadtown.github.io/PROVES_LIBRARY/)
- Demonstrated feasibility of automated dependency extraction

### ✅ Phase 2: Infrastructure - **COMPLETE**

**Cloud Database:**
- Neon PostgreSQL with pgvector for semantic search
- Knowledge graph schema (nodes + ERV relationships)
- Connection pooling and query utilities

**LLM Extraction Pipeline:**
- GPT-4o-mini powered dependency extractor
- Document chunking and prompt engineering
- Cross-document dependency detection
- Full LangSmith tracing for observability

**Visualization:**
- GitHub Pages site with Tactile theme
- 5 interactive Mermaid diagram pages
- Automated deployment via GitHub Actions

### ⏸️ Phase 3: Automation - **IN PROGRESS**

**Next Steps:**
- Test automated extraction vs manual analysis
- Refine prompts based on LangSmith traces
- Load extracted dependencies into knowledge graph
- Validate query patterns (transitive chains, cascade paths)

---

## 🚀 Quick Start

### Prerequisites

- **Python 3.9+**
- **Git**
- **API Keys:**
  - OpenAI (for LLM extraction)
  - LangSmith (for tracing/observability)
  - Neon PostgreSQL (database connection string)

### Installation

```bash
# 1. Clone repository
git clone https://github.com/Lizo-RoadTown/PROVES_LIBRARY.git
cd PROVES_LIBRARY

# 2. Set up Python environment
python -m venv .venv
.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # macOS/Linux

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment
cp .env.example .env
# Edit .env and add your API keys:
#   NEON_DATABASE_URL=postgresql://...
#   OPENAI_API_KEY=sk-...
#   LANGSMITH_API_KEY=lsv2_pt_...
#   LANGSMITH_TRACING=true
```

### Test the System

```bash
# Test database connection
python scripts/db_connector.py

# Test knowledge graph
python scripts/graph_manager.py

# Run dependency extraction (with LangSmith tracing)
python scripts/dependency_extractor.py trial_docs/fprime_i2c_driver_full.md

# View trace in LangSmith UI
# → https://smith.langchain.com (PROVES_Library project)
```

---

## 📚 Key Concepts

### ERV (Engineering Relationship Vocabulary)

6 dependency types for mission-critical systems:

| Type | Description | Example |
|------|-------------|---------|
| **depends_on** | Runtime dependency | ImuManager depends_on LinuxI2cDriver |
| **requires** | Build/config requirement | I2C driver requires board config |
| **enables** | Makes something possible | Load switch enables sensor power |
| **conflicts_with** | Incompatible | Two devices conflict on same I2C address |
| **mitigates** | Reduces risk | Watchdog mitigates infinite loop risk |
| **causes** | Leads to effect | Power glitch causes sensor reset |

### Knowledge Gaps

Dependencies that **exist but aren't documented**:

From our trial mapping:
- ❌ Timing specifications (how fast must I2C clock be?)
- ❌ Voltage requirements (what voltage range for IMU?)
- ❌ Error recovery (what if I2C transaction fails?)
- ❌ Bus conflicts (how to handle address collisions?)
- ❌ Platform integration (which boards support which sensors?)

### Team Boundaries (FRAMES Model)

Organizational interfaces where knowledge is **lost**:

- **F´ Team ↔ PROVES Kit Team:** Interface strength 2/10 (WEAK)
- Documentation doesn't cross team boundaries
- Student graduation → 90% knowledge retention loss
- Cross-system dependencies remain hidden

### Transitive Dependencies

Multi-hop chains that cascade across systems:

```
Application Code
  → Device Manager
    → Bus Driver
      → Hardware Abstraction
        → Board Configuration
          → Power Management
            → Load Switch
              → Voltage Regulator
                → Battery (13 hops!)
```

One change at any level can cascade failures through entire chain.

---

## 🗂️ Repository Structure

```
PROVES_LIBRARY/
├── scripts/                    # Core utilities
│   ├── db_connector.py        # Neon PostgreSQL connection
│   ├── graph_manager.py       # Knowledge graph CRUD
│   └── dependency_extractor.py # LLM extraction + tracing
│
├── docs/                       # Documentation
│   ├── AGENT_HANDOFF.md       # 👈 START HERE (agent onboarding)
│   ├── AGENTIC_ARCHITECTURE.md # Agent system design
│   ├── KNOWLEDGE_GRAPH_SCHEMA.md # Database schema
│   ├── LANGSMITH_INTEGRATION.md # Tracing setup
│   └── *.md                   # Additional docs
│
├── trial_docs/                # Trial mapping results
│   ├── COMPREHENSIVE_DEPENDENCY_MAP.md # Full analysis
│   ├── fprime_i2c_driver_full.md # F´ documentation
│   └── proves_kit_power_mgmt_full.md # PROVES Kit docs
│
├── mcp-server/                # MCP server (future)
├── risk-scanner/              # Risk scanner (future)
├── library/                   # Knowledge entries (future)
├── .env.example               # Environment template
├── requirements.txt           # Python dependencies
└── README.md                  # This file
```

---

## 📖 Documentation

| Document | Purpose | Status |
|----------|---------|--------|
| **[AGENT_HANDOFF.md](AGENT_HANDOFF.md)** | **👈 START HERE** - Complete project status | ✅ Current |
| [GETTING_STARTED.md](GETTING_STARTED.md) | Setup and installation guide | ✅ Current |
| [ROADMAP.md](ROADMAP.md) | Implementation roadmap | ✅ Current |
| [docs/AGENTIC_ARCHITECTURE.md](docs/AGENTIC_ARCHITECTURE.md) | Agent system design | ✅ Current |
| [docs/LANGSMITH_INTEGRATION.md](docs/LANGSMITH_INTEGRATION.md) | Tracing and observability | ✅ Current |
| [docs/KNOWLEDGE_GRAPH_SCHEMA.md](docs/KNOWLEDGE_GRAPH_SCHEMA.md) | Database schema | ✅ Current |
| [trial_docs/COMPREHENSIVE_DEPENDENCY_MAP.md](trial_docs/COMPREHENSIVE_DEPENDENCY_MAP.md) | Trial results | ✅ Current |

---

## 🌐 Live Demos

- **GitHub Pages Visualization:** https://lizo-roadtown.github.io/PROVES_LIBRARY/
- **LangSmith Tracing:** https://smith.langchain.com (PROVES_Library project)
- **GitHub Repository:** https://github.com/Lizo-RoadTown/PROVES_LIBRARY

---

## 🔬 Research Background

This system implements concepts from:

- **FRAMES** (Sosa et al.) - Organizational knowledge flow analysis
- **ERV** (Engineering Relationship Vocabulary) - Structured dependency semantics
- **Knowledge Graphs** - Graph-based relationship modeling
- **LLM Extraction** - Automated dependency discovery from documentation
- **Agentic Systems** - Autonomous knowledge curation and validation

---

## 🤝 Contributing

This is an open research project. Contributions welcome:

- 🐛 Report issues with dependency extraction
- 📝 Submit knowledge entries with citations
- 🔍 Improve extraction prompts
- 🎨 Enhance visualizations
- 🧪 Add test cases

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file

Open source for the benefit of the CubeSat community.

---

## 👥 Team

**Elizabeth Osborn**
Cal Poly Pomona
eosborn@cpp.edu

**Acknowledgments:**
- NASA JPL for F Prime framework
- Cal Poly Pomona Bronco Space Lab for PROVES Kit
- Anthropic for Claude and Model Context Protocol
- LangSmith for LLM observability

---

## 🚨 Mission-Critical Use Case

> **Scenario:** University CubeSat program, 18 months before launch.
>
> **Team A (Power):** Updates load switch timing to optimize battery life. Tests locally - works perfectly. Commits change.
>
> **Team B (Sensors):** Two weeks later, IMU sensor stops responding during integration test. Root cause after 3 days of debugging: I2C driver depended on old timing. Dependency was **undocumented**.
>
> **Impact:** Mission delay, team morale damage, risk of deadline miss.
>
> **Prevention:** PROVES Library would have:
> 1. Extracted the I2C timing dependency from documentation
> 2. Detected the cross-system dependency (Power → Sensors)
> 3. Flagged the change as **HIGH RISK** before merge
> 4. Alerted Team B of required validation
>
> **Result:** Issue caught in hours, not days. Mission stays on schedule.

This is why we build.

---

**Portfolio Site:** https://lizo-roadtown.github.io/proveskit-agent/
