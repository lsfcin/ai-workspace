# AppTime — Roadmap

## M14 — Goals and Dynamic Overlay

To implement this feature you'll likely have to read the entire milestone (M14 — Goals and Dynamic Overlay), it is not separated in small sequential bullets as other roadmap cases. Create your own todo list and write it in subsection, then follow it changing the - (todo) for x (done) step by step. Also, remember to commit changes.

### 1. Dynamic Overlay Feedback

Following "Calm Technology" principles, the overlay should move from the periphery of attention to the center only when behavior becomes risky. Here are a list of feedbacks we will explore, each with a code.

#### F.VW - Visual Weight

- **Intent:** To disrupt the "digital trance" of mindless scrolling.
- **Feedback:** **"Visual Weight."** As the passes between 80% to 100% of their limit, the overlay grow accordingly (1.2x scale, 0.01 scale addition for each % of time, e.g., 87% of the limit means 1.07x the scale). This increases its "visual salience," making the passage of time more physically felt without being intrusive.

#### F.BN - Breathing Nudge

- **Intent:** To provide a "Silent Mirror" of behavior without interrupting the task.
- **Feedback:** **"The Breathing Nudge."** The overlay uses a smooth fade-in (randomly between 2-3 seconds), stays on (randomy between 1-3 second) and fade-out (between 2-3 seconds seconds) cycle. This intermittent (and random pattern) presence prevents "banner blindness" by subtly re-engaging the user's awareness.

#### F.PM - Personalized Message

- **Intent:** Explicitly alert user of harmful behavior.
- **Visuals:** Momentarily displays a **Personalized Message** with max 2 lines and 4 words per line. Message appears with 3 seconds fade-in, stays for 10 seconds and then fades out in 3 seconds. After another minute the message appears again. For each case in subsection 2.2 (goal x usage metric) write a pre-defined a message (or a mesage stubs/templates with gaps to be filled by apps names or any other relevant info) so we do not need to create the message on runtime. Messages should relate to the harm of the behavior based on the selected research/insights. Be kind with those messages

### 2. Goal Tiers & Parameters

These levels guide the user from simple awareness to high-performance focus. The numbers are derived from recent longitudinal studies on sleep quality and attention span. 

#### 2.1 Scientific Rationales

- **The 4-Hour Threshold:** Studies define "high risk" use as ≥ 4 hours daily, which is strongly associated with depression and irregular sleep routines.
- **The 60-Unlock Cap:** High-frequency checking (≥ 400 times/week or ~ 60/day) is a stronger predictor of poor sleep and "Nomophobia" than total time.
- **The 20-Minute Session:** This aligns with the **20-20-20 rule** (taking a break every 20 minutes to look 20 feet away) to mitigate Digital Eye Strain and "Text Neck".


#### 2.2 Awareness levels per metric and selected overlay feedbacks
For each usage metric a type of feedback (or a combined set) will be applied. User selects a global goal level and may also select app-specific goal levels, we handle the feedback.

| Goal Level | 24h Phone Time | App-Specific 24h Limit | Unlocks per 24h (Check-ins) | Max Session | Phone Usage on Sleeping Hours | Social Apps (emails, messages and social media) on Wakeup
| Minimal Use Level   | < 1.5 hours | < 15 mins | < 25 per day | 5 mins   | < 21:00 | > 9:00
| Normal Use Level    | < 2.5 hours | < 30 mins | < 40 per day | 10 mins  | < 23:00 | > 8:00
| Extensive Use Level | < 4 hours   | < 60 mins | < 60 per day | 20 mins  | < 01:00 | > 7:00

F.VW - Visual Weight
F.BN - Breathing Nudge
F.PM - Personalized Message

24h Phone Time -> F.BN; and then if time is doubled F.VW; and after 5min start cycling F.PM
App-Specific 24h Limit -> F.BN; and then if time is doubled F.VW; and after 5min start cycling F.PM
Unlocks per 24h (Check-ins) -> F.PM 3 seconds after unlock
Max Session -> F.BN; and then if time is doubled F.VW; and after 5min start cycling F.PM
Phone Usage on Sleeping Hours -> F.VW + F.PM
Social Apps (emails, messages and social media) on Wakeup -> F.VW + F.PM

### 3. Goal UI Config

Show a selector for the core/global goal level (choose how to display it, it can be just "goal"). This is also the place to explain the levels based on research. Also user can select app-specific goals levels. Consider (not obliged to) perhaps merge these interface components with others (e.g., per-app overlay deactivation).

### 4. Bullet ToDo List

- x StorageService: goal level + per-app goal level keys
- x GoalConfig data class + goal tier constants (thresholds per metric per level)
- x F.PM message tables (PT-BR + EN) for each trigger scenario
- x OverlayService: read goal level + current metrics, compute active feedbacks
- x OverlayService: F.BN — random breathing cycle (fade in/stay/fade out) with Handler
- x OverlayService: F.VW — scale factor on WindowManager params based on % of limit
- x OverlayService: F.PM — fade-in message overlay, 10s on, fade out, 1min cooldown
- x OverlayService: sleeping-hours and wakeup-window detection
- x OverlayService: per-app goal evaluation (app-specific limit overrides global)
- x GoalScreen (Flutter): level selector with research rationale + per-app goal table
- x l10n: add new strings for GoalScreen + F.PM messages to both ARB classes
- x Wire GoalScreen into SettingsScreen or NavigationBar
- x Commit all

## M15 — Prepare to PlayStore submission

### Checklist

#### 1. App identity & metadata
- Set a real `applicationId` (e.g. `com.lucasf.apptime`) and confirm it is final — it cannot change after publish
- Bump `versionName` to `1.0.0` and `versionCode` to `1` in `build.gradle`
- Replace placeholder app name in `strings.xml` / `AndroidManifest.xml` (`AppTime`)
- Replace `ic_launcher` placeholder icon with final adaptive icon (foreground + background layers, 108dp safe zone)
- Add a short app description in PT-BR and EN (30 chars) and a long description (4 000 chars max) for the store listing

#### 2. Signing
- Create a release keystore (`keytool -genkey ...`) and store it outside the repo
- Configure `signingConfigs.release` in `build.gradle` (read credentials from `local.properties` or env vars — never commit the keystore)
- Build a signed AAB: `flutter build appbundle --release`

#### 3. Permissions audit
- Confirm every permission in `AndroidManifest.xml` has a visible rationale shown to the user (onboarding covers `SYSTEM_ALERT_WINDOW` + `PACKAGE_USAGE_STATS`)
- `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_DATA_SYNC` — verify correct `foregroundServiceType` declared
- Remove any unused permissions

#### 4. Privacy policy
- PlayStore requires a privacy policy URL for apps that request sensitive permissions (`PACKAGE_USAGE_STATS`, `SYSTEM_ALERT_WINDOW`)
- Draft a minimal policy (data stays on-device, no network calls, no analytics); host it (GitHub Pages or similar)
- Add the URL to the store listing and optionally link it from the app's Settings screen

#### 5. Store listing assets
- Feature graphic: 1024 × 500 px
- Phone screenshots: minimum 2, recommended 4–8 (use emulator or device)
- Short and full descriptions translated to both PT-BR and EN
- Content rating questionnaire (IARC) — likely "Everyone"

#### 6. Target API & compliance
- `targetSdkVersion` must be ≥ 34 (current Play requirement for new apps)
- Verify `compileSdkVersion` ≥ 35 (Flutter default should handle this)
- Declare `android:exported` on every `<activity>`, `<service>`, and `<receiver>` in the manifest

#### 7. Release track
- Create a Google Play Developer account (one-time $25 fee)
- Upload the AAB to the **Internal testing** track first and install via Play to verify signing + permissions
- Promote to **Closed testing** (beta) before production if desired
- Production review typically takes 1–3 days for a new app

#### 8. Post-launch minimum
- Set up crash reporting (Firebase Crashlytics free tier, or just monitor Play's built-in ANR/crash dashboard)
- Prepare a `1.0.1` patch plan for any day-one issues

## M16 — Small fixes

- Avoid counting as opening automatic app reinitializations (e.g., app reinitializes after asking for permissions or after a small update). Can we set a tolerance margin of 1 or 2 seconds? Maybe a full minute is enough, as for example user is zapping between apps to copy and paste content, share, etc. So ideally we would start the tolerance timestamp on the app exit/unfocus, give 2 minutes, and if the app is opened within that 2-minute period we do not count as an extra opening. Is there a real/official/scientific metric for it, if there is you can use it, maybe reconfigure the tolerance margin, you decide.