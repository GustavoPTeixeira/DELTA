# BL-13 — Privacy notice and in-app account deletion

| Field | Value |
|---|---|
| **ID** | BL-13 |
| **Type** | Story |
| **Priority** | High (blocks any public release) |
| **Story points** | 5 |
| **Sprint** | Release |
| **Depends on** | BL-06 (repositories) |
| **Branch** | `BL-13-privacy-account-deletion` |
| **Commit / PR** | `feat(BL-13): <description>` |

## 📖 Context and Business Rules
DELTA's users are teenagers (the 2019 survey: 77.8% were 14–15). The LGPD (Brazil's data protection law, Art. 14) requires that their data be handled in their best interest, with clear information about what is collected and why. Google Play also requires that apps which let users create an account offer a way to **delete the account from inside the app**, plus a web link for deletion requests.

Today the app has no privacy notice and no way to delete an account.

> This ticket isn't legal advice. Review the privacy text with the TCC advisor and the school before publishing.

**Data the app stores (to be listed in the notice):**
| Data | Where | Why |
|---|---|---|
| Name, username, e-mail | `users/{uid}`, Firebase Auth | Account and login |
| Role (student/teacher) | `users/{uid}` | Access to the right area |
| Class | `users/{uid}`, `classes/…/members` (BL-11) | Show results to the teacher |
| Quiz attempts and points | `users/{uid}/attempts` (BL-09) | Progress and the teacher dashboard |
| Reading progress, text size | On the device only | Continue reading |

**Scope:**
1. **"Política de privacidade" screen**, in plain language a teenager can understand: what is stored, why, who sees it (the student and their teacher), how long it's kept, and how to delete it. Linked from sign-up ("Ao criar a conta, você concorda com a Política de privacidade") and from Perfil.
2. **"Excluir minha conta" in Perfil**, at the bottom, in red:
   - a confirmation screen saying exactly what will be deleted, with the password typed again (Firebase requires a recent login)
   - deletes, in this order: `users/{uid}/attempts/*`, class membership, `usernames/{username}`, `users/{uid}`, then the Firebase Auth user
   - for a teacher: their texts stay, so classes keep working, but `createdBy` is replaced with a neutral value
3. **Web page for deletion requests** (required by Google Play): a short page on Firebase Hosting (BL-14) with the instructions and a contact e-mail.
4. **Data minimization check:** no analytics or crash reporting with personal data. If analytics is added later, it needs its own review.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: A student reads the privacy notice before signing up
- **Given** I am on the sign-up screen
- **When** I tap "Política de privacidade"
- **Then** I see the notice in plain Portuguese, and I can go back to the form without losing what I typed

#### Scenario 2: A student deletes their account
- **Given** I am logged in as a student with 3 attempts
- **When** I go to Perfil → "Excluir minha conta", type my password and confirm
- **Then** my attempts, my class membership, my username and my profile are deleted
- **And** my login no longer works
- **And** my username can be registered again

#### Scenario 3: Wrong password
- **Given** I'm on the deletion confirmation
- **When** I type the wrong password
- **Then** nothing is deleted and I see "Senha incorreta."

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Privacy link on sign-up | Happy path | Notice opens; the form keeps its data |
| **TC02** | Delete a student account | Happy path | All 5 data locations cleared; login fails |
| **TC03** | Delete with the wrong password | Negative | Nothing deleted |
| **TC04** | Delete a teacher account | Edge | Texts remain; `createdBy` neutralized |
| **TC05** | Username after deletion | Edge | Available again |
| **TC06** | Deletion interrupted midway (offline) | Edge | Clear error; retrying finishes the deletion |
| **TC07** | Web deletion page | Happy path | Reachable without logging in |

---

### 📸 Evidence Requested from QA
- [ ] Screenshots of the notice and the deletion flow
- [ ] Emulator screenshots before and after TC02 showing the data gone
- [ ] Record of the notice review by the advisor and the school
