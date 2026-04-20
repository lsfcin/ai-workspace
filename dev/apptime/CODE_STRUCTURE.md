# AppTime — Code Structure Blueprint

> Navigation reference for future sessions. Consult before editing any module.
> Update this file whenever modules, responsibilities, or data-flow change.

---

## Module Map

```
dev/apptime/
├── lib/
│   ├── main.dart                   [ENTRY]
│   ├── main_screen.dart            [NAV SHELL]
│   ├── screens/
│   │   ├── settings_screen.dart    [SETTINGS + PERMISSIONS]
│   │   ├── monitoring_screen.dart  [PER-APP CONTROLS]
│   │   ├── analytics_screen.dart   [CHARTS + ANALYTICS]
│   │   └── insights_screen.dart    [RESEARCH CAROUSEL]
│   ├── services/
│   │   ├── analytics_service.dart  [DATA ASSEMBLY]
│   │   ├── storage_service.dart    [PREFS WRAPPER]
│   │   └── service_channel.dart    [FLUTTER→KOTLIN RPC]
│   ├── models/
│   │   └── goal_config.dart        [GOAL ENUM + THRESHOLDS (Dart)]
│   ├── utils/
│   │   └── app_info.dart           [APP LABEL/COLOR/CLASSIFICATION]
│   ├── data/
│   │   └── insights.dart           [STATIC INSIGHT ENTRIES]
│   ├── theme/
│   │   └── app_theme.dart          [DESIGN TOKENS]
│   └── l10n/
│       ├── app_localizations.dart  [I18N CONTRACT]
│       ├── app_localizations_pt.dart
│       └── app_localizations_en.dart
└── android/app/src/main/kotlin/com/lsf/apptime/
    ├── MainActivity.kt             [FLUTTER ENTRY + CHANNEL HANDLER]
    ├── MonitoringService.kt        [FOREGROUND SERVICE: data collection]
    ├── OverlayService.kt           [FOREGROUND SERVICE: floating overlay]
    ├── GoalThresholds.kt           [GOAL THRESHOLDS (Kotlin mirror)]
    ├── PmMessages.kt               [PERSONALIZED MESSAGE STRINGS]
    └── BootReceiver.kt             [BOOT → start MonitoringService]
```

---

## Data Flow

```
[Android OS]
    └── UsageStatsManager.queryEvents()
            │
            ▼
    MonitoringService.kt (1s poll)
        - Accumulates daily/hourly ms per pkg + device
        - Counts unlocks, session opens
        - Writes: SharedPreferences (FlutterSharedPreferences)
        - Starts/restarts OverlayService every 30 ticks
            │
            ▼
    SharedPreferences ←──────────────────────── Flutter StorageService (reads/writes)
            │
            ▼
    OverlayService.kt (500ms poll)
        - Reads overlay_text, overlay_visible, current_pkg from prefs
        - Evaluates goal feedback: BN / VW / PM
        - Updates floating TextView appearance

[Flutter UI]
    main.dart → StorageService.init() → runApp(AppTimeApp)
        │
        ├── SettingsScreen    (permissions, toggles, goal level selection)
        ├── MonitoringScreen  (per-app enable/disable, goal override, insight rotator)
        ├── AnalyticsScreen   (1d/7d/30d charts, classification message)
        └── InsightsScreen    (research carousel, _InsightData.compute on build)

[Flutter → Kotlin RPC via 'apptime/service' channel]
    ServiceChannel.startMonitoring()
    ServiceChannel.stopMonitoring()
    ServiceChannel.isRunning()
    ServiceChannel.hasOverlayPermission() / requestOverlayPermission()
    ServiceChannel.hasUsagePermission()   / requestUsagePermission()
    ServiceChannel.getInstalledAppLabels() → Map<String,String>
    ServiceChannel.getLaunchers()          → Set<String>
```

---

## SharedPreferences Key Schema

All keys are prefixed `flutter.` on the Android side (Flutter plugin convention).
Kotlin must use `getLong()` not `getInt()` — Flutter stores ints as Long.

```
Overlay state (written by Flutter, read by OverlayService):
  overlay_text                 String
  overlay_visible              Boolean
  overlay_enabled              Boolean
  overlay_font_size            Int (was Double — handled by readFloat() in Kotlin)
  overlay_top_dp               Int
  overlay_show_border          Boolean (default: true)
  overlay_show_background      Boolean (default: true)

Monitoring output (written by MonitoringService, read by Flutter):
  daily_ms_{pkg}_{date}        Long   — per-app daily usage
  open_count_{pkg}_{date}      Int
  hourly_ms_{pkg}_{date}_{h}   Long   — per-app per-hour usage
  hourly_opens_{pkg}_{date}_{h}Int
  device_daily_ms_{date}       Long   — total device daily usage
  device_hourly_ms_{date}_{h}  Long
  unlock_count_{date}          Int
  hourly_unlocks_{date}_{h}    Int
  session_bucket_{0..3}_{date} Int    — 0:<1min 1:1-5min 2:5-15min 3:>15min
  current_pkg                  String — currently active package
  current_session_start_ms     Long

Control signals (written by Flutter, read by MonitoringService/OverlayService):
  disabled_apps                String (JSON array)
  monitor_launcher             Boolean
  goal_level                   Int    — 0=none 1=light 2=moderate 3=intense
  app_goal_{pkg}               Int    — per-app override; -1=off, 0=global

Lifecycle:
  monitoring_heartbeat_ms      Long   — last tick timestamp
  history_backfill_ts          Long   — last backfill run timestamp
  onboarding_done              Boolean
  monitoring_ever_started      Boolean

Settings:
  language_code                String — "pt" or "en"
  daily_goal_minutes           Int    — UNUSED, dead code
```

Date key format: `YYYY-MM-DD` anchored at 04:00 (not midnight).
`date` in key names = `today()` in Kotlin / `_todayKey()` in StorageService.

---

## Module Responsibilities

### `main.dart`
- Init `StorageService`, detect locale, decide onboarding vs main app
- Auto-starts MonitoringService if permissions already granted
- Provides `_setLocale` callback down to `SettingsScreen`

### `main_screen.dart`
- `IndexedStack` of 4 tabs: Settings(0), Monitoring(1), Analytics(2), Insights(3)
- All 4 screens instantiated at startup and kept alive forever
- Passes `storage` and `onLocaleChange` down

### `settings_screen.dart`
- Permission status display (overlay + usage stats)
- Start/stop monitoring button
- Overlay appearance toggles (border, background, font size, position)
- Language selector
- Delete-all-data action
- Privacy policy link

### `monitoring_screen.dart`
- Goal level selector (global)
- Per-app list: enable/disable, per-app goal override
- Insight-of-the-day rotator (rotates every 3 min from `kInsights`)
- Seeds `_dynamicLabels` + `_dynamicLaunchers` globals on init

### `analytics_screen.dart`
- Tab 1d: yesterday stacked-bar pattern, session distribution, opens
- Tab 7d: 7-day stacked pattern chart, weekly trend, previous-week comparison
- Tab 30d: 30-day usage trend line, engagement donut, top-apps list
- `_classificationMessage()`: 5×4 matrix of behavioural classification strings
- Seeds `_dynamicLabels` + `_dynamicLaunchers` on init (duplicate of monitoring_screen)

### `insights_screen.dart`
- Paginated carousel: _alertas (alerts) + _solucoes (solutions)
- `_InsightData.compute(storage)`: computes user metrics for personalised message
  - Runs synchronously in `build()` — 200-400 prefs reads per call
- `_passivePatterns` list (16 entries) — NOTE: diverges from analytics_screen (19)

### `storage_service.dart`
- Typed wrapper over SharedPreferences
- All prefs reads/writes go through this class from Dart side
- Contains: `_dayAnchor()`, `_todayKey()`, `_yesterdayKey()`, `_fmt()` — 4am boundary helpers
- Legacy aliases: `getLast24hMs` → `getTodayMs`, etc.
- `packagesDailyMs()` and `packagesLast24h()` scan all prefs keys — O(n_keys)

### `analytics_service.dart`
- Assembles `DaySummary` and `AppUsage` objects for N days
- Thin aggregation layer over StorageService
- Duplicates `_anchor()` / `_fmt()` date logic

### `service_channel.dart`
- Static Flutter→Kotlin bridge over `'apptime/service'` method channel
- `getInstalledAppLabels()` and `getLaunchers()` are always called together
  → should be one combined call

### `app_info.dart`
- `kAppLabels`: 96 static package→label entries
- `kAppColors`: 96 static package→color entries (parallel to kAppLabels)
- `_dynamicLabels`, `_dynamicLaunchers`: module-level mutable globals, seeded at runtime
- `isUserFacingApp(pkg)`: main filter — returns false for launchers, system processes
- `isLauncherPkg(pkg)`: checks dynamic set + hardcoded patterns + `.launcher`/`.home` suffix
- `isSystemPkg(pkg)`: checks known system package list + prefix patterns

### `goal_config.dart`
- `GoalLevel` enum: none(0), minimal/Light(1), normal/Moderate(2), extensive/Intense(3)
- `GoalThresholds.byLevel` table — **must stay in sync with GoalThresholds.kt**
- Thresholds: Light=relaxed(240min phone), Moderate=150min, Intense=strict(90min)

### `insights.dart`
- `kInsights`: 50 `InsightEntry` objects (text + URL) — Portuguese only
- Used by MonitoringScreen rotator (every 3 min, not daily)
- Distinct from `_alertas`/`_solucoes` in insights_screen.dart

### `app_theme.dart`
- `AppColors`: primary(0xFF4F6EF7), surfaceLight, surfaceDark, cardDark, success, error
- `AppSpacing`: xs=4, sm=8, md=16, lg=24, xl=32
- `AppRadius`: sm/md/lg/xl
- `AppTheme.light()` / `.dark()` — Material3 ThemeData

### `MonitoringService.kt`
- 1-second tick loop (main thread)
- Detects foreground app via `UsageStatsManager.queryEvents()`
- Accumulates: daily/hourly ms, opens, unlocks, session buckets
- `backfillHistory()`: 30-day backfill on startup (background thread, once/23h)
- `backfillGap()`: fills today's gap from last heartbeat on startup
- `effectiveLaunchers`: LAUNCHERS set + resolved default launcher at runtime
- Watchdog: every 30 ticks refreshes default launcher, restarts OverlayService

### `OverlayService.kt`
- 500ms poll, separate from MonitoringService
- Three feedback systems:
  - **BN (Breathing Nudge)**: alpha fade cycle when session exceeds threshold
  - **VW (Visual Weight)**: font scale proportional to daily % over limit
  - **PM (Personalized Message)**: replaces timer text for 20s, 60s cooldown
- `pmQueue`: list of triggered messages; `pmQueueIdx` cycles through them
- `SOCIAL_PATTERNS`: list for wakeup-social detection — diverges from Flutter side

### `GoalThresholds.kt`
- Mirror of `goal_config.dart` — must be manually kept in sync
- `NONE` sentinel: Int.MAX_VALUE for all limits

### `PmMessages.kt`
- 6 trigger messages in PT and EN
- `appLimitExceeded` uses `pkg.split(".").last()` for app name — can produce bad labels

### `MainActivity.kt`
- Flutter method channel handler
- `getInstalledApps`: CATEGORY_LAUNCHER query (returns all user-visible apps)
- `getLaunchers`: ACTION_MAIN + CATEGORY_HOME + resolveActivity (MATCH_DEFAULT_ONLY)

### `BootReceiver.kt`
- Starts MonitoringService only on boot — OverlayService not started until app opened

---

## Cross-Cutting Issues (for navigation/investigation)

### Critical Redundancies

| Issue | Files | Risk |
|---|---|---|
| 4am day-boundary date format | StorageService, AnalyticsService, analytics_screen, insights_screen, monitoring_screen, MonitoringService.kt, OverlayService.kt | 8 copies — divergence if any changes |
| `_passivePatterns` / `SOCIAL_PATTERNS` | analytics_screen.dart(19), insights_screen.dart(16), OverlayService.kt | 3 divergent lists — same user, different classifications |
| App brand colors | `kAppColors` in app_info.dart vs `_kAppColors` in analytics_screen.dart | Values partially differ |
| Goal threshold table | goal_config.dart ↔ GoalThresholds.kt | Manual sync — critical cross-platform risk |
| `today()`/`currentHour()`/`safeGetCount()` | MonitoringService.kt, OverlayService.kt | 2 copies each |
| `_SectionHeader` widget | monitoring_screen.dart, settings_screen.dart | Identical code |
| Duration formatter | `_fmtMs` (monitoring) vs `_fmtDuration` (analytics) | Divergent output format |
| Labels+launchers loading | MonitoringScreen._loadAppLabels, AnalyticsScreen._seedLabels | 2 independent channel call pairs |
| Method channel name `'apptime/service'` | service_channel.dart, MainActivity.kt | String literal — typo risk |

### Naming Confusions

- `kInsights` (MonitoringScreen rotator) ≠ `_Insight` (InsightsScreen carousel) — same word, different types
- `_InsightCard` exists in both monitoring_screen.dart and insights_screen.dart as private classes with different signatures
- `navHome` l10n key — no "Home" screen exists; dead key
- `effectiveLaunchers` (MonitoringService, mutable runtime set) vs `LAUNCHERS` (companion, static set) — easy to confuse
- `GoalLevel.minimal/normal/extensive` vs Kotlin comments `Light/Moderate/Intense` vs UI labels — 3 naming systems
- `packagesLast24h()` — actually returns today+yesterday packages, not last 24h

### Safety Flags

- `accumulateDailyMs()`: cross-midnight-to-4am session credits all to endDate in daily total (hourly splits correctly)
- `migrateCorruptedDeviceDaily()`: runs on every onStartCommand, silently wipes any daily total ≥ 23h
- Release build still uses debug signing (build.gradle.kts TODO comment)
- `minSdk` may resolve to 21 but app requires API 23 (`TYPE_APPLICATION_OVERLAY`, `AppOpsManager`)
- `launchUrl` without `canLaunchUrl` guard in MonitoringScreen's `_InsightCard`
- POST_NOTIFICATIONS: never explicitly requested at runtime — foreground services may silently fail on Android 13+ if notification permission denied

### Performance Hotspots

- `MonitoringService.tick()`: prefs.edit().apply() every 1s for heartbeat → 28K writes/8h
- `OverlayService`: getSharedPreferences() called every 500ms poll instead of caching
- `accumulateDailyMs()`: 5-6 separate prefs.edit().apply() per session close — should batch
- Analytics tabs are StatelessWidget — full prefs scan on every parent setState
- `_InsightData.compute()` in InsightsScreen.build(): 200-400 prefs reads synchronously
- `packagesDailyMs()` / `packagesLast24h()`: O(n_all_keys) scan on every call
- `_sortedPackages()` in MonitoringScreen: O(49n) double-loop

### Dead Code

- `dailyGoalMinutes` in StorageService — getter/setter, never read by any screen
- `AppColors.primaryDark` — defined, never referenced
- `permission_handler` pub dependency — never imported in Dart code
- `navHome` l10n key
- Several `goalScreen`/`perApp` l10n keys reference screens not in current 4-tab structure
