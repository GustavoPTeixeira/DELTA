# BL-02 — Harden Firestore rules and guarantee unique usernames

| Jira field | Value |
|---|---|
| **Summary** | Harden Firestore rules and guarantee unique usernames |
| **Issue type** | Story |
| **Priority** | Highest |
| **Story points** | 8 |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `security`, `lgpd`, `firestore-rules`, `auth` |
| **Blocked by** | Ticket 1 (Fix bugs in the sign-up, login and profile flows) |
| **Branch** | `BL-02-security-rules-hardening` |
| **Commit / PR** | `feat(BL-02): <description>` |
| **References** | Code evaluation, items #1 to #4 · [DELTA Screen Board](https://claude.ai/artifact/Wp9mzLhgPh8inAj36J4DiN) ("Aguardando aprovação" screen) |

## 📖 Context and Business Rules
DELTA's users are 9th-grade students. They are minors, and their personal data is protected by the LGPD (Brazil's data protection law). The evaluation found three problems in the Firestore rules:

1. **Enumeration without login:** `allow list: if request.query.limit <= 1` on `users` and `usuarios` lets anyone, without logging in, walk through the whole collection one document at a time using `startAfter`. This exposes every student's name, e-mail and role.
2. **Self-promotion to teacher:** anyone can sign up as `teacher` and then read every user's profile and write texts and questions.
3. **Non-atomic usernames:** the "is this username available?" check and the write are separate operations, so two simultaneous sign-ups can end up with the same username.

**Proposed solution:**
- Create a `usernames/{username}` collection holding `{ uid }`, written in the **same batch** as `users/{uid}`. The `create` rule only allows the write if the document doesn't exist, so Firestore itself guarantees uniqueness.
- Login by username: resolve username → e-mail **on the server**, with a callable Cloud Function `resolveLoginEmail`.
  - ⚠️ **Decision needed:** Cloud Functions require the **Blaze** plan (paid, with a free quota). If that isn't viable, the alternative is to store the `email` in `usernames/{username}` with `get` allowed and `list` denied. Unauthenticated users could then only look up usernames they already know, without listing the collection.
- Sign-up only accepts `role: 'student'`. Teachers sign up as `teacher_pending` and are approved by an admin, who changes the role in the Console or through a Function that sets a custom claim.
- **"Aguardando aprovação"** screen (route `/pending`), as in the DELTA Screen Board: shown while `role == 'teacher_pending'`, with the steps "Conta criada → Aprovação do administrador → Acesso ao painel" and a "Sair" button.
- `users`: `list` only for authenticated teachers. `usuarios` (legacy): `list` only when authenticated.
- Migration: a one-off script that creates `usernames/*` for existing users.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: A visitor can't list users
- **Given** I am not authenticated
- **When** I run a query on `users` with `limit(1)`
- **Then** Firestore returns `permission-denied`

#### Scenario 2: Login by username still works
- **Given** I have an account with the username `maria`
- **When** I log in typing `maria` and the correct password
- **Then** I get into the app normally

#### Scenario 3: Duplicate usernames are blocked even under concurrency
- **Given** two sign-ups with the username `joao` are sent at the same time
- **When** both try to write
- **Then** only one succeeds
- **And** the other gets "Este nome de usuário já está em uso"

#### Scenario 4: Nobody can promote themselves to teacher
- **Given** I choose "Professor" at sign-up
- **When** I finish signing up
- **Then** my account is `teacher_pending` and I see the "Aguardando aprovação" screen
- **And** a direct write with `role: 'teacher'` (through the SDK) is denied

#### Scenario 5: Changing the username frees the old one
- **Given** I change my username from `ana` to `ana.souza` in the profile
- **When** I save
- **Then** `usernames/ana` is deleted and `usernames/ana.souza` is created, in the same batch
- **And** another user can now take `ana`

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | `list` on `users` without auth (emulator) | Security | `permission-denied` |
| **TC02** | `list` on `usuarios` without auth | Security | `permission-denied` |
| **TC03** | `create` on `users/{uid}` with `role: 'teacher'` | Security | Denied |
| **TC04** | `update` changing `role` | Security | Denied |
| **TC05** | `create` on an existing `usernames/x` | Security | Denied |
| **TC06** | Login by username | Happy path | Success |
| **TC07** | Login by e-mail | Happy path | Success |
| **TC08** | Sign-up with a username already in use | Negative | pt-BR duplicate message |
| **TC09** | Username change in the profile | Happy path | Old one freed, new one reserved |
| **TC10** | Existing users after the migration | Regression | All have a `usernames` doc and can log in |

> TC01 to TC05 should be automated with `@firebase/rules-unit-testing` on the Firebase Emulator.

---

### 📸 Evidence Requested from QA
- [ ] Output of the rules test suite (emulator) with every case passing
- [ ] Screenshot of the `usernames` collection in Firestore
- [ ] Video of login by username and by e-mail
- [ ] Screenshot of the "Aguardando aprovação" screen for a teacher
- [ ] Record of the decision: Blaze plan + Function **or** the alternative without a Function
