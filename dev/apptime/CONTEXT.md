# AppTime

App Android para redução do vício no celular via consciência e informação sobre uso real.

## Missão e estratégia

| Aspecto | Detalhe |
|---------|---------|
| Problema | Uso inconsciente e compulsivo do celular |
| Abordagem | Visibilidade contínua do uso sem bloquear (nudge, não punição) |
| Feature core | Overlay flutuante mostrando aberturas e tempo acumulado do app em uso |
| Estratégias adicionais | Analytics comportamental, insights científicos, metas diárias, controle por app |

## Estado atual

| Item | Status |
|------|--------|
| Fase | Em desenvolvimento — rewrite from scratch |
| Plataforma | Android only (min SDK 21) |
| Stack | Flutter (UI) + Kotlin (overlay e monitoramento) |
| Última atualização | 2026-04-09 |

## Arquitetura em uma linha

Flutter UI → SharedPreferences ← `MonitoringService` Kotlin (rastreia sessões) → `OverlayService` Kotlin (View nativa, poll 500ms)

## Features

| Feature | Status |
|---------|--------|
| Overlay nativo (contagem de aberturas + tempo) | Planejado |
| MonitoringService — detecção e rastreio de sessões | Planejado |
| HomeScreen — permissões e toggle de monitoramento | Planejado |
| SettingsScreen — posição, fonte, metas, per-app | Planejado |
| AnalyticsScreen — gráficos 1/7/30 dias | Planejado |

## Refs

- Arquitetura detalhada, stack, ordem de impl: ver SPECS.md
