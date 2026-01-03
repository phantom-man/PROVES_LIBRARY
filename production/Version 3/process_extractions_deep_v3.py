"""
Process Extraction Queue - Deep Curator Agent (v3)

This script processes the extraction queue using the new DeepAgents-based Curator.
It replaces `process_extractions_v3.py`.

Usage:
    python production/Version 3/process_extractions_deep_v3.py --limit 1
"""

import os
import sys
import uuid
import argparse
from pathlib import Path
from dotenv import load_dotenv
import psycopg

# Setup paths
version3_folder = Path(__file__).parent
project_root = version3_folder.parent.parent
production_root = project_root / 'production'

# Add DeepAgents to path (needed for imports inside agent_deep_v3)
deepagents_path = project_root / 'deepagents' / 'libs' / 'deepagents'
if str(deepagents_path) not in sys.path:
    sys.path.insert(0, str(deepagents_path))

sys.path.insert(0, str(production_root))
sys.path.insert(0, str(version3_folder))

# Load environment
load_dotenv(project_root / '.env')

# Import the Deep Agent
try:
    from agent_deep_v3 import graph
    if graph is None:
        print("ERROR: Deep Curator Agent could not be initialized (check logs above).")
        sys.exit(1)
except ImportError as e:
    print(f"CRITICAL ERROR: Could not import agent_deep_v3: {e}")
    sys.exit(1)
except Exception as e:
    print(f"CRITICAL ERROR: Unexpected error importing agent_deep_v3: {e}")
    sys.exit(1)

def safe_print(text):
    """Print text, replacing characters Windows console can't display."""
    replacements = {
        '\u2032': "'",
        '\u2192': "->",
        '\u2713': "[OK]",
        '\u2717': "x",
    }
    for unicode_char, ascii_char in replacements.items():
        text = text.replace(unicode_char, ascii_char)
    return text.encode('ascii', 'replace').decode('ascii')

def get_pending_urls(limit: int | None = None):
    """Get pending URLs from queue."""
    db_url = os.environ.get('NEON_DATABASE_URL')
    if not db_url:
        print("WARNING: NEON_DATABASE_URL not set. Cannot fetch pending URLs.")
        return []
        
    try:
        conn = psycopg.connect(db_url)
        with conn.cursor() as cur:
            query = """
                SELECT url, quality_score, preview_components, preview_interfaces,
                       preview_keywords, preview_summary
                FROM urls_to_process
                WHERE status = 'pending'
                ORDER BY quality_score DESC, discovered_at ASC
            """
            if limit:
                query += f" LIMIT {limit}"
            cur.execute(query)  # type: ignore
            results = cur.fetchall()
        conn.close()
        return [
            {
                'url': row[0],
                'quality_score': row[1],
                'components': row[2] or [],
                'interfaces': row[3] or [],
                'keywords': row[4] or [],
                'summary': row[5] or ''
            }
            for row in results
        ]
    except Exception as e:
        print(f"ERROR: Failed to fetch pending URLs: {e}")
        return []

def update_url_status(url: str, status: str, error_msg: str | None = None):
    """Update URL status in database."""
    db_url = os.environ.get('NEON_DATABASE_URL')
    if not db_url:
        return

    try:
        conn = psycopg.connect(db_url)
        with conn.cursor() as cur:
            if status == 'completed':
                cur.execute("""
                    UPDATE urls_to_process
                    SET status = %s, processed_at = NOW(), error_message = NULL
                    WHERE url = %s
                """, (status, url))
            else:
                cur.execute("""
                    UPDATE urls_to_process
                    SET status = %s, error_message = %s
                    WHERE url = %s
                """, (status, error_msg, url))
            conn.commit()
        conn.close()
    except Exception as e:
        print(f"ERROR: Failed to update URL status: {e}")

def process_url(url_info: dict, index: int, total: int):
    """Process a single URL with the Deep Curator Agent."""
    url = url_info['url']
    print(f"\n{'='*80}")
    print(f"[DEEP AGENT] Processing [{index}/{total}]: {url}")
    print(f"{'='*80}")

    # Update status
    update_url_status(url, 'processing')

    # Build Task
    task = f"""Please extract architecture from this URL: {url}

Follow the standard pipeline:
1. Extract using the extractor agent.
2. Validate using the validator agent.
3. Store using the storage agent.

Report the final status.
"""

    try:
        thread_id = f"deep-v3-{uuid.uuid4().hex[:8]}"
        config = {
            "configurable": {"thread_id": thread_id},
            "recursion_limit": 50 # Deep agents might need more steps
        }

        print("[DEEP AGENT] Invoking DeepAgents pipeline...")
        
        # Stream the output to see what's happening
        final_message = ""
        for event in graph.stream({"messages": [{"role": "user", "content": task}]}, config):
            for key, value in event.items():
                if key == "agent":
                    if "messages" in value:
                        last_msg = value["messages"][-1]
                        if hasattr(last_msg, 'content') and last_msg.content:
                            print(f"\n[AGENT]: {safe_print(last_msg.content[:200])}...")
                            final_message = last_msg.content
                elif key == "tools":
                    print(f"[TOOL] Executing tool...")

        # Update status to completed
        update_url_status(url, 'completed')
        print(f"\n[SUCCESS] Processing completed.")
        return {'url': url, 'status': 'success', 'message': final_message}

    except Exception as e:
        update_url_status(url, 'failed', str(e))
        print(f"\n[ERROR] Processing failed: {e}")
        import traceback
        traceback.print_exc()
        return {'url': url, 'status': 'failed', 'error': str(e)}

def main():
    parser = argparse.ArgumentParser(description='Process extraction queue with Deep Curator')
    parser.add_argument('--limit', type=int, default=1, help='Number of URLs to process')
    args = parser.parse_args()

    urls = get_pending_urls(args.limit)
    if not urls:
        print("No pending URLs found.")
        return

    print(f"Found {len(urls)} pending URLs.")
    for i, url_info in enumerate(urls):
        process_url(url_info, i + 1, len(urls))

if __name__ == "__main__":
    main()
