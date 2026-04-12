# AppTime

Android app to reduce phone addiction through awareness — without blocking or punishing a native floating overlay shows real-time session counts and cumulative screen time for the active app and provide analytics.

## Setup

Android only · min SDK 21 · Flutter (UI) + Kotlin (overlay + monitoring)

## Architecture

`Flutter UI → SharedPreferences ← MonitoringService (Kotlin) → OverlayService (Kotlin)`

Full module breakdown, interfaces, and constraints → SPECS.md
Roadmap and pending milestones → ROADMAP.md

## Status

| Item | Value |
|------|-------|
| Phase | In dev — rewrite from scratch |
| Last milestone | M6 Analytics ✓ |
| Next | M7 Polish → v1.0 |

# LATEST CHANGES
- Official launcher icon added: dark bg (#1A1D2E), green timer arc (270°, #34D399) wrapping a white phone silhouette with brand-blue (#4F6EF7) screen. Source PNG at `assets/icon/app_icon.png`; all mipmap sizes (mdpi→xxxhdpi) generated via flutter_launcher_icons. Figma reference: https://www.figma.com/design/hXJFHj1HeDdXra5Z5zRB1g
