# PROVES Library Quick Reference

One-page command reference for common operations.

## Setup

```bash
# Automated setup (recommended)
python setup.py

# Manual setup
pip install -r requirements.txt
cp .env.example .env
# Edit .env with API keys
python neon-database/scripts/run_migration.py
```

## Core Commands

### Find Documentation URLs

```bash
# Crawl F´ and PROVES Kit documentation
python production/scripts/find_good_urls.py --fprime --proveskit --max-pages 50

# Check what's queued
python production/scripts/check_pending_extractions.py
```

### Extract Knowledge

```bash
# Process 10 URLs (autonomous agents)
python production/scripts/process_extractions.py --limit 10

# Process single URL (for testing)
python production/scripts/process_extractions.py --limit 1
```

### Generate Reports

```bash
# System progress report (calls Claude agent)
python testing/scripts/generate_progress_report.py

# Extraction quality analysis (database only, no API cost)
python production/scripts/improvement_analyzer.py
```

### Query Knowledge Graph

```bash
# Natural language queries via MCP
python mcp-server/examples/quick_start_mcp.py
```

## Database Operations

### Check Database Status

```bash
# Test connection and view stats
python neon-database/scripts/db_connector.py
```

### View Staged Extractions

```python
from neon-database.scripts.db_connector import get_db

db = get_db()
results = db.fetch_all(
    "SELECT candidate_type, candidate_key, confidence_score FROM staging_extractions ORDER BY created_at DESC LIMIT 10"
)
for r in results:
    print(f"{r['candidate_type']}: {r['candidate_key']} (confidence: {r['confidence_score']})")
```

### Add URL Manually

```python
from neon-database.scripts.db_connector import get_db

db = get_db()
db.execute(
    "INSERT INTO urls_to_process (url, source, quality_score) VALUES (%s, %s, %s)",
    ("https://example.com/doc.html", "manual", 0.9)
)
```

## Verification Workflow

### Option A: Notion (Recommended)

```bash
# Setup: See production/docs/NOTION_INTEGRATION_GUIDE.md

# Start webhook server (if using Notion sync)
python notion/scripts/notion_webhook_server.py
```

### Option B: Direct Database Query

```python
from neon-database.scripts.db_connector import get_db

db = get_db()

# View unreviewed extractions
pending = db.fetch_all(
    "SELECT * FROM staging_extractions WHERE review_decision IS NULL ORDER BY created_at DESC LIMIT 10"
)

# Approve an extraction
db.execute(
    "UPDATE staging_extractions SET review_decision = 'approve', reviewed_at = NOW() WHERE extraction_id = %s",
    (extraction_id,)
)
```

## Environment Variables

### Required

```bash
NEON_DATABASE_URL=postgresql://user:password@host/database
ANTHROPIC_API_KEY=sk-ant-api03-...
```

### Optional

```bash
# LangSmith (tracing and observability)
LANGCHAIN_TRACING_V2=true
LANGSMITH_API_KEY=lsv2_sk_...
LANGSMITH_PROJECT=PROVES_Library

# Notion (verification workflow)
NOTION_API_KEY=secret_...
NOTION_DATABASE_ID=...
```

## Common Flags

### process_extractions.py

```bash
--limit N           # Process N URLs (default: unlimited)
--source SOURCE     # Only process URLs from specific source
--min-quality Q     # Only process URLs with quality >= Q
```

### find_good_urls.py

```bash
--fprime            # Crawl F´ documentation
--proveskit         # Crawl PROVES Kit documentation
--max-pages N       # Maximum pages to crawl per source
--min-score S       # Minimum quality score to queue (0.0-1.0)
```

## File Locations

### Configuration

```
.env                           # Environment variables (API keys, database)
docker-compose.yml             # Local PostgreSQL setup
requirements.txt               # Python dependencies
```

### Documentation

```
docs/getting-started/          # Beginner guides
docs/architecture/             # System design docs
docs/diagrams/                 # Cross-system visualizations
production/docs/               # Production/extraction docs
mcp-server/docs/               # MCP server docs
neon-database/docs/            # Database docs
```

### Scripts

```
setup.py                       # Automated setup
production/scripts/            # Production extraction scripts
testing/scripts/               # Testing and analysis scripts
neon-database/scripts/         # Database utilities
notion/scripts/                # Notion integration
```

### Data

```
testing_data/                  # Test data and progress reports
testing_data/progress_diagrams/  # Generated progress reports
```

## Cost Estimates

| Operation | Cost | Time |
|-----------|------|------|
| Find URLs (crawling) | Free | 1-5 min |
| Extract 1 URL | $0.20-0.50 | 30-60 sec |
| Extract 10 URLs | $2-5 | 5-10 min |
| Progress report | $0.10-0.30 | 30-60 sec |
| Improvement analyzer | Free | <5 sec |

## Monitoring

### LangSmith Traces

If `LANGCHAIN_TRACING_V2=true`:
- View traces at: [smith.langchain.com](https://smith.langchain.com/)
- Project: `PROVES_Library`

### Database Statistics

```python
from neon-database.scripts.db_connector import get_db

db = get_db()
stats = db.fetch_all("SELECT * FROM database_statistics ORDER BY table_name")
for row in stats:
    print(f"{row['table_name']}: {row['row_count']} rows")
```

## Troubleshooting

### Database Connection Errors

```bash
# Test connection
python neon-database/scripts/db_connector.py

# If using Docker, check status
docker-compose ps

# Restart Docker database
docker-compose down
docker-compose up -d
```

### Import Errors

```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Check Python version (must be 3.11+)
python --version
```

### API Errors

```bash
# Verify API key
echo $ANTHROPIC_API_KEY  # Linux/Mac
echo %ANTHROPIC_API_KEY%  # Windows

# Check API key validity at console.anthropic.com
```

## Resources

- **Main README:** [../../README.md](../../README.md)
- **Production Guide:** [../../production/README.md](../../production/README.md)
- **MCP Integration:** [../../mcp-server/docs/MCP_INTEGRATION.md](../../mcp-server/docs/MCP_INTEGRATION.md)
- **Knowledge Framework:** [../../canon/KNOWLEDGE_FRAMEWORK.md](../../canon/KNOWLEDGE_FRAMEWORK.md)
- **GitHub Issues:** [github.com/Lizo-RoadTown/PROVES_LIBRARY/issues](https://github.com/Lizo-RoadTown/PROVES_LIBRARY/issues)
