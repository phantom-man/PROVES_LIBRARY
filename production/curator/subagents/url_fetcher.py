"""
URL Fetcher Sub-Agent
Fetches URLs from the urls_to_process database table.
"""
import psycopg
from langchain_core.tools import tool
from curator.config import config


def get_db_connection():
    """Get database connection from configuration."""
    if not config.NEON_DATABASE_URL:
        raise ValueError("NEON_DATABASE_URL not set")
    return psycopg.connect(config.NEON_DATABASE_URL)


@tool
def fetch_next_url() -> str:
    """
    Fetch the next pending URL from the urls_to_process database table.

    Returns the next URL to process, or a message if no URLs are available.
    """
    try:
        conn = get_db_connection()

        with conn.cursor() as cur:
            # Get the next pending URL with row locking to prevent race conditions
            cur.execute("""
                SELECT url, quality_score, quality_reason, preview_summary
                FROM urls_to_process
                WHERE status = 'pending'
                ORDER BY quality_score DESC, discovered_at ASC
                LIMIT 1
                FOR UPDATE SKIP LOCKED
            """)

            row = cur.fetchone()

            if not row:
                conn.close()
                return "No pending URLs available. All URLs have been processed."

            url, quality_score, quality_reason, preview_summary = row

            # Mark as processing
            cur.execute("""
                UPDATE urls_to_process
                SET status = 'processing', processed_at = NOW()
                WHERE url = %s
            """, (url,))

        conn.commit()
        conn.close()

        # Format preview if available
        preview = ""
        if preview_summary:
            preview = f"\n\nPreview: {preview_summary}"
        if quality_reason:
            preview += f"\nQuality reason: {quality_reason}"

        return f"""URL to process: {url}
Quality score: {quality_score}{preview}

Use this URL in extractor_agent task, then call mark_url_complete with the URL."""

    except Exception as e:
        return f"Error fetching URL: {str(e)}"


@tool
def mark_url_complete(url: str, status: str = "completed") -> str:
    """
    Mark a URL as completed or failed in the database.

    Args:
        url: The URL to mark (returned by fetch_next_url)
        status: Either 'completed' or 'failed'

    Returns:
        Confirmation message
    """
    try:
        conn = get_db_connection()

        with conn.cursor() as cur:
            cur.execute("""
                UPDATE urls_to_process
                SET status = %s, processed_at = NOW()
                WHERE url = %s
            """, (status, url))

        conn.commit()
        conn.close()

        return f"URL marked as {status}: {url}"

    except Exception as e:
        return f"Error marking URL complete: {str(e)}"
