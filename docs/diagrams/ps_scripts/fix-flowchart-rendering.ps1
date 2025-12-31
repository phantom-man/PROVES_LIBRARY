# Fix Mermaid flowchart rendering issues:
# 1. Subgraph labels overlapping content (fixed width issue)
# 2. Diamond text being cut off
# 3. Font inconsistency
# 4. Differences between GitHub preview and HTML rendering
#
# Key fixes:
# - Set htmlLabels: false to enable native SVG text wrapping
# - Increase rankSpacing for better vertical separation
# - Increase padding for subgraph breathing room
# - Update themeCSS for proper label positioning

$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Path "*.md" -Exclude "MERMAID_RULES.md","VALIDATION_REPORT.md"

foreach ($file in $files) {
    Write-Host "`nProcessing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $modified = $false
    
    # Fix 1: Change htmlLabels: true to false for proper text wrapping
    # With htmlLabels: false, Mermaid uses SVG text which handles wrapping better
    if ($content -match 'htmlLabels: true') {
        $content = $content -replace 'htmlLabels: true', 'htmlLabels: false'
        Write-Host "  ✓ Changed htmlLabels to false (enables SVG text wrapping)" -ForegroundColor Green
        $modified = $true
    }
    
    # Fix 2: Increase rankSpacing from 60 to 80 for subgraph label breathing room
    if ($content -match 'rankSpacing: 60') {
        $content = $content -replace 'rankSpacing: 60', 'rankSpacing: 80'
        Write-Host "  ✓ Increased rankSpacing to 80 (more vertical space)" -ForegroundColor Green
        $modified = $true
    }
    
    # Fix 3: Increase padding from 20 to 25 for better subgraph internal spacing
    if ($content -match 'padding: 20') {
        $content = $content -replace 'padding: 20', 'padding: 25'
        Write-Host "  ✓ Increased padding to 25 (better subgraph spacing)" -ForegroundColor Green
        $modified = $true
    }
    
    # Fix 4: Update themeCSS to add proper subgraph label styling
    # The old CSS had limited effectiveness with htmlLabels: true
    $oldThemeCSS = @"
  themeCSS: \|
    \.node rect, \.cluster rect, \.edgePath path \{ transition: filter 0\.2s ease, stroke-width: 0\.2s ease; \}
    \.node:hover rect, \.cluster:hover rect, \.edgePath:hover path \{ filter: drop-shadow\(0 0 8px rgba\(0,0,0,0\.35\)\); stroke-width: 3px; \}
    \.edgeLabel rect \{ rx: 6px; ry: 6px; stroke-width: 1px; \}
    \.cluster-label \{ display: block; padding-bottom: 8px; margin-bottom: 8px; font-weight: 600; white-space: nowrap; \}
"@
    
    $newThemeCSS = @"
  themeCSS: |
    .node rect, .cluster rect, .edgePath path { transition: filter 0.2s ease, stroke-width 0.2s ease; }
    .node:hover rect, .cluster:hover rect, .edgePath:hover path { filter: drop-shadow(0 0 8px rgba(0,0,0,0.35)); stroke-width: 3px; }
    .edgeLabel rect { rx: 6px; ry: 6px; stroke-width: 1px; }
    .cluster-label { font-weight: 600; }
    .node .label { dominant-baseline: middle; }
"@
    
    if ($content -match [regex]::Escape('cluster-label { display: block; padding-bottom: 8px')) {
        $content = $content -replace '\.cluster-label \{ display: block; padding-bottom: 8px; margin-bottom: 8px; font-weight: 600; white-space: nowrap; \}', '.cluster-label { font-weight: 600; }'
        Write-Host "  ✓ Simplified cluster-label CSS (removed fixed constraints)" -ForegroundColor Green
        $modified = $true
    }
    
    # Write back if modified
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✓ File saved" -ForegroundColor Green
    } else {
        Write-Host "  - No changes needed" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Flowchart Rendering Fixes Applied ===" -ForegroundColor Green
Write-Host @"

Changes made:
1. htmlLabels: false - Uses SVG text instead of HTML foreignObject
   - SVG text wraps properly within shapes
   - Consistent rendering across GitHub and HTML
   - Diamond/decision shapes won't clip text

2. rankSpacing: 80 - More vertical space between rows
   - Subgraph labels have room to display
   - Content won't overlap with labels above

3. padding: 25 - Slightly more internal subgraph padding
   - Labels won't overlap first nodes

4. Simplified cluster-label CSS
   - Removed 'display: block' and 'white-space: nowrap' constraints
   - Allows natural text flow

Test: Push to GitHub and view rendered HTML pages.
"@ -ForegroundColor Cyan
