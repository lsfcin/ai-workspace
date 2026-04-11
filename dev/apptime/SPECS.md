# AppTime — Specs

> Load when writing code, debugging, or checking constraints. For milestones → ROADMAP.md.

## Setup

**Stack**
```
Flutter (Dart) — Android only, min SDK 21
shared_preferences: ^2.3.3
permission_handler: ^12.0.1
fl_chart: ^0.70.2
flutter_launcher_icons: ^0.14.3 (dev)
```

**Android permissions**
`SYSTEM_ALERT_WINDOW`, `PACKAGE_USAGE_STATS`, `FOREGROUND_SERVICE`,
`FOREGROUND_SERVICE_SPECIAL_USE`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, `POST_NOTIFICATIONS`

## Architecture

**Module map**
```
Flutter App (UI)
    ↕ SharedPreferences
MonitoringService (Kotlin, foreground) — detects active app via UsageStatsManager, tracks sessions
    └── OverlayService (Kotlin) — native View, polls SharedPreferences every 500ms
```

**Critical constraints — do not change without ADR**
- Flutter handles UI only. Overlay and monitoring are pure Kotlin.
- Communication via SharedPreferences (pull), not EventChannel — avoids zombie state from Flutter engine.
- No `flutter_overlay_window` / `flutter_background_service` — overlay uses `WindowManager.addView()` natively with `START_STICKY`.
- Never use `totalTimeInForeground` from Android API — excludes active session. Track sessions manually.
- Launchers (MIUI home, Nexus, etc.) treated as special mode, not as "app".
- Screen off detected via event type 8 (`SCREEN_NON_INTERACTIVE`) — stop counting.

**SharedPreferences schema**

| Key | Type | Description |
|-----|------|-------------|
| `overlay_text` | String | Text shown in overlay |
| `overlay_visible` | Boolean | Whether overlay should appear |
| `overlay_anchor`, `overlay_font_size`, `overlay_top_dp`, `overlay_h_pct` | Mixed | Position and style |
| `daily_ms_{pkg}_{date}` | Long | Accumulated ms for app on that day |
| `open_count_{pkg}_{date}` | Int | App opens on that day |
| `unlock_count_{date}` | Int | Device unlocks on that day |
| `device_daily_ms_{date}` | Long | Total device usage on that day |
| `disabled_apps` | StringSet | Apps with overlay disabled |

**Overlay display logic**
- Phase 0 (first 5s after open): `"13x"` — open count for active app
- Phase 1 (after): `"0:45"` — cumulative time (`M:SS` if <1h, `H:MM` if ≥1h)
- On launcher — phase 0: unlocks (`"86x"`), phase 1: total device usage (`"2.3h"`)

**MethodChannel interface** — `"apptime/service"`
`startMonitoring` · `stopMonitoring` · `isRunning` · `requestOverlayPermission` · `requestUsagePermission`

## Features

| Feature | Status |
|---------|--------|
| Native overlay (open count + time) | ✓ |
| MonitoringService — session detection and tracking | ✓ |
| Screen-off detection / launcher special mode | ✓ |
| HomeScreen — permissions, monitoring toggle, daily insight | ✓ |
| SettingsScreen — overlay position, font, goals, per-app | ✓ |
| PerAppScreen — per-app overlay toggle | ✓ |
| AnalyticsScreen — 1/7/30d charts and session breakdown | ✓ |
| Polish — adaptive icon, edge cases, MIUI support | Planned |

## Conventions

**Theme**
```
primary=0xFF4F6EF7  primaryDark=0xFF3A55D4
surface=0xFFF7F8FC  surfaceDark=0xFF1A1D2E
card=white / 0xFF242740   success=0xFF34D399   error=0xFFF87171
Spacing XS=4 SM=8 MD=16 LG=24 XL=32 | Radius SM=8 MD=12 LG=16 XL=24
Material3, light/dark auto, cards elevation:0 with thin border
```
