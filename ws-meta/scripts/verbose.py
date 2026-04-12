"""
verbose.py — Formatador de verbose para orquestração de agentes.

Uso:
    from meta.scripts.verbose import send, recv, skip

    send("Gemini", 2, "Sumarizar doc.md")
    recv("Gemini", "Resumo: ...")
    skip(1, "Ollama offline")
"""

import sys


def send(to: str, tier: int, msg: str) -> None:
    """Claude delegando para um agente."""
    print(f"[Turin → {to} | T{tier}] {msg}", flush=True)


def recv(from_: str, msg: str) -> None:
    """Agente retornando resultado para Claude."""
    print(f"[{from_} → Turin] {msg}", flush=True)


def skip(tier: int, reason: str) -> None:
    """Pulando um tier com motivo."""
    print(f"[SKIP T{tier} — {reason}]", flush=True)


# --- CLI direto ---
# python meta/scripts/verbose.py send Gemini 2 "Sumarizar doc.md"
# python meta/scripts/verbose.py recv Gemini "Resumo: ..."
# python meta/scripts/verbose.py skip 1 "Ollama offline"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: verbose.py <send|recv|skip> [args...]")
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "send" and len(sys.argv) == 5:
        send(sys.argv[2], int(sys.argv[3]), sys.argv[4])
    elif cmd == "recv" and len(sys.argv) == 4:
        recv(sys.argv[2], sys.argv[3])
    elif cmd == "skip" and len(sys.argv) == 4:
        skip(int(sys.argv[2]), sys.argv[3])
    else:
        print(f"Comando inválido ou argumentos incorretos: {sys.argv[1:]}")
        sys.exit(1)
