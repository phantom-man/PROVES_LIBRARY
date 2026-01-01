# Fix common markdownlint issues in a Markdown file (PowerShell)
# - Adds blank lines after headings
# - Removes multiple consecutive blank lines
# - Fixes headings not starting at the beginning of the line
# - Fixes ordered list numbering
# - Removes spaces inside code spans
# - Fixes unordered list indentation
# - Fixes table pipe style (simple tables)

param(
    [string]$FilePath = "../docs/diagrams/MERMAID_RULES.md"
)

function Fix-Markdown {
    param([string]$content)

    # 1. Ensure headings start at the beginning of the line
    $content = $content -replace "(?m)^\s+(#+)", '$1'

    # 2. Add blank lines before and after headings
    $content = $content -replace "(?m)([^\n])\n(#+ )", '$1\n\n$2'  # Before
    $content = $content -replace "(?m)(#+ .+)(?!\n\n)(\n[^#\n])", '$1\n\n$2'  # After

    # 3. Remove multiple consecutive blank lines (keep max 1)
    $content = $content -replace "\n{3,}", "\n\n"

    # 4. Fix ordered list numbering (1. 2. 3. ...)
    $lines = $content -split "\n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "^\d+\. ") {
            $num = 1
            $j = $i
            while ($j -lt $lines.Length -and $lines[$j] -match "^\d+\. ") {
                $lines[$j] = $lines[$j] -replace "^\d+\. ", "$num. "
                $num++
                $j++
            }
            $i = $j - 1
        }
    }

    # 5. Remove spaces inside code spans (inline code)
    $lines = $lines | ForEach-Object {
        $_ -replace '` ([^`]+) `', '`$1`'
    }

    # 6. Fix unordered list indentation (MD007)
    $lines = $lines | ForEach-Object {
        if ($_ -match '^\s*[-*+] ') { $_.TrimStart() } else { $_ }
    }

    # 7. Fix table pipe style (add leading/trailing pipes for lines with at least one pipe)
    $lines = $lines | ForEach-Object {
        if ($_ -match '^[^|\n]*\|[^|\n]*$') {
            $l = $_.Trim()
            if (-not $l.StartsWith('|')) { $l = '|' + $l }
            if (-not $l.EndsWith('|')) { $l = $l + '|' }
            $l
        } else { $_ }
    }

    return ($lines -join "`n")
}

# --- VALIDATION ---
# Test the function on a sample string
$test = "#Heading\nText\n1. Item\n2. Item\n\n- List\n- List\n\nA | B\nC | D\n\n`` code span ``\n"
$fixed = Fix-Markdown $test
if ($fixed -notmatch '# Heading' -and $fixed -notmatch '\n{3,}' -and $fixed -notmatch '^\s*[-*+] ' -and $fixed -notmatch '^[^|\n]*\|[^|\n]*$') {
    # Validation passed, run on file
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $fixed = Fix-Markdown $content
        Set-Content -Path $FilePath -Value $fixed -Encoding UTF8
        Write-Host "Markdownlint fixes applied to $FilePath"
    } else {
        Write-Error "File not found: $FilePath"
    }
} else {
    Write-Error "Script validation failed. Not running on file."
}
