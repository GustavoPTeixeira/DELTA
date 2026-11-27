# 🎫 DELTA tickets

Detailed specs for the items in [BACKLOG.md](../BACKLOG.md), the source of truth for status and planning. Jira (project DEL) is frozen as of 2026-11-08.

Each ticket follows the structure of `.github/ISSUE_TEMPLATE/`: Context → BDD Scenarios → Test Case Matrix → QA Evidence. Tickets 01–08 still have a "Jira field" table from when they were created in Jira; the `ID` in the backlog is what counts now.

The app's UI copy stays in Portuguese (pt-BR) because that is what students see, so button labels and messages appear in quotes in Portuguese.

| Backlog ID | Ticket | Was (Jira) |
|---|---|---|
| BL-01 | [01-fix-auth-bugs.md](01-fix-auth-bugs.md) | DEL-17 |
| BL-02 | [02-security-rules-hardening.md](02-security-rules-hardening.md) | DEL-18 |
| BL-03 | [03-ci-and-package-rename.md](03-ci-and-package-rename.md) | DEL-16 |
| BL-04 | [09-qa-safety-net.md](09-qa-safety-net.md) | — |
| BL-05 | [10-dev-environment-emulators.md](10-dev-environment-emulators.md) | — |
| BL-06 | [04-riverpod-repositories.md](04-riverpod-repositories.md) | DEL-14 |
| BL-07 | [05-router-theme-validators.md](05-router-theme-validators.md) | DEL-15 |
| BL-08 | [06-firestore-content-model.md](06-firestore-content-model.md) | DEL-12 |
| BL-09 | [07-attempts-gamification.md](07-attempts-gamification.md) | DEL-13 |
| BL-10 | [11-usability-test.md](11-usability-test.md) | — |
| BL-11 | [12-classes.md](12-classes.md) | DEL-6 + DEL-9 |
| BL-12 | [08-teacher-dashboard-content-editor.md](08-teacher-dashboard-content-editor.md) | DEL-11 (absorbs DEL-5, DEL-7, DEL-8) |
| BL-13 | [13-privacy-account-deletion.md](13-privacy-account-deletion.md) | — |
| BL-14 | [14-release-readiness.md](14-release-readiness.md) | — |
| BL-19 | [15-teacher-role-completion.md](15-teacher-role-completion.md) | DEL-4 |

**Visual references:**
- [DELTA Screen Board](https://claude.ai/artifact/Wp9mzLhgPh8inAj36J4DiN): the screen layouts
- [DELTA Build Spec](https://claude.ai/artifact/H8W2ACfFF4hDGyNkebxwma): colors, sizes, components, rules and Dart code

## Writing a new ticket
1. Add a row to the right section of [BACKLOG.md](../BACKLOG.md) with the next free `BL-xx` ID.
2. Copy the structure of an existing ticket into `tickets/NN-short-name.md` (next free number).
3. Link the file from the backlog row and from the table above.

## Open decisions
- **BL-02:** Cloud Function (Blaze plan, paid) or the free alternative for login by username.
- **BL-08:** review the questions with the advisor: wrong alternatives for questions 2 to 5, and the fix for question 4 of Appendix D.
- **BL-09:** validate the point levels (Faísca 0, Feixe 200, Prisma 550, Espectro 1000).
- **BL-14:** choose the final app ID before the first store upload; it can't be changed later.
