"""
PreToolUse hook for Agent tool calls.

Always prints the routing check reminder (goes into Claude's context).
Logs Agent spawns based on verbose level in agent_verbose.level:
  0 = off | 1 = AGENT only | 2 = AGENT+OLLAMA+GEMINI | 3 = everything

Set level:  echo 3 > ws-meta/hooks/agent_verbose.level
"""

import json
import sys
from datetime import datetime
from pathlib import Path

HOOKS_DIR  = Path(__file__).parent
LEVEL_FILE = HOOKS_DIR / "agent_verbose.level"
LOG_FILE   = HOOKS_DIR / "routing.log"

REMINDER = (
    "ROUTING CHECK: Spawning T4+ agent. "
    "State in your response why T0 (Bash/MCP), T1 (Ollama), and T2 (Gemini) "
    "are insufficient for this task."
)

def verbose_level():
    try:
        return int(LEVEL_FILE.read_text().strip())
    except Exception:
        return 0

def main():
    raw = sys.stdin.read().strip()
    try:
        data = json.loads(raw) if raw else {}
    except json.JSONDecodeError:
        data = {}

    # Always print reminder — enforces routing discipline
    print(REMINDER)

    if verbose_level() < 1:
        return

    tool_input    = data.get("tool_input", data)
    subagent_type = tool_input.get("subagent_type", "general-purpose")
    model         = tool_input.get("model", "default")
    description   = tool_input.get("description", "")[:60]
    prompt        = tool_input.get("prompt", "")[:80].replace("\n", " ")

    line = (
        f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} "
        f"AGENT type={subagent_type} model={model} "
        f"desc={description!r} prompt={prompt!r}\n"
    )
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line)

if __name__ == "__main__":
    main()
