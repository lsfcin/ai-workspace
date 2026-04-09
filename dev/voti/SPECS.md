# Voti — Specs

## Stack (proposta — não confirmada)

| Camada | Tecnologia | Status |
|--------|-----------|--------|
| FE Mobile | React Native + Expo | Proposta |
| FE Web | React (Next.js) | Proposta |
| BE | [FastAPI ou Node — decidir] | Pendente |
| DB | PostgreSQL | Proposta |
| Deploy | [definir] | Pendente |

## Arquitetura proposta

```
[Mobile/Web] → API REST → BE → DB PostgreSQL
                                 ↕
                          Scraper/ETL ← Dados Abertos (Câmara, Senado, TSE)
```

ETL roda em batch (diário ou semanal), não em tempo real.
API serve dados já processados para o FE.

## Modelo de dados (rascunho)

| Entidade | Campos principais |
|----------|-------------------|
| Parlamentar | id, nome, partido, estado, casa (câmara/senado) |
| Votação | id, data, tema, descrição, resultado |
| VotoParlamentar | parlamentar_id, votação_id, voto (sim/não/abstenção/ausente) |
| UsuárioResposta | user_id, votação_id, posição (sim/não/neutro) |
| Match | user_id, parlamentar_id, score, detalhamento_por_tema |

## Constraints

- Dados devem vir exclusivamente de fontes oficiais abertas
- Zero tracking de usuário além do necessário para calcular match
- Apartidário — sem ranking de partidos, só de indivíduos
- Linguagem acessível — evitar jargão legislativo na interface
