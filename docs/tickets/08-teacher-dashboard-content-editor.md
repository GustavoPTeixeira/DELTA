# BL-12 — Teacher dashboard and text and quiz editor

| Jira field | Value |
|---|---|
| **Summary** | Teacher dashboard and text and quiz editor |
| **Issue type** | Story |
| **Priority** | Medium |
| **Story points** | 8 (can be split into 8a "Dashboard" and 8b "Content editor") |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `enhancement`, `teacher`, `content` |
| **Blocked by** | Ticket 2 (teacher role), Ticket 6 (content model) and Ticket 7 (attempts) |
| **Branch** | `BL-12-teacher-dashboard-editor` |
| **Commit / PR** | `feat(BL-12): <description>` |
| **References** | 2019 TCC, section 7 (future work) · [DELTA Screen Board](https://claude.ai/artifact/Wp9mzLhgPh8inAj36J4DiN) (Painel do professor, Novo texto) · [DELTA Build Spec](https://claude.ai/artifact/H8W2ACfFF4hDGyNkebxwma) (KpiTile, BarRow, AttentionBanner, PublishChecklist, Screens) |

## 📖 Context and Business Rules
Today "Área do Professor" is only a placeholder. In its final considerations, the TCC plans "a registration for teachers who want to add new texts from different areas of knowledge and new quizzes". This ticket delivers that, together with a dashboard for teachers to follow their students.

**Business rules:**
- Only users with `role == 'teacher'` can open `/teacher` (pending teachers stay on `/pending`, Ticket 2).
- Teachers can read students' attempts but can't change them.
- Every text needs an **author and source**, as the TCC methodology requires.
- A text can only be published with **5 complete questions of 5 alternatives each**, with the correct one marked (RF5). Drafts can be incomplete.
- Draft texts (`status: 'draft'`) don't appear to students.
- Teachers can only edit and delete the texts they created (`createdBy`).

**Scope:**
1. **Dashboard** (`/teacher`), with data from `collectionGroup('attempts')`:
   - 3 `KpiTile`: students, attempts this week, average score
   - `AttentionBanner` right below: "N alunos sem atividade há 5+ dias", with the names and a "Ver alunos" shortcut (hidden when N = 0)
   - "Acertos por matéria": one `BarRow` per subject, on a fixed 0–100% scale, in the subject color
   - student list ordered by last activity, with each student's average
   - a composite Firestore index for the query, and the rule `match /{path=**}/attempts/{id}` with read access for teachers only
   - for now the dashboard shows all students; grouping by class (`classes`) comes later
2. **"Conteúdo" tab:** list of the teacher's texts, with their status (draft/published) and edit and delete actions.
3. **Editor** (`/teacher/texts/new` and editing an existing text):
   - fields Matéria, Título, "Autor e fonte · obrigatório", Texto
   - question list with "+ Adicionar questão"; each question has a statement, 5 alternatives, the correct one marked and an optional explanation
   - `PublishChecklist` above the buttons (Matéria e título · Autor e fonte · Texto · N de 5 questões), showing what is done and what is missing
   - "Salvar rascunho" is always available; "Publicar" only unlocks when the checklist is complete
   - written in a batch: the text document + 5 question documents
4. **Firestore rules:** texts and questions writable only by teachers, and update/delete only by the author (`createdBy == request.auth.uid`); validate `status` and the required fields on publish.
5. Teacher bottom navigation: Painel, Conteúdo, Perfil.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: A teacher follows the class
- **Given** I am a teacher
- **When** I open the dashboard
- **Then** I see the number of students, this week's attempts, the average score, the average per subject and the student list with last activity
- **And** students without activity for 5+ days are flagged at the top

#### Scenario 2: Publishing a complete text
- **Given** I filled in subject, title, author and source, text and 5 complete questions
- **When** I tap "Publicar"
- **Then** the text appears to students in the chosen subject, with its 5 questions

#### Scenario 3: Publishing is blocked when data is missing
- **Given** my text has only 2 questions, or has no author and source
- **Then** the "Publicar" button is disabled and the checklist shows what is missing
- **And** "Salvar rascunho" still works

#### Scenario 4: Drafts don't appear to students
- **Given** I saved a text as a draft
- **When** a student opens the subject
- **Then** the draft doesn't appear

#### Scenario 5: Students can't access the teacher area
- **Given** I am a student
- **When** I try to open `/teacher` or write to `subjects/.../texts` (through the SDK)
- **Then** I am redirected, and the write is denied

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Dashboard with seed data | Happy path | Correct totals and averages |
| **TC02** | Bars per subject | UI review | 0–100% scale, each bar in the subject color |
| **TC03** | Publishing a complete text | Happy path | Visible to students with 5 questions |
| **TC04** | Publishing without author and source | Negative | Button disabled |
| **TC05** | Publishing with 4 questions | Negative | Button disabled |
| **TC06** | Saving an incomplete draft | Happy path | Saved; invisible to students |
| **TC07** | Editing another teacher's text (emulator) | Security | Denied |
| **TC08** | Student writes a text (emulator) | Security | Denied |
| **TC09** | Student reads `collectionGroup('attempts')` (emulator) | Security | Denied |
| **TC10** | Teacher changes a student's attempt (emulator) | Security | Denied |
| **TC11** | Student inactive for 6 days | Happy path | Appears in the banner at the top of the dashboard |
| **TC12** | Editor checklist | Happy path | Each item turns ✓ when filled in; "Publicar" unlocks with all 4 items |

---

### 📸 Evidence Requested from QA
- [ ] Screenshots of the dashboard and the editor side by side with the Screen Board
- [ ] Video of creating and publishing a text, and a student opening it
- [ ] Output of the rules test suite (TC07 to TC10)
- [ ] Confirmation of the test environment (Android/Emulator/Windows/Web)
