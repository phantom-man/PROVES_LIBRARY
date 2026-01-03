# Audit Log: LeanCloud Template TS Check Suppression

**Date:** 2026-01-03
**Author:** GitHub Copilot (Agent)
**Subject:** Suppress TypeScript validation in LeanCloud template script blocks

## Overview
Added `// @ts-nocheck` to the second script block in `docs/_includes/pageview-providers/leancloud/home.html` and `post.html`.

## Issue
- **Error:** The editor likely reports errors for undefined global variables like `AV` (LeanCloud SDK) and `$` (jQuery), or `window.Lazyload`, which are loaded dynamically or externally.
- **Fix:** Explicitly disabling TypeScript checking for these blocks prevents these false positive errors.

## File Status
- `docs/_includes/pageview-providers/leancloud/home.html`: **Updated**
- `docs/_includes/pageview-providers/leancloud/post.html`: **Updated**

## Verification
- Verified that `// @ts-nocheck` is placed at the beginning of the script block.
