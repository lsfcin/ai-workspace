#!/usr/bin/env python3
"""
Tier 2 — Gemini runner
Uso: python meta/scripts/gemini_run.py "<PROMPT>"
     python meta/scripts/gemini_run.py --file <ARQUIVO> --prompt "<INSTRUCAO>"
     python meta/scripts/gemini_run.py --model gemflash "<PROMPT>"
     python meta/scripts/gemini_run.py --model gemart --image-out icon.png "<PROMPT>"

Nomes canônicos dos modelos (usar no --model ou na API):
  gemflite  → gemini-3.1-flash-lite-preview  (15 RPM / 500 RPD) ← padrão texto
  gemlux    → gemini-2.5-flash-lite           (10 RPM / 20 RPD)
  gemflash  → gemini-2.5-flash                (5 RPM / 20 RPD)
  gemtrin   → gemini-3-flash-preview          (5 RPM / 20 RPD)
  --- image generation ---
  gemvision → gemini-2.5-flash-image          (daily limit)
  gemart    → gemini-3.1-flash-image-preview  (daily limit)
  gempic    → gemini-3-pro-image-preview      (daily limit, best quality)
"""
import argparse
import base64
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
    "gemflite":  "gemini-3.1-flash-lite-preview",
    "gemlux":    "gemini-2.5-flash-lite",
    "gemflash":  "gemini-2.5-flash",
    "gemtrin":   "gemini-3-flash-preview",
    # image-capable models
    "gemvision": "gemini-2.5-flash-image",
    "gemart":    "gemini-3.1-flash-image-preview",
    "gempic":    "gemini-3-pro-image-preview",
}

IMAGE_MODELS = {"gemvision", "gemart", "gempic"}

# Fallback chain for image generation
IMAGE_FALLBACK_CHAIN = ["gempic", "gemart", "gemvision"]

# Cadeia de fallback texto (ordem de disponibilidade decrescente)
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


def call_gemini_image(prompt: str, out_path: str, model_name: str = "gempic",
                      size: int = 1024, _chain: list = None) -> str:
    """Generate an image via Gemini and save to out_path. Returns the saved path."""
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise EnvironmentError("GEMINI_API_KEY não encontrada no ambiente.")

    model_id = resolve_model(model_name)
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:generateContent?key={key}"
    body = json.dumps({
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["IMAGE", "TEXT"]},
    }).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})

    try:
        resp = urllib.request.urlopen(req, timeout=60)
        data = json.loads(resp.read())

        image_part = None
        for part in data["candidates"][0]["content"]["parts"]:
            if "inlineData" in part:
                image_part = part["inlineData"]
                break

        if not image_part:
            raise RuntimeError("Model returned no image data.")

        img_bytes = base64.b64decode(image_part["data"])

        # Resize to requested square size using Pillow
        try:
            from PIL import Image
            import io
            img = Image.open(io.BytesIO(img_bytes)).convert("RGBA")
            if img.size != (size, size):
                img = img.resize((size, size), Image.LANCZOS)
            img.save(out_path, format="PNG")
            final_size = img.size
        except ImportError:
            with open(out_path, "wb") as f:
                f.write(img_bytes)
            final_size = ("?", "?")

        mime = image_part.get("mimeType", "?")
        print(f"[gemini_run] image saved → {out_path}  size={final_size}  mime={mime}", file=sys.stderr)
        return out_path

    except urllib.error.HTTPError as e:
        body_msg = e.read().decode(errors="replace")
        chain = _chain or IMAGE_FALLBACK_CHAIN[:]
        if model_name in chain:
            chain = chain[chain.index(model_name) + 1:]
        if chain:
            next_model = chain[0]
            print(f"[gemini_run] {model_name} ({model_id}) falhou ({e.code}), fallback → {next_model}", file=sys.stderr)
            return call_gemini_image(prompt, out_path, next_model, size, chain)
        raise RuntimeError(f"Image generation failed. Last error: {e.code} — {body_msg}") from e


def main():
    parser = argparse.ArgumentParser(description="Gemini runner (Tier 2)")
    parser.add_argument("prompt", nargs="?", help="Prompt direto")
    parser.add_argument("--file", help="Arquivo cujo conteúdo será incluído como contexto")
    parser.add_argument("--prompt", dest="prompt_flag", help="Instrução quando --file é usado")
    parser.add_argument(
        "--model", default=DEFAULT_MODEL,
        help="Modelo: gemflite (padrão texto), gempic/gemart/gemvision (imagem). IDs diretos também aceitos."
    )
    parser.add_argument("--image-out", dest="image_out", metavar="PATH",
                        help="Salvar imagem gerada neste caminho .png (ativa modo imagem)")
    parser.add_argument("--image-size", dest="image_size", type=int, default=1024,
                        help="Tamanho do lado do ícone quadrado em px (padrão: 1024)")
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

    if args.image_out:
        model = args.model if args.model != DEFAULT_MODEL else "gempic"
        call_gemini_image(full_prompt, args.image_out, model, args.image_size)
        print(args.image_out)
    else:
        result = call_gemini(full_prompt, args.model)
        print(result)


if __name__ == "__main__":
    main()
