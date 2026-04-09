# AI Workspace — Estrutura de Pastas (Piloto)

```
ai-workspace/
├── CLAUDE.md                          # Identity, routing, regras globais, abreviações
│
├── academia/
│   ├── CONTEXT.md                     # Visão geral: professor UFRPE, disciplinas, Notion
│   ├── ia4good/
│   │   ├── CONTEXT.md                 # Disciplina específica, turma, ementa resumida
│   │   ├── SPECS.md                   # Ferramentas, formato de entrega, critérios
│   │   ├── materiais/
│   │   └── exercicios/
│   ├── ihm/                           # (exemplo de outra disciplina — mesma estrutura)
│   │   ├── CONTEXT.md
│   │   └── ...
│   └── slides/
│       └── CONTEXT.md                 # Convenções de slides, ferramentas, templates
│
├── dev/
│   ├── CONTEXT.md                     # Stack geral, convenções de código, CI/CD
│   ├── apptimer/
│   │   ├── CONTEXT.md                 # O que é, estado atual, roadmap curto
│   │   ├── SPECS.md                   # Arquitetura, deps, API, DB schema
│   │   ├── decisions/                 # ADRs (Architecture Decision Records)
│   │   ├── src/
│   │   ├── docs/
│   │   └── tests/
│   ├── voti/
│   │   ├── CONTEXT.md
│   │   ├── SPECS.md
│   │   └── ...
│   ├── neoeduc/
│   │   ├── CONTEXT.md
│   │   ├── SPECS.md
│   │   └── ...
│   └── email-agent/
│       ├── CONTEXT.md
│       ├── SPECS.md
│       └── ...
│
├── pessoal/
│   ├── CONTEXT.md                     # Visão geral vida pessoal — sem detalhes sensíveis
│   ├── rpg/
│   │   ├── CONTEXT.md                 # D&D 5e, sistemas, estilo de jogo
│   │   ├── player/
│   │   │   ├── CONTEXT.md             # Personagens ativos, preferências de build
│   │   │   ├── kanon_ficha.md
│   │   │   └── cassian_ficha.md
│   │   └── gm/
│   │       ├── CONTEXT.md             # Estilo de mestre, campanhas, ferramentas
│   │       └── foundry/
│   │           └── CONTEXT.md         # Setup Foundry, módulos, isometric, plugins
│   ├── saude/
│   │   ├── CONTEXT.md                 # Métricas monitoradas, objetivos, rotina
│   │   └── registros/
│   ├── casa/
│   │   ├── CONTEXT.md                 # Projeto da casa em Recife, fase atual
│   │   ├── SPECS.md                   # Materiais, técnicas, orçamento
│   │   └── plantas/
│   └── produtividade/
│       ├── CONTEXT.md                 # CRM pessoal, email, agenda, prioridades
│       └── crm/
│
├── lih-dd/
│   ├── CONTEXT.md                     # Lab, pesquisadores, linhas de pesquisa
│   ├── papers/
│   │   └── CONTEXT.md
│   └── manifestos/
│
└── meta/
    ├── CONTEXT.md                     # O que é este workspace, como funciona o sistema
    ├── SPECS.md                       # Arquitetura do workspace, protocolos, regras de composição
    ├── tools/
    │   ├── CONTEXT.md                 # Ferramentas disponíveis, custo, quando usar
    │   └── TOOLS.md                   # Tabela de ferramentas (agentes, libs, CLIs, MCPs)
    ├── referencias/
    │   └── clief-notes/               # PDFs do curso como referência
    ├── templates/
    │   ├── CONTEXT_TEMPLATE.md        # Template padrão para novos CONTEXT.md
    │   ├── SPECS_TEMPLATE.md          # Template padrão para novos SPECS.md
    │   └── ADR_TEMPLATE.md            # Template para Architecture Decision Records
    └── backlog.md                     # Melhorias detectadas pelo agente durante trabalho
```

## Notas sobre a estrutura

**Profundidade máxima com CONTEXT.md: 4 níveis**
- Nível 0: `CLAUDE.md` (root)
- Nível 1: `academia/CONTEXT.md`
- Nível 2: `academia/ia4good/CONTEXT.md`
- Nível 3: `pessoal/rpg/gm/foundry/CONTEXT.md`

Abaixo disso, subpastas organizam arquivos mas sem CONTEXT.md próprio.

**SPECS.md aparece apenas onde há implementação técnica**
- Projetos de dev: sempre
- Casa (construção): sim, tem specs de materiais e técnicas
- Disciplinas: sim, tem specs de ferramentas e formato
- RPG player: não precisa
- Saúde: não precisa (por enquanto)

**O workspace `/meta/` é o único que pode modificar a estrutura dos outros.**
Todos os outros workspaces trabalham dentro de si mesmos.
