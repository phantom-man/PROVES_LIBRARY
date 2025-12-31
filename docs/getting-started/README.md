# Getting Started with PROVES Library

Welcome! This guide will help you set up and run the PROVES Library knowledge extraction system.

## What You'll Learn

1. [Quick Setup](#quick-setup) - Get running in 5 minutes
2. [Your First Extraction](#your-first-extraction) - Extract knowledge from a URL
3. [Understanding the Pipeline](#understanding-the-pipeline) - How the system works
4. [Next Steps](#next-steps) - Where to go from here

---

## Quick Setup

### Prerequisites

- **Python 3.11+** - [Download here](https://www.python.org/downloads/)
- **Database choice:**
  - Neon (cloud, recommended) - [Sign up](https://neon.tech)
  - Docker (local development) - [Install Docker](https://www.docker.com/products/docker-desktop/)
- **Anthropic API key** - [Get yours](https://console.anthropic.com/settings/keys)

### Automated Setup

```bash
# Clone the repository
git clone https://github.com/Lizo-RoadTown/PROVES_LIBRARY.git
cd PROVES_LIBRARY

# Run setup script
# Windows:
setup.bat

# macOS/Linux:
./setup.sh

# Or with Python:
python setup.py
```

The script will:
- Install Python dependencies
- Guide you through API key configuration
- Set up your database (Neon or local Docker)
- Run database migrations
- Verify everything works

**That's it!** You're ready to extract knowledge.

---

## Your First Extraction

Let's extract knowledge from a single NASA F´ documentation page.

### Step 1: Add a URL to Process

```bash
python -c "
from neon-database.scripts.db_connector import get_db
db = get_db()
db.execute(
    'INSERT INTO urls_to_process (url, source, quality_score) VALUES (%s, %s, %s)',
    ('https://nasa.github.io/fprime/UsersGuide/best/app-man-drv.html', 'tutorial', 0.95)
)
print('✓ URL added to queue')
"
```

### Step 2: Run Extraction

```bash
python production/scripts/process_extractions.py --limit 1
```

**What's happening:**
- Extractor agent reads the documentation
- Validator agent checks the extraction quality
- Storage agent saves results to `staging_extractions` table

This will take 30-60 seconds and cost ~$0.20-0.50.

### Step 3: View Results

```bash
python -c "
from neon-database.scripts.db_connector import get_db
db = get_db()
results = db.fetch_all(
    'SELECT candidate_type, candidate_key, confidence_score FROM staging_extractions ORDER BY created_at DESC LIMIT 5'
)
for r in results:
    print(f'{r[\"candidate_type\"]}: {r[\"candidate_key\"]} (confidence: {r[\"confidence_score\"]})')
"
```

You should see components, dependencies, and connections extracted from the documentation!

---

## Understanding the Pipeline

The PROVES Library follows this workflow:

```
Documentation → Crawler → Extraction → Validation → Staging → Human Review → Knowledge Graph
```

### 1. Smart Crawler

Finds high-quality documentation pages:

```bash
python production/scripts/find_good_urls.py --fprime --proveskit --max-pages 50
```

**What it does:** Analyzes documentation sites, scores page quality, queues URLs for extraction

### 2. Extraction Agents

Autonomous agents extract structured knowledge:

```bash
python production/scripts/process_extractions.py --limit 10
```

**What it does:**
- **Extractor:** Reads docs, identifies components/dependencies/connections
- **Validator:** Checks extraction quality, flags issues
- **Storage:** Saves to staging with full epistemic metadata

### 3. Human Verification

**Critical step:** Humans verify agent extractions before they enter the knowledge graph.

**Options:**
- **Notion (provided):** Pre-built verification workflow - [Setup guide](../../production/docs/NOTION_INTEGRATION_GUIDE.md)
- **Custom:** Build your own workflow using the `staging_extractions` table

**Why this matters:** Ensures the knowledge graph reflects verified engineering truth, not LLM hallucinations.

### 4. Knowledge Graph

Only verified knowledge enters the graph. Query it with:

```bash
python mcp-server/examples/quick_start_mcp.py
```

Natural language queries like:
- "What depends on the I2C bus?"
- "Show me all power system interfaces"
- "Trace this dependency back to source"

---

## Next Steps

### Run the Full Pipeline

```bash
# 1. Find documentation
python production/scripts/find_good_urls.py --fprime --proveskit --max-pages 50

# 2. Extract knowledge (autonomous agents)
python production/scripts/process_extractions.py --limit 10

# 3. Verify extractions (in Notion or custom tool)

# 4. Query knowledge graph
python mcp-server/examples/quick_start_mcp.py

# 5. Generate progress report
python testing/scripts/generate_progress_report.py

# 6. Analyze extraction quality
python production/scripts/improvement_analyzer.py
```

### Learn More

- [System Architecture](../architecture/AGENTIC_ARCHITECTURE.md) - How agents coordinate
- [Knowledge Framework](../../canon/KNOWLEDGE_FRAMEWORK.md) - Epistemic foundations
- [MCP Integration](../../mcp-server/docs/MCP_INTEGRATION.md) - Natural language queries
- [Production Guide](../../production/README.md) - Running the curator in production

### Common Issues

**"No module named 'psycopg2'"**
```bash
pip install -r requirements.txt
```

**"Database connection failed"**
- Check `NEON_DATABASE_URL` in `.env`
- If using Docker: `docker-compose up -d`
- Wait 5-10 seconds for PostgreSQL to initialize

**"Anthropic API error"**
- Check `ANTHROPIC_API_KEY` in `.env`
- Verify key at [console.anthropic.com](https://console.anthropic.com/settings/keys)

**Still stuck?**
- Check [production/docs/DEPLOYMENT_NOTES.md](../../production/docs/DEPLOYMENT_NOTES.md)
- Open an issue: [GitHub Issues](https://github.com/Lizo-RoadTown/PROVES_LIBRARY/issues)

---

## Cost Awareness

- **URL crawling:** Free (web scraping)
- **Extraction:** ~$0.20-0.50 per URL (depends on page length)
- **Progress reports:** ~$0.10-0.30 per run
- **Improvement analyzer:** Free (database analysis only)

**Tip:** Use `--limit` flags to control costs while testing:
```bash
python production/scripts/process_extractions.py --limit 1  # Start small
```

---

## Philosophy

> "Agents extract and categorize. Humans establish truth."

The PROVES Library is built on the principle that:
- **Agents** are excellent at finding patterns and extracting structure
- **Humans** are essential for verifying that structure matches reality
- **Systems** provide access to verified knowledge across personnel transitions

This separation ensures your knowledge graph reflects **verified engineering truth**, not hallucinated AI outputs.

---

**Ready to go deeper?** Check out the [Production README](../../production/README.md) for advanced usage.
