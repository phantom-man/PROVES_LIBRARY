# Testing Scripts

Testing and diagnostic scripts for the PROVES Library system.

## Meta-Analysis & Reporting

### generate_progress_report.py

Meta-analysis agent that generates visual progress reports.

```bash
python testing/scripts/generate_progress_report.py
```

**What it does:**

1. Reads context documents (README.md, CANON.md, ONTOLOGY.md)
2. Queries Neon database for current system state
3. Analyzes extraction progress, data quality, and emerging patterns
4. Generates mermaid diagrams following MERMAID_RULES.md
5. Saves reports to `testing_data/progress_diagrams/`

**Output:**

- `testing_data/progress_diagrams/progress_report_YYYY-MM-DD_HH-MM-SS.md` - Timestamped report
- `testing_data/progress_diagrams/latest.md` - Most recent report

**The agent analyzes:**

- Extraction pipeline status (URLs queued vs processed)
- Data quality metrics (lineage verification, confidence scores)
- Error patterns and improvement suggestions
- Emerging node and relationship structures
- System evolution over time
- Areas needing attention (data cleaning, coverage gaps)

**Questions it answers:**

- What is the database telling us about mission failure patterns?
- Are node and relationship structures emerging from the data?
- How clean is the data? What needs cleaning?
- What features are becoming visible?
- How has the system evolved since we started?

## Requirements

All testing scripts require:

- Python 3.11+
- Environment variables from `.env`:
  - `NEON_DATABASE_URL` - Database connection
  - `ANTHROPIC_API_KEY` - Claude API for analysis

## Related Directories

- **testing_data/** - Test outputs and historical data
- **production/scripts/** - Production pipeline scripts
- **scripts/archive/** - Archived one-time test scripts
