#!/usr/bin/env python3
"""
Tier 2 — Imago: geração de imagem via Imagen 4
Usa endpoint `predict` (diferente do generateContent padrão).
25 imagens/dia no free tier (compartilhado entre variantes).

Uso:
  python meta/scripts/imagen_run.py "Um gato laranja realista" -o saida.png
  python meta/scripts/imagen_run.py "Arte abstrata" --model imago-ultra
  python meta/scripts/imagen_run.py "Rascunho rápido" --model imago-flash

Nomes canônicos:
  imago       → imagen-4.0-generate-001       (padrão — qualidade/velocidade)
  imago-ultra → imagen-4.0-ultra-generate-001  (máxima qualidade, mais lento)
  imago-flash → imagen-4.0-fast-generate-001   (mais rápido, menor qualidade)
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
    "imago":       "imagen-4.0-generate-001",
    "imago-ultra": "imagen-4.0-ultra-generate-001",
    "imago-flash": "imagen-4.0-fast-generate-001",
}

FALLBACK_CHAIN = ["imago-flash", "imago", "imago-ultra"]


def call_imagen(
    prompt: str,
    model_name: str = "imago",
    sample_count: int = 1,
    aspect_ratio: str = "1:1",
    _chain: list = None,
) -> list[bytes]:
    """Retorna lista de imagens (bytes PNG)."""
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise EnvironmentError("GEMINI_API_KEY não encontrada.")

    model_id = MODEL_ALIASES.get(model_name.lower(), model_name)
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:predict?key={key}"

    body = json.dumps({
        "instances": [{"prompt": prompt}],
        "parameters": {
            "sampleCount": sample_count,
            "aspectRatio": aspect_ratio,
        },
    }).encode()

    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})

    try:
        resp = json.loads(urllib.request.urlopen(req, timeout=90).read())
        predictions = resp.get("predictions", [])
        if not predictions:
            raise ValueError(f"Nenhuma predição retornada: {resp}")
        return [base64.b64decode(p["bytesBase64Encoded"]) for p in predictions]

    except urllib.error.HTTPError as e:
        chain = _chain or FALLBACK_CHAIN[:]
        if model_name in chain:
            chain = chain[chain.index(model_name) + 1:]
        if chain:
            next_model = chain[0]
            print(f"[imagen_run] {model_name} falhou ({e.code}), fallback → {next_model}", file=sys.stderr)
            return call_imagen(prompt, next_model, sample_count, aspect_ratio, chain)
        raise


def main():
    parser = argparse.ArgumentParser(description="Imagen 4 runner (Tier 2)")
    parser.add_argument("prompt", help="Descrição da imagem a gerar")
    parser.add_argument("-o", "--output", default="meta/scripts/outputs/imagen_output.png",
                        help="Arquivo de saída .png (múltiplas: _1.png, _2.png...)")
    parser.add_argument("--model", default="imago",
                        help="imago | imago-ultra | imago-flash")
    parser.add_argument("--count", type=int, default=1, help="Quantidade de imagens (padrão: 1)")
    parser.add_argument("--ratio", default="1:1",
                        help="Aspect ratio: 1:1 | 16:9 | 9:16 | 4:3 | 3:4")
    args = parser.parse_args()

    print(f"[imagen_run] gerando {args.count}x com {args.model} ({args.ratio})...", file=sys.stderr)
    images = call_imagen(args.prompt, args.model, args.count, args.ratio)

    base, ext = os.path.splitext(args.output)
    if not ext:
        ext = ".png"

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    for i, img_bytes in enumerate(images):
        suffix = f"_{i+1}" if len(images) > 1 else ""
        path = f"{base}{suffix}{ext}"
        with open(path, "wb") as f:
            f.write(img_bytes)
        print(f"[imagen_run] salvo: {path} ({len(img_bytes)} bytes)", file=sys.stderr)
        print(path)


if __name__ == "__main__":
    main()
