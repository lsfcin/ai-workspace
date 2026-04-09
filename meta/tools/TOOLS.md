# Ferramentas Disponíveis

> Hardware: RTX 3050 6GB Laptop GPU · 16GB RAM
> Limite prático Ollama: modelos ≤7B rodam em GPU; 8-9B com RAM offload (mais lento)

## Prioridade de seleção (ordem de custo crescente)

1. Script Python / CLI → zero custo, sem LLM
2. Modelo local Ollama → zero custo, latência depende do tamanho
3. Gemini 2.0 Flash → ~$0.075/1M in · requer billing ativo (ver abaixo)
4. Claude Haiku 4.5 → ~$0.80/1M in · fallback quando Gemini indisponível
5. Claude Sonnet 4.6 → ~$3/1M in · qualidade sem complexidade extrema
6. Claude Opus 4.6 → ~$15/1M in · design, arquitetura, raciocínio complexo

## Agentes Cloud

| Agente | Modelo real | Status | RPM | RPD | Usar quando |
|--------|-------------|--------|-----|-----|-------------|
| Opus | claude-opus-4-6 | ✅ | — | — | Arquitetura, raciocínio complexo, code gen novo |
| Sonnet | claude-sonnet-4-6 | ✅ | — | — | Escrita, análise, qualidade sem gênio |
| Haiku | claude-haiku-4-5-20251001 | ✅ | — | — | Fallback pago leve quando Gemini offline |
| **Gemflite** | gemini-3.1-flash-lite-preview | ✅ | 15 | 500 | Triagem, lotes, contexto longo — **padrão T2** |
| **Gemlux** | gemini-2.5-flash-lite | ✅ | 10 | 20 | Fallback leve quando Gemflite esgota |
| **Gemtrin** | gemini-3-flash-preview | ✅ | 5 | 20 | Raciocínio mais capaz, uso pontual |
| **Gemflash** | gemini-2.5-flash | ✅ (instável) | 5 | 20 | Qualidade máxima T2; intermitente |
| **Gemvoice** | gemini-2.5-flash-preview-tts | ⚠️ | 3 | 10 | TTS — geração de áudio |
| **Tigon** | gemma-4-26b-a4b-it / gemma-4-31b-it | ✅ | 15 | 1500 | Tarefas curtas repetitivas, TPM ilimitado |
| **Triton** | gemma-3-{1b,4b,12b,27b}-it | ✅ | 30 | 14400 | Triagem e logs (TPM baixo: 15K) |

> **Gemini:** `GEMINI_API_KEY` presente no env. Free tier ativo — **sem billing necessário**.
> Cadeia de fallback automática: Gemflite → Gemlux → Gemtrin → Gemflash.
> Script: `python meta/scripts/gemini_run.py --model <nome> "<prompt>"`
> ~~gemini-2.0-flash~~ — não incluído no plano atual, não usar.

## Agentes Locais (Ollama — custo zero)

| Modelo | Tamanho | Status | Micro-test | Usar quando |
|--------|---------|--------|-----------|-------------|
| llama3.2:3b | 2.0GB | ✅ testado | JSON format ✅ | Formatação mecânica, latência <2s |
| deepseek-coder:6.7b | 3.8GB | ✅ testado | Python code ✅ | Boilerplate, snippets simples |
| qwen2.5-coder:7b | ~4.7GB | ✅ testado | Flatten list ✅ | Código qualidade — melhor que deepseek-coder |
| llama3.1:8b | 4.9GB | ✅ testado | Conceito PT ✅ | Raciocínio geral, textos em PT |
| deepseek-coder-v2 | 8.9GB | ✅ testado | Retry decorator ✅ | Código complexo (RAM offload, ~2min) |
| nomic-embed-text | 274MB | ✅ testado | Similaridade ✅ | Embeddings, busca semântica, RAG |
| faster-whisper | ~1GB | ❌ não instalado | — | STT local — transcrição de aulas, reuniões, áudios |

> `llama3:latest` removido (era redundante com llama3.1:8b, liberou 4.7GB).
> `llama3.1:latest` = mesmo arquivo que `llama3.1:8b` (hard link, não ocupa espaço extra).

## CLIs

| Ferramenta | Status | Propósito |
|------------|--------|-----------|
| pandoc | ✅ | Conversão md↔docx↔html↔pdf |
| ffmpeg | ✅ | Áudio/vídeo processing |
| jq | ✅ | Parsing/transformação de JSON |
| imagemagick | ❌ | Manipulação de imagem batch |
| rclone | ❌ | Sync de arquivos com cloud |

## MCPs ativos (nesta sessão)

| Serviço | Propósito |
|---------|-----------|
| Notion | CRUD páginas de disciplinas e notas |
| Gmail | Leitura e triagem de emails |
| Figma | Design, diagramas, code connect |

## Como chamar Gemini / Ollama em scripts

```python
# Gemini (requer billing ativo)
import urllib.request, json, os
def gemini(prompt, model="gemini-3.1-flash-lite-preview"):
    key = os.environ["GEMINI_API_KEY"]
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
    body = json.dumps({"contents":[{"parts":[{"text":prompt}]}]}).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type":"application/json"})
    return json.loads(urllib.request.urlopen(req).read())["candidates"][0]["content"]["parts"][0]["text"]

# Ollama (sempre disponível)
def ollama(prompt, model="llama3.2:3b"):
    url = "http://localhost:11434/api/generate"
    body = json.dumps({"model": model, "prompt": prompt, "stream": False}).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type":"application/json"})
    return json.loads(urllib.request.urlopen(req).read())["response"]

# Embeddings
def embed(text, model="nomic-embed-text"):
    url = "http://localhost:11434/api/embeddings"
    body = json.dumps({"model": model, "prompt": text}).encode()
    req = urllib.request.Request(url, data=body, headers={"Content-Type":"application/json"})
    return json.loads(urllib.request.urlopen(req).read())["embedding"]
```
