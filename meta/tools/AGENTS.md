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

## Agentes Tier 2 — Custo mínimo

### Gemini
**O que é:** Gemini Flash Lite via API (licença acadêmica).  
**Modelo padrão:** `gemini-3.1-flash-lite-preview`  
**Script:** `python meta/scripts/gemini_run.py "<PROMPT>"`  
**Quando:** sumarização de docs longos (>5 páginas), triagem em lote, semântica além do Tier 1, contextos >8k tokens

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

| Agente | Tier | Comando / entrada |
|--------|------|-------------------|
| Pygit | T0 | `python ...` / `git ...` |
| Bashman | T0 | `bash ...` / CLI |
| Llama | T1 | `ollama run <modelo> "<prompt>"` |
| Gemini | T2 | `python meta/scripts/gemini_run.py "<prompt>"` |
| Haiku | T3 | Agent tool / API `claude-haiku-4-5-20251001` |
| Sonnet | T4 | Agent tool / API `claude-sonnet-4-6` |
| Opus | T5 | Agent tool / API `claude-opus-4-6` |
