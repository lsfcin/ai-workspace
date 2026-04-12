# Roster de Agentes

## MCP Tools (T0)

| Nome | Acesso | Capacidades |
|------|--------|-------------|
| Figma | `mcp__claude_ai_Figma__*` | Criar arquivos, desenhar via JS Plugin API (`use_figma`), screenshots. Usar `figma.createNodeFromSvg(svg)` para ícones e vetores. |
| Gmail | `mcp__claude_ai_Gmail__*` | Ler/buscar emails, criar rascunhos |
| Notion | `mcp__claude_ai_Notion__*` | Ler/criar/atualizar páginas e databases |

## Tabela de agentes

| Nome | Modelo / executor | Tier | RPD | Verbose |
|------|-------------------|------|-----|---------|
| Pygit | python / git | T0 | ∞ | `[Turin → Pygit \| T0]` |
| Bashman | bash / CLI | T0 | ∞ | `[Turin → Bashman \| T0]` |
| Llama | ollama local | T1 | ∞ | `[Turin → Llama \| T1]` |
| Gemflite | gemini-3.1-flash-lite-preview | T2 | 500 | `[Turin → Gemflite \| T2]` |
| Gemlux | gemini-2.5-flash-lite | T2 | 20 | `[Turin → Gemlux \| T2]` |
| Gemtrin | gemini-3-flash-preview | T2 | 20 | `[Turin → Gemtrin \| T2]` |
| Gemflash | gemini-2.5-flash | T2 | 20 | `[Turin → Gemflash \| T2]` |
| Gemvoice | gemini-2.5-flash-preview-tts | T2 | 10 | `[Turin → Gemvoice \| T2]` |
| Gemvoice-Pro | gemini-2.5-pro-preview-tts | T2 | — | `[Turin → Gemvoice-Pro \| T2]` |
| Gemvision | gemini-2.5-flash-image | T2 | ❌ paid | `[Turin → Gemvision \| T2]` |
| Gempic | gemini-3-pro-image-preview | T2 | ❌ paid | `[Turin → Gempic \| T2]` |
| Gemart | gemini-3.1-flash-image-preview | T2 | ❌ paid | `[Turin → Gemart \| T2]` |
| Lyria | lyria-3-{clip,pro}-preview | T2 | diária | `[Turin → Lyria \| T2]` |
| Imago | imagen-4.0-generate-001 | T2 | ❌ paid | `[Turin → Imago \| T2]` |
| Gemwave | gemini-2.5-flash-native-audio-latest | T2 | ∞ WS | `[Turin → Gemwave \| T2]` |
| Gemlive | gemini-3.1-flash-live-preview | T2 | ∞ WS | `[Turin → Gemlive \| T2]` |
| Tigon | gemma-4-26b-a4b-it | T2 | 1500 | `[Turin → Tigon \| T2]` |
| Triton | gemma-3-12b-it | T2 | 14400 | `[Turin → Triton \| T2]` |
| Haiku | claude-haiku-4-5-20251001 | T3 | — | `[Turin → Haiku \| T3]` |
| Sonnet | claude-sonnet-4-6 | T4 | — | `[Turin → Sonnet \| T4]` |
| Opus | claude-opus-4-6 | T5 | — | `[Turin → Opus \| T5]` |
