# Voti

App allowing citizens to understand the match between their positions and actual politicians' voting records.

## Scope

| Aspect | Detail |
|--------|--------|
| Goal | Political transparency via citizen ↔ representative matching |
| Audience | Brazilian citizens, initial focus on Recife/PE |
| Phase | Planning — defining MVP |
| Target platform | Mobile (React Native) + Web |

## MVP concept

- User answers a questionnaire on voted topics (yes/no/neutral)
- System compares against real representatives' votes (open data)
- Generates a match ranking per representative
- Simple visualization: % alignment + breakdown by topic

## Data sources

- Câmara dos Deputados API (dados.camara.leg.br)
- Senado (open data)
- TSE (candidates and parties)

## Pending decisions

- [ ] Define BE stack (FastAPI vs Node)
- [ ] Define how to categorize votes into understandable topics
- [ ] Define MVP scope (federal only? include state level?)

Specs → [SPECS.md](SPECS.md)
