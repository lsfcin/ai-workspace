# Meta — Gestão do AI Workspace

Este ws gerencia a própria infraestrutura do AI Workspace.
Criar, revisar e melhorar: estrutura de pastas, CONTEXT.md, SPECS.md, routing, ferramentas.

## Propósito
Melhorar o próprio AI Workspace:
- Estrutura de pastas
- Qualidade dos contextos
- Consistência das specs
- Ferramentas funcionais e de qualidade
- Fluxos de trabalho

## Sub-contextos

| Subdir | Papel |
|--------|-------|
| `tools/` | Hub de delegação — routing em `CONTEXT.md`, task files em `tasks/`, glossário em `AGENTS.md` |
| `templates/` | Templates de CONTEXT, SPECS, ADR |
| `hooks/` | Scripts de automação (auto-commit) |
| `referencias/` | Clief notes e referências de método |

## Responsabilidades

- Identificar ineficiências e propor melhorias
- Refatorar contextos, otimização de tokens nos contextos e nas ações
- Sugerir novas estruturas
- Criar novos workspaces e ctx files (usar templates em `/meta/templates/`)
- Revisar ctx files existentes quando detectado no backlog
- Avaliar e integrar novas ferramentas (modelos, MCPs, CLIs)
- Não modificar arquivos estruturais diretamente
- Sempre propor mudanças via /_meta/changes/
- Manter `/meta/backlog.md` triado e priorizado
- Documentar decisões sobre o sistema em `/meta/decisions/`
- Versionar no Github as pastas e os arquivos exclusivamente relevantes ao AI Workspace (CONTEXT.md, SPECS.md, etc). Ignorar todos os demais arquivos.

## Princípios (baseados em Clief Notes)

- Sistema cresce por uso, não por planejamento. Versão mínima primeiro
- CONTEXT.md são notas de trabalho, não docs finais. Editar é barato
- Máx 4 níveis de profundidade com ctx próprio
- Se o sistema parece pesado → algo deu errado. Simplificar
- Refs completas do método: ver `/meta/referencias/clief-notes/`

## Gatilhos de melhoria
- Confusão recorrente
- Instruções redundantes
- Alto consumo de tokens
- Dificuldade de navegação

## Permissões

auto_update_context: false (sempre pedir confirmação neste ws)
