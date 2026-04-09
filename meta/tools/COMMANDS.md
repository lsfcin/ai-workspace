# Catálogo de Comandos — Delegação por Tier

> **Documento vivo.** Ao usar um comando não listado aqui que seja delegável (zero-token ou Gemini), adicione-o na seção correspondente. O objetivo é que este arquivo cresça como biblioteca de automações do workspace.

**Consultar ANTES de qualquer resposta que envolva processamento de dados, geração de texto ou análise.**

## Tabela de direcionamento rápido

| Tipo de tarefa | Tier | Seção |
|----------------|------|-------|
| Métricas de arquivo (palavras, linhas, chars) | 0 | Tier 0 → Contar |
| Buscar padrão / string em arquivos | 0 | Tier 0 → Buscar |
| Extrair / filtrar JSON | 0 | Tier 0 → JSON |
| Converter formato de documento | 0 | Tier 0 → Converter |
| Processar áudio / vídeo | 0 | Tier 0 → Áudio/vídeo |
| Listar / mover / renomear arquivos | 0 | Tier 0 → Arquivos |
| Rascunho / texto em PT-BR | 1 | Tier 1 → Texto |
| Gerar código (boilerplate / utilitários) | 1 | Tier 1 → Código |
| Classificar / extrair → JSON estruturado | 1 | Tier 1 → JSON |
| Similaridade semântica / RAG | 1 | Tier 1 → Embeddings |
| Sumarizar documento longo (>5 páginas) | 2 | Tier 2 → Sumarização |
| Triagem / classificação em lote | 2 | Tier 2 → Lote |
| Análise semântica além da capacidade Tier 1 | 2 | Tier 2 → Inline |

A cada execução, imprimir no chat:
```
[Claude → Agente | TN] descrição da ação
[Agente → Claude] resumo do resultado
```
Se pular um tier, imprimir:
```
[SKIP TN — motivo]
```
Motivos válidos de skip: (0) tarefa requer semântica; (1) Ollama offline ou qualidade insuficiente; (2) quota Gemini esgotada ou resposta inline obrigatória.

---

## Tier 0 — Scripts Python / CLI (zero tokens, zero custo)

### Contar palavras / linhas / chars em arquivo
**Quando:** métricas de texto sem semântica
```bash
python -c "import pathlib; t=pathlib.Path('<ARQUIVO>').read_text(encoding='utf-8'); print(f'palavras={len(t.split())} linhas={len(t.splitlines())} chars={len(t)}')"
```

### Buscar padrão em arquivos
**Quando:** encontrar string/regex no workspace sem semântica
```bash
grep -r "<PATTERN>" <DIR> --include="<*.ext>" -l
```

### Extrair / transformar JSON
**Quando:** filtrar campos, transformar estrutura de JSON
```bash
jq '<FILTRO>' <ARQUIVO.json>
# exemplos: '.[] | .name'  |  '.data | keys'  |  'map(select(.status=="<VAL>"))'
```

### Converter documentos (md ↔ docx ↔ html ↔ pdf)
**Quando:** conversão de formato, exportar material
```bash
pandoc "<INPUT>" -o "<OUTPUT>" [--reference-doc=<TEMPLATE.docx>]
```

### Processar áudio / vídeo
**Quando:** cortar, converter formato, extrair áudio
```bash
ffmpeg -i "<INPUT>" [<FLAGS>] "<OUTPUT>"
# extrair áudio:  -vn -acodec mp3
# cortar trecho:  -ss 00:MM:SS -to 00:MM:SS
```

### Listar / organizar arquivos (sem semântica)
**Quando:** inventário, rename em lote, mover arquivos
```python
python -c "
import pathlib, shutil
for p in pathlib.Path('<DIR>').glob('<PATTERN>'):
    print(p)  # substituir por: shutil.move(p, '<DEST>') para mover
"
```

---

## Tier 1 — Ollama Local (zero tokens, requer `ollama serve`)

> Verificar disponibilidade: `curl -s http://localhost:11434/api/tags | jq '.models[].name'`
> **Nota:** `ollama run` emite escape codes ANSI no bash. Para capturar output limpo, pipe para `sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'` (ver exemplos abaixo).

### Geração de texto / rascunho em PT-BR
**Quando:** rascunhos, reformulações, resumos simples sem alta qualidade
**Modelo:** `llama3.1:8b`
```bash
ollama run llama3.1:8b "<PROMPT>" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
```

### Geração de código (boilerplate / utilitários)
**Quando:** scaffolding, funções simples, scripts Python/TS
**Modelo:** `qwen2.5-coder:7b` (qualidade) · `deepseek-coder:6.7b` (mais rápido)
```bash
ollama run qwen2.5-coder:7b "<PROMPT_DE_CODIGO>" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
```

### Classificação / formatação estruturada → JSON
**Quando:** extrair campos, converter texto → JSON, categorizar em labels fixos
**Modelo:** `llama3.2:3b` (mais leve, <2s)
```bash
ollama run llama3.2:3b "Responda SOMENTE com JSON válido. <PROMPT>" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
```

### Via Python (para capturar output em script)
```python
python -c "
import urllib.request, json
body = json.dumps({'model':'<MODELO>','prompt':'<PROMPT>','stream':False}).encode()
req = urllib.request.Request('http://localhost:11434/api/generate', data=body, headers={'Content-Type':'application/json'})
print(json.loads(urllib.request.urlopen(req).read())['response'])
"
```

### Embeddings / similaridade semântica
**Quando:** busca por similaridade, RAG local
**Modelo:** `nomic-embed-text`
```python
python -c "
import urllib.request, json
body = json.dumps({'model':'nomic-embed-text','prompt':'<TEXTO>'}).encode()
req = urllib.request.Request('http://localhost:11434/api/embeddings', data=body, headers={'Content-Type':'application/json'})
emb = json.loads(urllib.request.urlopen(req).read())['embedding']
print(f'dims={len(emb)} amostra={emb[:4]}')
"
```

---

## Tier 2 — Gemini Flash Lite (custo mínimo; Claude lê apenas o resultado)

> Quota free tier: ~500 req/dia · ~15 RPM  
> Modelo padrão: `gemini-3.1-flash-lite-preview` · fallback: `gemini-2.5-flash-lite`  
> Custo para Claude: **somente tokens de leitura do output**.

### Script utilitário (prompt inline)
```bash
python meta/scripts/gemini_run.py "<PROMPT>"
```

### Script utilitário (arquivo como contexto)
```bash
python meta/scripts/gemini_run.py --file "<ARQUIVO>" --prompt "<INSTRUCAO>"
```

### Inline (sem depender do script utilitário)
```python
python -c "
import urllib.request, json, os
key = os.environ['GEMINI_API_KEY']
prompt = '<PROMPT>'
model = 'gemini-3.1-flash-lite-preview'
url = f'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}'
body = json.dumps({'contents':[{'parts':[{'text':prompt}]}]}).encode()
req = urllib.request.Request(url, data=body, headers={'Content-Type':'application/json'})
print(json.loads(urllib.request.urlopen(req).read())['candidates'][0]['content']['parts'][0]['text'])
"
```

**Casos de uso típicos:**
- Sumarizar documento longo (>5 páginas)
- Classificar/triar lista de itens em lote
- Análise semântica de texto que o Tier 1 não tem qualidade suficiente
- Qualquer contexto >8k tokens (Ollama degrada)

---

## Tier 3+ — Claude (somente após tiers anteriores serem descartados)

| Tier | Modelo | Quando |
|------|--------|--------|
| 3 | Claude Haiku 4.5 | Fallback pago leve; Gemini offline |
| 4 | Claude Sonnet 4.6 | Qualidade geral; análise contextual complexa |
| 5 | Claude Opus 4.6 | Arquitetura, design, raciocínio de alta complexidade |

> Regra: chegou no Tier 3+ → justificar por que tiers 0-2 foram inadequados.
