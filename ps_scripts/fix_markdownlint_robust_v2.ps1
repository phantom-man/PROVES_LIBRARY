<#
Universal Markdownlint Fixer Script (PowerShell)
- Each markdownlint rule handled in its own section
- Per-section backup, validation, and rollback
- Robust backup/restore logic (never deletes backup until script completes)
- Improved MD038: Handles inline code spans, ignores code blocks, and validates only true inline code
- Works for any markdown file

Usage: pwsh ./fix_markdownlint_robust_v2.ps1 -FilePath <file>
#>

param(
    [string]$FilePath = $(throw "FilePath is required")
)

function Backup-File($path) {
    $backup = "$path.bak"
    Copy-Item $path $backup -Force
    return $backup
}

function Restore-File($backup, $path) {
    if (Test-Path $backup) {
        Copy-Item $backup $path -Force
    }
}

function Remove-Backup($backup) {
    if (Test-Path $backup) { Remove-Item $backup -Force }
}

# --- MD012: No multiple consecutive blank lines ---
function Fix-MD012 {
    param([string]$content)
    $fixed = $content -replace "\n{3,}", "\n\n"
    # Edge: Don't remove blank lines inside code blocks
    $lines = $fixed -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        if ($result.Count -ge 2 -and !$inCode -and $line -eq '' -and $result[-1] -eq '' -and $result[-2] -eq '') { continue }
        $result += $line
    }
    return ($result -join "`n")
}
function Validate-MD012 {
    param([string]$content)
    return ($content -notmatch "\n{3,}")
}

# --- MD022: Blank lines around headings ---
function Fix-MD022 {
    param([string]$content)
    # Add blank lines before and after headings, skip code blocks
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        if ($line -match '^#+ ') {
            if ($result.Count -gt 0 -and $result[-1] -ne '') { $result += '' }
            $result += $line
            if ($i+1 -lt $lines.Length -and $lines[$i+1] -ne '') { $result += '' }
        } else {
            $result += $line
        }
    }
    return ($result -join "`n")
}
function Validate-MD022 {
    param([string]$content)
    $lines = $content -split "\n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^#+ ') {
            if ($i -gt 0 -and $lines[$i-1] -ne '') { return $false }
            if ($i+1 -lt $lines.Length -and $lines[$i+1] -ne '') { return $false }
        }
    }
    return $true
}

# --- MD023: Headings must start at beginning of line ---
function Fix-MD023 {
    param([string]$content)
    return ($content -replace "(?m)^\s+(#+)", '$1')
}
function Validate-MD023 {
    param([string]$content)
    return ($content -notmatch "(?m)^\s+#+")
}

# --- MD029: Ordered list item prefix ---
function Fix-MD029 {
    param([string]$content)
    $lines = $content -split "\n"
    $i = 0
    while ($i -lt $lines.Length) {
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
        $i++
    }
    return ($lines -join "`n")
}
function Validate-MD029 {
    param([string]$content)
    $lines = $content -split "\n"
    $i = 0
    while ($i -lt $lines.Length) {
        if ($lines[$i] -match "^\d+\. ") {
            $num = 1
            $j = $i
            while ($j -lt $lines.Length -and $lines[$j] -match "^\d+\. ") {
                if ($lines[$j] -notmatch "^$num\. ") { return $false }
                $num++
                $j++
            }
            $i = $j - 1
        }
        $i++
    }
    return $true
}

# --- MD038: No space in code span (robust) ---
function Fix-MD038 {
    param([string]$content)
    # Only fix inline code, not code blocks
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        # Replace only inline code spans with spaces inside
        $fixedLine = $line -replace '(`) ([^`]+) (`)', '$1$2$3'
        $result += $fixedLine
    }
    return ($result -join "`n")
}
function Validate-MD038 {
    param([string]$content)
    # Only check outside code blocks
    $lines = $content -split "\n"
    $inCode = $false
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { continue }
        if ($line -match '` [^`]+ `') { return $false }
    }
    return $true
}

# --- MD007: Unordered list indentation ---
function Fix-MD007 {
    param([string]$content)
    $lines = $content -split "\n" | ForEach-Object {
        if ($_ -match '^\s*[-*+] ') { $_.TrimStart() } else { $_ }
    }
    return ($lines -join "`n")
}
function Validate-MD007 {
    param([string]$content)
    return ($content -notmatch "(?m)^\s+[-*+] ")
}

# --- MD055/MD056: Table pipe style and column count ---
function Fix-MD055MD056 {
    param([string]$content)
    $lines = $content -split "\n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^[^|\n]*\|[^|\n]*$') {
            $l = $lines[$i].Trim()
            if (-not $l.StartsWith('|')) { $l = '|' + $l }
            if (-not $l.EndsWith('|')) { $l = $l + '|' }
            # Try to pad columns to match header
            if ($i -gt 0 -and $lines[$i-1] -match '^\|') {
                $headerCols = ($lines[$i-1] -split '\|').Count - 2
                $cols = ($l -split '\|').Count - 2
                if ($cols -lt $headerCols) {
                    $l += (' |' * ($headerCols - $cols))
                }
            }
            $lines[$i] = $l
        }
    }
    return ($lines -join "`n")
}
function Validate-MD055MD056 {
    param([string]$content)
    $lines = $content -split "\n"
    foreach ($line in $lines) {
        if ($line -match '^[^|\n]*\|[^|\n]*$') {
            if (-not $line.Trim().StartsWith('|') -or -not $line.Trim().EndsWith('|')) { return $false }
        }
    }
    return $true
}

# --- MAIN UNIVERSAL FIXER ---
if (!(Test-Path $FilePath)) { Write-Error "File not found: $FilePath"; exit 1 }
$content = Get-Content $FilePath -Raw
$backup = Backup-File $FilePath

try {
    # MD012
    $before = $content
    $content = Fix-MD012 $content
    if (-not (Validate-MD012 $content)) { Restore-File $backup $FilePath; throw "MD012 validation failed" }
    # MD022
    $before = $content
    $content = Fix-MD022 $content
    if (-not (Validate-MD022 $content)) { Restore-File $backup $FilePath; throw "MD022 validation failed" }
    # MD023
    $before = $content
    $content = Fix-MD023 $content
    if (-not (Validate-MD023 $content)) { Restore-File $backup $FilePath; throw "MD023 validation failed" }
    # MD029
    $before = $content
    $content = Fix-MD029 $content
    if (-not (Validate-MD029 $content)) { Restore-File $backup $FilePath; throw "MD029 validation failed" }
    # MD038
    $before = $content
    $content = Fix-MD038 $content
    if (-not (Validate-MD038 $content)) { Restore-File $backup $FilePath; throw "MD038 validation failed" }
    # MD007
    $before = $content
    $content = Fix-MD007 $content
    if (-not (Validate-MD007 $content)) { Restore-File $backup $FilePath; throw "MD007 validation failed" }
    # MD055/MD056
    $before = $content
    $content = Fix-MD055MD056 $content
    if (-not (Validate-MD055MD056 $content)) { Restore-File $backup $FilePath; throw "MD055/MD056 validation failed" }
    Set-Content -Path $FilePath -Value $content -Encoding UTF8
    Remove-Backup $backup
    Write-Host "Universal markdownlint fixes applied to $FilePath"
} catch {
    Write-Error $_
    Restore-File $backup $FilePath
    Write-Host "Rolled back to original file due to error. Please review the script section for improvements."
}
