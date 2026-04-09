# T3–T5 — Claude (Haiku / Sonnet / Opus)

**Quando:** tiers 0–2 inadequados. Justificar por que antes de usar.

## Ordem de escalada

| Tier | Agente | Modelo | Quando |
|------|--------|--------|--------|
| T3 | Haiku | claude-haiku-4-5-20251001 | Fallback pago leve; Gemini offline; tarefa simples |
| T4 | Sonnet | claude-sonnet-4-6 | Qualidade geral; análise contextual; implementação |
| T5 | Opus | claude-opus-4-6 | Arquitetura; design de sistema; raciocínio de alta complexidade |

## Invocação via Agent tool

```python
Agent(
    subagent_type="general-purpose",  # Sonnet por padrão
    prompt="<contexto completo + tarefa>"
)
```

Para tipos especializados: `subagent_type="Explore"` (codebase) · `"Plan"` (arquitetura) · `"claude-code-guide"` (Claude API/SDK).

**Fallback:** Opus é o teto — se não resolver, consultar o usuário.
