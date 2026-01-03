# Code Review: Notion Scripts
**Date:** January 3, 2026
**Reviewer:** GitHub Copilot

## Overview
This review covers the Python scripts located in `notion/scripts/`. These scripts handle the synchronization between the Neon database and Notion, including a webhook server for bidirectional updates.

## Files Reviewed
1.  `manual_sync_suggestions.py`
2.  `notion_webhook_server.py`
3.  `setup_notion.py`
4.  `sync_errors_to_notion.py`

## Critical Findings

### 1. Security Vulnerability in `notion_webhook_server.py`
**Severity:** High
**Location:** `verify_signature` function (Lines 460-475)
**Issue:** The script prints the `WEBHOOK_SECRET` and the received signature to standard output for debugging purposes.
```python
print(f"DEBUG: WEBHOOK_SECRET = '{WEBHOOK_SECRET}'")
```
**Recommendation:** **IMMEDIATELY REMOVE** these print statements. Never log secrets or sensitive tokens.

### 2. Inefficient Database Connection Management
**Severity:** Medium
**Location:** All files, especially `notion_webhook_server.py`
**Issue:** The scripts create a new database connection (`psycopg.connect`) for every operation (polling loop, webhook request, sync function).
**Impact:** High latency and potential connection exhaustion under load.
**Recommendation:** Implement a `ConnectionPool` (using `psycopg_pool`) to reuse connections, especially for the long-running webhook server.

### 3. `sys.path` Manipulation
**Severity:** Low
**Location:** `notion_webhook_server.py`, `setup_notion.py`
**Issue:** Scripts modify `sys.path` to import modules from `production` or `src`.
```python
sys.path.insert(0, str(project_root / 'production'))
```
**Impact:** Makes the code fragile and dependent on the specific directory structure.
**Recommendation:** Run scripts as modules (e.g., `python -m notion.scripts.server`) or install the project in editable mode (`pip install -e .`).

## Detailed File Analysis

### `notion_webhook_server.py`
*   **Polling Logic:** The `poll_for_unsynced_items` function runs an infinite loop with `asyncio.sleep(10)`. While functional, it creates a new DB connection every 10 seconds.
*   **Error Handling:** Broad `try...except Exception` blocks catch all errors but might mask specific issues.
*   **Type Safety:** The code lacks strict type hints in some places, though recent fixes have improved this.
*   **Hardcoded Limits:** Uses `LIMIT 10` for polling. This might be too low for high-throughput scenarios or too high if processing is slow.

### `manual_sync_suggestions.py`
*   **Hardcoded Limit:** Fetches only 10 unsynced suggestions.
*   **No Error Handling:** If the DB connection fails, the script crashes.

### `sync_errors_to_notion.py`
*   **Logic:** Fetches recent errors and syncs them.
*   **Improvement:** Could benefit from batch processing if the volume of errors is high.

## Action Plan
1.  **Fix Security Issue:** Remove secret logging in `notion_webhook_server.py`.
2.  **Optimize DB Connections:** Refactor `notion_webhook_server.py` to use a connection pool.
3.  **Standardize Imports:** Ensure consistent import paths.
4.  **Configuration:** Move magic numbers (limits, intervals) to environment variables or a config file.
