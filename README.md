# AI-Workspace

Workspace hierárquico para orquestração de contextos com IA, desenvolvido e mantido por **Lucas Silva Figueiredo** — Prof. de Ciência da Computação (UFRPE / CIn-UFPE), pesquisador em Inteligência Híbrida, Mechanism Design, AR e 3D Computer Vision.

O agente que navega este workspace chama-se **Crono**.

## Estrutura

```
AI-Workspace/
├── CLAUDE.md                  # Identidade, protocolo e routing do Crono
├── academia/                  # Disciplinas, materiais, slides
├── dev/                       # Projetos de software
├── lih-dd/                    # Lab LIH.DD — papers, manifestos
├── pessoal/                   # RPG, saúde, casa, produtividade
└── meta/                      # Gestão do próprio workspace
    ├── templates/             # Templates de CONTEXT, SPECS, ADR
    ├── tools/                 # Catálogo de ferramentas (TOOLS.md)
    ├── hooks/                 # Scripts de automação (auto-commit)
    └── referencias/
        └── clief-notes/       # PDFs de referência sobre AI workflows
```

Cada pasta é um **escopo de contexto**. O arquivo `CONTEXT.md` de cada nível define o significado daquele escopo. `SPECS.md` detalha restrições técnicas quando relevante.

## O que está versionado

Este repositório rastreia **apenas arquivos de sistema do workspace**:

| Tipo | Arquivos |
|------|----------|
| Protocolo do agente | `CLAUDE.md` |
| Contextos | `**/CONTEXT.md` |
| Especificações | `**/SPECS.md` |
| Templates e ferramentas | `meta/templates/`, `meta/tools/` |
| Referências | `meta/referencias/clief-notes/*.pdf` |

Dados de projetos específicos, fichas pessoais e materiais de aula **não são versionados**.

## Protocolo de contexto

O Crono segue uma cadeia de carregamento: ao receber uma tarefa, identifica o workspace-alvo pela tabela de routing em `CLAUDE.md` e lê os `CONTEXT.md` do nível 1 até a folha, sem carregar ramos não relacionados.

## Auto-versionamento

Edições em arquivos rastreados disparam automaticamente um commit via hook do Claude Code (`meta/hooks/auto_commit.py`), mantendo o histórico atualizado sem intervenção manual.

## Licença

MIT — ver [LICENSE](LICENSE).
