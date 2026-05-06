# AppTime — Code Structure & Reference

Last updated: 2026-04-21 (post-refactor + post-optimization milestones)

---

## Flutter / Dart — `lib/`

```
lib/
├── main.dart                        # App entry point, AppTimeApp, _AppTimeAppState
├── main_screen.dart                 # MainScreen — bottom nav, AppInfoService init
│
├── data/
│   ├── insight_content.dart         # InsightEntry, kAlertas, kSolucoes (47 entries, PT+EN)
│   └── insights.dart                # InsightEntry (rotator), kInsights (50 entries, PT+EN)
│
├── l10n/
│   ├── app_localizations.dart       # Abstract base — all l10n keys
│   ├── app_localizations_en.dart    # English implementations
│   └── app_localizations_pt.dart    # Portuguese implementations
│
├── models/
│   └── goal_config.dart             # GoalLevel enum, GoalThresholds, goalLevelFromInt
│
├── screens/
│   ├── analytics/
│   │   ├── analytics_screen.dart    # Shell: TabController + Tab1d/Tab7d/Tab30d
│   │   ├── analytics_helpers.dart   # Shared widgets: AppAgg, DonutChart, HorizontalAppBars,
│   │   │                            #   LegendDot/Item, Summary30dWidget, analysisCard(),
│   │   │                            #   analyticsNoData(), sevenDayLabel()
│   │   ├── classification_message.dart  # classificationMessage() — 5×4 tier matrix
│   │   ├── tab_day.dart             # Tab1d + hourly/session/opportunity charts
│   │   ├── tab_month.dart           # Tab30d + UsageTrend30d charts
│   │   └── tab_week.dart            # Tab7d + 7-day pattern + trend bars
│   │
│   ├── insights/
│   │   ├── insight_data.dart        # InsightData.compute() — pre-computed usage stats
│   │   └── insights_screen.dart     # InsightsScreen, _InsightCarousel, _InsightCard
│   │
│   ├── home_screen.dart             # Permissions + insight-of-day rotator
│   ├── monitoring_screen.dart       # MonitoringScreen, _InsightRotatorCard
│   ├── per_app_screen.dart          # Per-app goal/monitoring level selector
│   └── settings_screen.dart        # Settings: overlay, goal, language, data
│
├── services/
│   ├── analytics_service.dart       # AnalyticsService — builds DaySummary list (30 days)
│   ├── app_info_service.dart        # AppInfoService — loads labels + launchers once
│   ├── service_channel.dart         # ServiceChannel — MethodChannel bridge to Kotlin
│   └── storage_service.dart         # StorageService — SharedPreferences wrapper
│
├── theme/
│   └── app_theme.dart               # AppColors, AppSpacing
│
├── utils/
│   ├── app_info.dart                # kAppMeta, kPassivePatterns, labelForApp(),
│   │                                #   colorForApp(), isLauncherPkg(), isSystemPkg()
│   ├── date_utils.dart              # dayAnchor(), todayKey(), yesterdayKey(), fmtDate()
│   └── time_utils.dart              # fmtDuration(), fmtMs()
│
└── widgets/
    └── section_header.dart          # SectionHeader widget (shared across screens)
```

---

## Android / Kotlin — `android/app/src/main/kotlin/com/lsf/apptime/`

| File | Responsibility |
|------|---------------|
| `MainActivity.kt` | Flutter MethodChannel handler — start/stop service, permissions, getAppMetadata, getStartupStatus |
| `MonitoringService.kt` | Foreground service — 1s tick, accumulateDailyMs, session tracking, overlay text |
| `HistoryBackfill.kt` | Gap backfill (backfillGap) + 30-day history fill (backfillHistory); injectable |
| `OverlayService.kt` | Foreground service — overlay view lifecycle, updateOverlay(); delegates feedback to FeedbackEngine |
| `FeedbackEngine.kt` | F.BN breathing nudge, F.VW visual weight, F.PM personalized message; injectable |
| `AppConstants.kt` | LAUNCHERS, SOCIAL_PATTERNS, parseDisabledApps(), CHANNEL constant |
| `DateUtils.kt` | today(), currentHour(), safeGetCount() extension — shared by Monitoring/Overlay |
| `GoalThresholds.kt` | GoalThresholds data class + forLevel() tier table; mirrors goal_config.dart |
| `PmMessages.kt` | Personalized message strings (PT/EN) for all F.PM triggers |
| `BootReceiver.kt` | Restarts MonitoringService after device reboot |

---

## Architecture

```
Flutter UI ↔ SharedPreferences ← MonitoringService (foreground, 1s tick)
                                                  → OverlayService (500ms poll; 2000ms when screen off)
BootReceiver → starts MonitoringService on device reboot
```

**Critical constraints — do not change without understanding the full chain:**
- Flutter handles UI only; overlay and monitoring are pure Kotlin
- Communication via SharedPreferences pull, not EventChannel — avoids Flutter engine zombie state
- Overlay uses `WindowManager.addView()` with `START_STICKY`; never `flutter_overlay_window`
- Sessions tracked manually in `daily_ms_{pkg}_{date}` — never use `totalTimeInForeground` (excludes the active session, causing live lag)
- Launchers treated as special mode, not regular apps
- Screen off → `SCREEN_NON_INTERACTIVE` → immediately flush and close active session
- `disabledApps` stored as JSON string via `setString` (not `setStringList`) — required for cross-process read in Kotlin
- Integer values stored as `Long` by the Flutter plugin on Android — Kotlin must use `getLong()`, not `getInt()`
- SharedPreferences keys use `flutter.` prefix (Flutter plugin adds it); Kotlin reads them with that prefix

**Overlay behavior (post-M18):** timer-only display, immediate show/hide. Hidden on unmonitored apps and (optionally) the launcher. No count phase, no fades, no delays.

---

## SharedPreferences Schema

| Key | Type | Description |
|-----|------|-------------|
| `overlay_text` | String | Text shown in overlay |
| `overlay_visible` | Boolean | Whether overlay should appear |
| `overlay_font_size` | Float | Overlay text size (10–30 sp) |
| `overlay_show_background` | Boolean | Whether to draw background behind overlay |
| `daily_ms_{pkg}_{date}` | Long | Accumulated ms for app that calendar day |
| `open_count_{pkg}_{date}` | Int | App opens that calendar day |
| `unlock_count_{date}` | Int | Device unlocks that calendar day |
| `device_daily_ms_{date}` | Long | Total device usage that calendar day |
| `device_hourly_ms_{date}_{h}` | Long | Total device ms in hour h (0–23) |
| `hourly_opens_{pkg}_{date}_{h}` | Int | Per-app opens in hour h |
| `hourly_unlocks_{date}_{h}` | Int | Device unlocks in hour h |
| `session_bucket_{i}_{date}` | Int | Session count for bucket i (0=<1m 1=1-5m 2=5-15m 3=>15m) |
| `packages_index_{date}` | String (JSON) | Package names active on that date — avoids O(n_keys) scan |
| `disabled_apps` | String (JSON) | Packages with overlay disabled |
| `onboarding_done` | Boolean | Whether onboarding has been completed |
| `language_code` | String? | `null`=system · `"pt"` · `"en"` |
| `goal_level` | Int | 0=none 1=minimal 2=normal 3=extensive |
| `app_goal_{pkg}` | Int | Per-app goal override; 0=inherit global |
| `current_pkg` | String | Foreground package right now (written each tick) |
| `current_session_start_ms` | Long | Epoch ms when current session began |

---

## MethodChannel API — `"apptime/service"`

| Method | Direction | Description |
|--------|-----------|-------------|
| `getStartupStatus` | Dart→Kotlin | Returns `{overlayGranted, usageGranted, isRunning}` — single startup round-trip |
| `getAppMetadata` | Dart→Kotlin | Returns `{labels: Map<String,String>, launchers: List<String>}` — merged call |
| `startMonitoring` | Dart→Kotlin | Starts MonitoringService + OverlayService |
| `stopMonitoring` | Dart→Kotlin | Stops both services |
| `isRunning` | Dart→Kotlin | Returns Boolean (uses MonitoringService.isRunning static flag) |
| `requestOverlayPermission` | Dart→Kotlin | Opens system overlay permission screen |
| `hasOverlayPermission` | Dart→Kotlin | Returns Boolean |
| `requestUsagePermission` | Dart→Kotlin | Opens usage access settings |
| `hasUsagePermission` | Dart→Kotlin | Returns Boolean |

---

## Key Invariants

- **4am day boundary**: all date keys (`YYYY-MM-DD`) represent the 24h window starting at 04:00. `epochToDateKey()` (Kotlin) and `dayAnchor()` (Dart) implement this consistently. Cross-midnight sessions are split at the 4am boundary.
- **Single source of truth**: `kPassivePatterns` (Dart) and `AppConstants.SOCIAL_PATTERNS` (Kotlin) reference the same canonical string values. `kAppMeta` is the sole source for app labels and colors.
- **GoalThresholds parity**: enforced by `test/goal_thresholds_test.dart` (3 assertions, one per level).
- **Daily total == sum of hourly values**: `accumulateDailyMs` accumulates daily totals within the hourly walk loop.
- **Heartbeat granularity**: written every 30s (not 1s) — sufficient for gap detection; reduces disk writes by 30×.

---

## Test files — `test/`

| File | What it tests |
|------|--------------|
| `goal_thresholds_test.dart` | Dart/Kotlin GoalThresholds values parity (3 levels × 6 fields) |
| `widget_test.dart` | App smoke test — nav tabs render |

---

## Tech stack

| Layer | Technology |
|-------|------------|
| UI | Flutter / Dart — Android only, min SDK 23 |
| Overlay + monitoring | Kotlin native services |
| Storage | SharedPreferences |
| Charts | fl_chart ^0.70.2 |
| Icons (dev) | flutter_launcher_icons ^0.14.3 |

**Theme:** primary #4F6EF7 · surface #F7F8FC / #1A1D2E · card white / #242740 · success #34D399 · error #F87171  
**Spacing:** XS=4 SM=8 MD=16 LG=24 XL=32 · Radius: SM=8 MD=12 LG=16 XL=24 · Material3, light/dark auto
