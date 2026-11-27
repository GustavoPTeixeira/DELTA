# BL-03 — CI pipeline and rename the package to delta_app

| Jira field | Value |
|---|---|
| **Summary** | CI pipeline and rename the package to delta_app |
| **Issue type** | Task |
| **Priority** | High |
| **Story points** | 2 |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `chore`, `ci`, `devops` |
| **Blocked by** | — (can run in parallel with Ticket 1) |
| **Branch** | `BL-03-ci-and-package-rename` |
| **Commit / PR** | `chore(BL-03): <description>` |
| **References** | Code evaluation, items #12 to #14 |

## 📖 Context and Business Rules
Today `.github/` only has templates, so nothing stops a PR with broken tests from being merged. The package is still called `flutter_application_1`, the default name from `flutter create`, and the folder tree in the README is out of date.

**Scope:**
1. Create `.github/workflows/ci.yml`, running on `pull_request` and on `push` to `main`:
   - `flutter pub get`
   - `dart format --output=none --set-exit-if-changed .`
   - `flutter analyze`
   - `flutter test`
2. Turn on protection for the `main` branch: CI required to merge.
3. Rename `name: flutter_application_1` → `name: delta_app` in `pubspec.yaml`, update the `description`, and update the `package:flutter_application_1/...` imports in `test/`.
4. Update the folder tree in `README.md`, adding `profile_screen`, `teacher_home_screen`, `firestore.rules`, `test/` and `docs/`.

> The `flutter_application_1/` folder name in the repository can stay as it is. Only the Dart package name changes.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: A PR with a failing test is blocked
- **Given** I open a PR where a test fails
- **When** CI finishes
- **Then** the check is red and the merge button is blocked

#### Scenario 2: A healthy PR passes
- **Given** a PR that is formatted, has no analyzer warnings and passes every test
- **When** CI finishes
- **Then** the check is green

#### Scenario 3: The app still works after the rename
- **Given** the package has been renamed
- **When** I run `flutter run` and `flutter test`
- **Then** everything builds and passes, with no reference to `flutter_application_1` left in the Dart code

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Test PR with a false `expect` | Negative | Red CI, merge blocked |
| **TC02** | PR with a badly formatted file | Negative | Red CI at the format step |
| **TC03** | Correct PR | Happy path | Green CI |
| **TC04** | Search for `flutter_application_1` in `lib/` and `test/` | Review | No results |
| **TC05** | `flutter run -d chrome` after the rename | Regression | App opens normally |

---

### 📸 Evidence Requested from QA
- [ ] Screenshots of the red check (TC01) and the green check (TC03) on GitHub
- [ ] Screenshot of the protection rules on the `main` branch
- [ ] Confirmation that the app runs after the rename (Android/Emulator/Windows/Web)
