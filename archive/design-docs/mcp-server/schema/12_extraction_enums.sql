-- ============================================================================
-- PROVES Library - Extraction ENUMs & Helper Functions
-- ============================================================================
-- Version: 2.0.0
-- Updated: 2024-12-22
-- 
-- PURPOSE:
--   Define shared ENUM types for extraction confidence & evidence tracking.
--   These ENUMs are used by staging_extractions (13) and validation_decisions.
--
-- NOTE:
--   This file ONLY contains ENUMs and helper functions.
--   Table definitions are in 13_validation_staging.sql to avoid duplication.
-- ============================================================================

-- ============================================================================
-- CONFIDENCE LEVEL (derived from numeric score)
-- ============================================================================

CREATE TYPE confidence_level AS ENUM (
    'low',          -- 0.00–0.49: Uncertain, needs verification
    'medium',       -- 0.50–0.79: Likely correct, some gaps
    'high'          -- 0.80–1.00: High certainty, formal definition
);

COMMENT ON TYPE confidence_level IS
'Confidence Level Rubric for Extraction Agents:

HIGH (0.80–1.00):
  ✓ Doc explicitly defines it ("is/shall/must") or shows formal signature/table
  ✓ Term matches known F´ vocabulary (component/port/command/telemetry/event)
  ✓ Multiple sources agree

MEDIUM (0.50–0.79):
  ~ Strong cues but not a formal definition
  ~ Extracted from an example that looks representative
  ~ Missing 1–2 key properties

LOW (0.00–0.49):
  ✗ Inferred from narrative text
  ✗ Only appears once, unclear context
  ✗ Conflicts with another statement or lacks supporting structure

Agents MUST assign confidence_reason explaining which criteria apply.';

-- ============================================================================
-- EVIDENCE TYPE
-- ============================================================================

CREATE TYPE evidence_type AS ENUM (
    'definition_spec',      -- Formal definition, specification, interface contract
    'interface_contract',   -- Port signature, API contract, protocol spec
    'example',              -- Code example, usage sample
    'narrative',            -- Descriptive text, documentation prose
    'table_diagram',        -- Structured table, diagram, schematic
    'comment',              -- Code comment, inline documentation
    'inferred'              -- No direct evidence, inferred from context
);

-- ============================================================================
-- EXTRACTION METHOD
-- ============================================================================

CREATE TYPE extraction_method AS ENUM (
    'pattern',          -- Regex/pattern matching
    'llm',              -- LLM extraction (GPT, Claude, etc.)
    'hybrid',           -- Pattern + LLM combination
    'manual'            -- Human-entered
);

-- ============================================================================
-- CANDIDATE STATUS
-- ============================================================================

CREATE TYPE candidate_status AS ENUM (
    'pending',          -- Awaiting review (default, NEVER skip)
    'accepted',         -- Verified, promoted to core_entities
    'rejected',         -- Rejected as incorrect
    'merged',           -- Merged with another candidate (duplicate)
    'needs_context'     -- Need more information to decide
);

-- ============================================================================
-- CANDIDATE TYPE (what kind of entity/relationship)
-- ============================================================================

CREATE TYPE candidate_type AS ENUM (
    -- Nodes (entities)
    'component',        -- Software/hardware component
    'port',             -- F´ port or interface
    'command',          -- F´ command definition
    'telemetry',        -- Telemetry channel
    'event',            -- F´ event
    'parameter',        -- Configuration parameter
    'data_type',        -- Type definition
    
    -- Edges (relationships)
    'dependency',       -- A depends on B
    'connection',       -- A connects to B (port wiring)
    'inheritance',      -- A inherits from B
    'composition',      -- A contains B
    
    -- Specs/properties
    'constraint',       -- Requirement, limitation
    'rate_spec',        -- Timing specification
    'memory_spec',      -- Memory/resource specification
    'protocol_spec'     -- Protocol/format specification
);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Derive confidence_level from numeric score
CREATE OR REPLACE FUNCTION derive_confidence_level(score NUMERIC)
RETURNS confidence_level AS $$
BEGIN
    IF score >= 0.80 THEN
        RETURN 'high';
    ELSIF score >= 0.50 THEN
        RETURN 'medium';
    ELSE
        RETURN 'low';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- RUBRIC REFERENCE (for agent prompts)
-- ============================================================================

/*
CONFIDENCE SCORING EXAMPLES:

| Extraction                          | Score | Level  | Reason                               |
|-------------------------------------|-------|--------|--------------------------------------|
| Port with formal `.fpp` definition  | 0.95  | high   | Formal F´ syntax, interface contract |
| Component mentioned in prose        | 0.35  | low    | Narrative only, no formal definition |
| Telemetry from example code         | 0.65  | medium | Strong cues, missing units           |
| Dependency stated "A uses B"        | 0.80  | high   | Explicit statement, verb "uses"      |
| Inferred relationship               | 0.30  | low    | Single mention, unclear context      |

EVIDENCE LOCATION EXAMPLES:

For GitHub file:
{
    "doc": "Svc/TlmChan/TlmChan.fpp",
    "repo": "nasa/fprime",
    "commit": "abc123",
    "lines": [45, 52],
    "url": "https://github.com/nasa/fprime/blob/main/Svc/TlmChan/TlmChan.fpp#L45-L52"
}

For documentation page:
{
    "doc": "F Prime User Guide",
    "page": "Ports",
    "section": "Port Types",
    "url": "https://nasa.github.io/fprime/UsersGuide/user/ports.html"
}
*/
