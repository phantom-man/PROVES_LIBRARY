# Tools Audit

This document lists the tools created and modified during the recent development sessions, specifically focused on verifying and fixing Mermaid diagram rendering issues on GitHub.

## 1. Mermaid Rendering Verification Tool

**Location:** `scripts/verify_rendering.py`

**Description:**
A Python script that uses Playwright (headless Chromium) to verify if Mermaid diagrams in Markdown files render correctly on GitHub. It navigates to the GitHub blob URL of each file and checks for the presence of "Unable to render rich display" error containers. It also includes an auto-fix capability for common syntax errors (e.g., deprecated `:class` syntax).

**Key Features:**
- **Headless Browser Verification:** Renders the actual GitHub page to detect client-side rendering failures.
- **Auto-Fixer:** Can automatically correct deprecated Mermaid syntax (e.g., converting `A :class` to `A:::class`).
- **Configurable Timeout:** Supports long timeouts (90s) for large or complex diagrams.
- **Regex-based Parsing:** Identifies Mermaid blocks and applies syntax corrections safely.

**Usage:**
```bash
# Verify specific files
python scripts/verify_rendering.py --files docs/diagrams/overview.md

# Verify all files in docs/diagrams (default)
python scripts/verify_rendering.py

# Verify and attempt to fix errors
python scripts/verify_rendering.py --fix

# Specify branch, owner, or repo
python scripts/verify_rendering.py --branch main --owner my-org --repo my-repo
```

## 2. Rendering Fix Orchestrator

**Location:** `ps_scripts/check_and_fix_rendering.ps1`

**Description:**
A PowerShell script that orchestrates the entire verification and fix workflow. It handles the git operations required to verify local changes against GitHub's rendering engine by pushing to a temporary branch before running the verification script.

**Key Features:**
- **Workflow Automation:** Automates the cycle of Lint -> Push -> Verify.
- **Scan-Only Mode:** Can run a read-only scan of the repository to identify issues without making changes.
- **Fix Mode:** Can apply fixes and verify them.
- **Temporary Branch Management:** Pushes to a `verification-auto` branch to avoid cluttering `main` during testing.

**Usage:**
```powershell
# Run a full scan of the current directory (Report Only)
.\ps_scripts\check_and_fix_rendering.ps1 -ScanOnly -FilePath .

# Run verification and fix on a specific file
.\ps_scripts\check_and_fix_rendering.ps1 -FilePath docs/diagrams/overview.md

# Run verification and fix on a directory
.\ps_scripts\check_and_fix_rendering.ps1 -FilePath docs/diagrams
```

## Dependencies

- **Python 3.x**
- **Playwright:** `pip install playwright` && `playwright install chromium`
- **Git:** Must be installed and configured in the environment.
- **PowerShell:** Core or Windows PowerShell.
