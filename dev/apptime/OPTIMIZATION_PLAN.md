# AppTime — Optimization Plan

Sorted highest to lowest impact on battery/performance.
Goal: reduce disk I/O, CPU on the UI thread, and background resource usage without losing features.

---

## Priority 1 — Android background battery (most impactful)

- [ ] **O1. Throttle heartbeat write in `MonitoringService.tick()` to every 30 seconds.**
  Currently writes `prefs.edit().putLong(HEARTBEAT_KEY, ...).apply()` every 1s tick.
  Over 8h awake = 28,800 async disk-write enqueues per day, just for the heartbeat.
  Change: write heartbeat only when `tickCount % 30 == 0`. The heartbeat is only used for gap detection; 30s granularity is more than sufficient.

- [ ] **O2. Batch `accumulateDailyMs()` into a single `prefs.edit()...apply()` call.**
  Currently issues 5–6 separate `prefs.edit().apply()` per session close (daily app, daily device, hourly app, hourly device, session bucket). Merge all into one `edit()` block with chained `putLong()`/`putInt()` calls, ending with a single `apply()`. Reduces async disk I/O by ~5× per session close.

- [ ] **O3. Cache `SharedPreferences` instance in `OverlayService`.**
  `getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)` is called on every 500ms poll inside `updateOverlay()` and `evaluateFeedbacks()`. Cache as a `lateinit var prefs` in `onCreate()`. Eliminates a framework map lookup on 2 fast paths.

- [ ] **O4. Cache `PowerManager` in `MonitoringService`.**
  `getSystemService(POWER_SERVICE)` called every 1s tick. Store as a `lateinit val powerManager` in `onCreate()`.

- [ ] **O5. Reduce duplicate prefs reads in `evaluateFeedbacks()` (OverlayService).**
  `prefs.safeGetCount("flutter.unlock_count_$date")` is called twice in the same method invocation. Read once into a local variable.

- [ ] **O6. Consolidate per-tick prefs reads in `OverlayService.updateOverlay()`.**
  Multiple individual `prefs.getBoolean()` / `prefs.getInt()` calls per 500ms tick. Batch them into a single local data snapshot at the top of the method, reducing repeated map lookups.

---

## Priority 2 — Flutter UI thread / build cost

- [ ] **O7. Convert `InsightsScreen` to `StatefulWidget`; compute `_InsightData` once in `initState` and on explicit refresh.**
  Currently `_InsightData.compute(storage)` runs synchronously inside `build()`, firing 200–400 `SharedPreferences` reads on every parent `setState`. As a `StatefulWidget` with `_insightData` in state, it rebuilds only when the user navigates to the tab or explicitly refreshes.

- [ ] **O8. Convert analytics tabs (`_Tab1d`, `_Tab7d`, `_Tab30d`) to `StatefulWidget` with cached data.**
  All three are `StatelessWidget`, meaning every parent `setState` (e.g. overlay text update) re-runs full prefs scans synchronously: `getSummaries(30)` = up to 1,500 prefs reads for `_Tab30d`. Cache computed summaries in state; invalidate on a timer or explicit refresh action.
  > Suggestion: a "refresh" pull-down or a timed invalidation every 60 seconds would keep data fresh without continuous scans.

- [ ] **O9. Run `AnalyticsService.getSummaries()` on an isolate for the 30-day tab.**
  Until O8 is done, this is the minimal fix: wrap `getSummaries(30)` in `compute()` (Flutter's `Isolate.run` shorthand) to move the 1,500+ prefs reads off the UI thread.

- [ ] **O10. Cache `disabledApps` decode for the duration of `getSummaries()` in `AnalyticsService`.**
  `storage.disabledApps` JSON-decodes on every call; `getSummaries(30)` calls it 30 times. Read once at the start of the method, pass as a local variable through the loop.

---

## Priority 3 — SharedPreferences key scan reduction

- [ ] **O11. Build a per-day package index alongside raw prefs writes.**
  The root cause of O(n_keys) scans in `packagesDailyMs()` and `packagesLast24h()` is that there's no index. Maintain a `packages_index_{date}` key storing a JSON array of package names that were active on that date. `MonitoringService` appends to this on first daily write per package. Prefs scan becomes a single key read.

- [ ] **O12. Compile `RegExp` once outside loops in `StorageService.pruneOldData()` and `MonitoringService.pruneOldData()`.**
  Both methods recompile `RegExp(r'(\d{4}-\d{2}-\d{2})')` inside a `for` loop over all prefs keys. Move to a top-level or companion constant: `val dateRegex = Regex(...)`. Low frequency but easy win.

- [ ] **O13. Single-pass prune in `StorageService.pruneOldData()`.**
  Currently iterates all keys twice: once to find old keys, once to remove them. Combine into a single pass that removes immediately.

---

## Priority 4 — Monitoring screen rendering

- [ ] **O14. Optimize `_sortedPackages()` in `MonitoringScreen` from O(49n) to O(7n).**
  The current implementation iterates 7 days once to collect the package set, then iterates again per package to sum ms. Replace with a single pass: iterate 7 days once, accumulate `Map<String, int>` of total ms per package, then sort. Reduces iterations from 7×7 to 7 for the accumulation step.

- [ ] **O15. Debounce MonitoringScreen rebuild on prefs changes.**
  `_loadAppLabels()` is called in `initState`. If the screen is rebuilt (e.g., parent `setState`), it doesn't re-fire — correct. But `_sortedPackages()` is called in `build()` directly. Consider caching the sorted list in state and rebuilding only on `resumeApp` events.

---

## Priority 5 — Startup / launch time

- [ ] **O16. Compress the 3 method-channel round-trips at startup into one.**
  `main.dart` fires `hasOverlayPermission()`, `hasUsagePermission()`, and conditionally `startMonitoring()` sequentially before `runApp`. Add a single `getStartupStatus()` channel call returning `{overlayGranted, usageGranted, isRunning}`. Saves 2 round-trips from the cold-start path.

- [ ] **O17. Lazy-init analytics screen content.**
  All 4 `IndexedStack` screens are instantiated at startup. `InsightsScreen` (after O7) and `AnalyticsScreen` (after O8) will no longer compute on build but will still allocate widget trees. Consider `AutomaticKeepAliveClientMixin` with lazy first build to defer work until the tab is first visited.

---

## Priority 6 — Memory / GC

- [ ] **O18. Free analytics chart data when tab is not visible.**
  After O8, analytics tabs hold cached `List<DaySummary>` in state. When the user navigates away, this data can be freed after a TTL (e.g. 5 minutes) and re-fetched on next visit. Prevents unbounded memory growth on long app sessions.

- [ ] **O19. Avoid re-allocating the `_classificationMessage()` closure list on every build.**
  The 80-closure matrix in `analytics_screen.dart` is rebuilt on every `build()` call of `AnalyticsScreen`. Extract to a stateful field initialized once (or a module-level const-equivalent structure that captures context lazily).

---

## Priority 7 — Future / architectural

- [ ] **O20. Replace SharedPreferences with a SQLite database for time-series data.**
  Long-term: `daily_ms_{pkg}_{date}`, `hourly_ms_{pkg}_{date}_{h}`, etc. are a time-series dataset being jammed into a flat key-value store. A SQLite table with `(pkg, date, hour)` indexed columns would make range queries O(log n), eliminate full-key scans, and compress storage. This is a large change — plan separately.
  > Note: SharedPreferences is synchronous and simple. Only pursue O20 if profiling shows real-world jank on target devices.

- [ ] **O21. Reduce OverlayService poll rate dynamically.**
  500ms poll for the overlay is necessary during active foreground use, but could be reduced to 2000ms when the screen is off (`powerManager.isInteractive == false`). This halves overlay-service CPU when the phone is in pocket.
