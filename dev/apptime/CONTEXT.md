# AppTime

Android app to reduce phone addiction through awareness — without blocking or punishing a native floating overlay shows real-time session counts and cumulative screen time for the active app and provide analytics.

## Setup

Android only · min SDK 21 · Flutter (UI) + Kotlin (overlay + monitoring)

## Architecture

`Flutter UI → SharedPreferences ← MonitoringService (Kotlin) → OverlayService (Kotlin)`

Full module breakdown, interfaces, and constraints → [SPECS.md](SPECS.md)
Roadmap and pending milestones → [ROADMAP.md](ROADMAP.md)

## Status

| Item | Value |
|------|-------|
| Phase | In dev — rewrite from scratch |
| Last milestone | M6 Analytics ✓ |
| Next | M7 Polish → v1.0 |
