# BL-09 — Save attempts, points and student progress (gamification)

| Jira field | Value |
|---|---|
| **Summary** | Save attempts, points and student progress (gamification) |
| **Issue type** | Story |
| **Priority** | Medium |
| **Story points** | 8 |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `enhancement`, `rf5`, `gamification` |
| **Blocked by** | Ticket 6 (texts and quizzes in Firestore) |
| **Branch** | `BL-09-attempts-gamification` |
| **Commit / PR** | `feat(BL-09): <description>` |
| **References** | 2019 TCC, section 2.3 (gamification) · [DELTA Screen Board](https://claude.ai/artifact/Wp9mzLhgPh8inAj36J4DiN) (Matérias, Resultado, Progresso) · [DELTA Build Spec](https://claude.ai/artifact/H8W2ACfFF4hDGyNkebxwma) (Behavior rules, `delta_rules.dart`) |

## 📖 Context and Business Rules
Today the quiz result is lost when the screen closes. The TCC defines gamification (section 2.3) as using **points, levels, goals set by the user, and rankings** to engage students. This ticket saves attempts and delivers the student side. The teacher dashboard is Ticket 8.

**Data model:**
```
users/{uid}/attempts/{attemptId}
  subjectId, textId, textTitle, correct, total, answers: [int] (5),
  pointsEarned, finishedAt

users/{uid}
  + weeklyGoal (int, 1–7, default 3)
```

**Business rules** (values from the Build Spec, `delta_rules.dart`):
- The attempt is saved **as soon as the result screen opens**, so closing the app doesn't lose the result. "Refazer" creates a new attempt. Leaving mid-quiz saves nothing.
- **Points:** 10 per correct answer (`pointsPerCorrectAnswer`). The student's total is the sum of their attempts.
- **Levels** (the path of light): Faísca 0, Feixe 200, Prisma 550, Espectro 1000 points. ⚠️ Validate these values with the advisor before merging.
- **Streak:** consecutive days with at least one finished attempt.
- **Weekly goal:** the student sets their own goal of 1 to 7 texts per week (default 3). The week starts on Monday.
- **Ranking:** there will be no public ranking. If one is added later, it must be per class and opt-in, because the users are minors.
- Students can only create and read their own attempts, and can't edit or delete them.

**Scope:**
1. `QuizRepository` with `saveAttempt` and `watchAttempts(uid)`, and Firestore rules for `attempts` (create only by the owner, no update/delete, validated fields; readable by the owner and by teachers, for Ticket 8).
2. The `update` rule on `users/{uid}` also accepts `weeklyGoal` (integer from 1 to 7).
3. **Resultado:** show "+N pontos" next to the grade and save the attempt when the screen opens.
4. **Matérias:** `PointsCard` with points, the level badge, the spectrum-gradient bar and the goal row ("Meta da semana" + 3 dots + "Alterar").
5. **Textos da matéria:** best-score chip on `TextCard` (e.g. "✓ 4/5").
6. **Progresso** (bottom navigation tab, `/progress`), the only place in the app for progress:
   - summary with 3 numbers: points, texts read, days in a row
   - `LevelTrack` (Faísca → Feixe → Prisma → Espectro), with the filled part drawn to scale and "Faltam N pontos para …"
   - attempt history (`HistoryItem`), newest first; tapping one opens its result
   - the profile has no "Meu progresso" tab
7. Unit tests for `levelFor`, points, streak and goal progress.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: The result is saved
- **Given** I answered the 5 questions of a text and got 4 right
- **When** the result screen opens
- **Then** an attempt with `correct: 4, total: 5, pointsEarned: 40` is written
- **And** my points go up by 40

#### Scenario 2: Leveling up
- **Given** I have 520 points (Feixe level)
- **When** I finish a quiz with 4 correct answers
- **Then** I have 560 points and the badge shows "Nível 3 · Prisma"

#### Scenario 3: Weekly goal
- **Given** I set a goal of 3 texts
- **When** I finish my second text of the week
- **Then** the goal row on the points card shows 2 of 3 dots filled
- **And** when I tap "Alterar", I can pick a value from 1 to 7

#### Scenario 4: A student sees their own history
- **Given** I made 4 attempts
- **When** I open the Progresso tab
- **Then** I see all 4, newest first, with date, text, subject and score

#### Scenario 5: A student can't see or change another student's data
- **Given** I am a student
- **When** I try to read `users/{otherUid}/attempts` or edit one of my attempts (through the SDK)
- **Then** the operation is denied

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Opening the result screen | Happy path | Attempt written with the correct fields |
| **TC02** | Redo and finish again | Happy path | Two separate attempts |
| **TC03** | Leaving mid-quiz | Edge | No attempt written |
| **TC04** | Going from 549 to 550+ points | Edge | Level changes to Prisma |
| **TC05** | Setting the goal to 0 or 8 | Negative | Value rejected (UI and rule) |
| **TC06** | Streak with a day without attempts | Edge | Streak resets to 1 |
| **TC07** | Student history | Happy path | Ordered by `finishedAt` desc |
| **TC08** | Student reads another student's attempts (emulator) | Security | Denied |
| **TC09** | Student edits or deletes their own attempt (emulator) | Security | Denied |
| **TC10** | Unit tests for points, levels, streak and goal | Automated | Expected values |
| **TC11** | Closing the app on the result screen | Edge | Attempt already saved on reopen |
| **TC12** | Progresso tab with 340 points | UI review | Level track on Feixe, 40% of the way to Prisma |

---

### 📸 Evidence Requested from QA
- [ ] Screenshot of the attempt document in Firestore after TC01
- [ ] Screenshots of Matérias (points and goal), the result screen with points, and the Progresso tab
- [ ] Output of the rules test suite (TC08 and TC09)
- [ ] Record of the level validation with the advisor
- [ ] Confirmation of the test environment (Android/Emulator/Windows/Web)
