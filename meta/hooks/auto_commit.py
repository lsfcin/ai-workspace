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

# Padrões que definem arquivos rastreados (equivalente ao .gitignore whitelist)
TRACKED_PATTERNS = [
    r"CONTEXT\.md$",
    r"SPECS\.md$",
    r"CLAUDE\.md$",
    r"00_ESTRUTURA_DE_PASTAS\.md$",
    r"[/\\]meta[/\\]templates[/\\].+\.md$",
    r"[/\\]meta[/\\]tools[/\\].+\.md$",
    r"[/\\]meta[/\\]referencias[/\\]clief-notes[/\\]",
    r"[/\\]meta[/\\]hooks[/\\]",
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

    git("add", file_path)
    result = git("commit", "-m", f"auto: update {rel_path}")

    if result.returncode != 0 and "nothing to commit" not in result.stdout:
        # Falha real — registra no stderr mas não bloqueia o fluxo
        print(f"[auto_commit] commit falhou: {result.stderr}", file=sys.stderr)


if __name__ == "__main__":
    main()
    sys.exit(0)
