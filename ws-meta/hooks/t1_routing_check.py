#!/usr/bin/env python3
"""
UserPromptSubmit hook — T1 routing enforcement.

Fires before every Claude response. If the user's prompt looks like isolated
code generation (T1), injects a hard reminder to route through Ollama instead
of writing code inline.

Trigger: prompt matches code-gen patterns AND has no codebase-context signals.
"""
import json
import re
import sys
from datetime import datetime
from pathlib import Path

HOOKS_DIR = Path(__file__).parent
LOG_FILE  = HOOKS_DIR / "routing.log"

# Patterns that suggest "write me some code from scratch"
T1_TRIGGERS = [
    r"\bwrite\s+(a\s+|an\s+)?(function|method|class|script|snippet|util|helper|parser|decorator|algorithm)\b",
    r"\bcreate\s+(a\s+|an\s+)?(function|method|class|script|snippet|util|helper)\b",
    r"\bgenerate\s+(a\s+|an\s+)?(function|method|class|code|script|snippet)\b",
    r"\bimplement\s+(a\s+|an\s+)?(\w+\s+)?(function|method|class|algorithm|logic|struct|interface)\b",
    r"\bmake\s+(a\s+|an\s+)?(function|method|class|script|snippet)\b",
    r"\bbuild\s+(a\s+|an\s+)?(function|method|class|script|utility)\b",
    r"\bcode\s+(for|that|to)\s+\w+",
    r"\bboilerplate\b",
]

# Any of these signals mean codebase context IS needed → not T1
T1_EXCLUSIONS = [
    r"[/\\][a-zA-Z_]",                           # path separator → file path
    r"\b\w+\.(py|dart|js|ts|go|java|cpp|rs|kt|swift|rb|cs|vue|jsx|tsx)\b",  # file extension
    r"\b(fix|debug|refactor|update|change|modify|edit|patch|rename)\b",      # mutation intent
    r"\b(this file|this code|the codebase|the project|existing|current)\b",  # codebase ref
    r"\b(in\s+the\s+repo|in\s+the\s+app|in\s+the\s+project)\b",
    r"```",                                       # user is pasting existing code
]

REMINDER = (
    "[T1-HOOK] ROUTING ALERT: This prompt matches T1 (isolated code generation).\n"
    "MANDATORY: route through Ollama -- do NOT write code inline.\n"
    "  Simple/boilerplate  -> ollama run qwen2.5-coder:7b \"<full prompt>\"\n"
    "  Complex logic       -> ollama run deepseek-coder-v2 \"<full prompt>\"\n"
    "Run the Bash command and return Ollama's output. Skipping this violates the routing protocol."
)


def main():
    raw = sys.stdin.read().strip()
    try:
        data = json.loads(raw) if raw else {}
    except json.JSONDecodeError:
        data = {}

    prompt = data.get("prompt", "")
    if not prompt:
        return

    prompt_lower = prompt.lower()

    # Exclusions take priority — if any fire, this is NOT T1
    for excl in T1_EXCLUSIONS:
        if re.search(excl, prompt_lower, re.IGNORECASE):
            return

    # If a trigger fires, inject the routing reminder
    for trigger in T1_TRIGGERS:
        if re.search(trigger, prompt_lower, re.IGNORECASE):
            print(REMINDER)
            return


if __name__ == "__main__":
    main()
