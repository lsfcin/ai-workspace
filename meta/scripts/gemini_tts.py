#!/usr/bin/env python3
"""
Tier 2 — Gemvoice: TTS via Gemini
Gera áudio a partir de texto e salva como .wav

Uso:
  python meta/scripts/gemini_tts.py "Texto a sintetizar" -o saida.wav
  python meta/scripts/gemini_tts.py "Texto" --model gemvoice-pro --voice Kore
  python meta/scripts/gemini_tts.py "Texto" --model gemvoice-pro --multi  # multi-speaker

Vozes disponíveis (Gemvoice): Aoede, Charon, Fenrir, Kore, Puck
Vozes adicionais (Gemvoice-Pro): Orbit, Zephyr, Autonoe, Umbriel, Algieba, Despina, Erinome...

Nomes canônicos:
  gemvoice     → gemini-2.5-flash-preview-tts  (3 RPM / 10 RPD)
  gemvoice-pro → gemini-2.5-pro-preview-tts    (mais lento, mais natural)
"""
import argparse
import base64
import json
import os
import struct
import sys
import urllib.request
import urllib.error

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

MODEL_ALIASES = {
    "gemvoice":     "gemini-2.5-flash-preview-tts",
    "gemvoice-pro": "gemini-2.5-pro-preview-tts",
}

SAMPLE_RATE = 24000  # PCM rate devolvido pela API
CHANNELS    = 1
BIT_DEPTH   = 16


def pcm_to_wav(pcm_bytes: bytes, rate: int = SAMPLE_RATE) -> bytes:
    """Envolve PCM raw em cabeçalho WAV válido."""
    num_samples  = len(pcm_bytes) // 2
    data_size    = len(pcm_bytes)
    header = struct.pack(
        "<4sI4s4sIHHIIHH4sI",
        b"RIFF", 36 + data_size, b"WAVE",
        b"fmt ", 16, 1, CHANNELS,
        rate, rate * CHANNELS * BIT_DEPTH // 8,
        CHANNELS * BIT_DEPTH // 8, BIT_DEPTH,
        b"data", data_size,
    )
    return header + pcm_bytes


def call_tts(text: str, model_name: str = "gemvoice", voice: str = "Aoede") -> bytes:
    key = os.environ.get("GEMINI_API_KEY")
    if not key:
        raise EnvironmentError("GEMINI_API_KEY não encontrada.")

    model_id = MODEL_ALIASES.get(model_name.lower(), model_name)
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:generateContent?key={key}"

    body = json.dumps({
        "contents": [{"parts": [{"text": text}]}],
        "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
                "voiceConfig": {"prebuiltVoiceConfig": {"voiceName": voice}}
            },
        },
    }).encode()

    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    resp = json.loads(urllib.request.urlopen(req, timeout=60).read())

    audio_b64 = resp["candidates"][0]["content"]["parts"][0]["inlineData"]["data"]
    return base64.b64decode(audio_b64)


def main():
    parser = argparse.ArgumentParser(description="Gemvoice TTS runner (Tier 2)")
    parser.add_argument("text", help="Texto a sintetizar")
    parser.add_argument("-o", "--output", default="meta/scripts/outputs/tts_output.wav",
                        help="Arquivo de saída .wav")
    parser.add_argument("--model", default="gemvoice", help="gemvoice | gemvoice-pro")
    parser.add_argument("--voice", default="Aoede",
                        help="Nome da voz (Aoede, Charon, Fenrir, Kore, Puck…)")
    args = parser.parse_args()

    print(f"[gemini_tts] sintetizando com {args.model} / voz={args.voice}...", file=sys.stderr)
    pcm = call_tts(args.text, args.model, args.voice)
    wav = pcm_to_wav(pcm)

    out_path = args.output
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(wav)

    duration_s = len(pcm) / 2 / SAMPLE_RATE
    print(f"[gemini_tts] salvo: {out_path} ({len(wav)} bytes, ~{duration_s:.1f}s)", file=sys.stderr)
    print(out_path)


if __name__ == "__main__":
    main()
