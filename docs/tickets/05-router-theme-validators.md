# BL-07 — Navigation with go_router, DELTA theme and shared components

| Jira field | Value |
|---|---|
| **Summary** | Navigation with go_router, DELTA theme and shared components |
| **Issue type** | Story |
| **Priority** | Medium |
| **Story points** | 8 |
| **Epic** | DELTA v2 — Post code review |
| **Labels** | `ui`, `ux`, `navigation`, `design-system` |
| **Blocked by** | Ticket 4 (Riverpod and repositories) |
| **Branch** | `BL-07-router-theme-components` |
| **Commit / PR** | `feat(BL-07): <description>` |
| **References** | [DELTA Screen Board](https://claude.ai/artifact/Wp9mzLhgPh8inAj36J4DiN) (visuals) · [DELTA Build Spec](https://claude.ai/artifact/H8W2ACfFF4hDGyNkebxwma) (colors, sizes and Dart code) · Code evaluation, P1 (c) and (e) |

## 📖 Context and Business Rules
- **Navigation:** today it uses `Navigator.push` scattered across screens, and `popUntil` on logout. With `go_router`, role-based redirects live in one place and the web build gets real URLs.
- **Visuals:** every screen defines its own colors (`Colors.grey[300]`, `Colors.black87`), and `primarySwatch` is ignored in Material 3. DELTA's identity (Giovana Carvalho Bombardelli's logo, with the prism and the spectrum) doesn't appear in the app.
- **Validation:** the same validations are duplicated in login, sign-up and profile, with different rules. Example: the profile requires a username of 3 or more characters, and sign-up doesn't.

The **DELTA Screen Board** defines the visuals, and the **DELTA Build Spec** has every value (hex, sizes in dp/sp, radii, states) plus ready-to-use Dart code. This ticket builds the visual and navigation foundation. The new content and gamification screens come in Tickets 6, 7 and 8.

**Scope:**
1. **Theme:** copy `lib/core/theme/delta_colors.dart`, `delta_theme.dart` and `delta_rules.dart` from the Build Spec, and use `theme: buildDeltaTheme()` in `MaterialApp`.
2. **Bundled fonts:** add `google_fonts` and put the font files in `assets/google_fonts/` (Bricolage Grotesque 700/800, Lexend 400/500/600, Literata 400). Set `GoogleFonts.config.allowRuntimeFetching = false`, so the app never downloads fonts over the students' mobile data.
3. **Logo:** add `flutter_svg` and `assets/brand/delta_logo.svg` (the SVG from the Build Spec), replacing `Icons.change_history` on the login screen. Ask Giovana for the original vector file.
4. **Routes (`go_router`)**, with a `redirect` based on `authStateProvider` and `currentUserProvider`:
   - `/login`, `/register`, `/pending`
   - `/subjects`, `/subjects/:subjectId`, `/subjects/:subjectId/texts/:textId`, `…/quiz`, `…/quiz/result`
   - `/progress`, `/profile`, `/teacher`, `/teacher/texts/new`
   - Routes whose screens belong to other tickets (6, 7 and 8) can point to placeholders.
5. **Components in `core/widgets/`**, as in the Build Spec: `DeltaLogo`, `LoadingButton` (primary and ghost variants), `DeltaChip`, `SubjectCard`, `ErrorView`, `EmptyView`, and the `NavigationBar` with 3 destinations (Matérias, Progresso, Perfil).
6. **`core/validators.dart`**, with a single set of rules:
   - name: 3 to 100 characters
   - username: 3 to 30 characters, `[a-z0-9._]`, no spaces
   - e-mail: simple regex
   - password: 6 or more characters
7. **Apply the new layout** to the existing screens:
   - **Login:** logo, "Usuário ou e-mail" and "Senha" fields (with an eye icon and a 48 dp tap target), a right-aligned "Esqueceu sua senha?" link right under the password, an "Entrar" button and a secondary "Criar conta" button.
   - **Sign-up:** same layout as login. Fields: Nome, Nome de usuário, E-mail, Senha (with the eye toggle, KAN-15 pattern) and Perfil (Estudante / Professor).
   - **Matérias:** 2-column grid of `SubjectCard`, each card with the subject icon (`DeltaSubject.icon`). The "Continue lendo" card and the per-subject progress bar come in Ticket 6; the points card with the weekly goal comes in Ticket 7.
   - **Perfil:** account data only (the current form) with "Sair da conta" at the bottom. Student progress lives in the **Progresso** tab (Ticket 7), and the profile no longer has a "Meu progresso" tab.
8. **Color rules:** no hex values or `Colors.*` in widgets; everything goes through `DeltaColors` or `Theme.of(context)`. Text on a subject color uses `DeltaSubject.onColor`. Ciências, Educação Física, Geografia and História use dark text, because white fails the 4.5:1 minimum contrast.

---

### 🎯 User Stories & Acceptance Criteria (BDD)

#### Scenario 1: Role-based redirect
- **Given** I am logged in as a teacher
- **When** I try to open `/subjects` by URL (web)
- **Then** I am redirected to `/teacher`

#### Scenario 2: Logout goes back to login with no history
- **Given** I am on "Meu Perfil"
- **When** I confirm "Sair"
- **Then** I go to `/login`
- **And** the back button doesn't take me back to authenticated screens

#### Scenario 3: Consistent validation
- **Given** the username `ab`
- **When** I try to use it at sign-up **or** in the profile
- **Then** I get the same message: "O nome de usuário deve ter pelo menos 3 caracteres."

#### Scenario 4: Visual identity applied
- **Given** I open any screen
- **Then** colors, fonts and sizes match the Build Spec
- **And** the login screen shows the logo with the spectrum triangle

#### Scenario 5: Contrast on subject colors
- **Given** an element with a background in the Ciências, Educação Física, Geografia or História color
- **Then** the text on it is dark (`#1B1830`)
- **And** on the other subjects the text is white

#### Scenario 6: Fonts without internet
- **Given** I install the app and open it for the first time in airplane mode
- **Then** text renders in Lexend and Bricolage Grotesque, not the system default font

---

### 🧪 Test Case Matrix (QA Guide)

| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| **TC01** | Student opens `/teacher` | Security/UX | Redirects to `/subjects` |
| **TC02** | Teacher opens `/subjects` | Security/UX | Redirects to `/teacher` |
| **TC03** | Logged-out user opens `/profile` | Security/UX | Redirects to `/login` |
| **TC04** | `teacher_pending` opens `/teacher` | Security/UX | Redirects to `/pending` |
| **TC05** | Logout and back button | Negative | Stays on login |
| **TC06** | `validators.dart` unit tests | Automated | Valid and invalid cases for every field |
| **TC07** | Password toggle on sign-up | Happy path | Switches the icon and the visibility |
| **TC08** | Text color on each of the 8 subjects | Accessibility | Uses `onColor`; contrast ≥ 4.5:1 |
| **TC09** | First launch in airplane mode | Edge | DELTA fonts rendered |
| **TC10** | Search for `Color(0x` and `Colors.` in `lib/features/` | Review | No results (except through `onColor`) |
| **TC11** | Text at 130% (system setting) | Accessibility | Nothing clipped; titles wrap |
| **TC12** | Visual comparison with the Screen Board | UI review | Login, Sign-up, Matérias and Perfil match |

---

### 📸 Evidence Requested from QA
- [ ] Screenshots of Login, Sign-up, Matérias and Perfil side by side with the Screen Board
- [ ] Video of the redirects (TC01 to TC05)
- [ ] Screenshot of the first launch in airplane mode (TC09)
- [ ] `flutter test` output including `validators_test.dart`
- [ ] Confirmation of the test environment (Android/Emulator/Windows/Web)
