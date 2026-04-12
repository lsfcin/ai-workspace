# AppTime — Completed Milestones

## M8 — Fixes

- x Disappearance: overlay is resilient, but at some point it is still disappearing. It is the most important feature and we must guarantee by all means it remains there
- x Positioning: it is not working properly. Changing the direction (left, below, right) moves the overlay all over the corners of the screen. The intent was to move it to the left/bottom/right of the camera orifice on the screen. If it is not possible to have the camera orifice as anchor (and for exemple place the overlay on the left of it in the same region of the clock bar) then let's rephrase the config. we can just place it in the top center of the screen you know... it will be fine this way.
- x Can we place the overlay in the same height as the clock bar? It would be interesting to have such freedom of placement
- x Font size config is not working
- x The config show border (mostrar borda) does nothing
- x Displacement (sliders for vertical and horizontal) configs are not working either
- x Unblock counts are simply not working
- x I believe we are accumulating usage time of an app even if the screen is blocked. Maybe we are incrementing the time in other scenarios as well (not sure), for example after the app is open but we return to the launcher screen (without closing it) or go to another app. The time count should only consider when the app is on foreground.
- x I believe we are not using any usage data natively stored by Android, is this the best option? Is it because Android data isn't precise? If we do not use it we have to be flawless and always store precise data. I understand that maybe have mixed usage data (part from our end part from Android's native analytics) can be confusing/ambiguous and lead to errors. Define an strategy that is the most precise please.
- x Change monitoring policy from "Today" to "24h" meaning we're reporting on the last 24 hours of usage

## M9 — Polish

- x HomeScreen "Insight of the day": 50 PT-BR texts with high-citation recognized scientific references, 3min rotation
- x Adaptive icon (`flutter_launcher_icons`); Check it, I believe it is already done.
- x Edge cases: MIUI home, device reboot (service won't auto-start — document limitation), active session at day rollover

## M10 — Analysis Blocks

Analysis tab redesigned with three sub-tabs (24h · 7 days · 30 days). Blocks implemented:

1. **Sleep Hygiene and Circadian Rhythm** (24h) — hourly bar chart with 10 PM–6 AM highlight
2. **Impulsivity Index / Checking Habit** (24h) — hourly unlock scatter/bars
3. **Focus Fragmentation** (24h) — session-duration histogram with <1 min alert bars
4. **Engagement Balance** (7d) — donut chart active vs. passive app categories
5. **The "Dopamine Drain"** (7d) — top-5 apps horizontal ranked bars
6. **Relapse and Trend Analysis** (7d) — daily bars with previous-week reference line
7. **The "Opportunity Cost"** (24h) — offline-life infographic (book / walk / sleep equivalents)
8. **"Weekend Spike" Pattern** (30d) — heatmap calendar coloured by usage vs. goal
9. **"Phubbing" Alert** (24h) — usage at meal times (12–14h and 19–21h highlighted)

New SharedPreferences keys (written by Kotlin, read by Flutter):

| Key | Description |
|-----|-------------|
| `hourly_ms_{pkg}_{date}_{h}` | Per-app hourly ms |
| `device_hourly_ms_{date}_{h}` | Total device hourly ms |
| `hourly_opens_{pkg}_{date}_{h}` | Per-app hourly opens |
| `hourly_unlocks_{date}_{h}` | Hourly unlock count |
| `session_bucket_{0-3}_{date}` | Session duration buckets (<1 min · 1–5 · 5–15 · >15) |

## M11 — Insights

`InsightsScreen` with two tabs — **Alertas** and **Soluções** — containing 40 PT-BR research-backed cards organised by topic:

- Category A (Alertas): Impulsivity · Sleep Hygiene · Focus/Productivity · Passive Consumption · Physical Health · Social Impact
- Category B (Soluções): Habit Change Techniques · Wellbeing & Recovery · Awareness & Environment

`HomeScreen` also shows a rotating "Insight do dia" card (3-minute rotation, 50 texts from `lib/data/insights.dart`).

## M12 — Permissions Onboarding

`OnboardingScreen` shown on first launch (or when any permission is missing):

- Step 0 — Welcome: app description + "Começar" button
- Step 1 — Overlay permission (SYSTEM_ALERT_WINDOW): opens system settings, detects grant via `WidgetsBindingObserver.didChangeAppLifecycleState`
- Step 2 — Usage Stats permission (PACKAGE_USAGE_STATS): same pattern
- Auto-advances when permission is granted; skips onboarding entirely on subsequent launches if both permissions are present

## M13 — Language Support

Industry-standard i18n via a manual `AppLocalizations` class (same interface as `flutter gen-l10n`, no codegen required).

- `lib/l10n/app_localizations.dart` — abstract base + `LocalizationsDelegate`
- `lib/l10n/app_localizations_pt.dart` — PT-BR (default)
- `lib/l10n/app_localizations_en.dart` — EN-US
- `flutter_localizations` SDK dep added to `pubspec.yaml`
- `StorageService.languageCode` String? key persists the choice
- Auto-detects system locale on first launch (PT-BR unless system is `en`)
- Settings → Language section (`RadioGroup`: System / Português / English); change is immediate (no restart)
- All 6 screens migrated off hardcoded strings

## M14 — Goals and Dynamic Overlay ✓

**Goal tiers (Kotlin + Dart mirrors):**
- `GoalThresholds.kt` + `goal_config.dart`: 3 tiers (minimal/normal/extensive) × 6 metrics (phone time, app time, unlocks, session, sleep cutoff, wakeup hour)
- `PmMessages.kt`: 6 pre-defined PT-BR/EN message scenarios (phoneTimeExceeded, appLimitExceeded, sessionExceeded, sleepingHours, wakeupSocial, unlockExceeded)

**Dynamic Overlay feedbacks (OverlayService rewrite):**
- **F.BN Breathing Nudge:** random fade-in (2–3s) / stay (1–3s) / fade-out (2–3s) cycle using Handler-chained `ObjectAnimator`; activates when usage ≥ 100% of limit
- **F.VW Visual Weight:** `scaleX/scaleY` grows from 1.0 to 1.2 as usage climbs from 80% to 200% of limit
- **F.PM Personalized Message:** second `WindowManager` overlay at `Gravity.CENTER`; 3s fade-in → 10s on → 3s fade-out → 60s cooldown; triggers when usage doubles the limit, or immediately for sleep/wakeup/unlock scenarios
- Feedback evaluation runs every 5 poll ticks (~2.5s); per-app goal overrides global

**Flutter UI:**
- `GoalScreen`: 4 selectable cards (None/Minimal/Normal/Extensive) with research rationale and threshold chips; per-app goal dropdown table for all apps seen in last 7 days
- `SettingsScreen`: Goals tile navigates to `GoalScreen` (replaces old daily-goal dialog)
- `StorageService`: `goal_level` Int + `app_goal_{pkg}` Int per-app override keys
- l10n (PT+EN): 15 new GoalScreen strings in all three l10n files
