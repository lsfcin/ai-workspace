# Tools — Hub de Delegação

Este subdir contém o catálogo completo de agentes e comandos delegáveis.
Ler aqui ao decidir como executar qualquer tarefa com processamento, busca ou geração.

## Arquivos deste workspace

| Arquivo | O que contém |
|---------|-------------|
| `AGENTS.md` | Roster de agentes nomeados (Pygit, Bashman, Llama, Gemini, Haiku, Sonnet, Opus) com tiers, modelos e quando usar |
| `COMMANDS.md` | Catálogo de comandos por tier — snippets prontos para delegar |
| `TOOLS.md` | Tabela de ferramentas disponíveis com status (ativo / avaliar / descartado) |

## Gate de decisão

Antes de qualquer ação, percorrer em ordem:

```
1. É operação mecânica? (replace, grep, git, métricas, conversão, mídia)
   → SIM: Pygit ou Bashman (T0). Ver comandos em COMMANDS.md.

2. Precisa de semântica simples / rascunho?
   → Llama (T1). Verificar ollama serve antes.

3. Precisa de qualidade moderada ou doc longo (>5 páginas)?
   → Gemini (T2). Ver snippet em COMMANDS.md.

4. Requer raciocínio Claude?
   → Haiku (T3) → Sonnet (T4) → Opus (T5), nesta ordem.
```

Ver `AGENTS.md` para nome canônico de cada agente e verbose format.

## Escopo

| Aspecto | Detalhe |
|---------|---------|
| Objetivo | Manter catálogo atualizado de executores disponíveis |
| Responsável | Workspace `/meta/` |
| Última atualização | 2026-04-09 |

## Processo de atualização

1. Nova ferramenta identificada → adicionar em `TOOLS.md` com status [AVALIAR]
2. Testar em tarefa real → registrar resultado
3. Se aprovada → mudar status para ativo, documentar quando usar
4. Se reprovada → remover ou mover para seção "descartadas"
