# AppTime — Condensed History

## M8 — Core fixes and monitoring model
x Stabilized overlay persistence; changed reporting concept from "Today" to "24h".
x Reworked overlay positioning/configuration; fixed directional placement issues.
x Investigated unblock counting, foreground-only usage accounting, and screen-locked usage inflation.

## M9 — Polish
x Added "Insight of the day" on HomeScreen with ~50 PT-BR texts and 3-minute rotation.
x Confirmed adaptive launcher icon support; documented edge cases (MIUI home behavior, reboot auto-start limitation, active session rollover).

## M10 — Analysis blocks
x Redesigned Analysis into 3 subtabs: 24h, 7 days, 30 days.
x Added 9 analysis blocks: Sleep Hygiene, Circadian Rhythm, Impulsivity Index, Focus Fragmentation, Engagement Balance, Dopamine Drain, Relapse/Trend Analysis, Opportunity Cost, Weekend Spike Pattern, Phubbing Alert.
x Added SharedPreferences schema for hourly usage, opens, unlocks, and session-duration buckets.

## M11 — Insights
x Built `InsightsScreen` with two tabs: **Alertas** and **Soluções**.
x Added 40 research-backed PT-BR cards; added rotating HomeScreen insight card linked to `lib/data/insights.dart`.

## M12 — Permissions onboarding
x Added first-launch onboarding and permission gating (Welcome → Overlay → Usage Stats).
x Auto-advances after permission grants; skips on later launches when both granted.

## M13 — Language support
x Added manual i18n via `AppLocalizations`; implemented PT-BR and EN-US localization files.
x Added `flutter_localizations`; persisted language choice via `StorageService.languageCode`; auto-detects system locale on first launch.
x Migrated all 6 screens away from hardcoded strings.

## M14 — Goals and dynamic overlay
x Added goal tiers (minimal/normal/extensive) in Kotlin + Dart mirrors; thresholds for 6 metrics.
x Rewrote overlay feedback into 3 behaviors: Breathing Nudge, Visual Weight, Personalized Message.
x Added per-app goal overrides; added GoalScreen with research rationale and threshold chips.

## M15 — Fixes and refinements
x Reworked personalized messages: same position as overlay, shorter/stronger copy, longer display.
x Changed Insights UI to carousel-style browsing; cards ordered by relevance.
x Added weekly grid/horizontal stacked-hour view replacing weak weekend pattern analysis.
x Anti-double-counting tolerance for quick app reopens; overlay time shows seconds past 1 hour.
x Reworked per-app control: lists all apps with sorting and per-app monitoring/goal options.

## M16 — More fixes and structural changes
x Overlay always visible except on unmonitored apps or intentionally excluded launcher.
x Added setting to monitor or ignore the home screen/launcher.
x Fixed launcher usage inflation from mixed-day rolling window; introduced 4am day boundary.
x Renamed 24h analytics to "Today" (true same-day); separated monitoring on/off from overlay visibility.
x Moved goals to dedicated Monitoring tab; consolidated per-app control there.
x Corrected PM trigger timing; fixed insights link behavior.

## M17 — Persistent bugs and final hardening
x Fixed top-5 app chart; restored per-app control access through Settings.
x Removed vertical position slider; fixed font-size slider (reads continuously, not once at startup).
x Fixed overlay disappearance after long use (last known package fallback when UsageEvents returns null).
x Fixed launcher counters freezing/inflating (flush on screen-off, guard with isInteractive(), repair on startup).
x Fixed hour×weekday heatmap accuracy (distributes sessions across hourly buckets via start/end accumulation).

## M18 — Navigation, analytics, and UX polish
x Settings tab moved to first position; auto-starts monitoring on first launch.
x Control level terminology: Off / Light / Moderate / Intense.
x `com.google.android.googlequicksearchbox` treated as launcher.
x **Overlay simplified**: timer-only display, no count phase, no delays or fades — show/hide immediate.
x Fixed cross-process `disabledApps` encoding (`setStringList` → JSON via `setString`).
x Analytics: yesterday + last-7-days pattern charts (horizontal stacked bars, per-hour, per-app colors).
x `_debugCheckColorConflicts` moved to once-per-session (was causing 172-frame skips on every rebuild).
x Gap backfill on service restart: replays `UsageEvents` for periods when service was not running.

## M19 — Security and privacy hardening
x Added `android:usesCleartextTraffic="false"` and 90-day automatic data pruning.
x Added "Delete all data" action in Settings → Data & Privacy.
x Privacy policy at `docs/privacy_policy.html`, hosted at https://lsfcin.github.io/apptime/privacy_policy.html.
x Verified overlay `FLAG_NOT_TOUCHABLE` — confirmed non-intercepting.
x Removed dead permission `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`; fixed `BootReceiver` export gap; hardened `parseDisabledApps` against silent JSON failure.

## Revision + Code Structure milestone
x Full code read-through; produced CODE_STRUCTURE.md blueprint (modules, data flow, known issues).
x Logged refactor targets (ambiguities, redundancies, safety issues, naming problems) → REFACTOR_PLAN.md.
x Logged optimization targets (battery, UI thread, disk I/O, startup) → OPTIMIZATION_PLAN.md.

## Refactor milestone (R1–R37, all items complete)
x File splitting: `analytics_screen.dart` (2042 lines) → 5 files; `insights_screen.dart` → 3 files; `MonitoringService.kt` → MonitoringService + HistoryBackfill + AppConstants; `OverlayService.kt` → OverlayService + FeedbackEngine.
x Global state: extracted `AppInfoService`; merged `getInstalledAppLabels` + `getLaunchers` into single `getAppMetadata` channel call; extracted `kServiceChannel` constant.
x Date utilities: centralized 4am boundary helpers into `date_utils.dart` (Dart) and `DateUtils.kt` (Kotlin); unified duration formatting into `time_utils.dart`.
x App metadata: merged `kAppLabels` + `kAppColors` into `kAppMeta<AppMeta>`; removed all duplicate lookups; extracted `kPassivePatterns` as single source of truth.
x Dead code: removed `dailyGoalMinutes`, `AppColors.primaryDark`, `permission_handler` dependency, `getLast24h` aliases, 8 dead l10n keys.
x Safety/correctness: `canLaunchUrl` guard, locale-null fix, `_InsightRotatorCard` rename, `isSystemPkg` typo, deprecated `getRunningServices` replaced, explicit `minSdkVersion 23`.
x i18n: localized weekday labels, hardcoded PT reference lines, classification-message matrix, `kInsights` rotator, and Alertas/Soluções cards to EN.

## Optimization milestone (O1–O21, all except O20 complete)
x Battery: heartbeat throttled to every 30s; `accumulateDailyMs` batched into single `prefs.edit()`; SharedPreferences + PowerManager cached in service `onCreate()`.
x UI thread: analytics tabs and InsightsScreen converted to `StatefulWidget` with cached data — no more prefs scans on every parent rebuild.
x SharedPreferences I/O: per-day package index (`packages_index_{date}`) eliminates O(n_keys) scans; RegExp compiled once; single-pass prune.
x MonitoringScreen: `_sortedPackages()` reduced from O(49n) to O(7n); sorted list cached in state.
x Startup: 3 channel round-trips collapsed into single `getStartupStatus()` call.
x Overlay: poll rate reduced to 2000ms when screen is off (was always 500ms).
x Deferred: SQLite migration (O20) — appropriate for post-1.0.
