# PROVES Knowledge Capture Checklist

**Use this checklist when extracting, documenting, or transferring technical knowledge.**

Before knowledge enters the system, ask these seven questions to preserve dimensional grounding and prevent information loss at interfaces.

---

## 1. Who knew this, and how close were they?

**Observer coupling**

- Was this learned by direct involvement, or secondhand?
- Did the knower touch the real system, or only outputs?
- Would someone else interpret this the same way?

**👉 Flags**: embodiment loss, proxy replacement, misinterpretation

**Maps to**: Position (relative to observer)

---

## 2. Where does the experience live now?

**Pattern storage location**

- Is this skill or judgment carried by people?
- Is it written down, modeled, or logged?
- Does it survive if the person leaves?

**👉 Flags**: observer loss, practice decay, authorship loss

**Maps to**: Pattern Storage Location (internalized vs. externalized)

---

## 3. What has to stay connected for this to work?

**Relational integrity**

- Does this depend on sequence, timing, or coordination?
- Are decisions tied to outcomes?
- Are pieces stored together or scattered?

**👉 Flags**: fragmentation, silo effects, hidden dependencies

**Maps to**: Interface mechanisms, relational structure

---

## 4. Under what conditions was this true?

**Context preservation**

- What assumptions were in place?
- What constraints mattered?
- Would this still hold in a different setting?

**👉 Flags**: model overreach, context collapse

**Maps to**: Formalizability, scope conditions

---

## 5. When does this stop being reliable?

**Temporal validity**

- Does this age out?
- Does it require recalibration?
- Has the system changed since this was learned?

**👉 Flags**: drift, lifecycle mismatch

**Maps to**: Temporality (snapshot vs. lifecycle)

---

## 6. Who wrote or taught this, and why?

**Authorship & intent**

- Was this exploratory, provisional, or certain?
- Was it written to explain, persuade, or comply?
- What uncertainty was present but not recorded?

**👉 Flags**: bad authorship, pedagogical distortion, false authority

**Maps to**: Provenance, epistemic status

---

## 7. Does this only work if someone keeps doing it?

**Reenactment dependency**

- Does this knowledge require practice?
- Does it degrade without use?
- Can it be understood without having done it?

**👉 Flags**: embodied decay, skill erosion

**Maps to**: Pattern Storage Location (internalized/embodied)

---

## How to Use This Checklist

### For Knowledge Extraction Agents

Before marking knowledge as "extracted," verify that dimensional metadata captures answers to questions 1, 2, 4, 5, and 6.

### For Human Verifiers

When reviewing agent-extracted knowledge, check whether questions 3 and 7 reveal dependencies or embodied components that the agent missed.

### For Documentation Writers

When converting tacit knowledge to documentation, explicitly answer question 2: acknowledge what will be lost in the transfer from internalized to externalized pattern storage.

### For Interface Design

When designing knowledge transfer mechanisms (onboarding, handoffs, documentation), use questions 3 and 7 to identify where embodied knowledge cannot cross interfaces without support mechanisms.

---

## Example Application

**Scenario**: Documenting "how to verify RV3032 RTC installation"

**Question 1**: Was this learned hands-on or from docs?
- **Answer**: Technician tested 5 boards, noticed timing drift pattern
- **Capture**: High position (direct contact), embodied observation

**Question 2**: Where does this pattern recognition live?
- **Answer**: Technician can see drift visually on oscilloscope; not in any doc
- **Capture**: Internalized (embodied), at risk if technician rotates out

**Question 3**: What must stay connected?
- **Answer**: Oscilloscope trace → timing comparison → acceptable drift range
- **Capture**: Relational dependency between measurement and acceptance criteria

**Question 4**: Under what conditions?
- **Answer**: Room temperature, specific firmware version, after initial power-on
- **Capture**: Context-dependent (temperature, firmware, timing)

**Question 5**: When does this stop being reliable?
- **Answer**: If firmware changes or different RTC model is used
- **Capture**: Temporal validity = until hardware/firmware revision

**Question 6**: Who documented this and why?
- **Answer**: Technician wrote informal note after debugging session
- **Capture**: Exploratory, provisional (not formally validated)

**Question 7**: Does this require ongoing practice?
- **Answer**: Yes - recognizing "normal" vs "concerning" drift requires visual pattern matching
- **Capture**: Reenactment-dependent (embodied skill, degrades without practice)

**Result**: This knowledge has high embodiment risk. Interface transfer mechanism needed: capture oscilloscope traces as reference, formalize acceptance criteria, pair new technicians with experienced ones during initial installations.

---
