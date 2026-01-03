# Encoding and Linting Fixes Report

**Date:** January 3, 2026
**Agent:** GitHub Copilot

## Executive Summary

A comprehensive audit was conducted to identify and resolve character encoding issues (Mojibake), PowerShell script syntax errors, and potential Python encoding bugs. These issues posed risks of data corruption, script failures, and cross-platform incompatibility.

## 1. PowerShell Encoding Fixes (Mojibake Prevention)

**Issue:** Several PowerShell scripts used `Get-Content`and`Set-Content`without explicitly specifying`-Encoding UTF8`. On Windows, this defaults to Windows-1252 (ANSI), causing UTF-8 characters (like emojis or special symbols) to be corrupted when files are modified.

**Fix:** Updated all file I/O operations to enforce `UTF8` encoding.

**Affected Files:**
- `scripts/apply-theme.ps1` (Critical: Used for applying themes to all diagrams)
- `ps_scripts/fix_markdownlint.ps1`
- `ps_scripts/fix_tables_cross_system.ps1`
- `ps_scripts/fix_theme_css_indent.ps1`
- `ps_scripts/update_validation_report.ps1`
- `ps_scripts/fix_markdownlint_robust.ps1` (Superseded by v3)

## 2. PowerShell Script Analysis & Cleanup

**Issue:** The `ps_scripts` directory contained numerous PSScriptAnalyzer errors, including syntax errors, trailing whitespace, unused variables, and broken versioned copies of scripts.

**Fixes:**
- **Syntax Repair:** Completely rewrote `ps_scripts/convert_agentic_diagram.ps1` to fix parsing errors.
- **Cleanup:** Deleted broken/unused scripts:
  - `ps_scripts/fix_markdownlint_universal.ps1`
  - `ps_scripts/convert_agentic_diagram_v*.ps1`
  - `ps_scripts/fix_knowledge_gaps_v*.ps1`
  - `ps_scripts/fix_markdownlint_robust_v2.ps1`
  - `ps_scripts/apply-fall-all.ps1`
- **Linting:**
  - Removed trailing whitespace from all `.ps1` files.
  - Renamed functions in `fix_markdownlint_robust_v3.ps1`(e.g.,`Set-MD012`->`Format-MD012`) to comply with PowerShell verb standards.
  - Suppressed false-positive warnings where appropriate.

## 3. Python Encoding Fixes

**Issue:** Python scripts were using `open()`or`pathlib.Path.read_text()`without`encoding='utf-8'`. This relies on the system default encoding (often `cp1252`on Windows), leading to crashes or corruption when handling UTF-8 files (like`.env` or YAML registries).

**Fix:** Explicitly added `encoding='utf-8'` to all text file operations.

**Affected Files:**
- **`setup.py`**: Fixed reading `.env.example`and writing`.env`.
- **`mcp-server/src/proves_mcp/registry.py`**: Fixed loading of the YAML source registry.
- **`production/curator/notion_sync.py`**: Fixed `.env` file updates.
- **`production/Version 2/process_extractions_v2.py`**: Fixed log file creation.
- **`production/Version 3/process_extractions_v3.py`**: Fixed log file creation.

## Conclusion

The repository's maintenance scripts are now robust against encoding-related data corruption on Windows systems. The script library has been sanitized of broken versions and syntax errors.

