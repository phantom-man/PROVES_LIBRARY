# PROVES Library

Open source knowledge library for PROVES Kit and F Prime CubeSat missions.

## Overview

The PROVES Library is the working implementation of the knowledge capture and interrogation system described in the [PROVES Kit Agent portfolio](https://lizo-roadtown.github.io/proveskit-agent/).

**Core Problem:** Knowledge is fragmented across repos, issues, commits, docs, and teams - even in open source. University CubeSat programs can't learn from each other's failures and successes.

**Our Solution:** Automated knowledge capture through risk scanning + MCP-backed interrogatable library.

## System Architecture

```
┌─────────────────┐
│  Risk Scanner   │ ← Scans repos, detects risks (PUSH to teams)
│                 │ ← Captures context/fixes (PULL from teams)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Library     │ ← Stores lessons as markdown with metadata
│  (this repo)    │ ← Citations, excerpts, artifact links
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   MCP Server    │ ← Makes library interrogatable (not just searchable)
│                 │ ← Structured queries for AI tools
└─────────────────┘
```

## Repository Structure

```
PROVES_LIBRARY/
├── library/              # Knowledge entries (markdown with metadata)
│   ├── build/           # Build knowledge (assembly, hardware, testing)
│   ├── software/        # Software architecture (F Prime patterns)
│   └── ops/             # Operational knowledge (configs, fixes)
├── mcp-server/          # MCP server implementation
├── risk-scanner/        # Repository risk scanner
├── docs/                # Documentation and task breakdown
├── tests/               # Test suite
└── README.md
```

## What Needs to Be Built

### Phase 1: Foundation (Current)
- [x] Library structure (markdown storage)
- [ ] Entry schema definition
- [ ] MCP server skeleton
- [ ] Risk scanner skeleton

### Phase 2: Core Functionality
- [ ] MCP server endpoints (search, fetch, list)
- [ ] Risk scanner pattern matching
- [ ] Library indexing system
- [ ] Entry validation

### Phase 3: Integration
- [ ] VS Code extension (queries MCP)
- [ ] Risk scan workflow (push/pull loop)
- [ ] Community review process

### Phase 4: Agentic Systems (Future)
- [ ] Curator agent (normalizes lessons, maintains citations)
- [ ] Builder agent (generates components/code from patterns)

## Entry Format

Knowledge entries are stored as markdown files with frontmatter metadata:

```markdown
---
type: lesson | risk-pattern | config
domain: build | software | ops
observed: Brief context description
sources:
  - citation: Source URL or reference
    excerpt: Relevant excerpt
artifacts:
  - type: component | repo | doc | test
    path: Path or URL to artifact
resolution: How it was fixed (if applicable)
verification: How to verify the fix
tags: [power, radio, timing, etc]
---

# Entry Title

Detailed description of the lesson, risk pattern, or operational knowledge.

## Context

What led to this discovery...

## Resolution

How it was addressed...

## Verification

How to confirm the fix works...
```

## Knowledge Capture Flow

1. **Risk Scanner** runs on a repo
2. Detects mission-critical risk patterns
3. **PUSH:** Alerts team with risk details + fix links
4. **PULL:** Captures team's context and resolution
5. Raw capture submitted for review
6. **(Future) Curator Agent** normalizes into entry format
7. Human review approves entry
8. Entry added to library
9. **MCP Server** re-indexes
10. All teams benefit from new knowledge

## Technology Stack

- **Library Storage:** Markdown files with YAML frontmatter
- **MCP Server:** Python (FastAPI or similar)
- **Risk Scanner:** Python (AST parsing, pattern matching)
- **Indexing:** SQLite + embeddings (for semantic search)
- **VS Code Extension:** TypeScript

## Getting Started

### Prerequisites

- Python 3.9+
- Node.js 16+ (for VS Code extension)
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/Lizo-RoadTown/PROVES_LIBRARY.git
cd PROVES_LIBRARY

# Install MCP server dependencies
cd mcp-server
pip install -r requirements.txt

# Install risk scanner dependencies
cd ../risk-scanner
pip install -r requirements.txt
```

### Running the MCP Server

```bash
cd mcp-server
python server.py
```

### Running a Risk Scan

```bash
cd risk-scanner
python scanner.py --repo /path/to/repo
```

## Contributing

This is an open source project. Contributions welcome:

- Submit knowledge entries (with citations)
- Improve risk patterns
- Enhance MCP server
- Add scanner capabilities

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](LICENSE) file

## Contact

**Elizabeth Osborn**
Cal Poly Pomona
eosborn@cpp.edu

## Acknowledgments

- NASA JPL for F Prime
- Cal Poly Pomona Bronco Space Lab for PROVES Kit
- Anthropic for Claude and MCP

---

**Portfolio Site:** https://lizo-roadtown.github.io/proveskit-agent/
