---
layout: article
title: GNN Molecular Model
---



# GNN Molecular Model

Think of the truth graph as a molecular structure:
- **Nodes** are atoms (components, teams, documents).
- **Edges** are bonds (dependencies).
- **Bond strength** shows coupling (tight vs loose).
- **Message passing** is like an electron pull that carries influence across bonds.

[Back to Home](../index.html)

---

## Molecular View of the Graph

```mermaid
---
config:
  theme: base
  fontSize: 18
  themeCSS: |
    .label, .nodeLabel, text, svg text, tspan { font-size: 20px !important; font-weight: 500 !important; }
    .edgeLabel, .edgeLabel text, .edgeLabel tspan { font-size: 18px !important; font-weight: 500 !important; }
    .edgeLabel .label-container rect, .edgeLabel rect, .label-container rect, .edgeLabel path.label-container { stroke: #000 !important; stroke-width: 2px !important; fill-opacity: 1 !important; }
    .node:hover rect, .node:hover circle, .node:hover polygon { stroke-width: 3px !important; filter: drop-shadow(0 0 8px rgba(0,0,0,0.3)); cursor: pointer; }
    .edgePath:hover path { stroke-width: 3px !important; opacity: 1; }
    .edgeLabel:hover rect, .edgeLabel:hover .label-container rect { stroke-width: 2.5px !important; filter: brightness(1.1); }
  themeVariables:
    primaryColor: '#E8F5E9'
    secondaryColor: '#FCE4EC'
    tertiaryColor: '#FFF9C4'
    primaryTextColor: '#2E7D32'
    secondaryTextColor: '#C2185B'
    tertiaryTextColor: '#F57C00'
    primaryBorderColor: '#4CAF50'
    secondaryBorderColor: '#F06292'
    tertiaryBorderColor: '#FDD835'
    background: '#F1F8E9'
    textColor: '#2E7D32'
    lineColor: '#66BB6A'
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    fontSize: '18px'
    nodeBorder: '#4CAF50'
    mainBkg: '#E8F5E9'
    clusterBkg: '#FFF9C4'
    clusterBorder: '#FDD835'
    edgeLabelBackground: '#FCE4EC'
    actorBkg: '#E8F5E9'
    actorBorder: '#4CAF50'
    actorTextColor: '#2E7D32'
    signalColor: '#66BB6A'
    signalTextColor: '#2E7D32'
    labelBoxBkgColor: '#FCE4EC'
    noteBkgColor: '#FFF9C4'
    noteTextColor: '#F57C00'
    noteBorderColor: '#FDD835'
    pie1: '#4CAF50'
    pie2: '#F06292'
    pie3: '#FDD835'
    pie4: '#66BB6A'
    pie5: '#E91E63'
    pie6: '#FFEB3B'
    pie7: '#81C784'
    pie8: '#F48FB1'
    pie9: '#FFF176'
    pie10: '#A5D6A7'
    pie11: '#FCE4EC'
    pie12: '#FFF9C4'
    sectionBkgColor: '#FFF9C4'
    altSectionBkgColor: '#E8F5E9'
    sectionBkgColor2: '#FCE4EC'
    taskBkgColor: '#A5D6A7'
    taskBorderColor: '#4CAF50'
    activeTaskBkgColor: '#81C784'
    activeTaskBorderColor: '#388E3C'
    doneTaskBkgColor: '#C8E6C9'
    doneTaskBorderColor: '#4CAF50'
    critBkgColor: '#F48FB1'
    critBorderColor: '#C2185B'
    taskTextColor: '#2E7D32'
    taskTextOutsideColor: '#2E7D32'
    taskTextLightColor: '#2E7D32'
    taskTextDarkColor: '#FFFFFF'
    gridColor: '#C8E6C9'
    todayLineColor: '#C2185B'
    classText: '#2E7D32'
    fillType0: '#E8F5E9'
    fillType1: '#FCE4EC'
    fillType2: '#FFF9C4'
    fillType3: '#A5D6A7'
    fillType4: '#F48FB1'
    fillType5: '#FFF176'
    fillType6: '#81C784'
    fillType7: '#F8BBD0'
    attributeBackgroundColorOdd: '#F1F8E9'
    attributeBackgroundColorEven: '#E8F5E9'
  gantt:
    fontSize: 20
    barHeight: 24
    barGap: 6
    topPadding: 50
    leftPadding: 75
    gridLineStartPadding: 35
    numberSectionStyles: 4
  flowchart:
    curve: linear
    padding: 15
    nodeSpacing: 50
    rankSpacing: 50
    diagramPadding: 8
    wrappingWidth: 200
  sequence:
    diagramMarginX: 50
    diagramMarginY: 10
    actorMargin: 50
    width: 150
    height: 65
    boxMargin: 10
    boxTextMargin: 5
    noteMargin: 10
    messageMargin: 35
    mirrorActors: false
    bottomMarginAdj: 1
    useMaxWidth: true
    rightAngles: false
    showSequenceNumbers: false
  state:
    dividerMargin: 10
    sizeUnit: 5
    padding: 8
    textHeight: 10
    titleShift: -15
    noteMargin: 10
    forkWidth: 70
    forkHeight: 7
    miniPadding: 2
    fontSizeFactor: 5.02
    fontSize: 24
    labelHeight: 16
    edgeLengthFactor: 20
    compositeTitleSize: 35
    radius: 5
  class:
    arrowMarkerAbsolute: false
    hideEmptyMembersBox: false
  er:
    diagramPadding: 20
    layoutDirection: 'TB'
    minEntityWidth: 100
    minEntityHeight: 75
    entityPadding: 15
    stroke: 'gray'
    fill: 'honeydew'
    fontSize: 12
  journey:
    diagramMarginX: 50
    diagramMarginY: 10
    actorMargin: 50
    width: 150
    height: 65
    boxMargin: 10
    boxTextMargin: 5
  pie:
    textPosition: 0.75
  quadrant:
    chartWidth: 500
    chartHeight: 500
    titlePadding: 10
    titleFontSize: 20
    quadrantPadding: 5
    quadrantTextTopPadding: 5
    quadrantLabelFontSize: 16
    quadrantInternalBorderStrokeWidth: 1
    quadrantExternalBorderStrokeWidth: 2
    pointTextPadding: 5
    pointLabelFontSize: 12
    pointRadius: 6
    xAxisLabelPadding: 5
    xAxisLabelFontSize: 16
    yAxisLabelPadding: 5
    yAxisLabelFontSize: 16
  requirement:
    rect_fill: '#E8F5E9'
    text_color: '#2E7D32'
    rect_border_size: 2
    rect_border_color: '#4CAF50'
    rect_min_width: 200
    rect_min_height: 200
    fontSize: 14
    rect_padding: 10
    line_height: 20
  gitGraph:
    showBranches: true
    showCommitLabel: true
    mainBranchName: 'main'
    rotateCommitLabel: true
  c4:
    diagramMarginX: 50
    diagramMarginY: 10
    c4ShapeMargin: 50
    c4ShapePadding: 20
    width: 216
    height: 60
    boxMargin: 10---
flowchart TB
    subgraph Molecule ["Truth Graph as Molecular Structure"]
        A[Power Manager]
        B[I2C Bus]
        C[IMU Sensor]
        D[Load Switch]
        E[Topology Config]
        F[Team A Docs]
        G[Team B Docs]
    end

    P[Change Pulse]

    A --- B
    B --- C
    A --- D
    D --- C
    E --- A
    F --- E
    G --- E
    B --- G
    P --> A

    classDef atom fill:#f5f9ff,stroke:#4a7fb3,stroke-width:1px,color:#0b1b2b;
    classDef core fill:#ffe7b3,stroke:#c9882a,stroke-width:2px,color:#3a2603;
    classDef doc fill:#e8f7ef,stroke:#3a9d6d,stroke-width:1px,color:#0f2b1f;
    classDef pulse fill:#ffd6d6,stroke:#c44,stroke-width:2px,color:#3a0d0d;

    class A,B,C,D atom;
    class E core;
    class F,G doc;
    class P pulse;

    linkStyle 0 stroke:#4a7fb3,stroke-width:3px;
    linkStyle 1 stroke:#4a7fb3,stroke-width:3px;
    linkStyle 2 stroke:#4a7fb3,stroke-width:3px;
    linkStyle 3 stroke:#4a7fb3,stroke-width:3px;
    linkStyle 4 stroke:#9ab7d6,stroke-width:1px,stroke-dasharray:3 3;
    linkStyle 5 stroke:#9ab7d6,stroke-width:1px,stroke-dasharray:3 3;
    linkStyle 6 stroke:#9ab7d6,stroke-width:1px,stroke-dasharray:3 3;
    linkStyle 7 stroke:#9ab7d6,stroke-width:1px,stroke-dasharray:3 3;
    linkStyle 8 stroke:#c44,stroke-width:2px;
```

**Legend**
- **Thick bonds** = tight coupling (strong pull)
- **Dashed bonds** = loose coupling (weak pull)
- **Change pulse** = a modification that propagates across bonds

---



## Why this helps

A GNN learns which bonds carry the strongest influence. With verified edges and consistent labels, the model learns real system behavior instead of noise.

---

[Back to Home](../index.html)







