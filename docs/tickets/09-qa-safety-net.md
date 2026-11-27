# BL-04 — QA safety net: AuthService, QuestionScreen and ProfileScreen tests + coverage gate

| Field | Value |
|---|---|
| **ID** | BL-04 |
| **Type** | QA |
| **Priority** | Highest |
| **Story points** | 5 |
| **Sprint** | 1 |
| **Depends on** | BL-01 (auth bug fixes), BL-03 (CI) |
| **Branch** | `BL-04-qa-safety-net` |
| **Commit / PR** | `test(BL-04): <description>` |

## 📖 Context and Business Rules
Measured on 2026-11-08: the 13 tests pass, but they cover about 142 of the ~1,900 lines in `lib/`.

| File | Covered |
|---|---|
| `lib/services/auth_service.dart` | **0%** (0/108 lines) |
| `lib/screens/login_screen.dart` | 66% |
| `lib/screens/register_screen.dart` | 68% |
| `lib/models/user_model.dart` | 88% |
| `question_screen.dart`, `profile_screen.dart`, `main.dart` and the rest | not loaded by any test |

`AuthService` holds the most important logic in the app (sign-up, login by username, profile updates) and has no tests. BL-06 (Riverpod refactor) will rewrite exactly that code. These tests must exist **before** the refactor, so they can prove it changed nothing.

The existing widget tests only avoid Firebase because `AuthService` is created lazily (`late final`). Any test that taps "Entrar" with valid data would crash.

**Scope:**
1. Add `fake_cloud_firestore` and `firebase_auth_mocks` as `dev_dependencies`.
2. **`AuthService` unit tests** (inject the fakes through the existing constructor):
   - `register`: success writes `users/{uid}` with the right fields; username already taken; Firebase error mapped to the pt-BR message; Firestore write failure deletes the Auth user (from BL-01)
   - `login`: by e-mail; by username; unknown username; wrong password → generic message (BL-01)
   - `isUsernameAvailable`: free, taken in `users`, taken in the legacy `usuarios`
   - `getUserProfile`: existing, missing, Firestore error
   - `updateUserProfile`: same username; new free username; new taken username; empty name
3. **`QuestionScreen` widget tests** (it's pure, no Firebase): confirm disabled until an option is chosen; correct answer → green and +1 score; wrong answer → red on the choice and green on the right one; explanation appears after confirming; last question opens the results dialog with the right percentage; "Refazer" resets.
4. **`ProfileScreen` widget tests:** add an optional `authService` parameter (same pattern as `LoginScreen`), then test loading, the error state with "Tentar novamente", edit/cancel, validation messages, and a successful save.
5. **Coverage gate in CI** (extends BL-03): run `flutter test --coverage` and fail the job if `lib/services/` is below **60%** line coverage. Print a per-file table in the job log.

> These are characterization tests: they record what the app does after BL-01. When BL-06 or BL-08 change behavior on purpose, update the test in the same PR.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: The auth service is tested without Firebase
- **Given** the `AuthService` tests use `fake_cloud_firestore` and `firebase_auth_mocks`
- **When** I run `flutter test`
- **Then** they pass with no network access and no Firebase project

#### Scenario 2: The coverage gate blocks a regression
- **Given** a PR deletes tests so `lib/services/` drops below 60%
- **When** CI runs
- **Then** the job fails and shows the per-file coverage

#### Scenario 3: The quiz screen is protected
- **Given** someone changes the scoring in `QuestionScreen`
- **When** the tests run
- **Then** a wrong score makes a test fail

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | `flutter test` offline | Automated | All tests pass |
| **TC02** | Coverage of `lib/services/` | Automated | ≥ 60% |
| **TC03** | PR that lowers coverage below 60% | Negative | CI red |
| **TC04** | Total number of tests | Review | At least 13 + 25 new |
| **TC05** | `ProfileScreen` with an injected fake service | Automated | Tests don't touch real Firebase |

---

### 📸 Evidence Requested from QA
- [ ] CI log with the coverage table
- [ ] Screenshot of a red CI run caused by low coverage (TC03)
- [ ] `flutter test` output with the test count before and after
