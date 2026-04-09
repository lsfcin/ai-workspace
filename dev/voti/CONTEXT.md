# Voti

App que permite cidadãos entenderem o match entre suas posições e as votações reais de políticos.

## Escopo

| Aspecto | Detalhe |
|---------|---------|
| Objetivo | Transparência política via matching cidadão ↔ parlamentar |
| Público | Cidadãos brasileiros, foco inicial em Recife/PE |
| Fase | Planejamento — definindo MVP |
| Plataforma alvo | Mobile (React Native) + Web |
| Última atualização | 2026-04-08 |

## Conceito do MVP

- Usuário responde questionário sobre temas votados (sim/não/neutro)
- Sistema compara com votações reais de parlamentares (dados abertos)
- Gera ranking de match por parlamentar
- Visualização simples: % de alinhamento + detalhamento por tema

## Fontes de dados

- Câmara dos Deputados API (dados.camara.leg.br)
- Senado (dados abertos)
- TSE (candidatos e partidos)

## Decisões pendentes

- [ ] Definir stack BE (FastAPI vs Node)
- [ ] Definir como categorizar votações em temas compreensíveis
- [ ] Definir escopo do MVP (só federal? inclui estadual?)

## Refs

- Inspirações: ver `refs/inspiracoes.md` (quando criado)
- Dados da Câmara: ver `refs/api-camara.md` (quando criado)
