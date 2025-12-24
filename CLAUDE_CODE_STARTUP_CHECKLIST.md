# Claude Code - Daily Extraction Startup Checklist

**When user requests:** "Run the daily extraction workflow"

**Follow these steps BEFORE starting extraction:**

## Pre-Flight Checks

### 1. Environment Health ✅
```bash
cd curator-agent && python -X utf8 check_environment.py
```
- All checks must pass
- Database must be connected
- API keys must be set

### 2. Verify Next Page URL ✅ **CRITICAL**
```bash
cd curator-agent && python -X utf8 verify_page.py "<next_page_url>"
```

**Check:**
- ✅ Status: 200
- ✅ Has Content: True (> 500 chars)
- ✅ Sample looks like documentation (not just navigation/TOC)

**Red Flags:**
- ❌ Index pages (`/index.md`, `/index.html`) - usually just TOC
- ❌ Very short content (< 1000 chars) - likely empty
- ❌ Sample shows only navigation links - no technical content

**If page is bad:**
- Ask user if they want to skip it
- Or suggest the next page in queue
- Update extraction_progress.json to skip bad page

### 3. Review Task Scope
**Ask user to confirm:**
- One page or multiple pages?
- Do they want to verify each extraction (HITL)?
- Should I (Claude Code) act as curator instead of spawning the LangGraph curator?

### 4. Check for Known Issues
- Is recursion_limit issue still present? (curator loops)
- Are extractor tools working? (check LangSmith traces if available)
- Any failed runs in extraction_progress.json?

## During Extraction

### As Curator (if acting directly):
1. Fetch page content myself
2. Extract architecture using FRAMES
3. Present EACH extraction to user for verification
4. Stage approved extractions to database
5. Generate daily report

### If Using LangGraph Curator:
1. Monitor for "Sorry, need more steps" errors
2. Stop after 3 consecutive failures
3. Check LangSmith traces for root cause

## After Extraction

### 1. Generate Report
```bash
# Report is auto-generated, show user the file
cat curator-agent/reports/daily_report_YYYY-MM-DD.md
```

### 2. Update Progress
- extraction_progress.json updated automatically
- Show user: X/60 pages complete

### 3. Prepare Next Page
- Verify next page URL before ending session
- Note any issues for next run

---

## Quick Reference

**Verify page:**
```bash
cd curator-agent && python verify_page.py "<url>"
```

**Check DB state:**
```bash
cd curator-agent && python check_last_run.py
```

**Manual extraction (test):**
```bash
cd curator-agent && python test_curator_direct.py
```

---

**Remember:** I (Claude Code) CAN be the curator. Don't spawn unnecessary LangGraph agents!
