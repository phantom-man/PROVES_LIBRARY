---
description: Windows path handling rules
applyTo: '**'
---

# Windows Path Rules

## CRITICAL: Windows Path Handling

When working in this Windows environment:

1. **ALWAYS use Windows path format** with backslashes: `C:\Users\User\path\to\file`
2. **NEVER convert paths to Unix format** (forward slashes) unless explicitly running WSL commands
3. PowerShell is the default shell - use Windows-native path conventions
4. When using paths in commands, use raw Windows paths without conversion
5. Do NOT preprocess or normalize Windows paths to Unix format

## Examples

✅ CORRECT:
```powershell
Get-Content "C:\Users\User\PROVES_LIBRARY\README.md"
cd C:\Users\User\PROVES_LIBRARY
```

❌ WRONG:
```powershell
Get-Content "C:/Users/User/PROVES_LIBRARY/README.md"
cd /c/Users/User/PROVES_LIBRARY
```
