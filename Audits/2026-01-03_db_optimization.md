# Audit Report: Database Connection Optimization
**Date:** 2026-01-03
**File:** `notion/scripts/notion_webhook_server.py`

## Summary
Implemented asynchronous connection pooling using `psycopg_pool` to replace inefficient per-request database connections. This change improves performance, concurrency, and resource usage.

## Changes Implemented
1.  **Dependency:** Added `psycopg-pool` (installed via pip).
2.  **Imports:** Imported `AsyncConnectionPool` from `psycopg_pool`.
3.  **Initialization:**
    *   Added global `pool` variable.
    *   Initialized `pool` in `lifespan` startup event.
    *   Added graceful shutdown (closing pool) in `lifespan` shutdown event.
4.  **Refactoring:**
    *   Replaced all synchronous `psycopg.connect(DATABASE_URL)` calls with `async with pool.connection() as conn:`.
    *   Converted all cursor operations to async (`await cur.execute`, `await cur.fetchall`, `await cur.fetchone`, `await conn.commit`).
    *   Updated `poll_for_unsynced_items` loop to use the async pool.
    *   Updated all sync functions (`sync_extraction_to_notion`, etc.) to use the async pool.
    *   Updated webhook handlers (`handle_extraction_page_updated`, etc.) to use the async pool.

## Benefits
*   **Performance:** Eliminates the overhead of establishing a new TCP/SSL connection to Neon (PostgreSQL) for every single request or poll iteration.
*   **Concurrency:** Allows the FastAPI server to handle multiple webhooks concurrently without blocking the event loop on database I/O.
*   **Scalability:** Better resource management by maintaining a pool of reusable connections.

## Verification
*   Static analysis confirms no remaining `psycopg.connect` calls in `notion_webhook_server.py`.
*   Code structure follows `psycopg` v3 async patterns.

## Pylance Fixes & Import Standardization
In addition to the optimization, the following Pylance/Type errors were resolved:
1.  **Type Safety:** Added `Optional`, `cast`, and `Any` type hints to handle `None` values correctly.
2.  **Connection Pool:** Typed `pool` as `Any` (temporarily) to resolve generic type variance issues with `psycopg_pool`, while ensuring it is initialized correctly.
3.  **Environment Variables:** Added runtime checks for `DATABASE_URL` to satisfy type checkers.
4.  **Windows Compatibility:** Added `cast(io.TextIOWrapper, ...)` for `sys.stdout.reconfigure` to fix type errors on Windows.
5.  **Package Installation:** Installed `fastapi`, `uvicorn`, and `curator-agent` (local package in editable mode).
6.  **Import Cleanup:** Removed `sys.path` hacking. The script now relies on the installed `curator-agent` package.

## Configuration Management
**Date:** 2026-01-03
**Action:** Centralized configuration and standardized imports across all scripts.

### Changes
1.  **New Config Module:** Created `production/curator/config.py` to handle environment variables and validation.
2.  **Refactoring:** Updated the following files to use `curator.config` instead of `os.getenv`:
    *   `notion/scripts/notion_webhook_server.py`
    *   `production/curator/notion_sync.py`
    *   `production/curator/suggestion_sync.py`
    *   `notion/scripts/manual_sync_suggestions.py`
    *   `notion/scripts/sync_errors_to_notion.py`
3.  **Import Fixes:** Removed `sys.path` hacking and `src.` prefixes from all scripts in `notion/scripts/`, ensuring they use the installed `curator-agent` package.

### Benefits
*   **Single Source of Truth:** All configuration is defined in one place.
*   **Validation:** Critical variables (`DATABASE_URL`, `NOTION_API_KEY`) are validated on startup.
*   **Maintainability:** Cleaner code with standard imports.
