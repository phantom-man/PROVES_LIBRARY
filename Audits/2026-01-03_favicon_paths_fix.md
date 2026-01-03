# Audit Log: Favicon and Manifest Path Fixes

**Date:** 2026-01-03
**Author:** GitHub Copilot (Agent)
**Subject:** Fix relative paths in `browserconfig.xml` and `site.webmanifest`

## Overview
Updated the asset paths in `docs/assets/browserconfig.xml` and `docs/assets/site.webmanifest` to be absolute paths including the site's `baseurl` (`/PROVES_LIBRARY`). This ensures that favicons and app icons load correctly when the site is hosted on GitHub Pages.

## Changes Applied

### 1. `docs/assets/browserconfig.xml`
- **Issue:** The `src` attribute for `square150x150logo` was `assets/mstile-150x150.png`, which is a relative path that breaks if the browser config is loaded from a different context or if the base URL is not handled by the browser's XML parser relative to the site root.
- **Fix:** Updated path to `/PROVES_LIBRARY/assets/mstile-150x150.png`.

### 2. `docs/assets/site.webmanifest`
- **Issue:** The `src` attributes for the icons were relative (e.g., `android-chrome-192x192.png`). While valid relative to the manifest file itself, explicit absolute paths are more robust for PWA installation and validation across different hosting environments.
- **Fix:** Updated paths to include the base URL:
    - `/PROVES_LIBRARY/assets/android-chrome-192x192.png`
    - `/PROVES_LIBRARY/assets/android-chrome-512x512.png`

## File Status
- `docs/assets/browserconfig.xml`: **Updated**
- `docs/assets/site.webmanifest`: **Updated**

## Verification
- Verified against `docs/_config.yml` which defines `baseurl: /PROVES_LIBRARY`.
