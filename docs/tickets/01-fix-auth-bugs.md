# BL-01 — Fix bugs in the sign-up, login and profile flows

| Jira field | Value |
|---|---|
| **Summary** | Fix bugs in the sign-up, login and profile flows |
| **Issue type** | Bug |
| **Priority** | Highest |
| **Story points** | 5 |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `bug`, `auth`, `rf1`, `rf2`, `rf3` |
| **Blocked by** | — |
| **Branch** | `BL-01-fix-auth-bugs` |
| **Commit / PR** | `fix(BL-01): <description>` |
| **References** | Code evaluation (`docs/delta-code-evaluation.pdf`), items #5 to #11 |

## 📖 Context and Business Rules
The code evaluation found six bugs in the authentication flow (RF1, RF2, RF3):

1. **Sign-up race condition:** `authStateChanges` fires before the `users/{uid}` document is written. `main.dart` receives `null` and sends the user to `SubjectsScreen`, even when they signed up as a teacher. The `FutureBuilder` is also recreated on every rebuild, and an error while loading the profile also falls through to the student screen.
2. **Orphaned user:** if the Firestore write fails after `createUserWithEmailAndPassword`, the account stays in Firebase Auth with no profile.
3. **Wrong error code:** the code handles `invalid-credentials`, but Firebase sends `invalid-credential`. As a result, a wrong password shows Firebase's raw English message.
4. **Password `.trim()`:** leading and trailing spaces in the password are silently removed.
5. **Fake `createdAt`:** `UserModel.fromMap` uses `DateTime.now()` when the field is missing, so the profile shows "Membro desde" with today's date.
6. **Mixed-language messages that leak information:** some messages are in English, and login says "No user found with the provided username", which confirms whether a username exists.

**Rules:**
- Every message shown to the user is in pt-BR.
- A login with a non-existent user and a login with a wrong password show **the same** generic message.
- The password is sent to Firebase exactly as typed.

**Affected files:** `lib/main.dart`, `lib/services/auth_service.dart`, `lib/models/user_model.dart`, `lib/screens/login_screen.dart`, `lib/screens/profile_screen.dart`, `test/user_model_test.dart`.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: A newly registered teacher lands in the right area
- **Given** I am on the sign-up screen
- **When** I sign up with the "Professor" role
- **Then** I am taken to "Área do Professor" without restarting the app
- **And** while the profile does not exist in Firestore yet, I see a loading indicator, not the subjects screen

#### Scenario 2: A failed profile write does not leave an orphaned account
- **Given** Firestore is unavailable or rejects the write
- **When** I try to sign up
- **Then** I see an error message in pt-BR
- **And** the account does **not** remain in Firebase Auth

#### Scenario 3: Invalid credentials show a generic message
- **Given** I enter a non-existent user **or** a wrong password
- **When** I tap "Entrar"
- **Then** I see "E-mail/usuário ou senha incorretos. Tente novamente." in both cases

#### Scenario 4: Passwords with spaces are respected
- **Given** I signed up with the password `" minhaSenha "` (with spaces)
- **When** I log in typing `"minhaSenha"` without the spaces
- **Then** the login is rejected
- **And** with the original password, spaces included, the login works

#### Scenario 5: Profile without a sign-up date
- **Given** a legacy user without the `createdAt` field
- **When** I open "Meu Perfil"
- **Then** "Membro desde" shows "Não informada"

#### Scenario 6: Error loading the profile after login
- **Given** I am logged in and loading my profile fails
- **When** the app starts
- **Then** I see an error screen with "Tentar novamente" and "Sair" buttons, not the subjects screen

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Sign up as Professor | Happy path | Opens "Área do Professor" immediately |
| **TC02** | Sign up as Estudante | Happy path | Opens "Matérias" |
| **TC03** | Sign up with Firestore rejecting writes (emulator/rules) | Negative | pt-BR message; no account in Auth |
| **TC04** | Login with a non-existent user | Negative | Generic credentials message |
| **TC05** | Login with a wrong password | Negative | Same message as TC04 |
| **TC06** | Password with leading/trailing spaces | Edge | Only the exact password is accepted |
| **TC07** | Legacy profile without `createdAt` | Edge | "Não informada" |
| **TC08** | Unit test `UserModel.fromMap({})` | Automated | `createdAt == null` (replaces the current CT03 in `user_model_test`) |
| **TC09** | Unit test `_mapFirebaseAuthError('invalid-credential')` | Automated | Generic pt-BR message |
| **TC10** | No English messages left (code search) | Review | `grep` for "occurred\|No user\|taken" returns nothing |

---

### 📸 Evidence Requested from QA
- [ ] Video of a teacher sign-up going straight to "Área do Professor"
- [ ] Screenshots of the login error messages (TC04 and TC05 side by side)
- [ ] Screenshot of Firebase Console > Authentication after TC03 (no account created)
- [ ] `flutter test` output with all tests passing
- [ ] Confirmation of the test environment (Android/Emulator/Windows/Web)
