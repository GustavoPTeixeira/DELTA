# BL-19 — Finish the teacher role (Teacher Profile T0): pending approval, sign-up race, docs and tests

| Field | Value |
|---|---|
| **ID** | BL-19 |
| **Type** | Bug + Story |
| **Priority** | Highest |
| **Story points** | 5 |
| **Sprint** | 1 |
| **Depends on** | — |
| **Branch** | `BL-19-teacher-role` (from `qa-testing`) |
| **Commit / PR** | `feat(BL-19): <description>` |
| **Was (Jira)** | DEL-4 (T0 of the Teacher Profile epic DEL-1), conflict with DEL-22 |
| **Takes over from** | BL-01 (sign-up race and profile error fallback) and BL-02 (teacher_pending role and its rules) |

## 📖 Context and Business Rules
A review of DEL-4's acceptance criteria against `qa-testing` on 2026-11-08 found:

| Criterion | Before |
|---|---|
| AC1 teacher → Área do Professor | ⚠️ Worked on login; after sign-up the teacher landed on the student screen (race), and a profile error also fell back to the student area |
| AC2 student / no role → Matérias | ✅ |
| AC3 students can't write teacher data | ✅ |
| AC4 sign-up never creates a teacher | ❌ PR #6 (DEL-22) let anyone choose "Professor", and the rules accepted `role: 'teacher'` |
| CT04 nobody changes their own role | ✅ |
| T0.6 README explains teacher promotion | ❌ Missing |

**Decision (2026-11-08):** keep the "Professor" option on sign-up, but it creates `teacher_pending`. An admin promotes the account to `teacher` in the Firebase console.

**What changed:**
1. `UserRole.teacherPending` (stored as `teacher_pending`), `UserModel.isPendingTeacher`.
2. `AuthService.register` stores `teacher_pending` when "Professor" is chosen; new `watchUserProfile(uid)` stream.
3. `main.dart`: a new `AuthGate` watches the profile document instead of reading it once:
   - while the profile doesn't exist yet: "Preparando sua conta…" with "Sair" (fixes the sign-up race)
   - on error: an error screen with "Tentar novamente" and "Sair" (no more silent fallback to the student area)
   - `teacher_pending` → **PendingApprovalScreen** ("Aguardando aprovação")
   - an admin promotion switches the app to the teacher area live
4. Register screen: a hint under "Tipo de Perfil" when "Professor" is chosen.
5. `firestore.rules`: create accepts only `student` or `teacher_pending`.
6. README: how to approve a teacher, and how to run the tests.
7. Tests: 14 new Dart tests (routing with fake Firebase, register roles, profile stream, model) and 20 rules tests on the emulator (`firestore_tests/`).

---

### 🎯 Acceptance Criteria (BDD)

#### Scenario 1: Signing up as a teacher
- **Given** I choose "Professor" on sign-up
- **When** I finish signing up
- **Then** I see "Aguardando aprovação", never "Matérias" or "Área do Professor"

#### Scenario 2: Approval
- **Given** an admin changes my `role` to `teacher` in the console
- **Then** my app switches to "Área do Professor" without logging out

#### Scenario 3: Nobody self-promotes
- **Given** any signed-in user
- **When** they try to create or change their profile with `role: 'teacher'` through the SDK
- **Then** the write is denied

#### Scenario 4: No silent fallback
- **Given** my profile can't be loaded
- **Then** I see an error screen with "Tentar novamente" and "Sair"

---

### 🧪 Test Case Matrix

| ID | Scenario | Type | How | Status |
|---|---|---|---|---|
| **TC01** | Teacher login → teacher area | Automated | `auth_gate_test` | ✅ |
| **TC02** | Student / legacy login → Matérias | Automated | `auth_gate_test` | ✅ |
| **TC03** | Pending teacher → "Aguardando aprovação" | Automated | `auth_gate_test` | ✅ |
| **TC04** | Live promotion pending → teacher | Automated | `auth_gate_test`, `auth_service_test` | ✅ |
| **TC05** | Sign-up race: waits for the profile | Automated | `auth_gate_test` | ✅ |
| **TC06** | "Professor" sign-up stored as `teacher_pending` | Automated | `auth_service_test` | ✅ |
| **TC07** | Rules: no `teacher` on create; no self-promotion; teacher-only writes | Automated (emulator) | `firestore_tests/` (20 tests; 2 fail against the old rules) | ✅ |
| **TC08** | Real device: sign up as Professor, approve in the console, see the switch | Manual | Chrome against prod (passed 2026-11-27) | ✅ |
| **TC09** | Rules deployed to the Firebase project | Manual | `firebase deploy --only firestore:rules` (deployed 2026-11-08) | ✅ |

---

### ⚠️ Before merging
- **Deploy the rules.** Until `firestore.rules` is deployed, production still accepts self-registered teachers.
- **Audit existing teachers.** Accounts created while PR #6 was live may have `role: 'teacher'` without approval. Review the `users` collection in the console and change any unknown teacher to `teacher_pending`.

### 📸 Evidence Requested from QA
- [ ] `flutter test` output (27 tests) and the rules test summary (20 tests)
- [ ] Video of TC08
- [ ] Screenshot of the deployed rules in the Firebase console
