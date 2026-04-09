#!/usr/bin/env python3
"""
Tier 2 — Gemvision / Gempic / Gemart: geração de imagem via Gemini
Gera imagem a partir de prompt de texto e salva como .png

Uso:
  python meta/scripts/gemini_image.py "Um gato laranja" -o saida.png
  python meta/scripts/gemini_image.py "Diagrama UML" --model gempic
  python meta/scripts/gemini_image.py "Arte abstrata" --model gemart

Nomes canônicos:
  gemvision → gemini-2.5-flash-image         (padrão — rápido)
  gempic    → gemini-3-pro-image-preview     (qualidade pro)
  gemart    → gemini-3.1-flash-image-preview (mais recente)
"""
import argparse
import base64
import json
import os
import sys
import urllib.request
import urllib.error

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

MODEL_ALIASES = {
    "gemvision": "gemini-2.5-flash-image",
    "gempic":    "gemini-3-pro-image-preview",
    "gemart":    "gemini-3.1-flash-image-preview",
}

FALLBACK_CHAIN = ["gemvision", "gempic", "gemart"]


def call_image_gen(prompt: str, model_name: str = "gemvision", _chain: list = None) -> tuple[bytes, str]:
    """Retorna (image_bytes, mime_type)."""
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise EnvironmentError("GEMINI_API_KEY não encontrada.")

    model_id = MODEL_ALIASES.get(model_name.lower(), model_name)
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:generateContent?key={key}"

    body = json.dumps({
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["IMAGE", "TEXT"]},
    }).encode()

    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})

    try:
        resp = json.loads(urllib.request.urlopen(req, timeout=60).read())
        parts = resp["candidates"][0]["content"]["parts"]

        for part in parts:
            if "inlineData" in part:
                mime = part["inlineData"]["mimeType"]
                data = base64.b64decode(part["inlineData"]["data"])
                return data, mime

        raise ValueError(f"Nenhuma imagem na resposta: {[list(p.keys()) for p in parts]}")

    except urllib.error.HTTPError as e:
        chain = _chain or FALLBACK_CHAIN[:]
        if model_name in chain:
            chain = chain[chain.index(model_name) + 1:]
        if chain:
            next_model = chain[0]
            print(f"[gemini_image] {model_name} falhou ({e.code}), fallback → {next_model}", file=sys.stderr)
            return call_image_gen(prompt, next_model, chain)
        raise


def main():
    parser = argparse.ArgumentParser(description="Gemini image generation (Tier 2)")
    parser.add_argument("prompt", help="Descrição da imagem a gerar")
    parser.add_argument("-o", "--output", default="meta/scripts/outputs/image_output.png",
                        help="Arquivo de saída .png")
    parser.add_argument("--model", default="gemvision",
                        help="gemvision | gempic | gemart")
    args = parser.parse_args()

    print(f"[gemini_image] gerando com {args.model}...", file=sys.stderr)
    img_bytes, mime = call_image_gen(args.prompt, args.model)

    ext = mime.split("/")[-1].split(";")[0]
    out_path = args.output
    if not out_path.endswith(f".{ext}"):
        out_path = os.path.splitext(out_path)[0] + f".{ext}"

    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(img_bytes)

    print(f"[gemini_image] salvo: {out_path} ({len(img_bytes)} bytes, {mime})", file=sys.stderr)
    print(out_path)


if __name__ == "__main__":
    main()
