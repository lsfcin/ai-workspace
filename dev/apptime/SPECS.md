# AppTime — Specs

## Setup

| Layer | Technology |
|-------|------------|
| UI | Flutter / Dart — Android only, min SDK 21 |
| Overlay + monitoring | Kotlin native services |
| Storage | SharedPreferences |

**Libraries:** shared_preferences ^2.3.3 · permission_handler ^12.0.1 · fl_chart ^0.70.2 · flutter_launcher_icons ^0.14.3 (dev)

**Android permissions:** SYSTEM_ALERT_WINDOW · PACKAGE_USAGE_STATS · FOREGROUND_SERVICE · FOREGROUND_SERVICE_SPECIAL_USE · REQUEST_IGNORE_BATTERY_OPTIMIZATIONS · POST_NOTIFICATIONS

## Architecture

`Flutter UI ↔ SharedPreferences ← MonitoringService (foreground, Kotlin) → OverlayService (native View, 500ms poll)`

**Constraints — do not change without ADR**
- Flutter handles UI only; overlay and monitoring are pure Kotlin
- Communication via SharedPreferences pull, not EventChannel — avoids Flutter engine zombie state
- Overlay uses `WindowManager.addView()` with `START_STICKY` — no `flutter_overlay_window`
- Sessions tracked manually — never use `totalTimeInForeground` (excludes active session)
- Launchers treated as special mode, not regular apps
- Screen off = event type 8 (`SCREEN_NON_INTERACTIVE`) → stop counting

**SharedPreferences keys**

| Key | Type | Description |
|-----|------|-------------|
| `overlay_text` | String | Text shown in overlay |
| `overlay_visible` | Boolean | Whether overlay should appear |
| `overlay_anchor`, `overlay_font_size`, `overlay_top_dp`, `overlay_h_pct` | Mixed | Position and style |
| `daily_ms_{pkg}_{date}` | Long | Accumulated ms for app that day |
| `open_count_{pkg}_{date}` | Int | App opens that day |
| `unlock_count_{date}` | Int | Device unlocks that day |
| `device_daily_ms_{date}` | Long | Total device usage that day |
| `disabled_apps` | StringSet | Apps with overlay disabled |

**Overlay display**
- Phase 0 (first 5s after open): open count → `"13x"`
- Phase 1 (after): cumulative time → `"0:45"` (`M:SS` if <1h, `H:MM` if ≥1h)
- On launcher — phase 0: unlocks (`"86x"`), phase 1: total device usage (`"2.3h"`)

**MethodChannel** `"apptime/service"`: `startMonitoring` · `stopMonitoring` · `isRunning` · `requestOverlayPermission` · `requestUsagePermission`

## Features

| Feature | Status |
|---------|--------|
| Native floating overlay — open count + cumulative time | ✓ |
| Background app monitoring + session tracking | ✓ |
| Screen-off detection / launcher special mode | ✓ |
| HomeScreen — permissions, toggle, daily insight | ✓ |
| SettingsScreen — appearance, goals, per-app control | ✓ |
| PerAppScreen — per-app overlay toggle | ✓ |
| AnalyticsScreen — 1/7/30d charts and session breakdown | ✓ |
| Polish — adaptive icon, edge cases, MIUI support | Planned |

## Conventions

**Theme:** primary #4F6EF7 · primaryDark #3A55D4 · surface #F7F8FC / #1A1D2E · card white / #242740 · success #34D399 · error #F87171

Spacing: XS=4 SM=8 MD=16 LG=24 XL=32 · Radius: SM=8 MD=12 LG=16 XL=24 · Material3, light/dark auto, cards elevation 0 with thin border
