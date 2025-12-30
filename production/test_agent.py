"""
Quick test to verify create_agent() works with tools
"""
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic
from langchain_core.tools import tool

@tool
def simple_tool(text: str) -> str:
    """A simple test tool that echoes input."""
    return f"Tool received: {text}"

# Create agent
agent = create_agent(
    model=ChatAnthropic(model="claude-3-5-haiku-20241022", temperature=0.1),
    system_prompt="You are a test agent. When asked to test, call the simple_tool.",
    tools=[simple_tool],
)

# Test invocation
result = agent.invoke(
    {"messages": [{"role": "user", "content": "Please test the simple_tool with the text 'hello world'"}]},
    {"configurable": {"thread_id": "test-123"}}
)

print("Result:")
print(result["messages"][-1].content)
