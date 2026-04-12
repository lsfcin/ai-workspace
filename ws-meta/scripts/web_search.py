#!/usr/bin/env python3
"""
Tier 2 — Cascading web search for agents.

Tries providers in order, skipping those with no key or exhausted quota:
  Exa → Tavily → DuckDuckGo

Usage:
  python ws-meta/scripts/web_search.py "<query>"
  python ws-meta/scripts/web_search.py "<query>" --max 5
  python ws-meta/scripts/web_search.py "<query>" --provider ddg

Output: JSON array of {title, url, snippet} — provider used printed to stderr.

Keys (add to .env at workspace root):
  EXA_API_KEY   → https://dashboard.exa.ai/api-keys        (1000 req/mo free)
  TVLY_API_KEY  → https://app.tavily.com/home (API Keys)   (1000 req/mo free)
  DuckDuckGo requires no key.
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path

# Fix UTF-8 output on Windows
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Load .env from workspace root if present
try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).parent.parent.parent / ".env")
except ImportError:
    pass

MAX_DEFAULT = 5

# ---------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------

def search_exa(query, max_results):
    key = os.environ.get("EXA_API_KEY")
    if not key:
        raise EnvironmentError("EXA_API_KEY not set")
    from exa_py import Exa
    client = Exa(api_key=key)
    resp = client.search_and_contents(query, num_results=max_results, text={"max_characters": 300})
    return [
        {"title": r.title or "", "url": r.url, "snippet": (r.text or "")[:300]}
        for r in resp.results
    ]

def search_tavily(query, max_results):
    key = os.environ.get("TVLY_API_KEY")
    if not key:
        raise EnvironmentError("TVLY_API_KEY not set")
    from tavily import TavilyClient
    client = TavilyClient(api_key=key)
    resp = client.search(query, max_results=max_results)
    return [
        {"title": r.get("title", ""), "url": r.get("url", ""), "snippet": r.get("content", "")[:300]}
        for r in resp.get("results", [])
    ]

def search_ddg(query, max_results):
    try:
        from ddgs import DDGS
    except ImportError:
        from duckduckgo_search import DDGS
    with DDGS() as ddgs:
        results = list(ddgs.text(query, max_results=max_results))
    return [
        {"title": r.get("title", ""), "url": r.get("href", ""), "snippet": r.get("body", "")[:300]}
        for r in results
    ]

# ---------------------------------------------------------------------------
# Cascade
# ---------------------------------------------------------------------------

CASCADE = [
    ("exa",    search_exa),
    ("tavily", search_tavily),
    ("ddg",    search_ddg),
]

def run_cascade(query, max_results, force_provider=None):
    providers = [(n, f) for n, f in CASCADE if not force_provider or n == force_provider]
    errors = []
    for name, fn in providers:
        try:
            results = fn(query, max_results)
            print(f"[web_search] provider={name} results={len(results)}", file=sys.stderr)
            return results
        except EnvironmentError as e:
            errors.append(f"{name}: {e}")
        except Exception as e:
            errors.append(f"{name}: {type(e).__name__}: {e}")
            print(f"[web_search] {name} failed: {e}", file=sys.stderr)

    print(f"[web_search] all providers failed: {errors}", file=sys.stderr)
    sys.exit(1)

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Cascading web search for agents")
    parser.add_argument("query", help="Search query")
    parser.add_argument("--max", type=int, default=MAX_DEFAULT, help="Max results (default 5)")
    parser.add_argument("--provider", choices=["exa", "tavily", "ddg"],
                        help="Force a specific provider")
    args = parser.parse_args()

    results = run_cascade(args.query, args.max, args.provider)
    print(json.dumps(results, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
