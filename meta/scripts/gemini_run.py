#!/usr/bin/env python3
"""
Tier 2 — Gemini runner
Uso: python meta/scripts/gemini_run.py "<PROMPT>"
     python meta/scripts/gemini_run.py --file <ARQUIVO> --prompt "<INSTRUCAO>"
     python meta/scripts/gemini_run.py --model gemflash "<PROMPT>"

Nomes canônicos dos modelos (usar no --model ou na API):
  gemflite  → gemini-3.1-flash-lite-preview  (15 RPM / 500 RPD) ← padrão
  gemlux    → gemini-2.5-flash-lite           (10 RPM / 20 RPD)
  gemflash  → gemini-2.5-flash                (5 RPM / 20 RPD)
  gemtrin   → gemini-3-flash-preview          (5 RPM / 20 RPD)
"""
import argparse
import json
import os
import sys
import urllib.request
import urllib.error

# Fix UTF-8 output no Windows
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Mapa nome canônico → model ID da API
MODEL_ALIASES = {
    "gemflite": "gemini-3.1-flash-lite-preview",
    "gemlux":   "gemini-2.5-flash-lite",
    "gemflash": "gemini-2.5-flash",
    "gemtrin":  "gemini-3-flash-preview",
}

# Cadeia de fallback (ordem de disponibilidade decrescente)
FALLBACK_CHAIN = ["gemflite", "gemlux", "gemtrin", "gemflash"]

DEFAULT_MODEL = "gemflite"


def resolve_model(name: str) -> str:
    """Aceita nome canônico ou model ID direto."""
    return MODEL_ALIASES.get(name.lower(), name)


def call_gemini(prompt: str, model_name: str = DEFAULT_MODEL, _chain: list = None) -> str:
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise EnvironmentError("GEMINI_API_KEY não encontrada no ambiente.")

    model_id = resolve_model(model_name)
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:generateContent?key={key}"
    body = json.dumps({"contents": [{"parts": [{"text": prompt}]}]}).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})

    try:
        resp = urllib.request.urlopen(req, timeout=30)
        data = json.loads(resp.read())
        return data["candidates"][0]["content"]["parts"][0]["text"]

    except urllib.error.HTTPError as e:
        # Fallback automático pela cadeia
        chain = _chain or FALLBACK_CHAIN[:]
        if model_name in chain:
            chain = chain[chain.index(model_name) + 1:]
        if chain:
            next_model = chain[0]
            print(f"[gemini_run] {model_name} ({model_id}) falhou ({e.code}), fallback → {next_model}", file=sys.stderr)
            return call_gemini(prompt, next_model, chain)
        raise RuntimeError(f"Todos os modelos Gemini falharam. Último erro: {e.code} {e.reason}") from e


def main():
    parser = argparse.ArgumentParser(description="Gemini runner (Tier 2)")
    parser.add_argument("prompt", nargs="?", help="Prompt direto")
    parser.add_argument("--file", help="Arquivo cujo conteúdo será incluído como contexto")
    parser.add_argument("--prompt", dest="prompt_flag", help="Instrução quando --file é usado")
    parser.add_argument(
        "--model", default=DEFAULT_MODEL,
        help=f"Modelo: gemflite (padrão), gemlux, gemflash, gemtrin. IDs diretos também aceitos."
    )
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
