#!/usr/bin/env python3
"""
Tier 2 — Gemini Flash Lite runner
Uso: python meta/scripts/gemini_run.py "<PROMPT>"
     python meta/scripts/gemini_run.py --file <ARQUIVO> --prompt "<INSTRUCAO>"
"""
import argparse
import json
import os
import sys
import urllib.request

# Fix UTF-8 output no Windows (evita '?' em vez de acentos)
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DEFAULT_MODEL = "gemini-3.1-flash-lite-preview"
FALLBACK_MODEL = "gemini-2.5-flash-lite"


def call_gemini(prompt: str, model: str = DEFAULT_MODEL) -> str:
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise EnvironmentError("GEMINI_API_KEY não encontrada no ambiente.")

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
    body = json.dumps({"contents": [{"parts": [{"text": prompt}]}]}).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})

    try:
        resp = urllib.request.urlopen(req, timeout=30)
        data = json.loads(resp.read())
        return data["candidates"][0]["content"]["parts"][0]["text"]
    except urllib.error.HTTPError as e:
        if model == DEFAULT_MODEL:
            print(f"[gemini_run] {model} falhou ({e.code}), tentando fallback {FALLBACK_MODEL}...", file=sys.stderr)
            return call_gemini(prompt, FALLBACK_MODEL)
        raise


def main():
    parser = argparse.ArgumentParser(description="Gemini Flash Lite runner (Tier 2)")
    parser.add_argument("prompt", nargs="?", help="Prompt direto")
    parser.add_argument("--file", help="Arquivo cujo conteúdo será incluído como contexto")
    parser.add_argument("--prompt", dest="prompt_flag", help="Instrução quando --file é usado")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="Modelo Gemini")
    args = parser.parse_args()

    if args.file:
        with open(args.file, encoding="utf-8") as f:
            content = f.read()
        instruction = args.prompt_flag or "Resuma o conteúdo abaixo:"
        full_prompt = f"{instruction}\n\n---\n{content}"
    elif args.prompt:
        full_prompt = args.prompt
    else:
        print("Uso: gemini_run.py '<PROMPT>'  ou  gemini_run.py --file <ARQ> --prompt '<INSTR>'", file=sys.stderr)
        sys.exit(1)

    result = call_gemini(full_prompt, args.model)
    print(result)


if __name__ == "__main__":
    main()
