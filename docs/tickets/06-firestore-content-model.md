# BL-08 — Texts and quizzes loaded from Firestore (RF4/RF5)

| Jira field | Value |
|---|---|
| **Summary** | Texts and quizzes loaded from Firestore (RF4/RF5) |
| **Issue type** | Story |
| **Priority** | Medium |
| **Story points** | 8 |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `enhancement`, `rf4`, `rf5`, `firestore` |
| **Blocked by** | Ticket 2 (rules) and Ticket 5 (theme, routes and components) |
| **Branch** | `BL-08-firestore-content` |
| **Commit / PR** | `feat(BL-08): <description>` |
| **References** | 2019 TCC: RF4, RF5, Appendices C and D, Figures 7 to 9 · [DELTA Screen Board](https://claude.ai/artifact/Wp9mzLhgPh8inAj36J4DiN) (Matérias, Textos da matéria, Leitura, Questionário, Resultado) · [DELTA Build Spec](https://claude.ai/artifact/H8W2ACfFF4hDGyNkebxwma) (Screens and Behavior rules sections) |

## 📖 Context and Business Rules
Today the subjects, the text and the questions are hard-coded. Every subject opens the same text, and the per-subject text list (Figure 7 of the TCC) doesn't exist. The text also has the wrong title: the app shows "Nova Língua Portuguesa", but the real title is **"Nova língua brasileira"**, by Valentina Leite (Ciência Hoje das Crianças, 2015).

The TCC defines rules the current app doesn't follow:
- **RF5:** each quiz has **5 objective questions with 5 alternatives**, one of them correct. The current app has 3 questions with 4 alternatives.
- **RF5, pre-condition:** the quiz only unlocks **after reading** the text.
- **RF5, output:** at the end, the student sees their **grade** (*nota*) for the quiz.
- **Methodology:** every text must **credit its author and source**.

**Data model:**
```
subjects/{subjectId}                     name, order
  (the id follows DeltaSubject.id: artes, ciencias, educacao-fisica, geografia,
   historia, lingua-inglesa, lingua-portuguesa, matematica; the color comes from the enum, not the database)

subjects/{subjectId}/texts/{textId}      title, body, author, source, year, sourceUrl,
                                         readingTimeMin, order, status ('draft' | 'published'),
                                         createdAt, createdBy

subjects/{subjectId}/texts/{textId}/questions/{questionId}
                                         order, statement, options[5], correctOptionIndex (0–4),
                                         explanation (optional)
```

**Scope:**
1. `SubjectModel`, `TextModel` and `QuestionModel` (with 5 alternatives), and a `ContentRepository` with `watchSubjects()`, `watchTexts(subjectId)` (only `status == 'published'`), `getText(...)` and `getQuestions(...)`.
2. **Matérias:** cards come from Firestore, ordered by `order`, with "N de M lidos" and a progress bar per subject. At the top, the **"Continue lendo"** card (`ResumeCard`) opens the last text in progress; it disappears when nothing is in progress. Reading progress per text is stored locally.
3. **Textos da matéria** (new screen, `/subjects/:subjectId`): `SubjectHeader` in the subject color and a list of `TextCard` (title, author and source, reading time, "5 questões"). The first chip on each text shows its state: "Lendo · 38%", "Novo" or the best score. Empty state: "Nenhum texto cadastrado nesta matéria ainda."
4. **Leitura** (`/subjects/:subjectId/texts/:textId`):
   - title, credit line "Author · Source, year · N min", body in Literata with a drop cap in the subject color, 3 dp progress line
   - `ReadingUnlockButton`: while locked, the button fills up as the student reads ("Leia até o fim para liberar", caption "38% lido · cerca de 3 min restantes") and becomes "Responder questionário" when `reachedEndOfText()` (Build Spec, `delta_rules.dart`) is true
   - **"Aa"** control in the top bar for the text size (3 sizes, saved per student)
   - if the text fits on screen, the button starts unlocked; once unlocked for a text, it stays unlocked (store it locally, e.g. `shared_preferences`)
5. **Questionário** (`…/quiz`): `StepIndicator` with 5 segments, "Questão n de 5", the statement, 5 `QuizOption` with the states from the Build Spec (idle, selected, correct, wrong, dimmed), `FeedbackBanner` (a sentence first, "Boa! +10 pontos" or "Quase! A resposta certa é a B.", then the explanation), and the button "Confirmar resposta" → "Próxima questão" → "Ver resultado". No points chip at the top. Leaving mid-quiz asks for confirmation.
6. **Resultado** (`…/quiz/result`): a full screen replacing the current dialog, with:
   - a headline based on the score: "Mandou bem" (80% or more), "Bom trabalho" (60–79%), "Vale revisar o texto" (below 60%)
   - `ResultRing` (correct/total) and the **grade** from 0 to 10 with a decimal comma (`formatNota`: 4 of 5 → "8,0")
   - 5 review rows (✓/✕); the wrong ones have "Rever ›", which opens the question with its explanation
   - a primary "Próximo texto" button, a "Refazer" button and a "Voltar às matérias" link
   - saving the attempt and adding points is part of Ticket 7
7. **Seed** (`tool/seed_content.dart` or JSON + script):
   - the 8 subjects
   - the full text "Nova língua brasileira" (Appendix C), with `author: "Valentina Leite"`, `source: "Ciência Hoje das Crianças"`, `year: 2015`, `sourceUrl: "http://chc.org.br/nova-lingua-brasileira/"`
   - the 5 questions from Appendix D. Question 1 uses the alternatives from Figure 9. For questions 2 to 5 the TCC only gives the correct answer: write 4 wrong alternatives for each and review them with the advisor.
   - ⚠️ **Fix question 4 from Appendix D:** the recorded answer ("Psicóloga, mal e pterodáctilo") is wrong. Only "psicologia" is an example of a vowel that is pronounced but not written; "mal" is about the l/u sound, and "pterodáctilo" doesn't appear in the text.
8. **Firestore rules** for the nested paths:
   - texts and questions readable by authenticated users; `draft` texts only by their author and teachers
   - writes only by teachers (the editor is Ticket 8)
   - validate `options.size() == 5`, `correctOptionIndex` between 0 and 4, and required `author` and `source` on the text

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: A student goes from subject → text → reading
- **Given** I am a logged-in student
- **When** I tap "Língua Portuguesa" and then "Nova língua brasileira"
- **Then** I see the full text loaded from Firestore
- **And** I see the credit "Valentina Leite · Ciência Hoje das Crianças, 2015"

#### Scenario 2: The quiz only unlocks after reading
- **Given** I opened a text longer than the screen
- **When** I haven't reached the end yet
- **Then** the quiz button is locked and shows how much I've read
- **And** when I reach the end of the text, the "Responder questionário" button unlocks

#### Scenario 3: Quiz with 5 questions and 5 alternatives
- **Given** I opened the quiz
- **When** I answer the questions
- **Then** each question has 5 alternatives (A–E)
- **And** I can only confirm after choosing an alternative
- **And** after confirming, I see what was right and wrong (with a ✓/✕ icon and a sentence, not just color) and the explanation

#### Scenario 4: Result with a grade
- **Given** I got 4 of the 5 questions right
- **When** I finish the quiz
- **Then** I see the result screen with "4/5" and "Nota 8,0"
- **And** I see which questions I got wrong

#### Scenario 5: Subject with no content
- **Given** the "Artes" subject has no published texts
- **When** I open "Artes"
- **Then** I see the friendly empty state, with no error and no blank screen

#### Scenario 6: No connection
- **Given** I am offline with no cache
- **When** I open the subject list
- **Then** I see `ErrorView` with "Tentar novamente"

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Subject list ordered by `order` | Happy path | 8 subjects, each with its color and icon |
| **TC02** | Flow subject → text → reading → quiz → result | Happy path | Correct content at every step |
| **TC03** | Text credit | Happy path | Author, source and year visible in the list and on the reading screen |
| **TC04** | Quiz button before the end of the text | Negative | Locked, filled to the % read |
| **TC05** | Text shorter than the screen | Edge | Button unlocked immediately |
| **TC06** | Reopening an already-unlocked text | Edge | Still unlocked |
| **TC07** | Confirming without choosing an alternative | Negative | Button disabled |
| **TC08** | Result 4 of 5 | Happy path | "4/5" and "Nota 8,0" |
| **TC09** | `formatNota` unit test (0/5, 3/5, 5/5) | Automated | "0,0", "6,0", "10,0" |
| **TC10** | Subject with no texts | Edge | Empty state |
| **TC11** | Offline with no cache | Negative | ErrorView with retry |
| **TC12** | Student writes to `subjects/` (emulator) | Security | Denied |
| **TC13** | Question with 4 alternatives (emulator, as a teacher) | Security | Denied by the 5-alternative rule |
| **TC14** | Widget tests with `fake_cloud_firestore` | Automated | Screens render from the fake data |
| **TC15** | "Continue lendo" | Happy path | Shows the text in progress and opens at the saved position; disappears when nothing is in progress |
| **TC16** | "Aa" on the reading screen | Happy path | Changes the text size and keeps the choice on reopen |
| **TC17** | Getting a question wrong | Happy path | Sentence "Quase! A resposta certa é a X." before the explanation |
| **TC18** | "Rever" on the result screen | Happy path | Opens the missed question with its explanation |

---

### 📸 Evidence Requested from QA
- [ ] Video of the full flow (TC02), including the button unlocking at the end of the text
- [ ] Screenshots of the result screen and of the empty and error states
- [ ] Screenshot of the structure in the Firestore Console after the seed
- [ ] Record of the question review with the advisor (wrong alternatives and question 4)
- [ ] Confirmation of the test environment (Android/Emulator/Windows/Web)
