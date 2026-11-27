# BL-05 — Dev Firebase project and local Emulator Suite

| Field | Value |
|---|---|
| **ID** | BL-05 |
| **Type** | Chore |
| **Priority** | High |
| **Story points** | 3 |
| **Sprint** | 1 |
| **Depends on** | — |
| **Branch** | `BL-05-dev-environment` |
| **Commit / PR** | `chore(BL-05): <description>` |

## 📖 Context and Business Rules
Today there is a single Firebase project, `delta-eae4d`, and every run (`flutter run`, manual QA, demos) uses it. Every test account becomes real data in production, and the users are minors. Testing security rules (BL-02) against production is also risky.

**Scope:**
1. **Firebase Emulator Suite** for Auth and Firestore:
   - add an `emulators` block to `firebase.json` (Auth 9099, Firestore 8080, UI 4000)
   - in `main.dart`, when started with `--dart-define=USE_EMULATORS=true`, call `useAuthEmulator` and `useFirestoreEmulator`. Use `10.0.2.2` instead of `localhost` on the Android emulator.
   - a seed script (`tool/seed_emulator.dart` or JSON import) with a student, a pending teacher, an approved teacher and the content from BL-08 once it exists
2. **Separate dev project** (`delta-dev`) for shared testing on real devices:
   - `flutterfire configure` for the dev project into `lib/firebase_options_dev.dart`
   - choose the options with `--dart-define=ENV=dev|prod`; **dev is the default**, and prod is only used for release builds (BL-14)
   - deploy the same `firestore.rules` to both projects
3. **VS Code launch configurations** (`.vscode/launch.json`): "DELTA (emulators)", "DELTA (dev)", "DELTA (prod)".
4. **README:** a "Running locally" section with the emulator commands.

> Rule tests from BL-02 (`@firebase/rules-unit-testing`) run against these emulators, locally and in CI.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: Local development needs no internet
- **Given** I started `firebase emulators:start`
- **When** I run the app with `--dart-define=USE_EMULATORS=true` and sign up
- **Then** the account appears in the Emulator UI and **not** in the production console

#### Scenario 2: Production isn't the default
- **Given** I run `flutter run` with no flags
- **Then** the app connects to `delta-dev`, not `delta-eae4d`

#### Scenario 3: Seeded data for QA
- **Given** I run the seed script against the emulators
- **Then** I can log in as the student and both teachers without registering

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Sign up against the emulators | Happy path | User only in the Emulator UI |
| **TC02** | `flutter run` with no flags | Config | Uses `delta-dev` |
| **TC03** | Seed script | Happy path | 3 test users can log in |
| **TC04** | Android emulator against the local emulators | Edge | Connects through `10.0.2.2` |
| **TC05** | Release build | Config | Uses `delta-eae4d` (prod) |

---

### 📸 Evidence Requested from QA
- [ ] Screenshot of the Emulator UI with the seeded users
- [ ] Screenshot of the production console with no test accounts after TC01
- [ ] README section reviewed by someone running it for the first time
