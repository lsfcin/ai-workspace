# Meta — Specs do AI Workspace

## Arquitetura

| Conceito | Impl |
|----------|------|
| Routing | Tabela em CLAUDE.md root. Task → ws → arquivos a ler → modelo |
| Ctx hierárquico | CONTEXT.md em cada nível. Agente compõe do root à folha |
| Specs separados | SPECS.md para detalhes técnicos. Carregado só quando tarefa exige impl |
| Delegação | Mastermind (Opus) delega para Haiku/local/scripts conforme TOOLS.md |
| Consistência | Agente cruza instrução com specs antes de alterar stack/arquitetura |
| Atualização | Agente propõe diffs em ctx/specs após tarefas. Nunca altera sem confirmação |
| Backlog | Observações registradas em `/meta/backlog.md` sem interromper tarefa |

## Protocolo de criação de novo workspace

1. Criar pasta no nível adequado da hierarquia
2. Copiar `/meta/templates/CONTEXT_TEMPLATE.md` → `CONTEXT.md`
3. Preencher template com info do novo ws
4. Se ws técnico → copiar e preencher `SPECS_TEMPLATE.md` → `SPECS.md`
5. Adicionar rota na tabela de routing do CLAUDE.md root
6. Registrar criação em `/meta/backlog.md` como "concluído"

## Protocolo de revisão de ctx existente

1. Ler ctx atual + backlog de observações relacionadas
2. Propor diff com formato: trecho atual → trecho novo
3. Aguardar confirmação do usuário
4. Aplicar e marcar backlog como resolvido

## Limites de tamanho

| Arquivo | Máx linhas | Se ultrapassar |
|---------|-----------|----------------|
| CLAUDE.md root | 120 | Extrair seções para `/meta/` |
| CONTEXT.md | 40 | Extrair para arquivos auxiliares |
| SPECS.md | 80 | Dividir em SPECS_[area].md |
| TOOLS.md | 60 | Agrupar ferramentas por categoria |

## Deps do sistema

| Ferramenta | Propósito | Status |
|------------|-----------|--------|
| Claude Code (terminal) | Mastermind / orquestrador | [CONFIGURAR] |
| Ollama | Modelo local para tarefas delegadas | [INSTALAR] |
| MemPalace (MCP) | Memória longa entre sessões | [AVALIAR — projeto novo] |
| ChromaDB + PyYAML | Deps do MemPalace | [INSTALAR se MemPalace aprovado] |
| Node.js | Runtime para Claude Code | [VERIFICAR] |
