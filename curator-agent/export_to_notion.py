"""
Export Statistics to Notion

Exports extraction statistics and reports to Notion database/page.

Setup:
1. Create Notion integration at: https://www.notion.so/my-integrations
2. Get integration token
3. Add to .env: NOTION_API_KEY=secret_xxx
4. Share target page with integration
5. Get page ID from URL: https://www.notion.so/YOUR_PAGE_ID
6. Add to .env: NOTION_PAGE_ID=YOUR_PAGE_ID

Usage:
    python export_to_notion.py
    python export_to_notion.py --test  # Test connection only
"""

import os
import sys
import json
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv


def get_notion_client():
    """Get Notion client"""
    try:
        from notion_client import Client
    except ImportError:
        print("❌ notion-client not installed")
        print("Install: pip install notion-client")
        return None

    # Load env
    project_root = Path(__file__).parent.parent
    load_dotenv(project_root / '.env')

    api_key = os.environ.get('NOTION_API_KEY')
    if not api_key:
        print("❌ NOTION_API_KEY not set in .env")
        print()
        print("Setup:")
        print("1. Create integration: https://www.notion.so/my-integrations")
        print("2. Add to .env: NOTION_API_KEY=secret_xxx")
        return None

    return Client(auth=api_key)


def test_notion_connection():
    """Test Notion API connection"""
    client = get_notion_client()
    if not client:
        return False

    try:
        # Test by listing users
        users = client.users.list()
        print(f"✅ Connected to Notion (found {len(users.get('results', []))} users)")
        return True
    except Exception as e:
        print(f"❌ Notion connection failed: {e}")
        return False


def create_extraction_stats_page(client, page_id, progress, db_stats):
    """
    Create or update extraction statistics page in Notion.

    Args:
        client: Notion client
        page_id: Parent page ID
        progress: Progress tracker dict
        db_stats: Database statistics dict
    """
    try:
        # Calculate statistics
        meta = progress['metadata']
        completed_pages = meta.get('completed_pages', 0)
        total_pages = meta.get('total_pages', 0)
        progress_pct = (completed_pages / total_pages * 100) if total_pages > 0 else 0

        total_extractions = sum(
            item.get('extractions_count', 0)
            for item in progress.get('completed', [])
        )

        # Build page content
        page_title = f"PROVES Kit Extraction Stats - {datetime.now().strftime('%Y-%m-%d')}"

        # Create page
        new_page = client.pages.create(
            parent={"page_id": page_id},
            properties={
                "title": {
                    "title": [
                        {
                            "text": {
                                "content": page_title
                            }
                        }
                    ]
                }
            },
            children=[
                # Header
                {
                    "object": "block",
                    "type": "heading_1",
                    "heading_1": {
                        "rich_text": [{"type": "text", "text": {"content": "Overview"}}]
                    }
                },
                # Callout with summary
                {
                    "object": "block",
                    "type": "callout",
                    "callout": {
                        "rich_text": [
                            {
                                "type": "text",
                                "text": {
                                    "content": f"Progress: {completed_pages}/{total_pages} pages ({progress_pct:.1f}%)\n"
                                               f"Total Extractions: {total_extractions}\n"
                                               f"Verified Entities: {db_stats.get('verified_entities', 0) if db_stats else 'N/A'}"
                                }
                            }
                        ],
                        "icon": {"emoji": "📊"}
                    }
                },
                # Progress bar (using quote blocks)
                {
                    "object": "block",
                    "type": "heading_2",
                    "heading_2": {
                        "rich_text": [{"type": "text", "text": {"content": "Progress"}}]
                    }
                },
                {
                    "object": "block",
                    "type": "paragraph",
                    "paragraph": {
                        "rich_text": [
                            {
                                "type": "text",
                                "text": {"content": f"✅ Completed: {completed_pages}\n"}
                            },
                            {
                                "type": "text",
                                "text": {"content": f"⏭️ Skipped: {meta.get('skipped_pages', 0)}\n"}
                            },
                            {
                                "type": "text",
                                "text": {"content": f"❌ Failed: {meta.get('failed_pages', 0)}\n"}
                            }
                        ]
                    }
                },
            ]
        )

        # Add database statistics if available
        if db_stats:
            # Confidence scores
            conf = db_stats.get('confidence', {})
            client.blocks.children.append(
                block_id=new_page['id'],
                children=[
                    {
                        "object": "block",
                        "type": "heading_2",
                        "heading_2": {
                            "rich_text": [{"type": "text", "text": {"content": "Confidence Scores"}}]
                        }
                    },
                    {
                        "object": "block",
                        "type": "paragraph",
                        "paragraph": {
                            "rich_text": [
                                {
                                    "type": "text",
                                    "text": {
                                        "content": f"Average: {conf.get('avg', 0):.2f}\n"
                                                   f"Min: {conf.get('min', 0):.2f}\n"
                                                   f"Max: {conf.get('max', 0):.2f}"
                                    }
                                }
                            ]
                        }
                    }
                ]
            )

            # Ecosystem breakdown
            ecosystems = db_stats.get('by_ecosystem', {})
            if ecosystems:
                eco_text = "\n".join([f"{eco}: {count}" for eco, count in ecosystems.items()])
                client.blocks.children.append(
                    block_id=new_page['id'],
                    children=[
                        {
                            "object": "block",
                            "type": "heading_2",
                            "heading_2": {
                                "rich_text": [{"type": "text", "text": {"content": "By Ecosystem"}}]
                            }
                        },
                        {
                            "object": "block",
                            "type": "paragraph",
                            "paragraph": {
                                "rich_text": [
                                    {
                                        "type": "text",
                                        "text": {"content": eco_text}
                                    }
                                ]
                            }
                        }
                    ]
                )

        # Add completed pages list
        completed = progress.get('completed', [])[-10:]  # Last 10
        if completed:
            pages_list = []
            for item in reversed(completed):
                pages_list.append({
                    "object": "block",
                    "type": "bulleted_list_item",
                    "bulleted_list_item": {
                        "rich_text": [
                            {
                                "type": "text",
                                "text": {
                                    "content": f"{item.get('title')} ({item.get('extractions_count', 0)} extractions)"
                                }
                            }
                        ]
                    }
                })

            client.blocks.children.append(
                block_id=new_page['id'],
                children=[
                    {
                        "object": "block",
                        "type": "heading_2",
                        "heading_2": {
                            "rich_text": [{"type": "text", "text": {"content": "Recent Pages"}}]
                        }
                    },
                    *pages_list
                ]
            )

        return True

    except Exception as e:
        print(f"❌ Error creating Notion page: {e}")
        return False


def export_report_to_notion(report_content, progress, db_stats):
    """
    Export report to Notion.

    Args:
        report_content: Markdown report content
        progress: Progress tracker dict
        db_stats: Database statistics dict
    """
    client = get_notion_client()
    if not client:
        return False

    # Get page ID
    page_id = os.environ.get('NOTION_PAGE_ID')
    if not page_id:
        print("❌ NOTION_PAGE_ID not set in .env")
        print()
        print("Setup:")
        print("1. Share target Notion page with your integration")
        print("2. Get page ID from URL: https://www.notion.so/YOUR_PAGE_ID")
        print("3. Add to .env: NOTION_PAGE_ID=YOUR_PAGE_ID")
        return False

    # Create stats page
    return create_extraction_stats_page(client, page_id, progress, db_stats)


def main():
    """Main function"""
    test_only = '--test' in sys.argv

    print()
    print("=" * 80)
    print("NOTION EXPORT")
    print("=" * 80)
    print()

    if test_only:
        print("Testing Notion connection...")
        success = test_notion_connection()
        return 0 if success else 1

    # Load progress
    from generate_final_report import load_progress, query_database_statistics

    progress = load_progress()
    if not progress:
        return 1

    db_stats = query_database_statistics()

    # Export to Notion
    print("Exporting to Notion...")
    success = export_report_to_notion("", progress, db_stats)

    if success:
        print("✅ Export complete")
    else:
        print("❌ Export failed")

    print()
    print("=" * 80)
    print()

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
