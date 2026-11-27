# 🗂️ DELTA Backlog

This file is the **source of truth** for the DELTA backlog. Jira (project DEL) is frozen as of 2026-11-08; new work is tracked only here.

Each item has a stable ID (`BL-xx`) used in branch names and commits. Detailed specs live in [tickets/](tickets/) (Context → BDD → Test Cases → QA Evidence).

## How to use this file
- **Moving an item:** cut its row from one status section and paste it into another. Update `Phase` when it changes.
- **Branch:** `BL-xx-short-name` (e.g. `BL-01-fix-auth-bugs`).
- **Flow:** branch from `main`, open the PR into `main` (decided 2026-11-27; `qa-testing` was retired).
- **Commit / PR:** `type(BL-xx): description` (e.g. `fix(BL-01): map invalid-credential error`). Put `Closes BL-xx` in the PR description.
- **Statuses** follow [QA_WORKFLOW.md](QA_WORKFLOW.md):

| Status | Meaning | GitHub label |
|---|---|---|
| 🧊 Icebox | Idea; not refined yet | — |
| 🗂️ Backlog | Refined, has a ticket, not planned | — |
| 📋 Ready | Planned for the current or next phase, meets the Definition of Ready | — |
| 🔨 In progress | Branch open, being built | — |
| 🧪 In QA | PR open, waiting for or in homologation | `qa:ready-for-test` / `qa:changes-requested` |
| ✅ Done | Merged into `main`, meets the Definition of Done | `qa:approved` |

**Definition of Ready:** has a ticket with BDD scenarios and test cases, dependencies are done or in the same phase, and an estimate.

**Definition of Done:** merged into `main`, CI green, every test case in the ticket passed, and QA evidence attached to the PR. Matching the [Screen Board](https://claude.ai/artifact/Wp9mzLhgPh8inAj36J4DiN) is only required from the 🎨 Layout phase on.

**Estimates** are story points (1, 2, 3, 5, 8). There's no measured velocity yet. Record points delivered at the end of each phase in the [Progress log](#-progress-log) and adjust.

---

## 🧭 Working agreement (2026-11-27)
- **Functionality first, layout last.** Phases 0–4 make every feature work. Visual work (theme, fonts, logo, Screen Board components, `go_router`, bottom navigation) waits for the 🎨 Layout phase.
- **Plain Material widgets until then.** Where tickets 06, 07, 08 and 12 describe Screen Board components (`PointsCard`, `TextCard`, spectrum bars…) or `go_router` routes, build only the behavior, with standard widgets and `Navigator`. The styling lands in BL-07.
- **No Riverpod for now (BL-06 postponed).** Each new feature gets a plain repository class (`ContentRepository`, `QuizRepository`, `ClassRepository`) passed in through the constructor, the same way `AuthGate` receives `authService`. BL-06 becomes an optional refactor after Phase 3.
- **Pair programming.** Code is drafted together and reviewed by Gustavo before it's applied.

---

## 🗺️ Roadmap

| Phase | Goal | Items (in order) | Points |
|---|---|---|---|
| **0 · Close what's open** | Finish the teacher role and clean up the repo | BL-19, BL-00 | 6 |
| **1 · Make what exists correct** | RF1 sign-up, RF2 login, RF3 profile work and are safe | BL-05, BL-01, BL-02, BL-03 | 13 |
| **2 · Student learning loop** | RF4 reading → RF5 quiz → result → progress | BL-08, BL-09 | 16 |
| **3 · Teacher** | Teacher Profile T1–T5: classes, dashboard, content editor | BL-11, BL-12 | 16 |
| **4 · Safety and compliance** | Minors' privacy, account deletion, test gaps | BL-13, BL-04 | 10 |
| **🎨 Layout** | New visual identity, usability test, stores | BL-07, BL-10, BL-14 | 16 |
| *Optional* | Riverpod refactor, only if the plain repositories start to hurt | BL-06 | 8 |

### Step-by-step checklist

**Phase 0 · Close what's open**
- [x] **BL-19:** TC08 manual test ✅ · PR #9 merged into `main` ✅ · ⬜ audit existing teachers in the console
- [ ] **BL-00:** ✅ version `docs/` · ✅ PRs straight into `main` · ✅ branch cleanup · ⬜ merge the BL-00 PR (details [below](#bl-00--repo-housekeeping-no-ticket-file))

**Phase 1 · Make what exists correct**
- [ ] **BL-05:** run the app against the local emulators, so manual tests stop creating real accounts in production
- [ ] **BL-01:** `invalid-credentials` → `invalid-credential` · stop trimming passwords · delete the Auth user if the profile write fails · no fake `createdAt` · pt-BR messages and one generic login error
- [ ] **BL-02:** close the unauthenticated `list` on `users` · atomic `usernames/{username}` + migration · ❓ username login: Cloud Function (Blaze plan) or e-mail only (free)
- [ ] **BL-03:** CI runs `flutter analyze` + `flutter test` on every PR · rename the package to `delta_app`

**Phase 2 · Student learning loop**
- [ ] **BL-08:** models + `ContentRepository` · seed script with the TCC texts · subjects → texts → reading → quiz (5 × 5) · quiz unlocks after reading · result screen with the grade · rules + tests · ❓ review the questions with the advisor
- [ ] **BL-09:** save attempts · points · levels · streak · weekly goal · progress screen · unit tests · ❓ validate the levels with the advisor

**Phase 3 · Teacher**
- [ ] **BL-11:** classes with a 6-character join code · students join · remove students and archive classes · rules
- [ ] **BL-12:** dashboard from attempts · text and quiz editor (draft / published) · teachers edit only their own texts

**Phase 4 · Safety and compliance**
- [ ] **BL-13:** privacy notice · "Excluir minha conta" · no personal data in analytics
- [ ] **BL-04:** fill test gaps (`QuestionScreen`, `ProfileScreen`) · coverage gate in CI

**🎨 Layout**
- [ ] **BL-07:** DELTA theme, fonts, logo, shared components, `go_router`, bottom navigation · apply the Screen Board to every screen
- [ ] **BL-10:** usability test with 5 ninth-graders
- [ ] **BL-14:** app ID, icon, splash, signing, App Check, hosting, stores

---

## 🔨 In progress

| ID | Item | Type | Pts | Phase | Depends on | Ticket | Was (Jira) |
|---|---|---|---|---|---|---|---|

## 🧪 In QA

| ID | Item | Type | Pts | Phase | Depends on | Ticket | Was (Jira) |
|---|---|---|---|---|---|---|---|
| BL-00 | Repo housekeeping: PRs straight into `main`, merged branches deleted, `docs/` versioned. PR open | Chore | 1 | 0 | — | (below) | — |

## 📋 Ready — Phases 0 and 1

| ID | Item | Type | Pts | Phase | Depends on | Ticket | Was (Jira) |
|---|---|---|---|---|---|---|---|
| BL-05 | Dev Firebase project and local Emulator Suite | Chore | 3 | 1 | — | [10](tickets/10-dev-environment-emulators.md) | — |
| BL-01 | Fix bugs in the sign-up, login and profile flows (sign-up race and profile error moved to BL-19) | Bug | 3 | 1 | BL-05 | [01](tickets/01-fix-auth-bugs.md) | DEL-17 |
| BL-02 | Harden Firestore rules and guarantee unique usernames (teacher_pending done in BL-19) | Story | 5 | 1 | BL-01 | [02](tickets/02-security-rules-hardening.md) | DEL-18 |
| BL-03 | CI pipeline and rename the package to delta_app | Chore | 2 | 1 | — | [03](tickets/03-ci-and-package-rename.md) | DEL-16 |

## 🗂️ Backlog

| ID | Item | Type | Pts | Phase | Depends on | Ticket | Was (Jira) |
|---|---|---|---|---|---|---|---|
| BL-08 | Texts and quizzes loaded from Firestore (RF4/RF5), plain Material UI | Story | 8 | 2 | BL-02 | [06](tickets/06-firestore-content-model.md) | DEL-12 |
| BL-09 | Save attempts, points and student progress (gamification), plain Material UI | Story | 8 | 2 | BL-08 | [07](tickets/07-attempts-gamification.md) | DEL-13 |
| BL-11 | Classes: create a class, join code, manage students | Story | 8 | 3 | BL-02 | [12](tickets/12-classes.md) | DEL-6 + DEL-9 |
| BL-12 | Teacher dashboard and text and quiz editor | Story | 8 | 3 | BL-09, BL-11 | [08](tickets/08-teacher-dashboard-content-editor.md) | DEL-11 (absorbs DEL-5, DEL-7, DEL-8) |
| BL-13 | Privacy notice and in-app account deletion | Story | 5 | 4 | BL-02 | [13](tickets/13-privacy-account-deletion.md) | — |
| BL-04 | QA safety net: QuestionScreen and ProfileScreen tests + coverage gate (AuthService tests started in BL-19) | QA | 5 | 4 | BL-01, BL-03 | [09](tickets/09-qa-safety-net.md) | — |
| BL-07 | Navigation with go_router, DELTA theme and shared components; apply the Screen Board | Story | 8 | 🎨 Layout | Phase 4 | [05](tickets/05-router-theme-validators.md) | DEL-15 |
| BL-10 | Usability test with 5 ninth-graders | UX research | 3 | 🎨 Layout | BL-07 | [11](tickets/11-usability-test.md) | — |
| BL-14 | Release readiness: app ID, name, icon, splash, signing, App Check, hosting | Chore | 5 | 🎨 Layout | BL-03, BL-07 | [14](tickets/14-release-readiness.md) | — |
| BL-06 | Repository layer and state management with Riverpod (postponed 2026-11-27; optional) | Refactor | 8 | Optional | Phase 3 | [04](tickets/04-riverpod-repositories.md) | DEL-14 |

## 🧊 Icebox

| ID | Item | Why it's here | Was (Jira) |
|---|---|---|---|
| BL-15 | Teachers flag and favorite texts and quizzes for their classes | Needs BL-11 and BL-12 first, and a clear use case | DEL-10 |
| BL-16 | Teacher Profile epic (umbrella) | Not an item: DEL-1 groups T0 role (BL-19), T1 content + T2 quizzes (BL-12), T3 classes + T4 students (BL-11), T5 grades (BL-12), T6 favorites (BL-15) | DEL-1 |
| BL-17 | Login with Google | From the TCC's future work; needs a privacy review for minors (BL-13) | — |
| BL-18 | Class ranking (opt-in, per class only) | From TCC §2.3; only after BL-10 shows students want it | — |

## ✅ Done

| ID | Item | PR | Merged into | Was (Jira) |
|---|---|---|---|---|
| BL-19 | Finish the teacher role: pending approval, sign-up race, docs, tests (rules deployed 2026-11-08, TC08 passed 2026-11-27) | #9 | `main` (2026-11-27) | DEL-4 |
| — | User profile screen (RF3) | #3 | `main` | — |
| — | Teacher role and role-based access control (Teacher Profile T0) | #5 (KAN-5) | `main` (via #9) | DEL-4, DEL-20 |
| — | Role selection (Student / Teacher) on sign-up | #6 (KAN-13) | `main` (via #9) | DEL-22 |
| — | Standardize login validation and password toggle | #7 (KAN-15) | `main` (via #9) | DEL-21 |
| — | Widget tests for login and register screens | #8 (KAN-16) | `main` (via #9) | DEL-19 |

> ℹ️ PR #9 (BL-19) was merged into `main` on 2026-11-27. Because its branch was based on `qa-testing`, it also brought PRs #5–#8 into `main`. `qa-testing` is now behind `main` (see BL-00).

---

## BL-00 — Repo housekeeping (no ticket file)
- [x] ~~Get PRs #5–#8 into `main`~~: done through PR #9 (2026-11-27)
- [x] Branch flow: PRs go straight into `main`; `qa-testing` retired (2026-11-27)
- [x] `git checkout main && git pull`
- [x] Deleted merged branches locally and on GitHub (all had 0 commits missing from `main`): `KAN-5-…`, `KAN-13-…`, `KAN-15-…`, `KAN-16-…`, `feat/rf3-perfil-usuario`, `BL-19-teacher-role`, `qa-testing`, `master`
- [x] `docs/` is versioned: the `docs` line was dropped from `.gitignore`
- [ ] Optional: archive the DEL Jira project, with a note pointing to this file

> 💡 Lesson learned: "Discard" on untracked files in VS Code's Source Control deletes them (on Windows they go to the Recycle Bin). That happened to `docs/` on 2026-11-27 and it was restored from there.

---

## 📈 Progress log

| Phase | Dates | Planned pts | Delivered pts | Notes |
|---|---|---|---|---|
| 0 | | 6 | | |
| 1 | | 13 | | |
