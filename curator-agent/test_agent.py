"""
Quick test of the Curator Deep Agent
"""
import sys
import os

# Add parent scripts to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'scripts'))

# Set up environment
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '..', '.env'))

# Import the agent
from src.curator.agent import graph

def setup_console():
    """Set up console for UTF-8 output (Windows fix)"""
    if sys.platform == "win32":
        try:
            sys.stdout.reconfigure(encoding='utf-8')
        except :
            os.system('chcp 65001 > nul')
            sys.stdout.flush()
setup_console()

# Test it
print("=" * 60)
print("Testing PROVES Library Curator Deep Agent")
print("=" * 60)
config = {"configurable": {"thread_id": "1", "user_id": "curators-tests"}}

# Simple test
result = graph.invoke({
    "messages": [{
        "role": "user",
        "content": "List the current state of the knowledge graph using the storage agent"
    }]
},
config
)

print("\nAgent Response:")
# Handle emojis in output for Windows console
try:
    print(result['messages'][-1].content)
except UnicodeEncodeError:
    # Fallback: replace emojis with text representations
    print(result['messages'][-1].content.encode('ascii', errors='replace').decode('ascii'))

print("\n" + "=" * 60)
print("Test complete! Check LangSmith for full trace:")
print("https://smith.langchain.com/")
print("=" * 60)
