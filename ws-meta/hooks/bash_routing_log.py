"""
PostToolUse hook for Bash, Glob, Grep, and MCP tool calls.

Fully silent — writes nothing to stdout (no extra tokens for Claude).
Logs based on verbose level in agent_verbose.level:
  0 = off
  1 = AGENT only (this hook does nothing)
  2 = OLLAMA + GEMINI + WEBSEARCH + MCP  (all explicit delegations)
  3 = everything (adds BASH + GLOB + GREP)

Set level:  echo 3 > ws-meta/hooks/agent_verbose.level

Orphan detection: if web_search.py fires but the next logged tool is not
gemini_run.py, a WARN line is appended to the log.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

HOOKS_DIR    = Path(__file__).parent
LEVEL_FILE   = HOOKS_DIR / "agent_verbose.level"
LOG_FILE     = HOOKS_DIR / "routing.log"
PENDING_FILE = HOOKS_DIR / ".pending_synthesis"
MAX_LINES    = 500

INTERNAL = (
    "auto_commit.py",
    "bash_routing_log.py",
    "agent_routing_check.py",
    "health_check.py",
)


def verbose_level():
    try:
        return int(LEVEL_FILE.read_text().strip())
    except Exception:
        return 0


def is_python_exec(command, script):
    """True only when `script` is being executed by python, not read/catted."""
    lower = command.lower()
    idx = lower.find(script)
    if idx == -1:
        return False
    prefix = lower[:idx]
    return "python" in prefix


def extract_bash(tool_input):
    command = tool_input.get("command", "")

    if any(skip in command for skip in INTERNAL):
        return None, None

    if "ollama run" in command:
        return "OLLAMA", command[:100].replace("\n", " ")

    if is_python_exec(command, "gemini_run.py"):
        return "GEMINI", command[:100].replace("\n", " ")

    if is_python_exec(command, "web_search.py"):
        return "WEBSEARCH", command[:100].replace("\n", " ")

    return "BASH", command[:100].replace("\n", " ")


def extract_glob(tool_input):
    pattern = tool_input.get("pattern", "")
    path    = tool_input.get("path", "")
    snippet = f"pattern={pattern!r}" + (f" path={path!r}" if path else "")
    return "GLOB", snippet[:100]


def extract_grep(tool_input):
    pattern = tool_input.get("pattern", "")
    path    = tool_input.get("path", "")
    glob    = tool_input.get("glob", "")
    snippet = f"pattern={pattern!r}" + (f" path={path!r}" if path else "") + (f" glob={glob!r}" if glob else "")
    return "GREP", snippet[:100]


def extract_mcp(tool_name, tool_input):
    parts = tool_name.split("__")
    short = f"{parts[-2].replace('claude_ai_', '')}:{parts[-1]}" if len(parts) >= 3 else tool_name
    ctx = next((f"{k}={str(v)[:60]!r}" for k, v in tool_input.items() if v), "")
    return "MCP", f"tool={short} {ctx}"


def check_orphan():
    """If a pending synthesis flag exists, log a warning and clear it."""
    if PENDING_FILE.exists():
        try:
            query = PENDING_FILE.read_text(encoding="utf-8").strip()
            warn = (
                f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} "
                f"WARN web_search not followed by gemini_run — possible inline summarization"
                f"{(' query=' + query[:60]) if query else ''}\n"
            )
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write(warn)
        except Exception:
            pass
        finally:
            try:
                PENDING_FILE.unlink()
            except Exception:
                pass


def main():
    level = verbose_level()
    if level < 2:
        return

    raw = sys.stdin.read().strip()
    try:
        data = json.loads(raw) if raw else {}
    except json.JSONDecodeError:
        return

    tool_name  = data.get("tool_name", "")
    tool_input = data.get("tool_input", data)

    if tool_name.startswith("mcp__"):
        route, snippet = extract_mcp(tool_name, tool_input)

    elif tool_name == "Bash":
        route, snippet = extract_bash(tool_input)
        if route is None:
            return
        if route == "BASH" and level < 3:
            return

    elif tool_name == "Glob":
        if level < 3:
            return
        route, snippet = extract_glob(tool_input)

    elif tool_name == "Grep":
        if level < 3:
            return
        route, snippet = extract_grep(tool_input)

    else:
        return

    if route is None or snippet is None:
        return

    # Orphan detection: WEBSEARCH sets the flag; GEMINI clears it;
    # anything else that reaches here while the flag is set triggers a warning.
    if route == "WEBSEARCH":
        try:
            command = tool_input.get("command", "")
            # extract the query argument as context for the warning
            query = command.split("web_search.py")[-1].strip().strip('"').strip("'")[:80]
            PENDING_FILE.write_text(query, encoding="utf-8")
        except Exception:
            pass
    elif route == "GEMINI":
        try:
            PENDING_FILE.unlink(missing_ok=True)
        except Exception:
            pass
    else:
        check_orphan()

    line = (
        f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} "
        f"{route} {snippet}\n"
    )
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line)

    try:
        lines = LOG_FILE.read_text(encoding="utf-8").splitlines(keepends=True)
        if len(lines) > MAX_LINES:
            LOG_FILE.write_text("".join(lines[-MAX_LINES:]), encoding="utf-8")
    except Exception:
        pass


if __name__ == "__main__":
    main()
