# Clief Notes — Referência de Método

Material do curso "The Foundation" por Jake Van Clief (Clief Notes / Skool).
Base teórica para a arquitetura deste AI Workspace.

## Quando consultar

- Ao criar ou revisar CONTEXT.md, SPECS.md, routing tables
- Ao avaliar se a estrutura de pastas está seguindo os princípios
- Ao explicar o sistema para terceiros

## Arquivos por prioridade

### Essenciais (ler primeiro)

| Arquivo | Conteúdo-chave |
|---------|---------------|
| 3.1 The Full Walkthrough | Sistema de 3 camadas: Map (CLAUDE.md) → Rooms (CONTEXT.md) → Tools. Routing table. Naming conventions |
| 3.2 Customizing for Your Use Case | 3 exemplos reais (content creator, freelancer, developer). Como adaptar layers ao seu trabalho |
| 3.3 Common Mistakes | 7 erros: ctx longo, sem routing table, ws demais, ctx sobre IA em vez do trabalho, ctx desatualizado, pasta flat, over-engineering |
| 1.3 How to Structure Any Prompt | Framework 5 partes: Identity, Task, Context, Constraints, Output Format. Chunking |

### Úteis (consultar quando relevante)

| Arquivo | Conteúdo-chave |
|---------|---------------|
| 1.2 Your First Folder | Setup mínimo: 3 arquivos (CLAUDE.md, CONTEXT.md, REFERENCES.md) |
| 4.2 Claude Code in Practice | Loop Read→Think→Write→Check→Adjust. Desktop vs Code. Token math (200K ctx, ~2K/doc) |
| 2.5 Clawdbot (Moltbot) | Orquestração vs inteligência. Framework 60/30/10. Onde vive o valor |
| 2.6 Video as Code | Pipeline: spec.md → style guide → component registry → Remotion → CapCut. Separation of concerns aplicada a trabalho criativo. Constraints melhoram output |
| 2.2 One Line of Python | 7 camadas: Python→bytecode→C→assembly→machine code→hardware→elétrons. Toda camada começou não-confiável e virou confiável via arquitetura. IA = próxima camada |

### Contexto teórico (consultar para entendimento profundo)

| Arquivo | Conteúdo-chave |
|---------|---------------|
| 2.1 Video Text Guide | Mapa da série de 6 vídeos. Throughline: IA = próxima camada de 70+ anos de stack |
| 2.3 How a 1953 Word Game Explains AI Memory | Context window = working memory. Em LLMs, código e dados são a mesma coisa. Por isso prompt injection funciona e por isso ctx estruturado importa |
| 2.4 The Ladder That Explains Every AI Failure | Valor vive acima do que foi commoditizado. Não automatize na camada errada |
| 1.1 What You Need | Setup: Claude account (Free/Pro/Max), VS Code ou Cursor, Node.js para Claude Code |

### PDFs não mepeados neste arquivo de contexto

2.7, 4.1, 4.3, 4.4, 4.5, 5.1

## Princípios-chave extraídos

1. CLAUDE.md é mapa, não enciclopédia. Cabe em 1 tela
2. Routing table: task → pasta → o que ler. Elimina ambiguidade
3. CONTEXT.md descreve o trabalho, não a personalidade da IA (80/20)
4. Comece mínimo, cresça por uso. 15 min na v1
5. Trate ctx files como notas de trabalho — edite sempre
6. Mais de 8-10 arquivos no mesmo nível → precisa de subpastas
7. Se em dúvida se algo merece ws próprio → não merece. Subfolder
8. IA é componente (10%), valor está na arquitetura ao redor (90%)
9. Spec é o ponto de alavancagem — quanto mais preciso, melhor o output
10. Constraints não limitam, focam. Style guide e component registry são constraints encodadas como arquivos
