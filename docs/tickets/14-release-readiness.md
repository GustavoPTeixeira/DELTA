# BL-14 — Release readiness: app ID, name, icon, splash, signing, App Check, hosting

| Field | Value |
|---|---|
| **ID** | BL-14 |
| **Type** | Chore |
| **Priority** | High (blocks the pilot) |
| **Story points** | 5 |
| **Sprint** | Release |
| **Depends on** | BL-03 (package rename), BL-07 (logo and theme) |
| **Branch** | `BL-14-release-readiness` |
| **Commit / PR** | `chore(BL-14): <description>` |

## 📖 Context and Business Rules
The app still carries the defaults from `flutter create` (checked on 2026-11-08):

| Where | Today |
|---|---|
| Android `applicationId` and `namespace` | `com.example.flutter_application_1` (**Google Play rejects `com.example`**) |
| Android launcher name | `flutter_application_1` |
| Web tab title and `manifest.json` | `flutter_application_1` |
| App icon and splash | Flutter defaults |
| Release signing | Debug key |

**Scope:**
1. **App ID:** pick the final ID (e.g. `br.edu.ifsul.delta` or `com.<yourname>.delta`); it **can't be changed** after publishing. Change it in Android (`applicationId`, `namespace`, the Kotlin package folder) and the iOS bundle ID. **Register the new Android/iOS app in Firebase** and run `flutterfire configure` again, because `google-services.json` is tied to the old package name.
2. **App name:** "DELTA" on Android (`android:label`), iOS (`CFBundleDisplayName`), web (`<title>`, `manifest.json` name/short_name) and Windows.
3. **Icon and splash:** generate them from the logo (`flutter_launcher_icons`, `flutter_native_splash`), with the spectrum triangle on the background color from the Build Spec. Include an Android adaptive icon.
4. **Release signing:** create the upload keystore and keep it **out of the repository** (in `key.properties`, already ignored). Back it up somewhere safe; losing it blocks updates.
5. **Versioning:** `version: 1.0.0+1` in `pubspec.yaml`, bumped on every release, plus a `CHANGELOG.md`.
6. **Firebase App Check:** Play Integrity on Android and reCAPTCHA Enterprise on web, first in monitoring mode, then enforced on Firestore and Auth.
7. **Web build on Firebase Hosting** for the pilot (school computers): `flutter build web` + `firebase deploy --only hosting`. It also hosts the account deletion page from BL-13.
8. **Distribution for the pilot:** the Google Play internal testing track, or the web link.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: The app looks like DELTA everywhere
- **Given** I install the release build
- **Then** the launcher shows "DELTA" with the DELTA icon
- **And** the splash screen shows the logo
- **And** the web tab says "DELTA"

#### Scenario 2: Firebase still works after the ID change
- **Given** the new app ID is registered in Firebase
- **When** I sign up and log in on the release build
- **Then** everything works and the data reaches the prod project

#### Scenario 3: Requests without App Check are rejected
- **Given** App Check is enforced
- **When** a script calls Firestore without a valid App Check token
- **Then** the request is denied

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Search for `com.example` and `flutter_application_1` in `android/`, `ios/`, `web/` | Review | No results |
| **TC02** | Release APK/AAB signed with the upload key | Config | `apksigner verify` passes |
| **TC03** | Sign-up and login on the release build | Regression | Works against prod |
| **TC04** | Icon and splash on Android 12+ and older | UI review | Correct on both |
| **TC05** | Web deploy | Happy path | App loads from the Hosting URL |
| **TC06** | Firestore call without App Check (enforced) | Security | Denied |

---

### 📸 Evidence Requested from QA
- [ ] Screenshots of the launcher, splash and web tab
- [ ] Firebase console showing the new app registrations
- [ ] Hosting URL working
- [ ] Confirmation that the keystore is backed up outside the repository
