#!/usr/bin/env python3
"""
Meta-Analysis Agent: Progress Report Generator

This agent reads the current state of the PROVES Library system and generates
visual progress reports using mermaid diagrams.

It analyzes:
- Database state (extractions, nodes, relationships)
- System evolution and data quality
- Emerging patterns and insights
- Areas needing attention

Outputs: Mermaid diagrams in testing_data/progress_diagrams/
"""

import os
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any
import anthropic
from dotenv import load_dotenv

# Setup paths
script_dir = Path(__file__).parent
project_root = script_dir.parent.parent
sys.path.insert(0, str(project_root / 'neon-database' / 'scripts'))

# Load environment
load_dotenv(project_root / '.env')

from db_connector import get_db


class ProgressReportAgent:
    """Meta-analysis agent that generates visual progress reports"""

    def __init__(self):
        self.client = anthropic.Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))
        self.project_root = project_root
        self.output_dir = project_root / 'testing_data' / 'progress_diagrams'
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def read_context_documents(self) -> Dict[str, str]:
        """Read README, CANON, ONTOLOGY for context"""
        docs = {}

        # README.md
        readme_path = self.project_root / 'README.md'
        if readme_path.exists():
            docs['README'] = readme_path.read_text(encoding='utf-8')

        # CANON.md
        canon_path = self.project_root / 'canon' / 'CANON.md'
        if canon_path.exists():
            docs['CANON'] = canon_path.read_text(encoding='utf-8')

        # ONTOLOGY.md
        ontology_path = self.project_root / 'canon' / 'ONTOLOGY.md'
        if ontology_path.exists():
            docs['ONTOLOGY'] = ontology_path.read_text(encoding='utf-8')

        # MERMAID_RULES.md
        rules_path = self.project_root / 'docs' / 'diagrams' / 'MERMAID_RULES.md'
        if rules_path.exists():
            docs['MERMAID_RULES'] = rules_path.read_text(encoding='utf-8')

        return docs

    def query_database_state(self) -> Dict[str, Any]:
        """Query Neon database for current system state"""
        db = get_db()
        state = {}

        # URLs to process
        result = db.fetch_one("SELECT COUNT(*) as count FROM urls_to_process WHERE processed_at IS NULL")
        state['pending_urls'] = result['count'] if result else 0

        result = db.fetch_one("SELECT COUNT(*) as count FROM urls_to_process WHERE processed_at IS NOT NULL")
        state['processed_urls'] = result['count'] if result else 0

        # Staging extractions
        result = db.fetch_one("SELECT COUNT(*) as count FROM staging_extractions")
        state['total_extractions'] = result['count'] if result else 0

        results = db.fetch_all("""
            SELECT candidate_type, COUNT(*) as count
            FROM staging_extractions
            GROUP BY candidate_type
        """)
        state['extractions_by_type'] = {row['candidate_type']: row['count'] for row in results}

        # Lineage quality
        result = db.fetch_one("""
            SELECT
                COUNT(*) FILTER (WHERE lineage_verified = true) as verified,
                COUNT(*) FILTER (WHERE lineage_verified = false) as unverified,
                AVG(lineage_confidence) as avg_confidence
            FROM staging_extractions
        """)
        state['lineage_quality'] = {
            'verified': result['verified'] if result else 0,
            'unverified': result['unverified'] if result else 0,
            'avg_confidence': float(result['avg_confidence']) if result and result['avg_confidence'] else 0.0
        }

        # Errors (stored in staging_extractions.error_log JSONB column)
        result = db.fetch_one("""
            SELECT COUNT(*) as count
            FROM staging_extractions
            WHERE error_count > 0
        """)
        state['total_errors'] = result['count'] if result else 0
        state['errors_by_type'] = {}  # Error types are in JSONB, would need complex query

        # Improvement suggestions
        result = db.fetch_one("SELECT COUNT(*) as count FROM improvement_suggestions")
        state['total_suggestions'] = result['count'] if result else 0

        results = db.fetch_all("""
            SELECT category, COUNT(*) as count
            FROM improvement_suggestions
            GROUP BY category
        """)
        state['suggestions_by_category'] = {row['category']: row['count'] for row in results}

        # Recent activity
        result = db.fetch_one("""
            SELECT COUNT(*) as count
            FROM staging_extractions
            WHERE created_at > NOW() - INTERVAL '7 days'
        """)
        state['extractions_last_7_days'] = result['count'] if result else 0

        return state

    def generate_report(self, report_type: str = 'full') -> str:
        """Generate progress report using Claude"""

        print("[*] Reading context documents...")
        docs = self.read_context_documents()

        print("[*] Querying database state...")
        db_state = self.query_database_state()

        print("[*] Generating analysis with Claude Sonnet...")

        # Build comprehensive prompt
        prompt = f"""You are a meta-analysis agent for the PROVES Library project.

Your task: Analyze the current state of the system and generate visual progress reports using mermaid diagrams.

# Context Documents

## README.md (Project Overview)
{docs.get('README', 'Not found')}

## CANON.md (Design Principles)
{docs.get('CANON', 'Not found')[:5000]}  # Truncated for length

## ONTOLOGY.md (Knowledge Structure)
{docs.get('ONTOLOGY', 'Not found')[:5000]}  # Truncated for length

# Current Database State

{self._format_db_state(db_state)}

# Your Mission

Generate mermaid diagrams that visualize:

1. **Extraction Progress** - Current pipeline status, what's queued vs processed
2. **Data Quality Overview** - Lineage verification, confidence scores, error patterns
3. **Emerging Patterns** - What the data is beginning to show (nodes, relationships)
4. **System Evolution** - How the system has grown, what's changed
5. **Areas Needing Attention** - Data cleaning needs, coverage gaps

# Critical Requirements

You MUST follow these mermaid diagram rules from MERMAID_RULES.md:

{docs.get('MERMAID_RULES', 'Rules not found')[:3000]}  # Key rules

**CRITICAL RULES:**
- NO HTML tags like <br/> in flowcharts
- NO colons in subgraph labels (use "Layer 1 App" not "Layer 1: App")
- Quote all paths with forward slashes: ["/dev/i2c"]
- Quote text with special characters: ["Status [YES] OK"]
- NO double colons (Status::OK → Status_OK)

# Output Format

Generate a comprehensive progress report with multiple mermaid diagrams.

For each diagram:
1. Provide a clear heading (##)
2. Brief description of what it shows
3. The mermaid diagram (properly formatted)
4. Key insights from the diagram

Think deeply about:
- What is the database telling us about mission failure patterns?
- Are node and relationship structures emerging?
- How clean is the data? What needs attention?
- What has changed since we started?
- What features or insights are becoming visible?

Generate the report now."""

        response = self.client.messages.create(
            model="claude-sonnet-4-5-20250929",
            max_tokens=16000,
            temperature=0.3,
            messages=[{"role": "user", "content": prompt}]
        )

        return response.content[0].text

    def _format_db_state(self, state: Dict[str, Any]) -> str:
        """Format database state for prompt"""
        return f"""
## URLs
- Pending: {state['pending_urls']}
- Processed: {state['processed_urls']}
- Total: {state['pending_urls'] + state['processed_urls']}

## Extractions
- Total: {state['total_extractions']}
- Last 7 days: {state['extractions_last_7_days']}

By Type:
{self._format_dict(state['extractions_by_type'])}

## Lineage Quality
- Verified: {state['lineage_quality']['verified']}
- Unverified: {state['lineage_quality']['unverified']}
- Average Confidence: {state['lineage_quality']['avg_confidence']:.2f}

## Errors
- Total: {state['total_errors']}

By Type:
{self._format_dict(state['errors_by_type'])}

## Improvement Suggestions
- Total: {state['total_suggestions']}

By Category:
{self._format_dict(state['suggestions_by_category'])}
"""

    def _format_dict(self, d: Dict) -> str:
        """Format dictionary for display"""
        if not d:
            return "  (none)"
        return "\n".join(f"  - {k}: {v}" for k, v in d.items())

    def save_report(self, report_content: str):
        """Save report to file with timestamp"""
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        filename = f"progress_report_{timestamp}.md"
        filepath = self.output_dir / filename

        # Add metadata header
        header = f"""# Progress Report
**Generated:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
**Agent:** Meta-Analysis Progress Reporter

---

"""

        full_content = header + report_content
        filepath.write_text(full_content, encoding='utf-8')

        print(f"\n[SAVED] Report saved to: {filepath}")

        # Also save as latest.md for easy access
        latest_path = self.output_dir / "latest.md"
        latest_path.write_text(full_content, encoding='utf-8')
        print(f"[SAVED] Also saved as: {latest_path}")

        return filepath


def main():
    """Main execution"""
    print("=" * 60)
    print("PROVES Library - Progress Report Generator")
    print("=" * 60)
    print()

    agent = ProgressReportAgent()

    try:
        print("[*] Analyzing system state...\n")
        report = agent.generate_report()

        print("\n[*] Saving report...\n")
        filepath = agent.save_report(report)

        print("\n" + "=" * 60)
        print("[SUCCESS] Progress report generated successfully!")
        print("=" * 60)
        print(f"\nView report at: {filepath}")
        print(f"Or open: testing_data/progress_diagrams/latest.md")

    except Exception as e:
        print(f"\n[ERROR] Error generating report: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
