# BL-11 — Classes: create a class, join code, manage students

| Field | Value |
|---|---|
| **ID** | BL-11 |
| **Type** | Story |
| **Priority** | Medium |
| **Story points** | 8 |
| **Sprint** | 4 |
| **Depends on** | BL-02 (rules), BL-06 (repositories) |
| **Branch** | `BL-11-classes` |
| **Commit / PR** | `feat(BL-11): <description>` |
| **Replaces** | Jira DEL-9 "Create and edit classes" + DEL-6 "Add, edit and remove students in classes" |

## 📖 Context and Business Rules
The teacher dashboard (BL-12) shows results per class ("9º ano B"), but the app has no concept of a class. `firestore.rules` already reserves a `classes` collection, with nothing using it.

**Data model:**
```
classes/{classId}
  name ("9º ano B"), schoolYear (2026), teacherId, joinCode, createdAt, archived (bool)

classes/{classId}/members/{uid}
  joinedAt, joinCode (the code used, checked by the rules)

joinCodes/{code}
  classId        (lookup used by the rules; a 6-character code without ambiguous letters, e.g. "K7RM2Q")

users/{uid}
  + classId     (one class per student for now)
```

**Business rules:**
- Only approved teachers (`role == 'teacher'`) create classes. A teacher can have several classes.
- Each class gets a **6-character join code**, avoiding letters and digits that look alike (0/O, 1/I/L). The teacher can generate a new code, which invalidates the old one.
- A student joins with the code. A student belongs to **one class** at a time; joining another class moves them.
- The teacher can remove a student from the class. The student's account and attempts are kept.
- The teacher can rename or archive a class. Archived classes leave the dashboard but keep their data.
- The rules check that a student can only create their own `members/{uid}` document, and only with the class's current code.

**Screens** (not drawn on the Screen Board yet; draw them first, using the Build Spec components):
- **Teacher → Turmas:** list of classes with student counts; "Nova turma"; class detail with the join code (large, with a "Copiar" button), the student list with "Remover", and "Gerar novo código".
- **Student → Perfil:** "Minha turma" showing the class name, or "Entrar em uma turma" with a code field. Also offered once after sign-up, with a "Pular" option.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: A teacher creates a class
- **Given** I am an approved teacher
- **When** I create the class "9º ano B"
- **Then** it appears in my list with a 6-character join code and 0 students

#### Scenario 2: A student joins with the code
- **Given** I am a student and I have the code "K7RM2Q"
- **When** I type it in "Entrar em uma turma"
- **Then** I see "Você entrou na turma 9º ano B"
- **And** the teacher sees me in the class's student list

#### Scenario 3: Wrong or old code
- **Given** the teacher generated a new code
- **When** I type the old code
- **Then** I see "Código inválido. Confira com seu professor." and I don't join

#### Scenario 4: Removing a student
- **Given** a student is in my class
- **When** I tap "Remover" and confirm
- **Then** the student leaves the class, and their account and attempts remain

#### Scenario 5: Security
- **Given** I am a student
- **When** I try, through the SDK, to add another user to a class or join without a valid code
- **Then** the write is denied

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Create a class | Happy path | Class with a valid 6-character code |
| **TC02** | Join with the right code | Happy path | Student in the class |
| **TC03** | Join with a wrong code | Negative | Message; no membership |
| **TC04** | Join with an old code after regenerating | Negative | Denied |
| **TC05** | Join a second class | Edge | Moves from the old class to the new one |
| **TC06** | Remove a student | Happy path | Membership removed; attempts kept |
| **TC07** | Archive a class | Happy path | Hidden from the dashboard; data kept |
| **TC08** | Student creates a class (emulator) | Security | Denied |
| **TC09** | Student adds another user to a class (emulator) | Security | Denied |
| **TC10** | Teacher edits another teacher's class (emulator) | Security | Denied |
| **TC11** | Join code generator unit test | Automated | 6 characters, no ambiguous ones |

---

### 📸 Evidence Requested from QA
- [ ] Screenshots of the new screens next to their board designs
- [ ] Video: a teacher creates a class, a student joins with the code, the teacher sees the student
- [ ] Output of the rules test suite (TC08 to TC10)
