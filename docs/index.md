---
layout: article
title: PROVES Library
key: page-home
---

# PROVES Library: Trial Dependency Mapping

## Visual Analysis of CubeSat Knowledge Dependencies

This site demonstrates comprehensive dependency tracking for CubeSat mission-critical knowledge. We analyzed two real-world documents to show how hidden dependencies between systems can lead to catastrophic failures.

---

## The Problem: Knowledge Loss at Team Boundaries

**Real Scenario:** Team B modified power management code, tested it locally (worked), but caused catastrophic failure 2 weeks before launch. Team A knew the answer from "several generations before" but the knowledge wasn't accessible across team boundaries.

**Our Solution:** Map EVERY dependency, track WHERE knowledge lives, and alert on knowledge at risk of loss.

---

## Trial Analysis Summary

### Documents Analyzed

1. **[F´ I2C Driver Documentation](https://github.com/nasa/fprime/blob/devel/docs/how-to/develop-device-driver.md)** (411 lines)
   - NASA/JPL flight software framework
   - I2C communication and device driver patterns

2. **[PROVES Kit Power Management](https://github.com/proveskit/pysquared/blob/main/docs/load_switch.md)** (154 lines)
   - University CubeSat platform
   - Load switch control for subsystem power

### Key Findings

- **45+ Dependencies Identified** across 6 categories
- **4 Critical Cross-System Dependencies** found (not documented in either system)
- **2 Complete Transitive Dependency Chains** traced
- **5 Major Knowledge Gaps** detected
- **Team Interface Weakness** identified between F´ and PROVES Kit teams

---

## Interactive Diagrams

Explore the dependency relationships through interactive visualizations:

### 📊 [Dependency Overview](diagrams/overview.html)
Complete inventory of all 45+ dependencies found in both documents, categorized by type (software, hardware, configuration).

### 🔗 [Cross-System Dependencies](diagrams/cross-system.html)
The 4 critical dependencies between F´ and PROVES Kit that are **NOT documented** in either system - the exact failure mode from the Team A/Team B scenario.

### ⛓️ [Transitive Dependency Chains](diagrams/transitive-chains.html)
Multi-hop dependency paths showing how Application Layer depends on I2C, which depends on Power, which depends on Load Switch configuration.

### ⚠️ [Knowledge Gaps](diagrams/knowledge-gaps.html)
What's NOT documented: power-on timing, voltage stability, error recovery, bus sharing conflicts, and platform integration.

### 👥 [Team Boundaries](diagrams/team-boundaries.html)
Organizational analysis showing WEAK interface between NASA/JPL F´ team and university PROVES Kit teams - where knowledge gets lost.

---

## System Capabilities Demonstrated

### ✅ Comprehensive Dependency Discovery
- Found EVERY dependency mentioned in source documents
- Tracked 6 dependency types: software, hardware, configuration, build, data, state

### ✅ Location Tracking
- Every dependency has source file and line number citations
- Can answer: "Where is Component X mentioned?"

### ✅ Cross-Document Analysis
- Identified relationships between separate documentation sources
- Found hidden dependencies across system boundaries

### ✅ Knowledge Gap Detection
- Flagged 5 major undocumented dependencies
- Detected negative space (what's missing from docs)

### ✅ Transitive Chain Tracing
- Followed dependencies through multiple hops
- Identified complete dependency paths

### ✅ Organizational Insight
- Mapped knowledge to source teams
- Identified weak team interfaces
- Flagged knowledge at risk of loss

---

## Technical Implementation

This analysis demonstrates the foundation for the PROVES Library automated knowledge graph system:

**Database Schema:**
- `library_entries` - Indexed documentation
- `kg_nodes` - Components and concepts
- `kg_relationships` - Dependency edges with metadata
- `team_boundaries` - Organizational interfaces
- `knowledge_validation` - Validation tracking

**Query Capabilities:**
```sql
-- "What depends on Component X?"
SELECT * FROM kg_relationships WHERE to_node_id = X;

-- "Where is knowledge about X documented?"
SELECT * FROM library_entries WHERE content LIKE '%X%';

-- "What breaks if I change X?"
SELECT transitive_dependencies(X);
```

---

## Next Steps

### Phase 1: Manual Trial ✅ (Complete)
- Fetch F´ and PROVES Kit documentation
- Identify all dependencies manually
- Create comprehensive dependency map
- Generate visualization diagrams

### Phase 2: Database Integration (In Progress)
- Insert trial documents into Neon PostgreSQL
- Create knowledge graph nodes and relationships
- Test query capabilities
- Validate approach scalability

### Phase 3: Automation (Planned)
- NLP extraction of dependencies from markdown
- Code analysis for `#include` and import statements
- Configuration file parsing (.fpp, .xml, CMake)
- Automated dependency discovery at scale

### Phase 4: Agent Integration (Planned)
- Curator agent for quality assessment
- Builder agent for component generation
- Risk scanner for failure pattern detection
- Continuous knowledge capture from teams

---

## Documentation

- [Trial Mapping Design Document](TRIAL_MAPPING_DESIGN.html)
- [Comprehensive Dependency Map](../trial_docs/COMPREHENSIVE_DEPENDENCY_MAP.html)
- [Original F´ Documentation](../trial_docs/fprime_i2c_driver_full.html)
- [Original PROVES Kit Documentation](../trial_docs/proves_power_full.html)

---

## About PROVES Library

The PROVES Library is an agentic knowledge base system for CubeSat missions that:
- Captures tribal knowledge before it's lost to student turnover
- Maps technical dependencies (ERV) and organizational knowledge flow (FRAMES)
- Prevents mission failures by surfacing hidden dependencies
- Scales from documentation to code to runtime telemetry

**Technology Stack:**
- LangGraph + Claude (Deep Agents)
- Neon PostgreSQL + pgvector
- MCP (Model Context Protocol)
- GitHub API integration
- RAG (Retrieval Augmented Generation)

---

**Last Updated:** December 20, 2024
**Status:** Trial Phase Complete, Database Integration In Progress
