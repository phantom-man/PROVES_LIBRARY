"""PROVES Library Curator Agent"""
import sys
import os

# Add neon-database scripts to path for graph_manager and other utilities
# This must happen before any subagents are imported
neon_db_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'neon-database', 'scripts'))
if neon_db_path not in sys.path:
    sys.path.insert(0, neon_db_path)
