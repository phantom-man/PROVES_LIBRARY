# Audit Log: LeanCloud Post Template Refactor

**Date:** 2026-01-03
**Author:** GitHub Copilot (Agent)
**Subject:** Refactor `docs/_includes/pageview-providers/leancloud/post.html` to eliminate editor syntax errors

## Overview
Refactored the JavaScript in `post.html` to pass Liquid variables via `data-` attributes on the `<script>` tag instead of injecting them directly into the JS code. This resolves persistent "Expression expected" and syntax errors in the editor caused by `{{ page.title | jsonify }}` appearing in a position where a JS expression was expected.

## Changes Applied

### 1. Data Attributes
- **Change:** Added `id="leancloud-script-post"` and `data-*` attributes for `app-id`, `app-key`, `app-class`, `title`, and `key` to the script tag.
- **Reason:** Allows passing server-side data to the client-side script using standard HTML attributes, which are valid syntax.

### 2. JavaScript Logic
- **Change:** Updated the script to retrieve configuration and page data using `document.getElementById('leancloud-script-post').getAttribute(...)`.
- **Change:** Removed direct Liquid injections like `var title = {{ page.title | jsonify }};`.
- **Change:** Updated the jQuery selector to use the retrieved `key` variable: `$("[data-page-key='" + key + "']")`.

## File Status
- `docs/_includes/pageview-providers/leancloud/post.html`: **Updated**

## Verification
- Verified that the new code is valid JavaScript syntax.
- Verified that `escape` filter is used for attributes to ensure HTML safety.
