# AppTime

Android app to reduce phone addiction through awareness — a native floating overlay shows real-time session counts and cumulative screen time for the active app, without blocking or punishing. Personalized analytics help understand 

## Setup

Android only · min SDK 21 · Flutter (UI) + Kotlin (overlay + monitoring)

## Architecture

`Flutter UI → SharedPreferences ← MonitoringService (Kotlin) → OverlayService (Kotlin)`

Full module breakdown, interfaces, and constraints → SPECS.md

## Structure

| Path | Content |
|------|---------|
| `lib/` | Flutter/Dart UI screens and services |
| `android/.../kotlin/` | Native Kotlin services (overlay, monitoring) |
| `decisions/` | ADRs for architectural choices |
| `SPECS.md` | Full setup, architecture, constraints, feature specs |
| `ROADMAP.md` | Active and upcoming milestones |

## Core features

- Native floating overlay — open count + cumulative time for active app
- Background monitoring — session tracking, screen-off detection, launcher handling
- Per-app analytics — 1/7/30d usage breakdowns
- Settings — overlay appearance, daily goals, per-app toggle

## Status

| Item | Value |
|------|-------|
| Phase | In dev — rewrite from scratch |
| Last milestone | M6 Analytics ✓ |
| Next | M7 Polish → v1.0 |

# LATEST CHANGES
