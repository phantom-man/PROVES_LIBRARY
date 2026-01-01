# --- Loop Detection Utility ---
function Detect-Loop {
    param([string]$logFile, [string]$currentAction)
    if (!(Test-Path $logFile)) { return $false }
    $lastLines = Get-Content $logFile -Tail 5
    $repeatCount = ($lastLines | Where-Object { $_ -like "*${currentAction}*" }).Count
    if ($repeatCount -ge 3) {
        Write-Host "[LOOP DETECTED] Action '$currentAction' repeated $repeatCount times in last 5 log entries. Halting further action."
        Add-Content $logFile ("[" + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + "] [LOOP DETECTED] Action '$currentAction' repeated $repeatCount times. Halting further action.")
        exit 99
    }
    return $false
}


<#
Universal Markdownlint Fixer Script (PowerShell)
- Each markdownlint rule handled in its own section
- Per-section backup, validation, and rollback
- Robust backup/restore logic (never deletes backup until script completes)
- Improved MD007: Handles unordered lists, nested lists, ignores code blocks, and validates only true lists
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
    return $backupFile
}

function Restore-File {
    param([string]$backup, [string]$target)
    Copy-Item $backup $target -Force
}

function Remove-Backup {
    param([string]$backup)
    if (Test-Path $backup) { Remove-Item $backup -Force }
}

# --- MD012: No multiple consecutive blank lines ---
function Fix-MD012 {
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
    return ($result -join "`n")
}

function Validate-MD012 {
    param([string]$content)
    # Return $false if 2+ consecutive blank lines are found
    return ($content -notmatch "(\n\s*){3,}")
}

function Validate-MD022 {
    param([string]$content)
    $lines = $content -split "\n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match '^#+ ') {
            $prev = if ($i -gt 0) { $lines[$i-1] } else { '' }
            $next = if ($i+1 -lt $lines.Length) { $lines[$i+1] } else { '' }
            Write-Host ("[Validate-MD022] Heading at index " + $i + ": '" + $lines[$i] + "'")
            Write-Host ("[Validate-MD022] Prev line (" + ($i-1) + "): '" + $prev + "'")
            Write-Host ("[Validate-MD022] Next line (" + ($i+1) + "): '" + $next + "'")
            # Allow: file start, after YAML/code, or blank line before heading
            if ($i -eq 0 -or $prev -match '^(---|```|\s*\w+:\s*)$' -or $prev -eq '') {
                # OK
            } else {
                Write-Host "[Validate-MD022] FAIL: No blank/YAML/code before heading at $i"
                return $false
            }
            # After heading: allow blank, code, YAML, or file end
            if ($i+1 -ge $lines.Length -or $next -match '^(---|```|\s*\w+:\s*)$' -or $next -eq '') {
                # OK
            } else {
                Write-Host "[Validate-MD022] FAIL: No blank/YAML/code after heading at $i"
                return $false
            }
        }
    }
    return $true
}

# --- MD022: Headings must be surrounded by blank lines ---
function Fix-MD022 {
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
        if ($line -match '^#+ ') {
            $prev = if ($result.Count -gt 0) { $result[$result.Count-1] } else { '' }
            $next = if ($i+1 -lt $lines.Length) { $lines[$i+1] } else { '' }
            Write-Host ("[Fix-MD022] Heading at index " + $i + ": '" + $line + "'")
            Write-Host ("[Fix-MD022] Prev line (" + ($result.Count-1) + "): '" + $prev + "'")
            Write-Host ("[Fix-MD022] Next line (" + ($i+1) + "): '" + $next + "'")
            # Ensure blank line before heading (unless at file start or after YAML/code block)
            if ($result.Count -eq 0 -or $prev -match '^(---|```|\s*\w+:\s*)$') {
                # OK, do nothing
            } elseif ($prev -ne '') {
                Write-Host "[Fix-MD022] Inserting blank line before heading at $i"
                $result += ''
            }
            $result += $line
            # Ensure blank line after heading (unless at end or next is code block/YAML)
            if ($i+1 -ge $lines.Length -or $next -match '^(---|```|\s*\w+:\s*)$') {
                # OK, do nothing
            } elseif ($next -ne '') {
                Write-Host "[Fix-MD022] Inserting blank line after heading at $i"
                $result += ''
            }
        } else {
            $result += $line
        }
    }
    return ($result -join "`n")
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

# --- MD007: Unordered list indentation (robust) ---
function Fix-MD007 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    $prevIndent = 0
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
function Validate-MD007 {
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
function Fix-MD055MD056 {
    param([string]$content)
    $lines = $content -split "\n"
    $out = New-Object System.Collections.ArrayList
    $i = 0
    while ($i -lt $lines.Length) {
        $line = $lines[$i]
        # Detect table header (must have at least one pipe, not code block)
        if ($line -match '^[^|\n]*\|[^|\n]*$' -and $line.Trim() -notmatch '^\|.*\|$' -and $line -notmatch '^```') {
            # Table block: collect all contiguous lines with at least one pipe
            $table = @($line)
            $j = $i+1
            while ($j -lt $lines.Length -and $lines[$j] -match '^[^|\n]*\|[^|\n]*$' -and $lines[$j] -notmatch '^```') {
                $table += $lines[$j]
                $j++
            }
            # Determine max columns from header
            $header = $table[0].Trim()
            $headerCols = ($header -split '\|').Count
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

# --- MD046: Code block style (convert indented to fenced) ---
function Fix-MD046 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    $codeBlock = @()
    foreach ($line in $lines) {
        if ($line -match '^\s{4,}' -and !$inCode) {
            $inCode = $true
            $codeBlock = @($line.TrimStart())
        } elseif ($inCode -and $line -match '^\s{4,}') {
            $codeBlock += $line.TrimStart()
        } elseif ($inCode) {
            $result += '```'
            $result += $codeBlock
            $result += '```'
            $result += $line
            $inCode = $false
            $codeBlock = @()
        } else {
            $result += $line
        }
    }
    if ($inCode) {
        $result += '```'
        $result += $codeBlock
        $result += '```'
    }
    return ($result -join "`n")
}
function Validate-MD046 {
    param([string]$content)
    # No indented code blocks (4+ spaces at start of line outside fenced blocks)
    $lines = $content -split "\n"
    $inCode = $false
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if (!$inCode -and $line -match '^\s{4,}\S') { return $false }
    }
    return $true
}

# --- MD037: No space in emphasis markers ---
function Fix-MD037 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        # Remove spaces after opening and before closing emphasis markers (single * or _)
        $fixed = $line
        # Remove space after opening * or _
        $fixed = $fixed -replace '\* +', '*'
        $fixed = $fixed -replace '_ +', '_'
        # Remove space before closing * or _
        $fixed = $fixed -replace ' +\*', '*'
        $fixed = $fixed -replace ' +_', '_'
        $result += $fixed
    }
    return ($result -join "`n")
}
function Validate-MD037 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { continue }
        # Look for space after * or _
        if ($line -match '\* +' -or $line -match '_ +') { return $false }
        # Look for space before * or _
        if ($line -match ' +\*' -or $line -match ' +_') { return $false }
    }
    return $true
}

# --- MD026: No trailing punctuation in headings ---
function Fix-MD026 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        if ($line -match '^#+ .*[!?.:;]$') {
            $fixed = $line -replace '([!?.:;]+)$', ''
            $result += $fixed
        } else {
            $result += $line
        }
    }
    return ($result -join "`n")
}
function Validate-MD026 {
    param([string]$content)
    $lines = $content -split "\n"
    $inCode = $false
    foreach ($line in $lines) {
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { continue }
        if ($line -match '^#+ .*[!?.:;]$') { return $false }
    }
    return $true
}

# --- MD198: Heading style (enforce ATX # style) ---
function Fix-MD198 {
    param([string]$content)
    # Convert setext (underlined) headings to ATX
    $lines = $content -split "\n"
    $inCode = $false
    $result = New-Object System.Collections.ArrayList
    $i = 0
    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        if ($line -match '^```') { $inCode = -not $inCode }
        if ($inCode) { [void]$result.Add($line); $i++; continue }
        while ($i -lt $lines.Count) {
            $line = $lines[$i]
            if ($line -match '^```') { $inCode = -not $inCode }
            if ($inCode) { [void]$result.Add($line); $i++; continue }
            if ($line -match '^#+ ') {
                # Ensure exactly one blank line before heading (unless at file start)
                if ($result.Count -eq 0) {
                    # File start, do nothing
                } elseif ($result[$result.Count-1] -ne '') {
                    [void]$result.Add('')
                } elseif ($result.Count -gt 1 -and $result[$result.Count-2] -eq '') {
                    # Remove extra blank lines before heading
                    while ($result.Count -gt 1 -and $result[$result.Count-2] -eq '') { $result.RemoveAt($result.Count-2) }
                }
                [void]$result.Add($line)
                # Skip all blank lines after heading
                $j = $i+1
                while ($j -lt $lines.Count -and $lines[$j] -eq '') { $j++ }
                # Add exactly one blank line after heading (unless at end or next is code block/YAML)
                if ($j -lt $lines.Count -and $lines[$j] -notmatch '^(---|```|\s*\w+:\s*)$') { [void]$result.Add('') }
                $i = $j
                continue
            }
            [void]$result.Add($line)
            $i++
        }
        return ($result -join "`n")
    }

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
        # MD046
        $before = $content
        $content = Fix-MD046 $content
        if (-not (Validate-MD046 $content)) { Restore-File $backup $FilePath; throw "MD046 validation failed" }
        # MD037
        $before = $content
        $content = Fix-MD037 $content
        if (-not (Validate-MD037 $content)) { Restore-File $backup $FilePath; throw "MD037 validation failed" }
        # MD026
        $before = $content
        $content = Fix-MD026 $content
        if (-not (Validate-MD026 $content)) { Restore-File $backup $FilePath; throw "MD026 validation failed" }
        # MD198
        $before = $content
        $content = Fix-MD198 $content
        if (-not (Validate-MD198 $content)) { Restore-File $backup $FilePath; throw "MD198 validation failed" }
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

Main
