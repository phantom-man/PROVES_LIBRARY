


<#
Universal Markdownlint Rule Script (PowerShell)
- Each markdownlint rule handled in its own section
- Per-section backup, validation, and rollback
- Robust backup/restore logic (never deletes backup until script completes)
- Improved MD007: Handles unordered lists, nested lists, ignores code blocks, and tests only true lists
- Works for any markdown file

Usage: pwsh ./fix_markdownlint_robust_v3.ps1 -FilePath <file>
#>

# --- Robust Backup/Restore Functions ---
function Backup-File {
    param([string]$file)
    $backupDir = Join-Path -Path (Split-Path $file -Parent) -ChildPath ".backups"
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = Join-Path $backupDir ("$(Split-Path $file -Leaf).bak.$timestamp")
    Copy-Item $file $backupFile -Force
    # Log backup creation in git
    git add $backupFile
    git commit -m "Backup created for $file as $backupFile."
    return $backupFile
}

function Restore-File {
    param([string]$backup, [string]$target)
    Copy-Item $backup $target -Force
    # Log restore in git
    git add $target
    git commit -m "Restored $target from backup $backup."
}

function Remove-Backup {
    param([string]$backup)
    if (Test-Path $backup) { Remove-Item $backup -Force }
    # Log backup removal in git
    git add $backup
    git commit -m "Removed backup $backup."
}

# --- MD012: No multiple consecutive blank lines ---
function Repair-MD012 {
    param([string]$content)
    # Replace 2+ consecutive blank lines (including whitespace-only lines) with a single blank line
    $lines = $content -split "\n"
    $result = @()
    $blankCount = 0
    foreach ($line in $lines) {
        if ($line -match '^\s*$') {
            $blankCount++
        } else {
            $blankCount = 0
        }
        if ($blankCount -le 1) {
            $result += $line
        }
    }
    $fixedContent = ($result -join "`n")
    # Log repair in git
    $tempFile = "$env:TEMP\md012repair_$(Get-Date -Format 'yyyyMMddHHmmss').md"
    $fixedContent | Set-Content $tempFile
    git add $tempFile
    git commit -m "Repair-MD012 applied to content."
    Remove-Item $tempFile -Force
    return $fixedContent
}

function Test-MD012 {
    param([string]$content)
    # Return $false if 2+ consecutive blank lines are found
    $lines = $content -split "\n"
    $blankCount = 0
    foreach ($line in $lines) {
        if ($line -match '^\s*$') {
            $blankCount++
        } else {
            $blankCount = 0
        }
        if ($blankCount -ge 2) {
            return $false
        }
    }
    $isValid = $true
    # Log test in git
    $tempFile = "$env:TEMP\md012test_$(Get-Date -Format 'yyyyMMddHHmmss').md"
    $content | Set-Content $tempFile
    git add $tempFile
    git commit -m "Test-MD012 run on content."
    Remove-Item $tempFile -Force
    return $isValid
}

function Test-MD022 {
    param([string]$content)
    $lines = $content -split "\n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^#+ ' -and $lines[$i] -notmatch '^#+ ```(mermaid|yaml)?$') {
            $prev = if ($i -gt 0) { $lines[$i-1] } else { '' }
            $next = if ($i+1 -lt $lines.Length) { $lines[$i+1] } else { '' }
            Write-Host ("[Test-MD022Valid] Heading at index " + $i + ": '" + $lines[$i] + "'")
            Write-Host ("[Test-MD022Valid] Prev line (" + ($i-1) + "): '" + $prev + "'")
            Write-Host ("[Test-MD022Valid] Next line (" + ($i+1) + "): '" + $next + "'")
            # Allow: file start, after YAML/code, or blank line before heading
            if ($i -eq 0 -or $prev -match '^(---|```|\s*\w+:\s*)$' -or $prev -eq '') {
                # OK
            } else {
                Write-Host "[Test-MD022Valid] FAIL: No blank/YAML/code before heading at $i"
                return $false
            }
            # After heading: allow blank, code, YAML, or file end
            if ($i+1 -ge $lines.Length -or $next -match '^(---|```|\s*\w+:\s*)$' -or $next -eq '') {
                # OK
            } else {
                Write-Host "[Test-MD022Valid] FAIL: No blank/YAML/code after heading at $i"
                return $false
            }
        }
    }
    return $true
}

# --- MD022: Headings must be surrounded by blank lines ---
function Set-MD022 {
    param([string]$content)
    $lines = $content -split "\n"
    $result = @()
    $inCode = $false
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) {
            $result += $line
            continue
        }
        if ($line -match '^#+(\s+|```|```mermaid|```yaml|\s*curve:|\s*theme:|\s*fontSize:|\s*title:|\s*config:|\s*flowchart:|\s*gantt:|\s*sequence:|\s*state:|\s*class:|\s*er:|\s*journey:|\s*pie:|\s*quadrant:|\s*requirement:|\s*gitGraph:|\s*c4:)?$' -and $line -notmatch '^#+ ```(mermaid|yaml)?$') {
            $prev = if ($result.Count -gt 0) { $result[$result.Count-1] } else { '' }
            $next = if ($i+1 -lt $lines.Length) { $lines[$i+1] } else { '' }
            # Always insert blank line before heading unless at file start
            if ($result.Count -eq 0) {
                # OK, do nothing
            } elseif ($prev -notmatch '^\s*$') {
                $result += ''
            }
            $result += $line
            # Always insert blank line after heading unless at end
            if ($i+1 -ge $lines.Length) {
                # OK, do nothing
            } elseif ($next -notmatch '^\s*$') {
                $result += ''
            }
        } else {
            $result += $line
        }
    }
    return ($result -join "`n")
}

# --- MD023: Headings must start at beginning of line ---
function Set-MD023 {
    param([string]$content)
    return ($content -replace "(?m)^\s+(#+)", '$1')
}
function Test-MD023 {
    param([string]$content)
    $lines = $content -split "\n"
    foreach ($line in $lines) {
        if ($line -match "^\s+#+") { return $false }
    }
    return $true
}

# --- MD029: Ordered list item prefix ---
function Set-MD029 {
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
function Test-MD029 {
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
function Set-MD038 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        # Replace all inline code spans with spaces inside (greedy, robust)
        $fixedLine = $line
        while ($fixedLine -match '` [^`]+ `') {
            $fixedLine = $fixedLine -replace '` ([^`]+) `', '`$1`'
        }
        $result += $fixedLine
    }
    return ($result -join "`n")
}
function Test-MD038 {
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

# --- MD007: Unordered list indentation (robust) ---
function Set-MD007 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        # Only fix unordered lists outside code blocks
        if ($line -match '^(\s*)[-*+] ') {
            $currentIndent = ($line -replace '^([-*+]) ', '').Length - $line.TrimStart().Length
            if ($currentIndent -lt 0) { $currentIndent = 0 }
            # For nested lists, indent by multiples of 2 spaces per nesting level
            $nestLevel = 0
            $tmp = $line
            while ($tmp -match '^(\s*)[-*+] ') {
                $nestLevel++
                $tmp = $tmp -replace '^(\s*)[-*+] ', ''
            }
            $fixedIndent = ' ' * (($nestLevel - 1) * 2)
            $fixed = $fixedIndent + $line.TrimStart()
            $result += $fixed
        } else {
            $result += $line
        }
    }
    return ($result -join "`n")
}
function Test-MD007 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { continue }
        # Only check outside code blocks
        if ($line -match '^(\s{3,})[-*+] ') { return $false }
    }
    return $true
}

# --- MD055/MD056: Table pipe style and column count ---
function Set-MD055MD056 {
    param([string]$content)
    $lines = $content -split "\n"
    $out = New-Object System.Collections.ArrayList
    $i = 0
    while ($i -lt $lines.Length) {
        $line = $lines[$i]
        # Detect table header (must have at least one pipe, not code block)
        if ($line -match '^\s*\S.*\|.*$' -and $line -notmatch '^```') {
            # Skip lines that are headings, not table rows
            if ($line -match '^#+ ') { $out.Add($line) | Out-Null; $i++; continue }
            # Table block: collect all contiguous lines with at least one pipe
            $table = @($line)
            $j = $i+1
            while ($j -lt $lines.Length -and $lines[$j] -match '^\s*\S.*\|.*$' -and $lines[$j] -notmatch '^```') {
                $table += $lines[$j]
                $j++
            }
            # Determine max columns from header or max row
            $headerCols = ($table | ForEach-Object { ($_ -split '\|').Count }) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
            # Fix each row
            for ($k = 0; $k -lt $table.Count; $k++) {
                $row = $table[$k].Trim()
                $rowCells = $row -split '\|'
                # Remove empty leading/trailing cells from split
                if ($rowCells[0] -eq '') { $rowCells = $rowCells[1..($rowCells.Count-1)] }
                if ($rowCells[-1] -eq '') { $rowCells = $rowCells[0..($rowCells.Count-2)] }
                # Pad or trim to headerCols
                if ($rowCells.Count -lt $headerCols) {
                    $rowCells += @(' ' * ($headerCols - $rowCells.Count))
                } elseif ($rowCells.Count -gt $headerCols) {
                    $rowCells = $rowCells[0..($headerCols-1)]
                }
                # Always add leading/trailing pipes
                $fixedRow = '|' + ($rowCells -join '|') + '|'
                $out.Add($fixedRow) | Out-Null
            }
            $i = $j
        } else {
            $out.Add($line) | Out-Null
            $i++
        }
    }
    return ($out -join "`n")
}

function Set-MD019 {
    param([string]$content)
    # Remove multiple spaces after hash in headings
    $lines = $content -split "\n"
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^(#+)\s{2,}') {
            $fixed = $line -replace '^(#+)\s{2,}', '$1 '
            Write-Host "MD019 set: '$line' -> '$fixed'"
            $result += $fixed
        } else {
            $result += $line
        }
    }
    return ($result -join "`n")
}

# --- Main entry point ---
function Main {
    param()
    if (-not $PSBoundParameters.ContainsKey('FilePath')) {
        Write-Host "Usage: pwsh ./fix_markdownlint_robust_v3.ps1 -FilePath <file>"
        return
    }
    $content = Get-Content $FilePath -Raw
    $backup = Backup-File $FilePath
    try {
        $content = Repair-MD012 $content
        if (-not (Test-MD012 $content)) { Restore-File $backup $FilePath; throw "MD012 validation failed" }
        $content = Set-MD022 $content
        if (-not (Test-MD022 $content)) { Restore-File $backup $FilePath; throw "MD022 validation failed" }
        $content = Set-MD023 $content
        if (-not (Test-MD023 $content)) { Restore-File $backup $FilePath; throw "MD023 validation failed" }
        $content = Set-MD029 $content
        if (-not (Test-MD029 $content)) { Restore-File $backup $FilePath; throw "MD029 validation failed" }
        $content = Set-MD038 $content
        if (-not (Test-MD038 $content)) { Restore-File $backup $FilePath; throw "MD038 validation failed" }
        $content = Set-MD007 $content
        if (-not (Test-MD007 $content)) { Restore-File $backup $FilePath; throw "MD007 validation failed" }
        $content = Set-MD055MD056 $content
        if (-not (Test-MD055MD056 $content)) { Restore-File $backup $FilePath; throw "MD055/MD056 validation failed" }
        # Additional rules can be added here as needed, following the Set-*/Test-* pattern.
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
        Remove-Backup $backup
        Write-Host "Universal markdownlint fixes applied to $FilePath"
    }
    catch {
        Write-Error $_
        Restore-File $backup $FilePath
        Write-Host "Rolled back to original file due to error. Please review the script section for improvements."
    }
}




