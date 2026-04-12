#!/usr/bin/env python3
"""
auto_commit.py — Hook PostToolUse do Claude Code
Dispara git add + commit quando um arquivo rastreado do AI-Workspace é modificado.

Invocado via settings.json:
  PostToolUse → matcher: Edit|Write → command: python .../auto_commit.py
"""
import json
import os
import re
import subprocess
import sys

WORKSPACE = r"C:\Users\Lucas\Desktop\AI-Workspace"
CLAUDE_SETTINGS = r"C:\Users\Lucas\.claude\settings.json"
SETTINGS_BACKUP = r"C:\Users\Lucas\Desktop\AI-Workspace\ws-meta\config\settings.json"

# Padrões que definem arquivos rastreados (equivalente ao .gitignore whitelist)
TRACKED_PATTERNS = [
    r"CONTEXT\.md$",
    r"SPECS\.md$",
    r"CLAUDE\.md$",
    r"AGENTS\.md$",
    r"[/\\]ws-meta[/\\]templates[/\\].+\.md$",
    r"[/\\]ws-meta[/\\]references[/\\]clief-notes[/\\]",
    r"[/\\]ws-meta[/\\]hooks[/\\]",
    r"[/\\]ws-meta[/\\]scripts[/\\]",
    r"[/\\]ws-meta[/\\]config[/\\]",
    r"README\.md$",
    r"LICENSE$",
    r"\.gitignore$",
]


def is_tracked(path: str) -> bool:
    return any(re.search(p, path, re.IGNORECASE) for p in TRACKED_PATTERNS)


def git(*args) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", "-C", WORKSPACE, *args],
        capture_output=True,
        text=True,
    )


def extract_latest_change(path: str) -> str | None:
    """Read last '- ' line from # LATEST CHANGES section, if present."""
    try:
        lines = open(path, encoding="utf-8").readlines()
    except OSError:
        return None
    in_section = False
    last_entry = None
    for line in lines:
        if line.strip() == "# LATEST CHANGES":
            in_section = True
            continue
        if in_section and line.startswith("- "):
            last_entry = line.strip()[2:]
    return last_entry


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    if tool_name not in ("Edit", "Write"):
        sys.exit(0)

    file_path = data.get("tool_input", {}).get("file_path", "")
    if not file_path or not is_tracked(file_path):
        sys.exit(0)

    rel_path = os.path.relpath(file_path, WORKSPACE)
    change = extract_latest_change(file_path)
    msg = change if change else f"update {rel_path}"

    git("add", file_path)
    result = git("commit", "-m", f"auto: {msg}")

    if result.returncode != 0 and "nothing to commit" not in result.stdout:
        print(f"[auto_commit] commit falhou: {result.stderr}", file=sys.stderr)


if __name__ == "__main__":
    main()
    sys.exit(0)
