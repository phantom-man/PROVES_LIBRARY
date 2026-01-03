---
layout: article
title: PROVES Library
key: page-home
---

# PROVES Library: Agentic Knowledge for CubeSat Mission Safety

**Automated dependency capture + knowledge graph + human review** to prevent
cross-team failures when critical knowledge disappears.

---

## dY>y At a Glance

<div class="card-grid card-grid-3">
  <div class="card">
    <h3>Capture</h3>
    <p>Extract dependencies with citations from docs, code, and issues.</p>
  </div>
  <div class="card">
    <h3>Validate</h3>
    <p>Normalize into ERV relationships and check duplicates.</p>
  </div>
  <div class="card">
    <h3>Review</h3>
    <p>Gate mission-critical items for human approval.</p>
  </div>
  <div class="card">
    <h3>Store</h3>
    <p>Write entries to a structured knowledge graph.</p>
  </div>
  <div class="card">
    <h3>Visualize</h3>
    <p>Render diagrams and trace transitive chains.</p>
  </div>
  <div class="card">
    <h3>Learn</h3>
    <p>Use feedback to improve prompts and patterns.</p>
  </div>
</div>

---

## dY?-‹,? Agentic AI Structure

```mermaid
---
config:
  theme: base
  fontSize: 16
  themeCSS: |
    .node rect, .cluster rect, .edgePath path { transition: filter 0.2s ease, stroke-width: 0.2s ease; }
    .node:hover rect, .cluster:hover rect, .edgePath:hover path { filter: drop-shadow(0 0 8px rgba(0,0,0,0.35)); stroke-width: 3px; }
    .edgeLabel rect { rx: 6px; ry: 6px; stroke-width: 1px; }
    .cluster-label { font-weight: 600; }
    .node .label, .nodeLabel, .node foreignObject div, .edgeLabel { font-size: 20px !important; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif !important; }
    .node.decision .label, .node polygon + .label { font-size: 18px !important; }
  themeVariables:
    primaryColor: '#FFF3E0'
    secondaryColor: '#F3E5F5'
    tertiaryColor: '#FFF8E1'
    primaryTextColor: '#5D4037'
    secondaryTextColor: '#4A148C'
    tertiaryTextColor: '#F57F17'
    primaryBorderColor: '#FF6F00'
    secondaryBorderColor: '#9C27B0'
    tertiaryBorderColor: '#FBC02D'
    background: '#FFF8E1'
    textColor: '#5D4037'
    lineColor: '#FF9800'
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    fontSize: '16px'
    nodeBorder: '#FF6F00'
    mainBkg: '#FFF3E0'
    clusterBkg: '#F3E5F5'
    clusterBorder: '#9C27B0'
    edgeLabelBackground: '#FFF8E1'
    actorBkg: '#FFF3E0'
    actorBorder: '#FF6F00'
    actorTextColor: '#5D4037'
    signalColor: '#FF9800'
    signalTextColor: '#5D4037'
    labelBoxBkgColor: '#F3E5F5'
    noteBkgColor: '#FFF8E1'
    noteTextColor: '#F57F17'
    noteBorderColor: '#FBC02D'
    pie1: '#FF6F00'
    pie2: '#9C27B0'
    pie3: '#FBC02D'
    pie4: '#FF9800'
    pie5: '#BA68C8'
    pie6: '#FFD54F'
    pie7: '#FFB74D'
    pie8: '#CE93D8'
    pie9: '#FFF176'
    pie10: '#FF8A65'
    pie11: '#F3E5F5'
    pie12: '#FFF8E1'
    sectionBkgColor: '#FFF8E1'
    altSectionBkgColor: '#FFF3E0'
    sectionBkgColor2: '#F3E5F5'
    taskBkgColor: '#FFB74D'
    taskBorderColor: '#FF6F00'
    activeTaskBkgColor: '#FF9800'
    activeTaskBorderColor: '#E65100'
    doneTaskBkgColor: '#FFCC80'
    doneTaskBorderColor: '#FF6F00'
    critBkgColor: '#CE93D8'
    critBorderColor: '#7B1FA2'
    taskTextColor: '#5D4037'
    taskTextOutsideColor: '#5D4037'
    taskTextLightColor: '#5D4037'
    taskTextDarkColor: '#FFFFFF'
    gridColor: '#FFCC80'
    todayLineColor: '#7B1FA2'
    classText: '#5D4037'
    fillType0: '#FFF3E0'
    fillType1: '#F3E5F5'
    fillType2: '#FFF8E1'
    fillType3: '#FFB74D'
    fillType4: '#CE93D8'
    fillType5: '#FFD54F'
    fillType6: '#FF8A65'
    fillType7: '#BA68C8'
    attributeBackgroundColorOdd: '#FFF8E1'
    attributeBackgroundColorEven: '#FFF3E0'
  gantt:
    fontSize: 16
    barHeight: 24
    barGap: 6
    topPadding: 50
    leftPadding: 75
    gridLineStartPadding: 35
    numberSectionStyles: 4
  flowchart:
    curve: 'linear'
    htmlLabels: false
    useMaxWidth: true
    padding: 25
    nodeSpacing: 60
    rankSpacing: 80
    diagramPadding: 8
  sequence:
    diagramMarginX: 50
    diagramMarginY: 10
    actorMargin: 50
    boxMargin: 10
    boxTextMargin: 5
    noteMargin: 10
---
flowchart TB
  subgraph Sources
    A1[F Prime docs]
    A2[PROVES Kit docs]
    A3[Issues and PRs]
  end

  subgraph Ingestion
    B1[Doc sync]
    B2[Normalization]
  end

  subgraph Agents
    C1[Curator agent]
    C2[Extractor]
    C3[Validator]
    C4[Storage]
    C5[Human review]
  end

  subgraph Knowledge Base
    D1[Library entries]
    D2[Knowledge graph]
    D3[ERV relationships]
  end

  subgraph Outputs
    E1[GitHub Pages diagrams]
    E2[Queries and analysis]
    E3[Risk scanner]
  end

  A1 --> B1
  A2 --> B1
  A3 --> B1
  B1 --> B2
  B2 --> C1
  C1 --> C2
  C2 --> C3
  C3 -->|low/medium| C4
  C3 -->|high/conflict| C5
  C5 -->|approve| C4
  C5 -->|reject| C1
  C4 --> D1
  C4 --> D2
  D2 --> D3
  D1 --> E1
  D2 --> E2
  D2 --> E3
```

---

## dY` Lifecycle: Curation Run

```mermaid
---
config:
  theme: base
  fontSize: 16
  themeCSS: |
    .node rect, .cluster rect, .edgePath path { transition: filter 0.2s ease, stroke-width: 0.2s ease; }
    .node:hover rect, .cluster:hover rect, .edgePath:hover path { filter: drop-shadow(0 0 8px rgba(0,0,0,0.35)); stroke-width: 3px; }
    .edgeLabel rect { rx: 6px; ry: 6px; stroke-width: 1px; }
    .cluster-label { font-weight: 600; }
    .node .label, .nodeLabel, .node foreignObject div, .edgeLabel { font-size: 20px !important; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif !important; }
    .node.decision .label, .node polygon + .label { font-size: 18px !important; }
  themeVariables:
    primaryColor: '#FFF3E0'
    secondaryColor: '#F3E5F5'
    tertiaryColor: '#FFF8E1'
    primaryTextColor: '#5D4037'
    secondaryTextColor: '#4A148C'
    tertiaryTextColor: '#F57F17'
    primaryBorderColor: '#FF6F00'
    secondaryBorderColor: '#9C27B0'
    tertiaryBorderColor: '#FBC02D'
    background: '#FFF8E1'
    textColor: '#5D4037'
    lineColor: '#FF9800'
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    fontSize: '16px'
    nodeBorder: '#FF6F00'
    mainBkg: '#FFF3E0'
    clusterBkg: '#F3E5F5'
    clusterBorder: '#9C27B0'
    edgeLabelBackground: '#FFF8E1'
    actorBkg: '#FFF3E0'
    actorBorder: '#FF6F00'
    actorTextColor: '#5D4037'
    signalColor: '#FF9800'
    signalTextColor: '#5D4037'
    labelBoxBkgColor: '#F3E5F5'
    noteBkgColor: '#FFF8E1'
    noteTextColor: '#F57F17'
    noteBorderColor: '#FBC02D'
    pie1: '#FF6F00'
    pie2: '#9C27B0'
    pie3: '#FBC02D'
    pie4: '#FF9800'
    pie5: '#BA68C8'
    pie6: '#FFD54F'
    pie7: '#FFB74D'
    pie8: '#CE93D8'
    pie9: '#FFF176'
    pie10: '#FF8A65'
    pie11: '#F3E5F5'
    pie12: '#FFF8E1'
    sectionBkgColor: '#FFF8E1'
    altSectionBkgColor: '#FFF3E0'
    sectionBkgColor2: '#F3E5F5'
    taskBkgColor: '#FFB74D'
    taskBorderColor: '#FF6F00'
    activeTaskBkgColor: '#FF9800'
    activeTaskBorderColor: '#E65100'
    doneTaskBkgColor: '#FFCC80'
    doneTaskBorderColor: '#FF6F00'
    critBkgColor: '#CE93D8'
    critBorderColor: '#7B1FA2'
    taskTextColor: '#5D4037'
    taskTextOutsideColor: '#5D4037'
    taskTextLightColor: '#5D4037'
    taskTextDarkColor: '#FFFFFF'
    gridColor: '#FFCC80'
    todayLineColor: '#7B1FA2'
    classText: '#5D4037'
    fillType0: '#FFF3E0'
    fillType1: '#F3E5F5'
    fillType2: '#FFF8E1'
    fillType3: '#FFB74D'
    fillType4: '#CE93D8'
    fillType5: '#FFD54F'
    fillType6: '#FF8A65'
    fillType7: '#BA68C8'
    attributeBackgroundColorOdd: '#FFF8E1'
    attributeBackgroundColorEven: '#FFF3E0'
  gantt:
    fontSize: 16
    barHeight: 24
    barGap: 6
    topPadding: 50
    leftPadding: 75
    gridLineStartPadding: 35
    numberSectionStyles: 4
  flowchart:
    curve: 'linear'
    htmlLabels: false
    useMaxWidth: true
    padding: 25
    nodeSpacing: 60
    rankSpacing: 80
    diagramPadding: 8
  sequence:
    diagramMarginX: 50
    diagramMarginY: 10
    actorMargin: 50
    boxMargin: 10
    boxTextMargin: 5
    noteMargin: 10
---
sequenceDiagram
  participant Doc as Documentation
  participant Curator
  participant Extractor
  participant Validator
  participant Review as Human Review
  participant Storage
  participant Graph as Knowledge Graph

  Doc->>Curator: Ingest source
  Curator->>Extractor: Capture ALL dependencies with citations
  Extractor-->>Curator: Raw data with context
  Curator->>Validator: Flag anomalies check patterns
  Validator-->>Curator: Staged with flags and notes
  Curator->>Staging: Store ALL to staging tables
  Staging-->>Review: Human verifies EVERY piece
  Review-->>Graph: Only verified data enters truth
  Graph->>Graph: Align sources establish truth
  Graph-->>Storage: Ack
  Storage-->>Curator: Stored summary
```

---

## dY"S Trial Results (What We Found)

- **45+ dependencies** with citations across FA' + PROVES Kit docs
- **4 cross-system dependencies** not documented in either system
- **2 transitive dependency chains** traced end-to-end
- **5 knowledge gaps** that explain mission failures

---

## dY"S Interactive Diagrams

- [Dependency Overview](diagrams/overview.html)
- [Cross-System Dependencies](diagrams/cross-system.html)
- [Transitive Dependency Chains](diagrams/transitive-chains.html)
- [Knowledge Gaps](diagrams/knowledge-gaps.html)
- [Team Boundaries](diagrams/team-boundaries.html)

---

## dY"- What This Enables

- Detect risky changes before they cascade across subsystems.
- Preserve the "why" behind technical decisions.
- Enable cross-team learning without tribal knowledge loss.

---

## Documentation

- [**Getting Started Guide**](getting-started/) - New user walkthrough
- [**Quick Reference**](getting-started/QUICK_REFERENCE.html) - Command cheat sheet
- [Trial Mapping Design Document](../testing_data/diagrams/TRIAL_MAPPING_DESIGN.html)
- [Comprehensive Dependency Map](../testing_data/diagrams/COMPREHENSIVE_DEPENDENCY_MAP.html)
- [Original F´ Documentation](../testing_data/diagrams/fprime_i2c_driver_full.html)
- [Original PROVES Kit Documentation](../testing_data/diagrams/proves_power_full.html)
