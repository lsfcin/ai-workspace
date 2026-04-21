# AppTime — Code Structure (post-refactor)

Last updated: 2026-04-21 (after full Refactor milestone)

---

## Flutter / Dart — `lib/`

```
lib/
├── main.dart                        # App entry point, AppTimeApp, _AppTimeAppState
├── main_screen.dart                 # MainScreen — bottom nav, AppInfoService init
│
├── data/
│   ├── insight_content.dart         # InsightEntry, kAlertas, kSolucoes (47 entries)
│   └── insights.dart                # InsightEntry (rotator), kInsights (50 entries)
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
│   │   └── insights_screen.dart    # InsightsScreen, _InsightCarousel, _InsightCard
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
| `MainActivity.kt` | Flutter MethodChannel handler — start/stop service, permissions, getAppMetadata |
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

## Key Invariants

- **4am day boundary**: all date keys (`YYYY-MM-DD`) represent the 24h window starting at 04:00. `epochToDateKey()` (Kotlin) and `dayAnchor()` (Dart) implement this consistently.
- **Single source of truth**: `kPassivePatterns` (Dart) and `AppConstants.SOCIAL_PATTERNS` (Kotlin) both reference the same canonical list via the same string values. `kAppMeta` is the sole source for app labels and colors.
- **GoalThresholds parity**: enforced by `test/goal_thresholds_test.dart` (3 assertions, one per level).
- **Daily total == sum of hourly values**: `accumulateDailyMs` accumulates daily totals within the hourly walk loop, ensuring cross-4am sessions are correctly split across day boundaries.

---

## Test files — `test/`

| File | What it tests |
|------|--------------|
| `goal_thresholds_test.dart` | Dart/Kotlin GoalThresholds values parity (3 levels × 6 fields) |
| `widget_test.dart` | App smoke test — nav tabs render |
