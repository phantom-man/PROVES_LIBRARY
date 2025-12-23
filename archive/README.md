# Archive Directory

This directory contains outdated, superseded, or unimplemented code and documentation from the PROVES Library project evolution.

> ⚠️ **Important:** Critical lessons and design principles from these documents have been extracted to [CANON.md](../CANON.md). The CANON file preserves institutional knowledge that must never be lost.

## Knowledge Extraction (December 2025)

The following key concepts were extracted from archived documents before archiving:

| Archived Document | Extracted To | Key Lessons |
|-------------------|--------------|-------------|
| `AGENT_INTELLIGENCE_GUIDE.md` | CANON.md §1, §3 | Autonomous intelligence principles, transfer learning methodology |
| `DESIGN_ACTION_LEVEL_HITL.md` | CANON.md §2 | Data-level vs action-level HITL, plan-then-execute pattern |
| `OPTION_REMOVE_HITL.md` | CANON.md §1.2 | "Criticality is metadata, not a gate" principle |
| `README_MONITORING.md` | CANON.md §9, §10 | Transparency stack, monitoring patterns |
| `GITHUB_API_SYNC_QUICKSTART.md` | CANON.md §9.3 | GitHub API sync pattern |
| `12_extraction_confidence.sql` | `12_extraction_enums.sql` | ENUMs extracted, duplicate table removed |
| `AGENT_BEHAVIOR_SPEC.md` (v1) | `AGENT_BEHAVIOR_SPEC.md` (v2) | 9 agents → 3 agents, LangGraph loop control |

## Recent Changes (December 22, 2025)

### Schema Consolidation
- **Deleted:** `12_extraction_confidence.sql` (duplicate table removed)
- **Created:** `12_extraction_enums.sql` (ENUMs only, no duplicate tables)
- **Kept:** `13_validation_staging.sql` as the single staging table

### Agent Spec Simplification
- **Old:** 9 agents (Capture, Extraction, Validator, Parser, Chunking, Embedding, Graph, Scoring)
- **New:** 3 agents (Extractor, Validator, Decision Maker)
- **Not agents:** Chunking, embedding, graph building, scoring → batch functions
- **Loop control:** LangGraph `recursion_limit` + `ToolCallLimitMiddleware` (not custom schema)

## Archive Organization

### curator-agent-old/
**Superseded curator agent scripts and documentation**
- Old monitoring scripts, demo files, and design docs
- Replaced by simplified agent architecture in `curator-agent/`

Contents:
- `README_OLD.md` - Old README before simplification
- `AGENT_INTELLIGENCE_GUIDE.md` - Old training approach doc
- `DESIGN_ACTION_LEVEL_HITL.md` - Design doc for HITL patterns
- `demo_learning.py`, `quick_monitor.py` - Old demo/monitoring scripts

### legacy-agents/
**Superseded agent implementations**
- Old standalone agent architecture (before LangGraph Deep Agents)
- Replaced by: [curator-agent/](../curator-agent/)

Contents:
- `agents/` - Old agent design docs and incomplete implementations
- `curator_agent.py` - Standalone curator agent (superseded by Deep Agent system)

### design-docs/
**Design documents for unimplemented features**
- Components that were designed but never built
- Kept for future reference

Contents:
- `mcp-server/` - MCP server design (not implemented)
- `risk-scanner/` - Risk scanner design (not implemented)

### outdated-docs/
**Documentation that no longer reflects current architecture**
- Old setup guides, architecture docs
- Superseded by current documentation

Contents:
- `LANGSMITH_INTEGRATION.md` - Old LangSmith setup (tracing now disabled)
- `OPENTELEMETRY_INTEGRATION.md` - OpenTelemetry docs (not implemented)
- `GITHUB_ACTIONS_SETUP.md` - CI/CD docs (not yet implemented)
- `GITHUB_API_SYNC_QUICKSTART.md` - GitHub sync (not yet implemented)

### old-configs/
**Deprecated configuration templates**
- Old database configurations (Neo4j)
- Outdated environment templates

### historical/
**Point-in-time records**
- Setup logs from specific dates
- Status snapshots

## Why Archive Instead of Delete?

Archiving preserves:
1. **Historical context** - Understanding how the project evolved
2. **Design decisions** - Why certain approaches were chosen or abandoned
3. **Future reference** - Ideas that might be revisited later
4. **Attribution** - Credit for work done, even if superseded

## What's Current?

See [FOLDER_STRUCTURE.md](../FOLDER_STRUCTURE.md) for the current project organization.

---

Last Updated: December 22, 2025
