# AppTime — Roadmap

Read the next milestone, implement it bullet by bullet. After a bullet is done, change the dash - to an x, and commit.

## M18 — Overall Adjustments
x In the dopamine drain chart improve the references, just author and year is not enough to find it. display title and venue of publication (journal/conference proceedings)

x In the 30 days analysis subtab, the first card says "2h44 total usage". Is it an average usage per day? complete it plz. same for unblocks count. state that it is /day (/dia)

x In the usage trend chart - 30 days . show captions for the apps lines. also, fix the reference, author and year is not enough.

x Delete the last card/block of 30-days trend, it does not have any rich analysis

x Standardize the first analysis card (about usage time and unlocks) of all three subtabs (1 day, 7 days, 30 days) using the 30 days as standard

- Monitoring gaps: we should handle the monitoring gaps when our app is not active. Do you have any ideas? If you have any better you can bring it on. Mine is to use android data to fill unmonitored gaps. Somehow we must know when we lost the track and when we recovered it and then search through the android data to grab info about exactly that period.

- Let's separate the overlay visualization from our status if monitoring is on or off. Please create a toggle that is on by default for analyzing usage and choose the best place to display it on the config tab.

x Insight links are not clickable

x The reference on the insight of the day brings just author and year, it is not enough. Use the sama structure for all our references.

x The slider of overlay font size does not affect the actual overlay

- The goals should be moved to its own tab, but let's call it monitoring (monitoramento), you can abbreviate it to fit a a tab. Now in this tab we will group of features, the goals and the monitoring + per-app control. Aggregate the per-app control in the same drop-down of the goals, adding an option to not monitor. Actually it is already aggregated... right? Ok! So all you need is to ditch the per-app goals list.

- The list of per-app goals, which is now the same as the per-app control, is too technical. Exclude background and coresystem apps (e.g., android, settings, permissioncontroller); Fix names to use the popular (maybe the play store) names; Place the icon of each app before its name

- Stop showing the unlock count of the home-screen (android/launcher/etc) if the user presses the home (circle) button or the atlernate (square) button. These are moments of quick transition so showing immediatly the count can be confusing, so just don't show it, wait 5 secs and then if the user remains on the home screen/launcher then you can show the total time of phone usage on the overlay as it already happens. Show the count only after unlocks that go directly to the launcher. If an unlock shows at first an app, than you should proceed with the behavior of the overlay for that app. Do not change the count behavior itself, just when it is showed.

- Configured to have the strict goal, because of that just saw a personalized message on the overlay about melatonin but it is 4:30pm. Check the triggers/routes/decision of these messages so they are picked for the right context.

x Review the insights and see if there is a need to add more to cover two topics, brain-rot and comparisons between phone addiction and drugs addiction. I want you to give more attention on these two topics, perhaps prepare 4 insights for each (2 about the issue and 2 with strategies). I believe those are strong convincing points

## M19 — Prepare to PlayStore submission

### Checklist

#### 0. Check legal concerns
- Once launched we'll expose the app to everyone, first review what issues may imply in legal concerns
- Consider a launch route that protects us, if there is not, it is fine
- Define protection startegy
- Build all materials/documents, manifests, don't know, what you can so we avoid being sued, I have no money or energy to handle that

#### 1. App identity & metadata
- Set a real `applicationId` (e.g. `com.lsf.apptime`) and confirm it is final — it cannot change after publish
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