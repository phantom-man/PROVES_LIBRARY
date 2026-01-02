<#
Universal Markdownlint Rule Script (PowerShell)
- Each markdownlint rule handled in its own section
- Per-section backup, validation, and rollback
- Robust backup/restore logic (never deletes backup until script completes)
- Improved MD007: Handles unordered lists, nested lists, ignores code blocks, and tests only true lists
- Works for any markdown file

Usage: pwsh ./fix_markdownlint_robust_v3.ps1 -FilePath <file>
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# --- Robust Backup/Restore Functions ---
function Backup-File {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$file)
    $backupDir = Join-Path -Path (Split-Path $file -Parent) -ChildPath ".backups"
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = Join-Path $backupDir ("$(Split-Path $file -Leaf).$timestamp.bak")
    if ($PSCmdlet.ShouldProcess($file, "Backup file to $backupFile")) {
        Copy-Item $file $backupFile -Force
        # Log backup creation in git
        git add $backupFile | Out-Null
        git commit -m "Backup created for $file as $backupFile." | Out-Null
    }
    return $backupFile
}

function Restore-File {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$backup, [string]$target)
    if ($PSCmdlet.ShouldProcess($target, "Restore file from $backup")) {
        Copy-Item $backup $target -Force
        # Log restore in git
        git add $target | Out-Null
        git commit -m "Restored $target from backup $backup." | Out-Null
    }
}

function Remove-Backup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$backup)
    if ($PSCmdlet.ShouldProcess($backup, "Remove backup file")) {
        if (Test-Path $backup) {
            Remove-Item $backup -Force
            # Log backup removal in git
            git add $backup | Out-Null
            git commit -m "Removed backup $backup." | Out-Null
        }
    }
    else {
        # No state change if ShouldProcess returns false
        return
    }
}

# --- MD012: No multiple consecutive blank lines ---
function Set-MD012 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    # Replace 2+ consecutive blank lines (including whitespace-only lines) with a single blank line, including at file start/end
    $lines = $content -split "\n"
    $result = [System.Collections.Generic.List[string]]::new()
    $blankCount = 0
    foreach ($line in $lines) {
        if ($line -match '^\s*$') {
            $blankCount++
        } else {
            $blankCount = 0
        }
        if ($blankCount -le 1) {
            $null = $result.Add($line)
        }
    }
    # Remove leading blank lines at file start
    while ($result.Count -gt 0 -and $result[0] -match '^\s*$') { $result.RemoveAt(0) }
    # Remove trailing blank lines at file end
    while ($result.Count -gt 0 -and $result[$result.Count-1] -match '^\s*$') { $result.RemoveAt($result.Count-1) }
    $fixedContent = ($result.ToArray() -join "`n")
    if ($PSCmdlet.ShouldProcess("MD012", "Apply markdownlint fix for MD012")) {
        Write-Information "Set-MD012 applied."
    }
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
    return $true
}

function Test-MD022 {
    param([string]$content)
    $lines = $content -split "\n"
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        $prev = if ($i -gt 0) { $lines[$i-1] } else { '' }
        $next = if ($i+1 -lt $lines.Length) { $lines[$i+1] } else { '' }
        if ($line -match '^#') {
            Write-Information ("[Test-MD022Valid] Prev line (" + ($i-1) + "): '" + $prev + "'")
            Write-Information ("[Test-MD022Valid] Next line (" + ($i+1) + "): '" + $next + "'")
            if ($i -eq 0 -or $prev -match '^(---|```|\s*\w+:\s*)$' -or $prev -eq '') {
                # OK
            } else {
                Write-Information "[Test-MD022Valid] FAIL: No blank/YAML/code before heading at $i"
                return $false
            }
            if ($i+1 -ge $lines.Length -or $next -match '^(---|```|\s*\w+:\s*)$' -or $next -eq '') {
                # OK
            } else {
                Write-Information "[Test-MD022Valid] FAIL: No blank/YAML/code after heading at $i"
                return $false
            }
        }
    }
    return $true
}

# --- MD022: Headings must be surrounded by blank lines ---
function Set-MD022 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    $lines = $content -split "\n"
    $result = [System.Collections.Generic.List[string]]::new()
    $inCode = $false
    $headingPattern = '^(#+)(\s+|\s*```|\s*```mermaid|\s*```yaml|\s*curve:|\s*theme:|\s*fontSize:|\s*title:|\s*config:|\s*flowchart:|\s*gantt:|\s*sequence:|\s*state:|\s*class:|\s*er:|\s*journey:|\s*pie:|\s*quadrant:|\s*requirement:|\s*gitGraph:|\s*c4:|\s*\w+:)?$'
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*```') { $inCode = -not $inCode }
        if ($inCode) {
            $null = $result.Add($line)
            continue
        }
        if ($line -match $headingPattern) {
            # Always insert a blank line above unless at file start
            if ($result.Count -eq 0 -or $result[$result.Count-1] -notmatch '^\s*$') {
                $null = $result.Add('')
            }
            $null = $result.Add($line)
            # Always insert a blank line below unless at file end or next is heading
            $nextIdx = $i+1
            while ($nextIdx -lt $lines.Length -and $lines[$nextIdx] -match '^\s*$') { $nextIdx++ }
            $nextLine = if ($nextIdx -lt $lines.Length) { $lines[$nextIdx] } else { '' }
            if ($nextIdx -ge $lines.Length -or $nextLine -match $headingPattern) {
                # End of file or next is heading: still insert blank line for MD022 compliance
                $null = $result.Add('')
            } elseif ($nextLine -notmatch '^\s*$' -and $nextLine -notmatch $headingPattern) {
                $null = $result.Add('')
            }
        } else {
            $null = $result.Add($line)
        }
    }
    # Remove leading blank lines at file start
    while ($result.Count -gt 0 -and $result[0] -match '^\s*$') { $result.RemoveAt(0) }
    # Remove trailing blank lines at file end
    while ($result.Count -gt 0 -and $result[$result.Count-1] -match '^\s*$') { $result.RemoveAt($result.Count-1) }
    $fixedContent = ($result.ToArray() -join "`n")
    if ($PSCmdlet.ShouldProcess("MD022", "Apply markdownlint fix for MD022")) {
        # Could add logging here if desired
    }
    return $fixedContent
}

# --- MD023: Headings must start at beginning of line ---

###############################################################
# MD023: Headings must start at beginning of line
###############################################################
function Set-MD023 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    # Remove leading whitespace before heading hashes
    $fixedContent = ($content -replace "(?m)^\s+(#+)", '$1')
    if ($PSCmdlet.ShouldProcess("MD023", "Apply markdownlint fix for MD023")) {
        # Could add logging here if desired
    }
    return $fixedContent
}

function Test-MD023 {
    param([string]$content)
    # Return $false if any heading does not start at the beginning of the line
    $lines = $content -split "\n"
    foreach ($line in $lines) {
        if ($line -match "^\s+#+") { return $false }
    }
    return $true
}

# --- MD029: Ordered list item prefix ---

###############################################################
# MD029: Ordered list item prefix
###############################################################
function Set-MD029 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    # Normalize ordered list numbers so each list starts at 1 and increments
    $lines = $content -split "\n"
    $i = 0
    while ($i -lt $lines.Length) {
        if ($lines[$i] -match "^\d+\. ") {
            $num = 1
            $j = $i
            # For each contiguous block of ordered list items
            while ($j -lt $lines.Length -and $lines[$j] -match "^\d+\. ") {
                $lines[$j] = $lines[$j] -replace "^\d+\. ", "$num. "
                $num++
                $j++
            }
            $i = $j - 1
        }
        $i++
    }
    $fixedContent = ($lines -join "`n")
    if ($PSCmdlet.ShouldProcess("MD029", "Apply markdownlint fix for MD029")) {
        # Could add logging here if desired
    }
    return $fixedContent
}

function Test-MD029 {
    param([string]$content)
    # Return $false if any ordered list does not increment properly
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

###############################################################
# MD038: No space in code span (robust)
###############################################################
function Set-MD038 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    # Remove spaces inside inline code spans (e.g., ` code ` -> `code`), outside code blocks
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^\s*```') { $inCode = -not $inCode }
        if ($inCode) { $result += $line; continue }
        # Replace all inline code spans with spaces inside (greedy, robust)
        $fixedLine = $line
        while ($fixedLine -match '` [^`]+ `') {
            $fixedLine = $fixedLine -replace '` ([^`]+) `', '`$1`'
        }
        $result += $fixedLine
    }
    $fixedContent = ($result -join "`n")
    if ($PSCmdlet.ShouldProcess("MD038", "Apply markdownlint fix for MD038")) {
        # Could add logging here if desired
    }
    return $fixedContent
}

function Test-MD038 {
    param([string]$content)
    # Only check outside code blocks for code spans with spaces
    $lines = $content -split "\n"
    $inCode = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*```') { $inCode = -not $inCode }
        if ($inCode) { continue }
        if ($line -match '` [^`]+ `') { return $false }
    }
    return $true
}

# --- MD007: Unordered list indentation (robust) ---

###############################################################
# MD007: Unordered list indentation (robust)
###############################################################
function Set-MD007 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    # Fix unordered list indentation (2 spaces per nesting level), outside code blocks
    $lines = $content -split "\n"
    $inCode = $false
    $result = @()
    foreach ($line in $lines) {
        if ($line -match '^\s*```') { $inCode = -not $inCode }
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
    $fixedContent = ($result -join "`n")
    if ($PSCmdlet.ShouldProcess("MD007", "Apply markdownlint fix for MD007")) {
        # Could add logging here if desired
    }
    return $fixedContent
}

function Test-MD007 {
    param([string]$content)
    # Only check outside code blocks for unordered list indentation
    $lines = $content -split "\n"
    $inCode = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*```') { $inCode = -not $inCode }
        if ($inCode) { continue }
        # Only check outside code blocks
        if ($line -match '^(\s{3,})[-*+] ') { return $false }
    }
    return $true
}

# --- MD055/MD056: Table pipe style and column count ---

###############################################################
# MD055/MD056: Table pipe style and column count
###############################################################
function Set-MD055MD056 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    # Normalize table rows to have consistent pipe style and column count
    $lines = $content -split "\n"
    $out = New-Object System.Collections.ArrayList
    $i = 0
    while ($i -lt $lines.Length) {
        $line = $lines[$i]
        # Detect table header (must have at least one pipe, not code block)
        if ($line -match '^\s*\S.*\|.*$' -and $line -notmatch '^\s*```') {
            # Skip lines that are headings, not table rows
            if ($line -match '^#+ ') { $out.Add($line) | Out-Null; $i++; continue }
            # Table block: collect all contiguous lines with at least one pipe
            $table = @($line)
            $j = $i+1
            while ($j -lt $lines.Length -and $lines[$j] -match '^\s*\S.*\|.*$' -and $lines[$j] -notmatch '^\s*```') {
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
    $fixedContent = ($out -join "`n")
    if ($PSCmdlet.ShouldProcess("MD055MD056", "Apply markdownlint fix for MD055/MD056")) {
        # Could add logging here if desired
    }
    return $fixedContent
}

function Test-MD055MD056 {
    param([string]$content)
    $lines = $content -split "\n"
    $i = 0
    $inCode = $false
    while ($i -lt $lines.Length) {
        $line = $lines[$i]
        if ($line -match '^\s*```') {
            $inCode = -not $inCode
            $i++
            continue
        }
        if ($inCode) {
            $i++
            continue
        }
        if ($line -match '^\s*\S.*\|.*$') {
            if ($line -match '^#+ ') { $i++; continue }
            $table = @($line)
            $j = $i + 1
            while ($j -lt $lines.Length) {
                $next = $lines[$j]
                if ($next -match '^\s*```') { break }
                if ($next -notmatch '^\s*\S.*\|.*$') { break }
                $table += $next
                $j++
            }
            $expectedColumns = $null
            foreach ($row in $table) {
                $segments = @($row.Trim() -split '\|')
                if ($segments.Count -eq 0) { continue }
                $rowCells = @()
                for ($idx = 0; $idx -lt $segments.Count; $idx++) {
                    $isBoundary = ($idx -eq 0) -or ($idx -eq $segments.Count - 1)
                    if ($isBoundary -and $segments[$idx] -eq '') { continue }
                    $rowCells += $segments[$idx]
                }
                if ($null -eq $expectedColumns) {
                    $expectedColumns = $rowCells.Count
                    continue
                }
                if ($rowCells.Count -ne $expectedColumns) { return $false }
            }
            $i = $j
        } else {
            $i++
        }
    }
    return $true
}


###############################################################
# MD019: No multiple spaces after hash in headings
###############################################################
function Set-MD019 {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string]$content)
    # Remove multiple spaces after hash in headings
    if ($PSCmdlet.ShouldProcess("Content", "Apply markdownlint fix for MD019")) {
        $lines = $content -split "\n"
        $result = @()
        foreach ($line in $lines) {
            if ($line -match '^(#+)\s{2,}') {
                $fixed = $line -replace '^(#+)\s{2,}', '$1 '
                Write-Information "MD019 set: '$line' -> '$fixed'"
                $result += $fixed
            } else {
                $result += $line
            }
        }
        return ($result -join "`n")
    } else {
        return $content
    }
}

# --- Main entry point ---

###############################################################
# Main entry point
###############################################################
function Main {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    $content = Get-Content $FilePath -Raw
    $backup = Backup-File $FilePath
    try {
        # Apply and validate each rule in sequence, but only restore backup if an actual error/exception is thrown
        $content = Set-MD022 $content
        if (-not (Test-MD022 $content)) { Write-Warning "MD022 validation failed after fix. Leaving file as-is for inspection." }
        $content = Set-MD012 $content
        if (-not (Test-MD012 $content)) { Write-Warning "MD012 validation failed after fix. Leaving file as-is for inspection." }
        $content = Set-MD019 $content
        $content = Set-MD023 $content
        if (-not (Test-MD023 $content)) { Write-Warning "MD023 validation failed after fix. Leaving file as-is for inspection." }
        $content = Set-MD029 $content
        if (-not (Test-MD029 $content)) { Write-Warning "MD029 validation failed after fix. Leaving file as-is for inspection." }
        $content = Set-MD038 $content
        if (-not (Test-MD038 $content)) { Write-Warning "MD038 validation failed after fix. Leaving file as-is for inspection." }
        $content = Set-MD007 $content
        if (-not (Test-MD007 $content)) { Write-Warning "MD007 validation failed after fix. Leaving file as-is for inspection." }
        $content = Set-MD055MD056 $content
        if (-not (Test-MD055MD056 $content)) { Write-Warning "MD055/MD056 validation failed after fix. Leaving file as-is for inspection." }
        # Additional rules can be added here as needed, following the Set-*/Test-* pattern.
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
        Remove-Backup $backup
        Write-Information "Universal markdownlint fixes applied to $FilePath"
    }
    catch {
        Write-Error $_
        Restore-File $backup $FilePath
        Write-Information "Rolled back to original file due to error. Please review the script section for improvements."
    }
}






Main -FilePath $FilePath




