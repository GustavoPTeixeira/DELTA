# BL-06 — Repository layer and state management with Riverpod

| Jira field | Value |
|---|---|
| **Summary** | Repository layer and state management with Riverpod |
| **Issue type** | Story (refactor) |
| **Priority** | High |
| **Story points** | 8 |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `refactor`, `architecture`, `riverpod` |
| **Blocked by** | BL-01 (auth bugs), BL-03 (CI/rename) and BL-04 (QA safety net: the refactor needs tests first) |
| **Branch** | `BL-06-riverpod-repositories` |
| **Commit / PR** | `refactor(BL-06): <description>` |
| **References** | Code evaluation, P1 (a) and (b) |

## 📖 Context and Business Rules
Today `AuthService` handles authentication, profiles, username lookup, the legacy collection and error mapping all at once. On top of that, every screen creates its own instance (`AuthService()`). This makes testing hard and will get worse once texts, quizzes and the teacher area are added.

**This ticket is a refactor only: no visible behavior changes.**

**Scope:**
1. New folder structure:
   ```
   lib/
     core/       (theme, widgets and validators come in Ticket 5)
     data/
       models/        user_model, question_model
       repositories/  auth_repository, user_repository
     features/
       auth/     login_screen, register_screen, password_reset_dialog
       student/  subjects_screen, reading_screen, question_screen
       teacher/  teacher_home_screen
       profile/  profile_screen
     app.dart
     main.dart
   ```
2. Repositories with an abstract interface and a Firebase implementation:
   - `AuthRepository`: `authStateChanges`, `signIn`, `signUp`, `signOut`, `sendPasswordReset`
   - `UserRepository`: `watchUser(uid)` (stream), `createProfile`, `updateProfile`, `reserveUsername`
3. Add `flutter_riverpod` with these providers:
   - `authRepositoryProvider`, `userRepositoryProvider`
   - `authStateProvider` (StreamProvider<User?>)
   - `currentUserProvider` (StreamProvider<UserModel?>, watching `users/{uid}`)
4. Screens become `ConsumerWidget`/`ConsumerStatefulWidget`. `setState` stays for local state (password toggle, the selected quiz option).
5. Tests: `ProviderScope(overrides: [...])` with fakes (`fake_cloud_firestore`, `firebase_auth_mocks`), plus unit tests for the repositories.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: No functional regression
- **Given** the refactor is done
- **When** I go through sign-up, login (by username and by e-mail), profile editing, reading, the quiz and logout
- **Then** everything works exactly as before

#### Scenario 2: Screens don't create services
- **Given** the code in `lib/features/`
- **When** I search for `AuthService()` or `FirebaseFirestore.instance`
- **Then** there are no matches: everything comes from providers

#### Scenario 3: Widget tests don't depend on Firebase
- **Given** a widget test for `LoginScreen`
- **When** it runs with fake repositories
- **Then** it can simulate a successful and a failed login without initializing Firebase

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | The 13 existing tests | Regression | All pass (with updated imports) |
| **TC02** | `UserRepository` unit tests with `fake_cloud_firestore` | Automated | create, update, watch and username reservation covered |
| **TC03** | Widget test: successful login with fakes | Automated | Navigates to the home screen |
| **TC04** | Widget test: failed login with fakes | Automated | Shows a SnackBar with the message |
| **TC05** | Full manual run (student and teacher) | Regression | Same behavior as `main` |

---

### 📸 Evidence Requested from QA
- [ ] `flutter test` output (number of tests before and after)
- [ ] Video of the full manual run (TC05)
- [ ] Screenshot of the new folder tree
- [ ] Confirmation of the test environment (Android/Emulator/Windows/Web)
