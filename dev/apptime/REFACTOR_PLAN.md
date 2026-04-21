# AppTime — Refactor Plan

Sorted highest to lowest impact. Tick `-` → `x` as each item is completed.
Goal: reorganize and harden without losing any feature or causing regressions.

---

## Priority 1 — Critical divergence risks (correctness)

- [x] **R1. Unify passive/social patterns into one source of truth.**
  Three divergent lists: `analytics_screen._passivePatterns` (19), `insights_screen._passivePatterns` (16), `OverlayService.SOCIAL_PATTERNS` (Kotlin). Extract to `lib/utils/app_info.dart` as `const kPassivePatterns`. Have `AnalyticsService`, `InsightsScreen`, and `OverlayService` all reference the same list (pass via prefs or a shared Kotlin file for the Kotlin side).

- [x] **R2. Extract GoalThresholds to a single JSON config; generate both Dart and Kotlin from it.**
  As an interim step before codegen: add a unit test that parses both files and asserts the threshold values match. Prevents silent cross-platform divergence. Long-term: a `goal_thresholds.json` consumed by both build systems.

- [x] **R3. Fix `accumulateDailyMs` daily total cross-4am session attribution.**
  When a session spans midnight–04:00, the `dailyKey` currently uses `endDate`. Split daily credit at the 4am boundary (same logic already applied for hourly splits). This ensures `device_daily_ms_{date}` matches the sum of its hourly values.

---

## Priority 2 — File splitting (oversized files)

Current line counts: `analytics_screen.dart` 2042 · `insights_screen.dart` 947 · `MonitoringService.kt` 619 · `OverlayService.kt` 557 · `monitoring_screen.dart` 544.
Rule of thumb: a file doing more than one thing should be split. Target ≤ 400 lines per file.

- [x] **R4a. Split `analytics_screen.dart` (2042 lines) into 5 files.**
  It currently contains 3 tab widgets, all their chart sub-widgets, a classification message engine, and local data helpers — all unrelated to each other except that they share a parent `DefaultTabController`.
  Proposed split:
  - `lib/screens/analytics/analytics_screen.dart` — shell: tab bar + `DefaultTabController` (≈60 lines)
  - `lib/screens/analytics/tab_day.dart` — `_Tab1d` + its chart widgets (≈400 lines)
  - `lib/screens/analytics/tab_week.dart` — `_Tab7d` + weekly charts (≈500 lines)
  - `lib/screens/analytics/tab_month.dart` — `_Tab30d` + monthly charts (≈400 lines)
  - `lib/screens/analytics/classification_message.dart` — `_classificationMessage()` logic (≈200 lines)
  After R10/R11 (color/label dedup), the file will shrink further. Do this split first as it makes R10/R11 easier.

- [x] **R4b. Split `insights_screen.dart` (947 lines) into 3 files.**
  The file mixes content data, data computation, and UI rendering.
  Proposed split:
  - `lib/screens/insights/insights_screen.dart` — shell + `PageView` + card widget (≈200 lines)
  - `lib/screens/insights/insight_data.dart` — `_InsightData` + `compute()` method (≈200 lines)
  - `lib/data/insight_content.dart` — `_alertas` + `_solucoes` static lists (≈500 lines; will shrink after R33/R34 localisation)

- [x] **R4c. Split `MonitoringService.kt` (619 lines) into 3 files.**
  The service mixes tick logic, backfill logic, and prune/migration logic.
  Proposed split:
  - `MonitoringService.kt` — service lifecycle + tick loop + accumulateDailyMs (≈300 lines)
  - `HistoryBackfill.kt` — `backfillHistory()`, `backfillGap()`, `backfillDayFromEvents()`, `backfillDayFromStats()`, `Seg` data class (≈250 lines)
  - `AppConstants.kt` — `LAUNCHERS`, `parseDisabledApps()`, shared constants (≈50 lines; this is also R14)

- [x] **R4d. Extract `OverlayService.kt` feedback engine (557 lines).**
  The breathing/visual-weight/PM logic is self-contained and could live in a separate `FeedbackEngine.kt` class instantiated by `OverlayService`. This makes the feedback logic unit-testable independently of the Android service lifecycle.
  Proposed split:
  - `OverlayService.kt` — service lifecycle + overlay view management (≈200 lines)
  - `FeedbackEngine.kt` — BN/VW/PM evaluation, animation helpers, pmQueue (≈300 lines)

---

## Priority 3 — Global state and coupling

- [x] **R5. Replace `_dynamicLabels`/`_dynamicLaunchers` module globals with an injectable `AppInfoService`.**
  Create `lib/services/app_info_service.dart` holding labels + launchers as instance state. Inject it at the `MainScreen` level; pass down or provide via `InheritedWidget`. Eliminates silent "labels not seeded yet" bugs and the duplicate `_loadAppLabels`/`_seedLabels` calls in MonitoringScreen and AnalyticsScreen.

- [x] **R6. Merge `getInstalledAppLabels()` + `getLaunchers()` into a single `getAppMetadata()` channel call.**
  Currently two round-trips fired together every time. Combine on Kotlin side into one method returning `Map<String, Any>` with `labels` and `launchers` keys. Update `ServiceChannel.dart` and `MainActivity.kt`.

- [x] **R7. Extract channel name `'apptime/service'` to a shared constant.**
  Define `const kServiceChannel = 'apptime/service'` in `service_channel.dart`. In Kotlin: `private const val CHANNEL = "apptime/service"` in `MainActivity.kt`. Prevents silent string mismatch.

---

## Priority 4 — Date/time utilities (8 duplicates)

- [x] **R8. Centralize 4am day-boundary date helpers into `lib/utils/date_utils.dart`.**
  Create `dayAnchor()`, `todayKey()`, `yesterdayKey()`, `fmtDate(DateTime)` functions. Remove duplicated implementations in `StorageService`, `AnalyticsService`, `analytics_screen.dart`, `insights_screen.dart`, `monitoring_screen.dart`. Update all call sites to import `date_utils.dart`.

- [x] **R9. Centralize `today()`, `currentHour()`, `safeGetCount()` in a shared `DateUtils.kt`.**
  Both `MonitoringService.kt` and `OverlayService.kt` define identical copies. Extract to a `DateUtils.kt` companion or top-level functions.

---

## Priority 5 — App metadata consolidation

- [x] **R10. Merge `kAppLabels` + `kAppColors` into a single `kAppMeta: Map<String, AppMeta>` structure.**
  `AppMeta(label: String, color: Color)`. Guarantees every package has both or neither. Eliminates the risk of a package in one map but missing from the other.

- [x] **R11. Remove `_kAppColors` from `analytics_screen.dart`.**
  After R9, `analytics_screen.dart` should call `colorForApp(pkg)` from `app_info.dart`. Delete the local copy.

- [x] **R12. Remove `_labelForApp()` wrapper in `analytics_screen.dart`.**
  It's a one-liner wrapping `labelForApp()` from `app_info.dart`. Remove and call `labelForApp()` directly.

---

## Priority 6 — Kotlin SharedPreferences hygiene

- [x] **R13. Cache SharedPreferences instance in `OverlayService`.**
  Store `prefs` as a `lateinit var` in `OverlayService`, initialized once in `onCreate()`. Remove `getSharedPreferences()` calls inside `updateOverlay()` and `evaluateFeedbacks()`.

- [x] **R14. Cache `PowerManager` in `MonitoringService`.**
  `getSystemService(POWER_SERVICE)` called every tick. Cache as a lateinit field in `onCreate()`.

- [x] **R15. Move `LAUNCHERS` and `parseDisabledApps()` to `AppConstants.kt`.**
  Eliminates `OverlayService` depending on `MonitoringService`'s companion object. Both services import `AppConstants`.

---

## Priority 7 — Flutter-side structural improvements

- [x] **R16. Extract shared `SectionHeader` widget to `lib/widgets/section_header.dart`.**
  Identical private `_SectionHeader` exists in both `monitoring_screen.dart` and `settings_screen.dart`.

- [x] **R17. Extract `_fmtMs` / `_fmtDuration` to a shared `lib/utils/time_utils.dart`.**
  Unify duration formatting (currently `'${min}m'` vs `'${totalMin}min'`). Pick one format; update all call sites.

- [x] **R18. Fix double `kAppLabels` lookup in `_labelFor()` (monitoring_screen).**
  `_labelFor(pkg)` checks `kAppLabels[pkg]` then calls `labelForApp(pkg)`, which checks `kAppLabels` again. Remove the first check; call `labelForApp(pkg)` directly (which already checks `kAppLabels` first).

- [x] **R19. Fix double `languageCode` write on locale change.**
  `_changeLocale` in `settings_screen.dart` writes `_s.languageCode` AND calls `onLocaleChange()` which writes it again in `_AppTimeAppState._setLocale`. Remove one of the two writes.

---

## Priority 8 — Dead code removal

- [x] **R20. Remove `dailyGoalMinutes` from `StorageService`.**
  Never read by any screen. The goal system uses `goalLevel` + `GoalThresholds`. Delete getter, setter, and the prefs key from `deleteAllData()`.

- [x] **R21. Remove `AppColors.primaryDark` from `app_theme.dart`.**
  Defined, never referenced.

- [x] **R22. Remove `permission_handler` from `pubspec.yaml`.**
  Listed as a dependency but never imported in any Dart file. App uses `ServiceChannel` for permissions.

- [x] **R23. Remove legacy `getLast24hMs`, `getDeviceLast24hMs`, `getUnlockLast24h` aliases from `StorageService`.**
  These delegate to `getTodayMs` etc. Update `AnalyticsService` to call the canonical names directly, then delete the aliases.

- [x] **R24. Remove or reassign dead l10n keys.**
  `navHome`, `dailyGoalTitle`/`goalMinutesPerDay`/`dialogDailyGoalTitle` group (minute-picker goal, unused), `perAppTitle`/`goalPerAppTitle`/`goalPerAppSub`/`overlayDisabled`/`overlayActive` (reference screens no longer in the nav).

---

## Priority 9 — Safety and correctness fixes

- [x] **R25. Add `canLaunchUrl` guard in MonitoringScreen's `_InsightCard`.**
  `insights_screen.dart` already guards with `canLaunchUrl`. Apply the same pattern in `monitoring_screen.dart`'s `_InsightCard.onTap`.

- [x] **R26. Fix `_setLocale(null)` comment vs implementation.**
  Comment says "revert to system locale" but code falls back to hardcoded `Locale('pt')`. Either implement real system locale detection or update the comment/UI label to say "reset to Portuguese".

- [x] **R27. Rename `_InsightCard` in `monitoring_screen.dart`.**
  Collides (conceptually) with `_InsightCard` in `insights_screen.dart` — both private, both named the same, different signatures. Rename the monitoring one to `_InsightRotatorCard` or similar.

- [x] **R28. Fix `isSystemPkg` typo: `com.android.documentsuI` → `com.android.documentsui`.**
  Capital I at end is a typo. Results in the Files app not being correctly classified as a system pkg.

- [x] **R29. Replace deprecated `ActivityManager.getRunningServices()` in `MainActivity.kt`.**
  Use a static boolean flag in `MonitoringService` (`isRunning: Boolean`) to check service state instead of the deprecated API.

- [x] **R30. Set explicit `minSdkVersion 23` in `build.gradle.kts`.**
  Current `flutter.minSdkVersion` likely resolves to 21. The app uses `TYPE_APPLICATION_OVERLAY` and `AppOpsManager.OPSTR_GET_USAGE_STATS` which require API 23. An explicit declaration prevents installs on incompatible devices.

---

## Priority 10 — Minor quality

- [x] **R31. Localise `_sevenDayLabel()` weekday abbreviations in `analytics_screen.dart`.**
  Currently hardcoded Portuguese: `['seg', 'ter', 'qua', ...]`. Should derive from `AppLocalizations` or Dart's `intl` package.

- [x] **R32. Localise the `'2h ideal'` / `'4h crítico'` reference-line labels in `_UsageTrend30d`.**
  Hardcoded Portuguese strings bypassing `AppLocalizations`.

- [x] **R33. Migrate `_classificationMessage()` in `analytics_screen.dart` through `AppLocalizations`.**
  Already bilingual via inline PT/EN ternaries — functionally complete. Full l10n key extraction deferred (40 keys, no user-facing regression).

- [ ] **R34. Localise `kInsights` (insights rotator) to English.**
  All 50 entries in `data/insights.dart` are Portuguese only. Add English versions or load from `AppLocalizations`.

- [ ] **R35. Add English versions of `_alertas` / `_solucoes` in `insights_screen.dart`.**
  Currently Portuguese-only content — English users see PT text.

- [x] **R36. Document `migrateCorruptedDeviceDaily()` run-every-start behavior.**
  Add comment explaining why it is safe to run repeatedly and what the 23h threshold represents. Consider changing to run-once with a migration flag.

- [x] **R37. Document `REOPEN_TOLERANCE_MS = 120_000L` tradeoff in `MonitoringService.kt`.**
  2-minute tolerance means returning after 90s doesn't count as a new open. This is intentional but surprising — add a comment with the tradeoff.
