# Archive Manifest

> **The `.archive/` folder is hidden from normal workflow.** This manifest documents what's there and why.

---

## Why Archive?

Archived items contain **outdated mental models** that caused drift:
- "Dependencies" instead of "Components + Interfaces + Flows"
- "Criticality as gate" instead of "Capture ALL, humans verify"
- "Agents decide importance" instead of "Agents map structure"

**The archive exists to prevent these wrong models from infecting new work.**

---

## What's Archived (December 2025)

| Folder | Contents | Why Archived |
|--------|----------|--------------|
| `.archive/curator-agent-old/` | Old monitoring scripts, demo files | Replaced by FRAMES-based architecture |
| `.archive/legacy-agents/` | Standalone agent implementations | Replaced by LangGraph Deep Agents |
| `.archive/design-docs/` | MCP server, risk scanner designs | Not implemented, outdated approach |
| `.archive/outdated-docs/` | Old LangSmith, OpenTelemetry, GitHub Actions docs | Not implemented or superseded |
| `.archive/old-configs/` | Neo4j configs, old env templates | Replaced by PostgreSQL/Neon |
| `.archive/historical/` | Setup logs, status snapshots | Historical record only |

---

## Key Lessons Extracted Before Archiving

Critical knowledge was moved to [CANON.md](CANON.md) before archiving:

| From | To CANON.md | Lesson |
|------|-------------|--------|
| `AGENT_INTELLIGENCE_GUIDE.md` | §1, §3 | Autonomous intelligence, transfer learning |
| `DESIGN_ACTION_LEVEL_HITL.md` | §2 | Plan-then-execute pattern |
| `OPTION_REMOVE_HITL.md` | §1.2 | **WRONG MODEL** - "Criticality as gate" was wrong |
| Criticality model docs | §1.2 | **CORRECTED** to Truth Layer Architecture |

---

## Current Architecture (FRAMES-Based)

The current system uses FRAMES methodology:
- **ONTOLOGY.md** - Loaded into every extraction prompt to prevent drift
- **CANON.md** - Immutable principles that must never be lost
- **curator-agent/** - LangGraph Deep Agents using FRAMES vocabulary

### FRAMES Vocabulary

| Term | Meaning | Old (Wrong) Term |
|------|---------|------------------|
| **Components** | Semi-autonomous units with boundaries | "Things" |
| **Interfaces** | Where components connect | "Connections" |
| **Flows** | What moves through interfaces | "Dependencies" |
| **Mechanisms** | What maintains interfaces | (not captured) |
| **Confidence** | Documentation clarity (agent assesses) | - |
| **Criticality** | Mission impact (human assigns) | "HIGH/MEDIUM/LOW gate" |

---

## Never Repeat These Mistakes

1. ❌ "Dependencies" without structure → Use Components + Interfaces + Flows
2. ❌ "Criticality as gate" → Capture ALL, humans verify
3. ❌ "Agents decide importance" → Agents map structure, humans judge
4. ❌ Prompts without ontology → EVERY prompt loads ONTOLOGY.md

---

## How to Update

When archiving new items:

1. **Extract lessons** to CANON.md first
2. **Move files** to appropriate `.archive/` subfolder
3. **Update this manifest** with what/why
4. **Check for infection** - grep for old vocabulary in active code

---

Last Updated: December 22, 2025
