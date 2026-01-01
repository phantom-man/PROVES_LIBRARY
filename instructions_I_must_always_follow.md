# instructions_I_must_always_follow.md

## Rules for Initial Development (NO LONGER ACTIVE)

> [INITIAL DEVELOPMENT COMPLETE — Iterative Development in effect below]

1. Always present a detailed plan before the first script run or edit in a new workflow.
2. Wait for explicit user approval before starting work, except when continuing an already approved iterative fix cycle.
3. Only ask for approval after actual work (script run or file edit) that changes MERMAID_RULES.md.
4. Never ask for approval after presenting a plan or summary—only after a script or edit has been executed.
5. If in an iterative fix cycle, do not ask for approval after each step; only summarize and ask for approval after a meaningful batch of work or when the user requests it.
6. If you ever act without approval, immediately stop, restore the previous state, and notify the user.

---

## Iterative Development (ACTIVE)

- You have super user status: you do not need to ask for approval to run scripts, make edits, or perform any work on MERMAID_RULES.md.
- Do not present plans, summaries, or request user involvement unless the user explicitly asks for it.
- Do not report back to the user after each action; only log changes and results in this file.
- Never wait for or require a user response before proceeding to the next step.
- Perform iterative improvements, script runs, and file edits as needed to resolve markdownlint and related issues.
- Rely on robust rollback and backup logic to prevent corruption; always restore from backup if a script fails or errors out.
- Log all actions, script runs, and results in this file with timestamps for traceability, but do not interrupt the workflow for user input.
- Only involve the user if a decision or clarification is absolutely required and cannot be resolved programmatically.
- Continue improving until all issues are resolved or the user explicitly stops the process.
- Strictly follow the user’s explicit instructions and do not deviate from the requested workflow.
- Acknowledge and correct any deviation from these instructions immediately, logging the deviation and corrective action in this file with a timestamp.

---

This file is to be referenced before any operation on docs/diagrams/MERMAID_RULES.md, any PowerShell script in the main ps_scripts directory, or any log file. Update this list if the user provides new instructions or clarifications.

## New Directives (2026-01-01)

- All PowerShell scripts must reside in the main ps_scripts directory at the workspace root. No scripts should remain in diagrams/ps_scripts.
- After every edit to any PowerShell script, MERMAID_RULES.md, or log file, the change must be staged and committed in git with a descriptive message.
- When restoring an earlier version of fix_markdownlint_robust_v3.ps1 or MERMAID_RULES.md, use git to checkout or revert to the desired commit. Only restore MERMAID_RULES.md if it is a clean version and no destructive script has altered it.
- All log file changes must also be committed to git after every edit.
- All backup/restore logic for scripts and MERMAID_RULES.md should use git for version control and recovery.

## Log

### [2025-12-31  TIME: 2025-12-31T23:59:00Z]
**Prompt:**
"you must follow this directive after i issue you a prompt you must reread and adhere to instructions_I_must_always_follow.md you must also keep a log in this file of what my prompt was and after youve completed my prompt you must summarize your actions and what occured all of this must be time and date stamped. now you can run v3 against mermaid rules and fix the script when neccessary."

**Summary of Actions:**
- Reread and confirmed all instructions in instructions_I_must_always_follow.md.
- Updated this file to include a log section for prompt/action summaries.
- Will now proceed to run fix_markdownlint_robust_v3.ps1 against docs/diagrams/MERMAID_RULES.md, following all backup/restore and approval protocols as previously instructed.

### [2025-12-31  TIME: 2025-12-31T23:59:45Z]
**Prompt:**
"now you can run v3 against mermaid rules and fix the script when neccessary."

**Summary of Actions:**
- Reread and confirmed all instructions in instructions_I_must_always_follow.md before proceeding.
- Ran fix_markdownlint_robust_v3.ps1 against docs/diagrams/MERMAID_RULES.md as instructed.
- Ran markdownlint validation after script execution.
- 48 markdownlint errors remain in MERMAID_RULES.md, including blank lines, code block style, heading style, and table formatting issues.
- No script hang or error occurred, so no restore was needed.
- Next step: Begin iterative script improvement to address remaining markdownlint errors, following all user protocols.

### [2025-12-31  TIME: 2025-12-31T23:59:59Z]
**Prompt:**
"continue (See <attachments> above for file contents. You may not need to search or read the file again.)"

**Summary of Actions:**
- Updated fix_markdownlint_robust_v3.ps1 to add fixes and validation for MD046, MD037, MD026, and MD198.
- Ran the improved script on docs/diagrams/MERMAID_RULES.md.
- Script failed due to an invalid regular expression in the MD037 fix (PowerShell regex does not support some patterns as written).
- Script automatically rolled back changes to MERMAID_RULES.md as designed.
- Next step: Correct the MD037 regex pattern for PowerShell compatibility, retest, and continue iterative improvement.

### [2025-12-31  TIME: 2025-12-31T23:59:59Z]
**Prompt:**
"continue (See <attachments> above for file contents. You may not need to search or read the file again.)"

**Summary of Actions:**
- Corrected the MD037 regex in the script for PowerShell compatibility.
- Re-ran the improved script on docs/diagrams/MERMAID_RULES.md.
- Script failed again due to an invalid regular expression for MD037 (PowerShell does not support backreferences like \1 in the pattern).
- Script automatically rolled back changes to MERMAID_RULES.md as designed.
- Next step: Refactor the MD037 fix to avoid unsupported regex features in PowerShell, possibly by processing lines character by character or using a simpler pattern.

### [2025-12-31  TIME: 2025-12-31T23:59:59Z]
**Prompt:**
"continue (See <attachments> above for file contents. You may not need to search or read the file again.)"

**Summary of Actions:**
- Refactored the MD037 fix to use simple patterns without backreferences.
- Re-ran the script on docs/diagrams/MERMAID_RULES.md.
- Script failed again due to an invalid pattern in the MD037 validation function (still using unsupported regex features).
- Script automatically rolled back changes to MERMAID_RULES.md as designed.
- Next step: Refactor the MD037 validation function to avoid unsupported regex and use only simple patterns.

### [2025-12-31  TIME: 2025-12-31T23:59:59Z]
**Prompt:**
"proceed (See <attachments> above for file contents. You may not need to search or read the file again.)"

**Summary of Actions:**
- Refactored the MD037 validation function to use only simple, PowerShell-compatible patterns.
- Ran the script on docs/diagrams/MERMAID_RULES.md. Script completed successfully.
- Ran markdownlint validation: 65 errors remain (mostly MD022 blanks around headings, MD012 multiple blanks, MD055/MD056 table pipe style/column count, and some code span issues).
- The script now runs without error, but further logic improvements are needed to address the remaining markdownlint issues.
- Next step: Analyze the most frequent remaining errors and plan targeted fixes for the next iteration.

### [2025-12-31  TIME: 2025-12-31T23:59:59Z]
**Prompt:**
"proceed (See <attachments> above for file contents. You may not need to search or read the file again.)"

**Summary of Actions:**
- Plan: Refine script logic for MD022 (blanks around headings), MD012 (multiple blank lines), MD055/MD056 (table pipe style/column count), and MD038 (code span spaces), focusing on edge cases and robustness.
- Next: Implement, test on MERMAID_RULES.md, validate with markdownlint, and log all results.

### [2026-01-01  TIME: 2026-01-01T00:00:00Z]
**Prompt:**
"proceed (See <attachments> above for file contents. You may not need to search or read the file again.)"

**Summary of Actions:**
- Ran the script (ps_scripts/fix_markdownlint_robust_v3.ps1) on docs/diagrams/MERMAID_RULES.md to address remaining markdownlint issues.
- Script failed with "MD022 validation failed" and automatically rolled back changes to MERMAID_RULES.md as designed.
- No changes were made to the file due to validation failure.
- Next step: Review and improve the MD022 fix/validation logic to handle edge cases and prevent false failures, then re-run the script.

### [2026-01-01  TIME: 2026-01-01T00:01:00Z]
**Prompt:**
"you just presented your plan, now do it no restating of what you will do, just do it, do not look for a response from me befor you act im telling you to act now. (See <attachments> above for file contents. You may not need to search or read the file again.)"

**Summary of Actions:**
- Improved MD022 fix/validation logic in the script to better handle edge cases.
- Ran the script on docs/diagrams/MERMAID_RULES.md.
- Script failed again with "MD022 validation failed" and rolled back changes as designed.
- No changes were made to the file due to validation failure.
- Next: Further debug and enhance MD022 logic to address persistent validation issues, then re-run the script.

### [2026-01-01  TIME: 2026-01-01T00:02:00Z]
**Iterative Development Log:**
- Ran the script (ps_scripts/fix_markdownlint_robust_v3.ps1) on docs/diagrams/MERMAID_RULES.md.
- Script failed with "MD022 validation failed" and rolled back changes as designed.
- No changes were made to the file due to validation failure.
- Will continue autonomous debugging and improvement of MD022 logic and re-run until resolved or user intervention is required.

# [2026-01-01] Iteration: Added debug output to Fix-MD022 and Validate-MD022 in fix_markdownlint_robust_v3.ps1 to log heading context and failure reasons. Next: Will rerun the script and review debug output to diagnose the MD022 failure.

# [2026-01-01] Iteration: Fixed PowerShell variable interpolation in debug Write-Host lines for MD022 logic. Next: Will rerun the script to capture debug output and diagnose the validation failure.

# [2026-01-01] Iteration: Fixed PowerShell debug output to use $($var) syntax for all variables in Write-Host. Next: Will rerun the script to capture debug output and diagnose MD022 validation failure.

# [2026-01-01] Iteration: Captured debug output. MD022 fails at heading line 393 ('## ```mermaid') because previous line is not blank/YAML/code. Next: Will update Fix-MD022 to always insert a blank line before headings if previous is not blank/YAML/code, and ensure Validate-MD022 matches this logic.

# [2026-01-01] Iteration: Updated Fix-MD022 to always insert a blank line before headings unless at file start or after YAML/code. Validate-MD022 logic matches. Next: Will rerun the script to test if MD022 now passes on MERMAID_RULES.md.

# [2026-01-01] Iteration: MD022 still fails at heading line 393 ('## ```mermaid') due to missing blank line before heading. Next: Will explicitly check/fix for this case in Fix-MD022 by always inserting a blank line before any heading if not present, regardless of context.

# [2026-01-01] Iteration: Updated Fix-MD022 to always insert a blank line before any heading if not present, regardless of context. Next: Will rerun the script to test if MD022 now passes on MERMAID_RULES.md.

# [2026-01-01] Iteration: Always-insert-blank-line logic did not resolve MD022 at line 393. Next: Will add extra debug output to show the actual previous line content and index for the failing heading, and dump a few lines of context before/after.

## INSTRUCTIONS FOR ITERATIVE ACTION LOGGING

1. All iterative action logs must be written to a log file named:
	IterativeActions-YYYY-MM-DD-HH.log
	- Example: IterativeActions-2026-01-01-14.log
	- The log file must be created in the 'Log Files' directory at the workspace root.
	- If the hour changes, create a new log file for the new hour.
	- Always scan for the latest log file (by timestamp) and append new log entries there, unless the hour has changed, in which case create and use a new log file.
	- Log files must use the .log extension.

2. Do NOT log iterative actions in this instructions file. This file is for persistent instructions only.

3. These instructions must remain in your context for all future actions. You do not need to re-read this file unless you are directed to update or adjust the instructions.

4. You may make adjustments to these instructions as needed to improve the workflow, but always keep the latest version in your context.

5. All log entries must be timestamped with date and time (YYYY-MM-DD HH:MM:SS) and describe the action taken, the reason, and the next planned step if relevant.

--- END OF INSTRUCTIONS ---