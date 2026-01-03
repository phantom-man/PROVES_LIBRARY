# Audit Log: Favicon Manifest Extension Fix

**Date:** 2026-01-03
**Author:** GitHub Copilot (Agent)
**Subject:** Fix Webhint manifest extension error by restructuring Liquid include

## Overview
Resolved a persistent Webhint error ("Web app manifest should have the filename extension 'webmanifest'") in `docs/_includes/head/favicon.html`.

## Issue
The linter was unable to determine the file extension because the `href` attribute contained only a Liquid variable `{{ __return }}`. Even though the variable resolved to a path ending in `.webmanifest`, the static analysis failed. Attempts to suppress the error via configuration were unsuccessful.

## Fix
Refactored the Liquid include to separate the file path from the extension:
-   **Old:** `path='/assets/site.webmanifest'` -> `href="{{ __return }}"`
-   **New:** `path='/assets/site'` -> `href="{{ __return }}.webmanifest"`

This ensures the `href` attribute explicitly ends with `.webmanifest`, satisfying the linter's static check while maintaining the correct dynamic URL generation.

## File Status
-   `docs/_includes/head/favicon.html`: **Updated**
-   `docs/.hintrc`: **Deleted** (cleanup)

## Verification
-   Verified that `get_errors` returns no errors for the file.
