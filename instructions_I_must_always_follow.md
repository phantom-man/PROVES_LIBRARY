# instructions_I_must_always_follow.md

## Rules for Initial Development (NO LONGER ACTIVE)

> [INITIAL DEVELOPMENT COMPLETE — Iterative Development in effect below]

1. Always present a detailed plan before the first script run or edit in a new workflow.
2. Wait for explicit user approval before starting work, except when continuing an already approved iterative fix cycle.
3. Only ask for approval after actual work (script run or file edit) that changes [Targeted File].
4. Never ask for approval after presenting a plan or summary—only after a script or edit has been executed.
5. If in an iterative fix cycle, do not ask for approval after each step; only summarize and ask for approval after a meaningful batch of work or when the user requests it.
6. If you ever act without approval, immediately stop, restore the previous state, and notify the user.

---

## Iterative Development (ACTIVE)

- You have super user status: you do not need to ask for approval to run scripts, make edits, or perform any work on [Targeted File].
- Do not present plans, summaries, or request user involvement unless the user explicitly asks for it.
- Do not report back to the user after each action; only log changes and results in this file.
- Never wait for or require a user response before proceeding to the next step.
- Perform iterative improvements, script runs, and file edits as needed to resolve markdownlint and related issues.
- Rely on robust rollback and backup logic to prevent corruption; always restore from backup if a script fails or errors out.
- Log all actions, script runs, and results in this file with timestamps for traceability, but do not interrupt the workflow for user input.
- Only involve the user if a decision or clarification is absolutely required and cannot be resolved programmatically.
  - If an unrecoverable error or ambiguous situation arises that cannot be resolved automatically, immediately escalate to the user for guidance, logging the issue and pausing further automated actions until resolved.
- Continue improving until all issues are resolved or the user explicitly stops the process.
- Strictly follow the user’s explicit instructions and do not deviate from the requested workflow.
- Acknowledge and correct any deviation from these instructions immediately, logging the deviation and corrective action in this file with a timestamp.

---

## [Targeted File] Clarification

Whenever these instructions reference [Targeted File], it refers to the specific file currently being operated on by the workflow, script, or user request. Automation and scripts must resolve [Targeted File] contextually based on the current operation. If ambiguous, escalate for user clarification.

This file is to be referenced before any operation on docs/diagrams/[Targeted File], any PowerShell script in the main ps_scripts directory, or any log file. Update this list if the user provides new instructions or clarifications.


## New Directives (2026-01-01)

*Note: The date 2026-01-01 is intentional and marks the activation of these directives. If this is not correct, update as needed.*

- All PowerShell scripts must reside in the main ps_scripts directory at the workspace root. No scripts should remain in diagrams/ps_scripts.
- After every edit to any PowerShell script, [Targeted File], or log file, the change must be staged and committed in git with a descriptive message.
- When restoring an earlier version of fix_markdownlint_robust_v3.ps1 or [Targeted File], use git to checkout or revert to the desired commit. Only restore [Targeted File] if it is a clean version and no destructive script has altered it.
- All log file changes must also be committed to git after every edit.
- All backup/restore logic for scripts and [Targeted File] should use git for version control and recovery.

## INSTRUCTIONS FOR ITERATIVE ACTION LOGGING

1. All iterative action logs must be written to a log file named:
  IterativeActions-YYYY-MM-DD-HH.log - Example: IterativeActions-2026-01-01-14.log
- The log file must be created in the 'Log Files' directory at the workspace root.
  - All timestamps and log file names must use the system's local time zone (CURRENT: Windows system time zone; update if workflow is used in other regions).
  - If the hour changes, create a new log file for the new hour.
    - On startup or resume, scan for the latest log file by parsing the filename timestamp (YYYY-MM-DD-HH) and selecting the most recent one whose hour (HH) matches the current system hour; otherwise, create and use a new log file for the current system hour.
    - Log files must use the .log extension.

1. Do NOT log iterative actions in this instructions file. This file is for persistent instructions only.

2. These instructions must remain in your context for all future actions. You do not need to re-read this file unless you are directed to update or adjust the instructions.

3. You may make adjustments to these instructions as needed to improve the workflow, but always keep the latest version in your context.

4. All log entries must be timestamped with date and time (YYYY-MM-DD HH:MM:SS) and describe the action taken, the reason, and the next planned step if relevant.

--- END OF INSTRUCTIONS ---
