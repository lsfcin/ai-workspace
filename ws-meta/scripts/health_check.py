#!/usr/bin/env python3
"""
Health check — verifica disponibilidade dos executores do workspace.

Uso:
  python ws-meta/scripts/health_check.py          # check sem testar APIs
  python ws-meta/scripts/health_check.py --test   # inclui chamada real ao Gemini (consome quota)

Gera: ws-meta/references/tools_status.md
"""
import argparse
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

WORKSPACE = Path(__file__).resolve().parents[2]
OUTPUT = WORKSPACE / "ws-meta" / "tools" / "tools_status.md"
SCRIPTS = WORKSPACE / "ws-meta" / "scripts"

OLLAMA_MODELS_EXPECTED = ["qwen2.5-coder:7b", "deepseek-coder-v2", "qwen3:4b"]
GEMINI_SCRIPTS = ["gemini_run.py", "gemini_tts.py", "gemini_image.py", "imagen_run.py"]


def run(cmd: list[str]) -> tuple[int, str]:
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        return r.returncode, (r.stdout + r.stderr).strip()
    except Exception as e:
        return 1, str(e)


def check_ollama() -> tuple[str, list[str]]:
    code, out = run(["ollama", "list"])
    if code != 0:
        return "ERROR: ollama not found or not running", []
    lines = [l for l in out.splitlines() if l and not l.startswith("NAME")]
    models = [l.split()[0] for l in lines if l.split()]
    return "ok", models


def check_gemini_key() -> str:
    return "present" if os.environ.get("GEMINI_API_KEY") else "MISSING"


def check_gemini_call() -> str:
    code, out = run([
        sys.executable, str(SCRIPTS / "gemini_run.py"),
        "Reply with exactly: ok"
    ])
    if code == 0 and "ok" in out.lower():
        return "ok"
    return f"ERROR: {out[:120]}"


def check_scripts() -> dict[str, bool]:
    return {s: (SCRIPTS / s).exists() for s in GEMINI_SCRIPTS}


def build_report(test: bool) -> str:
    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    ollama_status, models = check_ollama()
    key_status = check_gemini_key()
    gemini_call = check_gemini_call() if test else "skipped (run with --test to call API)"
    scripts = check_scripts()

    missing_models = [m for m in OLLAMA_MODELS_EXPECTED if not any(m in installed for installed in models)]
    all_models_md = "\n".join(f"  - {m}" for m in models) if models else "  (none found)"
    missing_md = ("\n".join(f"  - {m} (!)" for m in missing_models)) if missing_models else "  (all expected models present)"

    scripts_md = "\n".join(
        f"  - {'ok' if ok else 'MISSING'} {name}" for name, ok in scripts.items()
    )

    return f"""# Tools Status

_Last check: {now}_

## Ollama (T1)

- Status: {ollama_status}
- Available models:
{all_models_md}
- Expected models check:
{missing_md}

## Gemini (T2)

- API key: {key_status}
- Live call test: {gemini_call}
- Scripts:
{scripts_md}

## Agents / MCP (T4+)

- Bash: always available
- MCP (Gmail, Notion, Figma): session-dependent — verify in VS Code
- Agent tools (Explore, general-purpose, Plan): always available
"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--test", action="store_true", help="Run live Gemini API call")
    args = parser.parse_args()

    report = build_report(test=args.test)
    OUTPUT.write_text(report, encoding="utf-8")
    print(report)
    print(f"[health_check] Written to {OUTPUT}")


if __name__ == "__main__":
    main()
