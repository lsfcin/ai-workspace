# AppTime — Refactor Plan

Sorted highest to lowest impact. Tick `-` → `x` as each item is completed.
Goal: reorganize and harden without losing any feature or causing regressions.

---

## Priority 1 — Critical divergence risks (correctness)

- [ ] **R1. Unify passive/social patterns into one source of truth.**
  Three divergent lists: `analytics_screen._passivePatterns` (19), `insights_screen._passivePatterns` (16), `OverlayService.SOCIAL_PATTERNS` (Kotlin). Extract to `lib/utils/app_info.dart` as `const kPassivePatterns`. Have `AnalyticsService`, `InsightsScreen`, and `OverlayService` all reference the same list (pass via prefs or a shared Kotlin file for the Kotlin side).

- [ ] **R2. Extract GoalThresholds to a single JSON config; generate both Dart and Kotlin from it.**
  As an interim step before codegen: add a unit test that parses both files and asserts the threshold values match. Prevents silent cross-platform divergence. Long-term: a `goal_thresholds.json` consumed by both build systems.

- [ ] **R3. Fix `accumulateDailyMs` daily total cross-4am session attribution.**
  When a session spans midnight–04:00, the `dailyKey` currently uses `endDate`. Split daily credit at the 4am boundary (same logic already applied for hourly splits). This ensures `device_daily_ms_{date}` matches the sum of its hourly values.

---

## Priority 2 — Global state and coupling

- [ ] **R4. Replace `_dynamicLabels`/`_dynamicLaunchers` module globals with an injectable `AppInfoService`.**
  Create `lib/services/app_info_service.dart` holding labels + launchers as instance state. Inject it at the `MainScreen` level; pass down or provide via `InheritedWidget`. Eliminates silent "labels not seeded yet" bugs and the duplicate `_loadAppLabels`/`_seedLabels` calls in MonitoringScreen and AnalyticsScreen.

- [ ] **R5. Merge `getInstalledAppLabels()` + `getLaunchers()` into a single `getAppMetadata()` channel call.**
  Currently two round-trips fired together every time. Combine on Kotlin side into one method returning `Map<String, Any>` with `labels` and `launchers` keys. Update `ServiceChannel.dart` and `MainActivity.kt`.

- [ ] **R6. Extract channel name `'apptime/service'` to a shared constant.**
  Define `const kServiceChannel = 'apptime/service'` in `service_channel.dart`. In Kotlin: `private const val CHANNEL = "apptime/service"` in `MainActivity.kt`. Prevents silent string mismatch.

---

## Priority 3 — Date/time utilities (8 duplicates)

- [ ] **R7. Centralize 4am day-boundary date helpers into `lib/utils/date_utils.dart`.**
  Create `dayAnchor()`, `todayKey()`, `yesterdayKey()`, `fmtDate(DateTime)` functions. Remove duplicated implementations in `StorageService`, `AnalyticsService`, `analytics_screen.dart`, `insights_screen.dart`, `monitoring_screen.dart`. Update all call sites to import `date_utils.dart`.

- [ ] **R8. Centralize `today()`, `currentHour()`, `safeGetCount()` in a shared `DateUtils.kt`.**
  Both `MonitoringService.kt` and `OverlayService.kt` define identical copies. Extract to a `DateUtils.kt` companion or top-level functions.

---

## Priority 4 — App metadata consolidation

- [ ] **R9. Merge `kAppLabels` + `kAppColors` into a single `kAppMeta: Map<String, AppMeta>` structure.**
  `AppMeta(label: String, color: Color)`. Guarantees every package has both or neither. Eliminates the risk of a package in one map but missing from the other.

- [ ] **R10. Remove `_kAppColors` from `analytics_screen.dart`.**
  After R9, `analytics_screen.dart` should call `colorForApp(pkg)` from `app_info.dart`. Delete the local copy.

- [ ] **R11. Remove `_labelForApp()` wrapper in `analytics_screen.dart`.**
  It's a one-liner wrapping `labelForApp()` from `app_info.dart`. Remove and call `labelForApp()` directly.

---

## Priority 5 — Kotlin SharedPreferences hygiene

- [ ] **R12. Cache SharedPreferences instance in `OverlayService`.**
  Store `prefs` as a `lateinit var` in `OverlayService`, initialized once in `onCreate()`. Remove `getSharedPreferences()` calls inside `updateOverlay()` and `evaluateFeedbacks()`.

- [ ] **R13. Cache `PowerManager` in `MonitoringService`.**
  `getSystemService(POWER_SERVICE)` called every tick. Cache as a lateinit field in `onCreate()`.

- [ ] **R14. Move `LAUNCHERS` and `parseDisabledApps()` to `AppConstants.kt`.**
  Eliminates `OverlayService` depending on `MonitoringService`'s companion object. Both services import `AppConstants`.

---

## Priority 6 — Flutter-side structural improvements

- [ ] **R15. Extract shared `SectionHeader` widget to `lib/widgets/section_header.dart`.**
  Identical private `_SectionHeader` exists in both `monitoring_screen.dart` and `settings_screen.dart`.

- [ ] **R16. Extract `_fmtMs` / `_fmtDuration` to a shared `lib/utils/time_utils.dart`.**
  Unify duration formatting (currently `'${min}m'` vs `'${totalMin}min'`). Pick one format; update all call sites.

- [ ] **R17. Fix double `kAppLabels` lookup in `_labelFor()` (monitoring_screen).**
  `_labelFor(pkg)` checks `kAppLabels[pkg]` then calls `labelForApp(pkg)`, which checks `kAppLabels` again. Remove the first check; call `labelForApp(pkg)` directly (which already checks `kAppLabels` first).

- [ ] **R18. Fix double `languageCode` write on locale change.**
  `_changeLocale` in `settings_screen.dart` writes `_s.languageCode` AND calls `onLocaleChange()` which writes it again in `_AppTimeAppState._setLocale`. Remove one of the two writes.

---

## Priority 7 — Dead code removal

- [ ] **R19. Remove `dailyGoalMinutes` from `StorageService`.**
  Never read by any screen. The goal system uses `goalLevel` + `GoalThresholds`. Delete getter, setter, and the prefs key from `deleteAllData()`.

- [ ] **R20. Remove `AppColors.primaryDark` from `app_theme.dart`.**
  Defined, never referenced.

- [ ] **R21. Remove `permission_handler` from `pubspec.yaml`.**
  Listed as a dependency but never imported in any Dart file. App uses `ServiceChannel` for permissions.

- [ ] **R22. Remove legacy `getLast24hMs`, `getDeviceLast24hMs`, `getUnlockLast24h` aliases from `StorageService`.**
  These delegate to `getTodayMs` etc. Update `AnalyticsService` to call the canonical names directly, then delete the aliases.

- [ ] **R23. Remove or reassign dead l10n keys.**
  `navHome`, `dailyGoalTitle`/`goalMinutesPerDay`/`dialogDailyGoalTitle` group (minute-picker goal, unused), `perAppTitle`/`goalPerAppTitle`/`goalPerAppSub`/`overlayDisabled`/`overlayActive` (reference screens no longer in the nav).

---

## Priority 8 — Safety and correctness fixes

- [ ] **R24. Add `canLaunchUrl` guard in MonitoringScreen's `_InsightCard`.**
  `insights_screen.dart` already guards with `canLaunchUrl`. Apply the same pattern in `monitoring_screen.dart`'s `_InsightCard.onTap`.

- [ ] **R25. Fix `_setLocale(null)` comment vs implementation.**
  Comment says "revert to system locale" but code falls back to hardcoded `Locale('pt')`. Either implement real system locale detection or update the comment/UI label to say "reset to Portuguese".

- [ ] **R26. Rename `_InsightCard` in `monitoring_screen.dart`.**
  Collides (conceptually) with `_InsightCard` in `insights_screen.dart` — both private, both named the same, different signatures. Rename the monitoring one to `_InsightRotatorCard` or similar.

- [ ] **R27. Fix `isSystemPkg` typo: `com.android.documentsuI` → `com.android.documentsui`.**
  Capital I at end is a typo. Results in the Files app not being correctly classified as a system pkg.

- [ ] **R28. Replace deprecated `ActivityManager.getRunningServices()` in `MainActivity.kt`.**
  Use a static boolean flag in `MonitoringService` (`isRunning: Boolean`) to check service state instead of the deprecated API.

- [ ] **R29. Set explicit `minSdkVersion 23` in `build.gradle.kts`.**
  Current `flutter.minSdkVersion` likely resolves to 21. The app uses `TYPE_APPLICATION_OVERLAY` and `AppOpsManager.OPSTR_GET_USAGE_STATS` which require API 23. An explicit declaration prevents installs on incompatible devices.

---

## Priority 9 — Minor quality

- [ ] **R30. Localise `_sevenDayLabel()` weekday abbreviations in `analytics_screen.dart`.**
  Currently hardcoded Portuguese: `['seg', 'ter', 'qua', ...]`. Should derive from `AppLocalizations` or Dart's `intl` package.

- [ ] **R31. Localise the `'2h ideal'` / `'4h crítico'` reference-line labels in `_UsageTrend30d`.**
  Hardcoded Portuguese strings bypassing `AppLocalizations`.

- [ ] **R32. Migrate `_classificationMessage()` in `analytics_screen.dart` through `AppLocalizations`.**
  Currently a 5×4 closure matrix with inlined PT/EN string literals. Move strings to `app_localizations_pt.dart` / `app_localizations_en.dart` and call via `AppLocalizations.of(context)`.

- [ ] **R33. Localise `kInsights` (insights rotator) to English.**
  All 50 entries in `data/insights.dart` are Portuguese only. Add English versions or load from `AppLocalizations`.

- [ ] **R34. Add English versions of `_alertas` / `_solucoes` in `insights_screen.dart`.**
  Currently Portuguese-only content — English users see PT text.

- [ ] **R35. Document `migrateCorruptedDeviceDaily()` run-every-start behavior.**
  Add comment explaining why it is safe to run repeatedly and what the 23h threshold represents. Consider changing to run-once with a migration flag.

- [ ] **R36. Document `REOPEN_TOLERANCE_MS = 120_000L` tradeoff in `MonitoringService.kt`.**
  2-minute tolerance means returning after 90s doesn't count as a new open. This is intentional but surprising — add a comment with the tradeoff.
