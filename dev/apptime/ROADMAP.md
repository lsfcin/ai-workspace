# AppTime — Roadmap

Read the next milestone, implement it bullet by bullet. After a bullet is done, change the dash - to an x, and commit.

## M16 — More Fixes

x Time overlay should be almost always on, unless we're talking by a unmonitored app (or if the user chose not to monitor the launcher/home screen [yes, we should give that option]) careful to not hide the timer count. It is always on and visible except if we are showing PMs (other messages) or if it is very briefly anymating in a fade out (which should be followed by a fade in the very next moment).

x PM became too big and text is being cropped horizontally (probably to fit in some text box). find a strategy for that.

x the overlay is showing 21:16:08 on the launcher. this can't be right. how can I have used it for more than 21 hours in the last 24 hours.

x the text (Passive:social, video, news apps. Active: all others) of engagement alance analysis card is always writen in english.

x the chart wekeend pattern should no longer be named like that. it is now week pattern, right? also, it is all blank. oh, just rechecked it, it has some bars on it, but they are 100% filled with all other apps option. so two fixes here, first, it is unlikely that I used several apps a 100% of the time on the last few hours, it should just fill horizontally each "cell" bar up to the %amount of minutes on that hour, e.g., if I used apps for 30 minutes only 50% of the bar should be filled. secondly, there should be 5 highest used apps visibly there, with their colors and also detailed in the caption. only after the 5 highest used the all other apps should appear.

x maybe there is one point we should discuss here. about the nature of the gathered data? are you fully relying on android data? is it enough? I want you to have data about each session of each app on the last 30 days. so just think of a way to guarantee that. 

x Important change! let's not monitor the last 24 hours. It is confusing regarding the time count. Because during the use, if you think in depth, in case I used the same app at the same time in the last day, the count should stay freeze, not adding a second, because I am using it now but we should be discarding the usage time from the last day as the time window goes by. So, let's simplify. Is it possible for us to use a different mark for a new day? Instead of 0:00 I would like to use 4am. This option is aligned with the fact that several addicted users usually sleep late and starting a new day at 0:00am may not represent reality. Can we, with some proper data organization, use 4am as start point of the new day? We can explain that briefly in some relevant place of our app. Then you can change everything that we do that is designed for the last 24h to work on two ways: today and yesterday. For the analysis subtab we use both. For current monitoring and overlay use just 'today'.


## M16 — Prepare to PlayStore submission

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