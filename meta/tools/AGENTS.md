# Roster de Agentes

Glossário técnico. **Não é lido durante routing** — use `tasks/*.md` para isso.

## Formato de verbose

```
[Claude → Agente | TN] o que foi pedido
[Agente → Claude] resultado ou resumo
[SKIP TN — motivo]
```

## Tabela de agentes

| Nome | Modelo / executor | Tier | RPD | Verbose |
|------|-------------------|------|-----|---------|
| Pygit | python / git | T0 | ∞ | `[Claude → Pygit \| T0]` |
| Bashman | bash / CLI | T0 | ∞ | `[Claude → Bashman \| T0]` |
| Llama | ollama local | T1 | ∞ | `[Claude → Llama \| T1]` |
| Gemflite | gemini-3.1-flash-lite-preview | T2 | 500 | `[Claude → Gemflite \| T2]` |
| Gemlux | gemini-2.5-flash-lite | T2 | 20 | `[Claude → Gemlux \| T2]` |
| Gemtrin | gemini-3-flash-preview | T2 | 20 | `[Claude → Gemtrin \| T2]` |
| Gemflash | gemini-2.5-flash | T2 | 20 | `[Claude → Gemflash \| T2]` |
| Gemvoice | gemini-2.5-flash-preview-tts | T2 | 10 | `[Claude → Gemvoice \| T2]` |
| Gemvoice-Pro | gemini-2.5-pro-preview-tts | T2 | — | `[Claude → Gemvoice-Pro \| T2]` |
| Gemvision | gemini-2.5-flash-image | T2 | diária | `[Claude → Gemvision \| T2]` |
| Gempic | gemini-3-pro-image-preview | T2 | diária | `[Claude → Gempic \| T2]` |
| Gemart | gemini-3.1-flash-image-preview | T2 | diária | `[Claude → Gemart \| T2]` |
| Lyria | lyria-3-{clip,pro}-preview | T2 | diária | `[Claude → Lyria \| T2]` |
| Imago | imagen-4.0-generate-001 | T2 | ❌ paid | `[Claude → Imago \| T2]` |
| Gemwave | gemini-2.5-flash-native-audio-latest | T2 | ∞ WS | `[Claude → Gemwave \| T2]` |
| Gemlive | gemini-3.1-flash-live-preview | T2 | ∞ WS | `[Claude → Gemlive \| T2]` |
| Tigon | gemma-4-26b-a4b-it | T2 | 1500 | `[Claude → Tigon \| T2]` |
| Triton | gemma-3-12b-it | T2 | 14400 | `[Claude → Triton \| T2]` |
| Haiku | claude-haiku-4-5-20251001 | T3 | — | `[Claude → Haiku \| T3]` |
| Sonnet | claude-sonnet-4-6 | T4 | — | `[Claude → Sonnet \| T4]` |
| Opus | claude-opus-4-6 | T5 | — | `[Claude → Opus \| T5]` |
