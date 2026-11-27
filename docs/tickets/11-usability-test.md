# BL-10 — Usability test with 5 ninth-graders

| Field | Value |
|---|---|
| **ID** | BL-10 |
| **Type** | UX research |
| **Priority** | Medium |
| **Story points** | 3 |
| **Sprint** | 3 (at the end, after BL-08 and BL-09 are in a test build) |
| **Depends on** | BL-09 |
| **Branch** | — (outputs a report in `docs/research/`) |

## 📖 Context and Business Rules
The new layout came from a design review, not from students. The TCC's own future work plans a pilot at the school where the 2019 survey was run. A small usability test before the pilot finds the biggest problems cheaply: five participants usually reveal most of the serious issues in a flow.

**Ethics and consent (users are minors):**
- written consent from the school and from each student's guardian, plus the student's own agreement
- no names in notes or recordings; participants are P1–P5
- if the session is recorded, record only the screen and audio, and delete it after analysis
- validate the consent form with the TCC advisor

**Plan:**
1. **Participants:** 5 ninth-grade students, mixed reading habits (the 2019 survey: 59.3% didn't have a reading habit).
2. **Build:** a test build on the **dev** project (BL-05) with seeded content, on an Android phone like the ones students use.
3. **Tasks** (think aloud, about 20 minutes each):
   - T1: "Abra um texto de Língua Portuguesa e leia até liberar o questionário."
   - T2: "Responda o questionário."
   - T3: "Veja quantos pontos você tem e quanto falta para o próximo nível."
   - T4: "Mude sua meta da semana para 4 textos."
   - T5: "Volte para o texto que você estava lendo."
4. **Measures:** task success (yes / with help / no), time per task, errors, and the SUS questionnaire in Portuguese at the end, adapted to the students' vocabulary.
5. **Questions to answer:** do students understand the locked button that fills up? Is "Continue lendo" found? Do points and levels motivate them? Is the text size comfortable?

**Output:** `docs/research/2026-usability-test.md` with findings ranked by severity, each linked to a new or updated backlog item.

---

### 🎯 Acceptance Criteria

- **Given** the 5 sessions are done
- **Then** the report lists every task's success rate and the average SUS score
- **And** every severe or major finding has a backlog item (new BL-xx or an update to an existing one)

---

### 🧪 Checklist

| ID | Item | Expected Result |
|---|---|---|
| **TC01** | Consent forms | Signed by the school, guardians and students before any session |
| **TC02** | Anonymization | No names or faces in notes or recordings |
| **TC03** | Report | Success per task, time, SUS, ranked findings |
| **TC04** | Backlog | Findings turned into BL items |

---

### 📸 Evidence
- [ ] Consent forms filed (not in the repository)
- [ ] Report committed to `docs/research/`
- [ ] Backlog updated with the findings
