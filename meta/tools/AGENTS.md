# Roster de Agentes — AI Workspace

Catálogo de todos os agentes e ferramentas nomeadas que Claude pode acionar.
Cada delegação deve aparecer no verbose usando o nome canônico abaixo.

## Formato de verbose

```
[Claude → Agente | TN] o que foi pedido
[Agente → Claude] resultado ou resumo
```

Ao pular tier:
```
[SKIP TN — motivo]
```

Motivos válidos: (T0) tarefa requer semântica; (T1) Ollama offline ou qualidade insuficiente; (T2) quota Gemini esgotada ou resposta inline obrigatória.

---

## Agentes Tier 0 — Zero tokens, zero custo

### Pygit
**O que é:** Executor de scripts Python + operações Git + manipulação de arquivos.  
**Cobre:** `python -c`, `python script.py`, `git *`, `pathlib`, `shutil`, `json`, `jq`  
**Quando:** métricas de texto, transformação de JSON, operações de arquivo, commits, git log

### Bashman
**O que é:** Executor de comandos shell/CLI.  
**Cobre:** `grep`, `find`, `pandoc`, `ffmpeg`, `curl`, qualquer CLI sem semântica  
**Quando:** conversão de documentos, processamento de mídia, buscas por padrão, pipelines shell

---

## Agentes Tier 1 — Ollama local (requer `ollama serve`)

### Llama
**O que é:** Interface para modelos Ollama locais.  
**Modelos cobertos:**
- `llama3.1:8b` — texto/rascunho em PT-BR
- `qwen2.5-coder:7b` — código boilerplate
- `deepseek-coder:6.7b` — código, mais rápido
- `llama3.2:3b` — classificação/JSON leve
- `nomic-embed-text` — embeddings/RAG

**Quando:** rascunhos, boilerplate, classificação, embeddings sem custo de API

---

## Agentes Tier 2 — Gemini (custo mínimo; Claude lê só o output)

> Cadeia de fallback automática no script: Gemflite → Gemlux → Gemtrin → Gemflash  
> Script: `python meta/scripts/gemini_run.py --model <nome> "<PROMPT>"`

### Gemflite ← padrão T2
**Modelo:** `gemini-3.1-flash-lite-preview` · 15 RPM / **500 RPD**  
**Quando:** triagem em lote, sumarização, classificação recorrente — alta disponibilidade  
**Verbose:** `[Claude → Gemflite | T2]`

### Gemlux
**Modelo:** `gemini-2.5-flash-lite` · 10 RPM / 20 RPD  
**Quando:** fallback leve quando Gemflite esgota; semântica levemente acima do Tier 1  
**Verbose:** `[Claude → Gemlux | T2]`

### Gemtrin
**Modelo:** `gemini-3-flash-preview` · 5 RPM / 20 RPD  
**Quando:** raciocínio mais capaz que Gemflite; uso pontual (20 RPD — economizar)  
**Verbose:** `[Claude → Gemtrin | T2]`

### Gemflash
**Modelo:** `gemini-2.5-flash` · 5 RPM / 20 RPD · ⚠️ intermitente  
**Quando:** qualidade máxima T2; tarefas que exigem mais raciocínio sem chegar ao T3  
**Verbose:** `[Claude → Gemflash | T2]`

### Gemvoice
**Modelo:** `gemini-2.5-flash-preview-tts` · 3 RPM / 10 RPD  
**Quando:** geração de áudio TTS; não usar para texto comum  
**Verbose:** `[Claude → Gemvoice | T2]`

### Tigon
**Modelos:** `gemma-4-26b-a4b-it` / `gemma-4-31b-it` · 15 RPM / 1.5K RPD · TPM ilimitado  
**Quando:** tarefas curtas e repetitivas em lote; prompts <500 tokens  
**Verbose:** `[Claude → Tigon | T2]`

### Triton
**Modelos:** `gemma-3-{1b,4b,12b,27b}-it` · 30 RPM / 14.4K RPD · TPM 15K (baixo!)  
**Quando:** triagem de emails, logs, prompts muito curtos e repetitivos  
**Verbose:** `[Claude → Triton | T2]`

---

## Agentes Tier 3–5 — Claude (custo normal)

### Haiku
**Modelo:** `claude-haiku-4-5-20251001`  
**Quando:** fallback pago leve; Gemini offline; tarefas simples que precisam de Claude

### Sonnet
**Modelo:** `claude-sonnet-4-6` (instância atual do orquestrador)  
**Quando:** qualidade geral, análise contextual, implementação, explicações

### Opus
**Modelo:** `claude-opus-4-6`  
**Quando:** arquitetura, design de sistema, raciocínio de alta complexidade, decisões críticas

---

## Referência rápida

| Agente | Tier | RPD | Comando / entrada |
|--------|------|-----|-------------------|
| Pygit | T0 | ∞ | `python ...` / `git ...` |
| Bashman | T0 | ∞ | `bash ...` / CLI |
| Llama | T1 | ∞ | `ollama run <modelo> "<prompt>"` |
| **Gemflite** | T2 | 500 | `python meta/scripts/gemini_run.py --model gemflite "<prompt>"` |
| **Gemlux** | T2 | 20 | `python meta/scripts/gemini_run.py --model gemlux "<prompt>"` |
| **Gemtrin** | T2 | 20 | `python meta/scripts/gemini_run.py --model gemtrin "<prompt>"` |
| **Gemflash** | T2 | 20 | `python meta/scripts/gemini_run.py --model gemflash "<prompt>"` |
| **Gemvoice** | T2 | 10 | API direta (TTS) |
| **Tigon** | T2 | 1500 | `python meta/scripts/gemini_run.py --model gemma-4-26b-a4b-it "<prompt>"` |
| **Triton** | T2 | 14400 | `python meta/scripts/gemini_run.py --model gemma-3-12b-it "<prompt>"` |
| Haiku | T3 | — | Agent tool / API `claude-haiku-4-5-20251001` |
| Sonnet | T4 | — | Agent tool / API `claude-sonnet-4-6` |
| Opus | T5 | — | Agent tool / API `claude-opus-4-6` |
