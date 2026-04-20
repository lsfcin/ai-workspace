# AppTime — Roadmap

Read the next milestone, implement it bullet by bullet. After a bullet is done, change the dash - to an x, and commit.

## Milestone — Revision and Code Structure blueprint
x Revise all the code. Read file for file. Everything. Write down an schematic study on a separate file e.g., CODE_STRUCTURE (can be a .md file or any other more suitable format). the code structure must show how we organize the code, which 'modules' and their responsabilities, how data flows. Think of this file as an useful blueprint for yourself, a intermediate file that makes it clear for you how our code works and is very useful for your navigation on the code from now on. Make it in a way you can even skip reading some functions or files, as an entrypoint for investigation. Also update the CONTEXT.md with two instructions for you, the first is to consult the file, the second is to update it whenever it is needed. In this schematic/structure file write down some pointers/references that will help you later to connect the notes on CODE_STRUCTURE with the actual code files, these notes are for you to use later, so write it in the best format for you. also, already make use of the revision time to note down observations on: 
  x ambiguities
  x redundancies
  x duplicated/uncentralized variables and functions
  x extra-complex, suboptimized routines
  x overall bad practicies
  x potential safety issues
  x point out wrong naming patterns
  x any other topic you think it is worth writing down

x After writing down the CODE_STRUCTURE and all its info, revise it, create a list of points in another file called REFACTOR_PLAN and sort it from the most relevant to the least. The refactor plan should prioritize mostly to reorganize the code, make it more robust and concise, taking all the care to not loose any features or to make them malfunction. If you think some features can be redesigned a bit, or even excluded you can point it out, ask me, or just write the suggestion on the plan. Do not refactor yet! Just create the plan.

x Separately, create another file called OPTIMIZATION_PLAN. It is a ToDo list of sorted points to speed up our app, make it lighter to load and to run. To make it more cumbersome regarding battery consumption both in foreground and in background. If you think some features can be redesigned a bit, or even excluded to make our app lighter and faster you can point it out, ask me, or just write the suggestion on the plan. Do not optimize yet! Just create the plan.

## Milestone — Refactor
- Perform the planned refactor in the REFACTOR_PLAN, point by point, ticking them with an x. If there are core decisions to make about the the refactoring tasks, ask me, give me the options before, and then follow the plan. then rename the previous CODE_STRUCTURE file as old, or deprecated, or any other word you see more fit and create a new one representing the current structure.

## Milestone — Optimization
- Perform the planned optimization in the OPTIMIZATION_PLAN, point by point, ticking them with an x. If there are core decisions to make about the the optimization tasks, ask me, give me the options before, and then follow the plan. then rename the previous CODE_STRUCTURE file as old, or deprecated, or any other word you see more fit and create a new one representing the current structure.

## Milestone — Prepare to PlayStore submission

### Checklist

#### 0. Check legal concerns
x Once launched we'll expose the app to everyone, first review what issues may imply in legal concerns
x Consider a launch route that protects us, if there is not, it is fine
x Define protection strategy
x Build all materials/documents, manifests, don't know, what you can so we avoid being sued, I have no money or energy to handle that

**Strategy:** local-only architecture means LGPD exposure is minimal (no data leaves device). Key protections implemented:
- Privacy policy live at https://lsfcin.github.io/apptime/privacy_policy.html
- Disclaimer tile in Settings (not medical advice, not a medical device)
- Scientific claims softened from definitive to hedged ("may impair", "may spike")
- Play Console Data Safety form: mark "no data collected", "no account required"
- No INTERNET permission in manifest — reviewers can verify network-free claim instantly

#### 1. App identity & metadata
x Set a real `applicationId` (e.g. `com.lsf.apptime`) and confirm it is final — it cannot change after publish
  - Using `com.lsf.apptime` — confirmed final (changed from com.lucasf.apptime to bypass a MIUI install block)
x Bump `versionName` to `1.0.0` and `versionCode` to `1` in `build.gradle`
  - Set via pubspec.yaml `version: 1.0.0+1`
x Replace placeholder app name in `strings.xml` / `AndroidManifest.xml` (`AppTime`)
x Replace `ic_launcher` placeholder icon with final adaptive icon (foreground + background layers, 108dp safe zone)
x Add a short app description in PT-BR and EN (30 chars) and a long description (4 000 chars max) for the store listing
  - Written in docs/store_listing.md — ready to paste into Play Console

#### 2. Signing
- Create a release keystore (`keytool -genkey ...`) and store it outside the repo
- Configure `signingConfigs.release` in `build.gradle` (read credentials from `local.properties` or env vars — never commit the keystore)
- Build a signed AAB: `flutter build appbundle --release`

#### 3. Permissions audit
x Confirm every permission in `AndroidManifest.xml` has a visible rationale shown to the user (onboarding covers `SYSTEM_ALERT_WINDOW` + `PACKAGE_USAGE_STATS`)
x `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_SPECIAL_USE` — foregroundServiceType="specialUse" declared on both services with subtype properties
x Remove any unused permissions — `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` removed

#### 4. Privacy policy
x PlayStore requires a privacy policy URL for apps that request sensitive permissions (`PACKAGE_USAGE_STATS`, `SYSTEM_ALERT_WINDOW`)
x Draft a minimal policy (data stays on-device, no network calls, no analytics); host it (GitHub Pages or similar)
x Add the URL to the store listing and optionally link it from the app's Settings screen
  - Live at https://lsfcin.github.io/apptime/privacy_policy.html

#### 5. Store listing assets
- Feature graphic: 1024 × 500 px
- Phone screenshots: minimum 2, recommended 4–8 (use emulator or device)
- Short and full descriptions translated to both PT-BR and EN
- Content rating questionnaire (IARC) — likely "Everyone"

#### 6. Target API & compliance
x `targetSdkVersion` must be ≥ 34 (current Play requirement for new apps) — uses `flutter.targetSdkVersion` (Flutter 3.x defaults to 35)
x Verify `compileSdkVersion` ≥ 35 — uses `flutter.compileSdkVersion`
x Declare `android:exported` on every `<activity>`, `<service>`, and `<receiver>` in the manifest — all declared

#### 7. Release track
- Create a Google Play Developer account (one-time $25 fee)
- Upload the AAB to the **Internal testing** track first and install via Play to verify signing + permissions
- Promote to **Closed testing** (beta) before production if desired
- Production review typically takes 1–3 days for a new app

#### 8. Post-launch minimum
- Set up crash reporting (Firebase Crashlytics free tier, or just monitor Play's built-in ANR/crash dashboard)
- Prepare a `1.0.1` patch plan for any day-one issues