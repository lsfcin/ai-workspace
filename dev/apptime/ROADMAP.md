# AppTime — Roadmap

Read the next milestone, implement it bullet by bullet. After a bullet is done, change the dash - to an x, and commit.

## M17 - Persistent Bugs

Some bugs are still there. Find definitive solutions for them or else explain to me if they are already solved but my tests do not reveal yet (due to my small time window of test, testing for only 2 days and some features show comparisons of full weeks or months) or else if they do not have a proper way to fix it.

x There should be 5 highest used apps visibly there, with their colors and also detailed in the caption. only after the 5 highest used the all other apps should appear.

x The option per-app control simply is not there.

x Config slider for overlay font-size ain't working.

x Config slider for vertical position ain't working either, but in this case you can just remove this config. It is fine.

x Timer is disappearing (or becoming invisible) without any other message being displayed. This happened while using the AppTime itself. It reappears if I open another app or go to the launcher.

x Avoid using technical words in the user interface such as overlay and launcher, specially if you're set to pt-br.

x Launcher is showing that I used my phone for more than 21hours. How is that possible? Also, it is frozen at 21:59:36...

x Not a correction, after finshing this milestone please explain to me how we are handling the data, are we collecting/storing something that is not what the android natively stores? I believe there is some serious core problem regarding our collection and storage and how we use it on our count and analysis. End your tasks and then return to this point to answer it seriously.


## M18 — Prepare to PlayStore submission

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