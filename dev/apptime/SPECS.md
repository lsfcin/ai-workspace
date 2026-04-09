# AppTime — Specs

> Referência de arquitetura e decisões para impl. Snippets de código: ver código-fonte.

## Arquitetura

```
Flutter App (UI)
    ↕ SharedPreferences
MonitoringService (Kotlin, foreground) — detecta app atual via UsageStatsManager, rastreia sessões
    └── OverlayService (Kotlin) — View nativa, lê SharedPreferences a cada 500ms
```

**Decisões críticas (não mudar sem ADR):**
- Flutter só faz UI. Overlay e monitoramento são Kotlin puro.
- Comunicação via SharedPreferences (pull), não EventChannel — evita zombie state da Flutter engine.
- Sem `flutter_overlay_window` / `flutter_background_service` — overlay usa `WindowManager.addView()` nativo com `START_STICKY`.
- Nunca usar `totalTimeInForeground` da API Android — não inclui sessão ativa. Rastrear sessões manualmente.
- Launchers (MIUI home, Nexus, etc.) tratados como modo especial, não como "app".
- Tela off detectada via eventos tipo 8 (`SCREEN_NON_INTERACTIVE`) — parar contagem.

## Stack

```
Flutter (Dart) — Android only, min SDK 21
shared_preferences: ^2.3.3
permission_handler: ^12.0.1
fl_chart: ^0.70.2
flutter_launcher_icons: ^0.14.3 (dev)
```

## Permissões Android

`SYSTEM_ALERT_WINDOW`, `PACKAGE_USAGE_STATS`, `FOREGROUND_SERVICE`,
`FOREGROUND_SERVICE_SPECIAL_USE`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, `POST_NOTIFICATIONS`

## SharedPreferences — estrutura de dados

| Chave | Tipo | Descrição |
|-------|------|-----------|
| `overlay_text` | String | Texto exibido no overlay |
| `overlay_visible` | Boolean | Se overlay deve aparecer |
| `overlay_anchor`, `overlay_font_size`, `overlay_top_dp`, `overlay_h_pct` | Mixed | Posição e estilo |
| `daily_ms_{pkg}_{date}` | Long | Ms acumulados do app no dia |
| `open_count_{pkg}_{date}` | Int | Aberturas do app no dia |
| `unlock_count_{date}` | Int | Desbloqueios do dispositivo |
| `device_daily_ms_{date}` | Long | Uso total do dispositivo no dia |
| `disabled_apps` | StringSet | Apps com overlay desabilitado |

## Overlay — lógica de exibição

- **Phase 0** (primeiros 5s após abertura): `"13x"` — contagem de aberturas do app
- **Phase 1** (depois): `"0:45"` — tempo acumulado (`M:SS` se <1h, `H:MM` se ≥1h)
- **No launcher**: phase 0 = desbloqueios (`"86x"`), phase 1 = uso total do dispositivo (`"2.3h"`)

Flutter controla `OverlayService` via `MethodChannel("apptime/service")`: `startMonitoring`, `stopMonitoring`, `isRunning`, `requestOverlayPermission`, `requestUsagePermission`.

## Telas Flutter

| Tela | Conteúdo |
|------|----------|
| HomeScreen | Card insight do dia (10 insights PT-BR, rotação 1min), permissões, toggle monitoramento |
| SettingsScreen | Overlay (borda, fundo, fonte 10–18px), comportamento (por app, launcher, meta diária 0–360min), posicionamento |
| PerAppScreen | Lista apps usados nos últimos 7 dias com toggle por app |
| AnalyticsScreen | Period 1/7/30d: resumo geral, uso/hora (BarChart 24h), sessões rápidas/médias/buracos negros, ativo vs passivo, padrão de sono, uso diário, progresso vs período anterior, transições entre apps |

## Tema

```
primary=0xFF4F6EF7  primaryDark=0xFF3A55D4
surface=0xFFF7F8FC  surfaceDark=0xFF1A1D2E
card=white / 0xFF242740   success=0xFF34D399   error=0xFFF87171
Espaçamento XS=4 SM=8 MD=16 LG=24 XL=32 | Radius SM=8 MD=12 LG=16 XL=24
Material3, light/dark auto, cards elevation:0 com borda fina
```

## Ordem de implementação

1. Setup — `pubspec.yaml`, `AndroidManifest`, `AppTheme`, `StorageService`
2. `OverlayService` (Kotlin) — View nativa, poll 500ms em SharedPreferences
3. `MonitoringService` (Kotlin) — detecção de app, banco de sessões, escreve prefs
4. `MethodChannel` — Flutter inicia/para serviços e consulta status
5. `HomeScreen` — permissões + toggle monitoramento
6. `SettingsScreen` + `PerAppScreen` — escrevem em prefs
7. `AnalyticsService` + `AnalyticsScreen` — sessões via `queryEvents` (tipos 1/2/8)
