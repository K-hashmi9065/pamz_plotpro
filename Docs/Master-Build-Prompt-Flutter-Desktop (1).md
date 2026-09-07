# Master Build Prompt
## Land Investment, Development & Sales Management System — Flutter Windows Desktop

<span class="doc-meta">Version 3 — updated for PRD v2.2 / User Flow v1.1 / Acceptance Criteria v1.1, plus: (1) fully offline local storage using SQLite + Hive, (2) an in-app "How to Use This App" Help tab with an embedded User Guide PDF, and (3) a "How is this calculated?" formula popup on every screen that shows a computed financial figure.</span>

---

## How to Use This Prompt

1. Keep this file in the project repo alongside:
   - `Land-Investment-System-PRD.md` (v2.2) — business requirements: entities, formulas, roles, workflows, legal/compliance considerations.
   - `Land-Investment-System-User-Flow.md` (v1.1) — screen-by-screen navigation per role.
   - `Land-Investment-System-Acceptance-Criteria.md` (v1.1) — Given/When/Then test cases per feature.
   - `Land-Investment-System-User-Guide.pdf` — the plain-language, end-user guide (new in v3, see Section 8A). If this file doesn't exist yet, generate a first draft from the in-app Help content once Section 8A is built, and keep it in the repo so it can ship inside the installer.
   - The existing `land_investment_app/` codebase — Phase 1 is already built (Section 3).
2. Paste this whole document as the task prompt to your coding agent (e.g. Claude Code), with the repo open and the documents above attached.
3. **This prompt defines *how* to build it** (architecture, UI/UX standards, validation conventions, testing mandate, phasing). **The PRD defines *what* to build.** Implement business rules exactly as the PRD states them. If something is genuinely ambiguous, stop and flag it as an open question (PRD §18) rather than guessing.
4. Work strictly in the phases in Section 16. Do not generate the whole application in one uncontrolled step.

---

## 1. Role

You are a Senior Flutter Desktop Engineer, Product Architect, Financial Software UX Specialist, QA Engineer, and Compliance-Aware Business Analyst. Build like a serious financial/business system, not a CRUD demo: every financial operation must be traceable and auditable, and financial transaction records are corrected through a logged reversal, never a silent edit.

## 2. Mission

Build a production-ready, **fully offline** Windows desktop application: **Land Investment, Development & Sales Management System**, exactly as specified in the attached PRD (v2.2) — land acquisition, landowners, investors/ownership (Admin-only), expenses, parent land & plot subdivision, buyers & sales, installments, receivables/payables/cash flow, profit & loss, investor profit distribution, audit history, documents & PDF-shareable reports, WhatsApp/SMS notifications — built for exactly two roles, **Admin** and **Member**, with **no approval/review workflow anywhere**: every permitted action is direct CRUD. All application data lives on the local machine (Section 3A) — there is no remote backend.

## 3. Already-Built Foundation — Phase 1 (do not redo, do not fork)

Phase 1 (project foundation, theme, application shell, and full navigation) is complete and unaffected by the PRD's v2.2 role/workflow changes — build on top of it; do not create a parallel/duplicate theme, router, or shell.

| Piece | Location | Notes |
|---|---|---|
| Color system | `lib/core/theme/app_colors.dart` | The only place colors are defined. Semantic: green=paid/completed/profit/positive cash flow; amber=pending/upcoming/warning/partial; red=overdue/loss/failed/critical; blue=info/active. Never color alone — pair with icon/text/badge. |
| Typography | `lib/core/theme/app_typography.dart` | Inter font. Page title 26px / section title 20px / card title 17px / body 15px / secondary 13px / table header 13px / table cell 14px / button 15px / input 15px. `amountLarge` (28px/700) and `amountMedium` (18px/700) exist specifically so every currency figure is the most visually prominent thing on its screen — use them for all money, never `body`/`bodyMedium`. |
| Theme assembly | `lib/core/theme/app_theme.dart` | Single light `ThemeData`. No dark theme. |
| Routing | `lib/core/routing/app_routes.dart` + `app_router.dart` | Single source of truth for all routes, registered inside one `ShellRoute`. |
| Navigation tree | `lib/core/navigation/nav_item.dart` + `nav_items_data.dart` | Full sidebar structure. **Update for v2.2:** the Investors section of this tree must render conditionally — present for Admin, entirely absent (not just disabled) from the tree Member sees, consistent with PRD §5/§11's "Member must have no visibility into Investor data at all." **Update for v3:** add a permanent **Help / User Guide** item (Section 8A), visible to both roles. |
| Shell | `lib/shared/widgets/app_shell.dart`, `sidebar/`, `top_bar/`, `breadcrumb/` | Persistent sidebar + top bar + breadcrumb wrapping every route. |
| Reusable page pieces | `lib/shared/widgets/page/page_header.dart`, `states/placeholder_page.dart` | `PageHeader` is the standard title row every screen uses; replace `PlaceholderPage` module-by-module as each feature is built. |
| State | `lib/shared/providers/navigation_providers.dart` | Riverpod `StateNotifierProvider` for sidebar expand/collapse. |
| Stack | Flutter, `flutter_riverpod`, `go_router`, `google_fonts`, `window_manager`, Clean Architecture / feature-first | Matches `lib/features/<name>/{data,domain,presentation}/` — follow this structure for every feature added from Phase 2 on. Local persistence (new in v3): `drift` (SQLite) for records, `hive` + `hive_flutter` for settings/preferences — see Section 3A. |

## 3A. Local Data Storage — SQLite + Hive (new in v3)

This app has **no server**. Everywhere else in this document that says "server-side" or "in the API response," read that as **"in the app's business logic layer, not the UI"** — the trust boundary is the compiled business-logic code running on the user's own machine, not a remote server. All data stays on the PC the app is installed on.

Two local storage tools are used, for two different kinds of data — think of it like a filing cabinet versus a sticky-note pad:

- **SQLite, via the `drift` package — the filing cabinet.** Every financial/business record goes here: Projects, Landowners, Land Acquisitions, Investors/Ownership, Expenses, Plots, Buyers, Sales, Installments, Distributions, Audit Log. Use `drift` (not raw `sqflite`) because it's a *type-safe* wrapper — it catches mistakes in how tables relate to each other (e.g. "this Plot must belong to a real Project") at compile time instead of at runtime, and it ships with proper migration tooling.
  - **Why SQLite and not Hive for this data:** these records constantly reference each other (an Installment belongs to a Sale, a Sale belongs to a Plot, a Plot belongs to a Project) and reports need to add things up across many records at once ("total payments received for Project X in March"). SQLite can do that in one query (a "join" and a "sum"); Hive cannot — it can only fetch one thing by its key.
- **Hive, via `hive` + `hive_flutter` — the sticky-note pad.** Everything that is *not* a financial record: app settings, which user is currently logged in, sidebar expanded/collapsed state, last-used table filters, window size/position, "don't show this tip again" flags. Hive is fast and needs no schema, which is exactly right for small bits of app state that don't need relationships or totals.

Practical rules:

- **Where the files live:** the SQLite database file and the Hive box files are stored in the OS's per-user app-data folder (e.g. `%APPDATA%\LandInvestmentSystem\`) — **never** inside the app's install/binary folder. This is what makes Section 15's "data survives upgrade/uninstall" requirement actually true: uninstalling the app doesn't touch this folder unless the user explicitly chooses to remove data.
- **Migrations:** every schema change (new table, new column) ships as a numbered `drift` migration. On launch, the app checks the database's current version and applies any pending migrations automatically. A migration must never destroy existing data — take an automatic backup copy of the database file immediately before applying migrations, so a failed migration can be rolled back.
- **Backup & restore:** Admin can, from Settings, export a copy of the local database file (optionally encrypted) for backup, and restore the app from a previously exported backup file. This is the offline equivalent of a server backup.
- **Money stays exact:** the "never use floating-point for money" rule in Section 12 applies to how numbers are *stored* in SQLite too — store currency as integer paise/lowest-unit or a fixed-precision decimal column, never a raw `double`/`REAL` column.

## 4. Core Development Principle

Every financial operation must be traceable, auditable, and validated. There is **no approval/review workflow** in this system (PRD §9) — every module is direct CRUD, scoped by role (Admin: full; Member: create + read on Sales/Purchases, read-only on Projects, no access to Investors — PRD §5/§11).

What replaces "approval" as the safety net is traceability, not a second person's sign-off:
- Statuses model each entity's own natural lifecycle (Project: `DRAFT…CLOSED`; Plot: `AVAILABLE…SOLD`; Installment: `PENDING…OVERDUE`) — none of these are approval gates, they describe where that record actually is.
- **Financial transaction records (payments, distributions) are never hard-deleted** — a correction is a new linked `VOID`/`REVERSE` entry, so both the original and the correction stay visible in the audit trail. This is a data-integrity default carried from PRD §9, applied directly by Admin with no one else's sign-off required — not an approval control. (PRD §18 Open Question 6 leaves room to change this if the client wants literal hard delete on transactions too — check before assuming either way.)
- Non-financial master data with no transactions ever recorded against it (e.g. a Plot nobody has sold) may be hard-deleted outright by Admin — ordinary CRUD, not subject to the rule above.

## 5. Compliance & Financial Law Principle

Do not invent laws, tax rules, accounting standards, securities regulations, or statutory requirements. PRD §12 already documents the India-context considerations relevant here — RERA applicability to plotted layouts, SEBI Collective Investment Scheme risk in pooled investor funding, the Benami Transactions Act, Income Tax Act provisions (business-income treatment, Section 43CA/50C circle-rate risk, TDS u/s 194-IA, cash-transaction limits u/s 269SS/269T/269ST), GST ambiguity on developed land, Stamp Duty & Registration, and KYC/FEMA — each already translated into a concrete design implication in PRD §12.8. Implement those exactly as listed; do not add new legal claims, and do not remove the "not legal certainty — jurisdiction-specific review required" framing anywhere it appears in UI copy (compliance flags, report footers, Settings/About).

## 6. Roles & Permissions — Exactly Two, No Exceptions

Implement precisely the two-role model in PRD §5/§11 — do not add a third role, and do not soften the Investor restriction "for convenience."

| | Admin | Member |
|---|---|---|
| Projects | Full CRUD | Read-only |
| Sales (Income) / Purchases (Expenses) | Full CRUD | Create + Read |
| Plots, Buyers, Landowners | Full CRUD | Read-only |
| Expenses | Full CRUD | Create + Read |
| **Investors / Investments / Ownership / Distributions** | **Full CRUD** | **No access whatsoever** — no route, no local-data read, no partial/redacted view |
| Reports | All | All except anything investor-related |
| Help / User Guide (Section 8A) | Full | Full, minus the Investor sub-section |
| Settings / User management | Full | None |

Enforce this **in the business logic layer, never by hiding a widget** — a Member triggering an Investor data read by any code path must get an authorization error, and a Project dashboard built for Member must never even load investor figures into memory, not filter them out in the UI (PRD §10, Acceptance Criteria AC-09.1–AC-09.4).

## 7. UI/UX Standards — Financial/Enterprise Software, Industry Standard

**Light theme only.** Design inspiration: banking software, accounting software, ERP systems, investment management dashboards. Avoid gaming-style UI, gradients, oversized cards, unnecessary animation, tiny or low-contrast text, confusing icons, excessive rounded containers, unnecessary popups. Prioritize clarity, accuracy, readability, consistency, and efficient desktop workflows over decoration.

Reuse the color system and typography scale from Section 3 exactly — do not redefine per screen. Every currency figure uses `amountLarge`/`amountMedium` and must visually dominate secondary metadata on its page. Use Indian number formatting everywhere (₹1,00,000 / ₹10,00,000 / ₹1,00,00,000) and one consistent date format (e.g. `03 Sep 2026`). Font must stay legible at every size in the scale — no text below the `secondary` (13px) tier anywhere, no low-contrast gray-on-white combinations outside the defined `textSecondary`/`textDisabled` tokens.

## 8. Desktop UX Conventions

Reuse the already-built persistent sidebar, top bar, breadcrumb, and `PageHeader`. Every listing screen needs search, filter, sort, date-range filter, status filter, pagination, correct currency/date formatting, status badges, and explicit empty/loading/error states. Support keyboard navigation. Test every screen at 1280×720, 1366×768, and 1920×1080 — no overflow, no clipped content, no overlapping widgets, no broken dialogs.

## 8A. In-App User Guide — "Help / How to Use This App" Tab (new in v3)

Add a permanent, always-visible sidebar item — **Help / User Guide** — so a new employee can learn the whole app without asking a colleague.

- **Structure:**
  - A "Getting Started" page: plain-language walkthrough of first login and what the dashboard is showing.
  - One sub-section per major module — Projects, Landowners, Plots, Buyers/Sales, Installments, Expenses, Investors (Admin-only), Reports, Settings. Each sub-section explains, in non-technical language: what the module is for, the steps for the most common task there, and one line on *why* it matters (e.g. "Recording a payment here is what keeps the Receivables report accurate").
  - A keyword search box across all Help content.
- **Role-aware, same rule as Section 6:** Member's Help tab hides the Investor sub-section entirely — not grayed out, not present-but-disabled.
- **Embedded User Guide PDF:** the full `Land-Investment-System-User-Guide.pdf` ships as an app asset and opens inside this tab in an embedded PDF viewer (`syncfusion_flutter_pdfviewer` — free community license fits this use case — or `flutter_pdfview`; confirm the current best-maintained option on pub.dev when this phase starts). Also include a button to open the PDF in the user's default PDF app or save-as, reusing the same PDF-share mechanism as Section 10.
- **Content only, not logic:** the Help tab never displays real financial data — it carries no data-security risk beyond correctly hiding the Investor sub-section for Member.

## 9. Form & Validation Standards — Mandatory/Optional Indication, Industry Standard

Every field is marked **required** or **optional**, one convention app-wide: `Field Name *` for required, `Field Name (Optional)` for optional — never ambiguous. Validate at both the field level and the business-rule boundary (in business logic, never UI-only). Every validation message is specific and actionable, referencing the real value where relevant — *"Payment amount cannot exceed the outstanding balance of ₹20,00,000"*, *"Total ownership cannot exceed 100%"*, *"This project code already exists"* — never *"Something went wrong."* Confirmation dialogs (with a reason field where the action is high-impact) are required for: voiding/reversing a transaction, changing ownership, closing a project, recording a distribution. Disable the submit button while a request is in flight so a double-click can never create a duplicate financial transaction.

## 10. Documents, Reports & PDF Generation/Sharing

Every report and statement listed in PRD §10 (Project, Portfolio, Investor, Buyer/Sales, Landowner/Purchases, Profit/Loss, Cash-flow, Receivable, Payable, Investment, Portfolio, Audit) must be **exportable as PDF** (Excel/CSV where the PRD specifies it too), and that PDF must be **shareable directly from the app** — save-as, print, and hand off to the OS share/print dialog, not just "visible on screen."

- Use a maintained Flutter PDF-generation approach capable of producing the document in-memory and handing it to Windows' native save/print flow (e.g. the `pdf` + `printing` package pairing is a common, well-supported choice) — confirm the current best option against `pub.dev` when this phase starts rather than assuming a specific version now.
- An Investor Statement PDF must show **Capital Contributed and Profit Earned as two separate, clearly labeled figures**, never netted into one number (PRD §7.5, Acceptance Criteria AC-11.2) — Investors have no login of their own, so this PDF (generated and shared by Admin) is their only view into their position.
- Any legal/financial report that touches the PRD §12 compliance considerations (e.g. anything referencing circle rate, TDS, or cash-transaction flags) must carry the same "not legal certainty" disclaimer in the exported PDF that appears in-app — the disclaimer travels with the document, not just the screen.
- A Member-requested report must never contain investor-related data, in the PDF or anywhere else (Acceptance Criteria AC-11.3).

## 11. Notifications — WhatsApp (Mandatory) + SMS (Optional, Config-Gated)

Per PRD §10: every relevant action (payment recorded, installment overdue, distribution recorded, project status change) notifies the concerned party — a system user (Admin/Member) or a non-login party (Buyer, Landowner, Investor) reached via their stored contact number.

- **WhatsApp is mandatory** for every relevant action — this is not optional and not deployment-configurable off.
- **SMS is optional**, off by default, toggled **only via environment/deployment configuration, never a code change**. If a client hasn't purchased the SMS add-on, SMS sending must be fully inert — no attempt made, no charge incurred — while WhatsApp and everything else keeps working normally.
- A notification-channel failure (WhatsApp or SMS) must **never** block, roll back, or fail the underlying business action — the payment/sale/distribution saves regardless; a failed send is logged for retry (Acceptance Criteria AC-12.5). Write this as a hard architectural boundary: the notification call must not be awaited inline in a way that can fail the transaction — fire it after the business write commits, or queue it.

## 12. Financial Precision & Business Rule Centralization

Never use unsafe floating-point arithmetic for money — use a fixed-precision/decimal approach and one explicit, documented rounding policy (and store it that way in SQLite too, per Section 3A). Every formula in PRD §7 (Actual Project Cost, Plot Cost Allocation, Net Sale Proceeds & Profit/Loss, Ownership %, Investor Profit/ROI/Settlement, Receivables/Payables/Cash Flow, Break-Even, Commission) lives in one centralized, independently unit-tested calculation layer — never re-implemented inline in a widget, provider, or screen. If two screens need the same number, they call the same function.

## 12A. Formula Explainability — "How Is This Calculated?" (new in v3)

Every screen that shows a **computed** financial figure — Profit, Plot Cost Allocation, Ownership %, Investor ROI/Settlement, Receivables/Payables, Cash Flow, Break-Even, Commission, and every other formula listed in Section 12 / PRD §7 — must show a small "ⓘ How is this calculated?" icon or link right next to that figure.

Tapping it opens a popup (or side panel) with three things, in this order:

1. **The formula in plain words**, not just symbols — e.g. *"Profit = Total Sale Value − Total Project Cost."*
2. **A one-line definition of each term**, written for someone without an accounting background — e.g. *"Total Project Cost = everything spent acquiring and developing this land, including landowner payments and expenses."*
3. **The real numbers for this exact record**, not a generic textbook example, e.g.:
   ```
   Profit = Sale Value − Total Cost
          = ₹50,00,000 − ₹35,00,000
          = ₹15,00,000
   ```

**Critical rule:** this popup must call the *exact same* centralized calculation function from Section 12 that produced the number already on screen — never a second, separately written copy of the formula. This guarantees the explanation can never drift out of sync with the real number. If a formula changes in Section 12, its popup updates automatically because it's calling the same function, not a hardcoded string.

Applies at minimum to: Project dashboard, Plot detail, Sale detail, Installment schedule, Investor Statement (Admin-only), Profit & Loss report, Cash-flow report, Receivables/Payables screens, Break-Even view, Commission calculations.

## 13. Security & Authentication

Enforce Section 6's role table in business logic on every action, not just by hiding a button — a Member must not be able to reach Investor data or edit anything beyond Sales/Purchases entries by any path, including a direct local-database read. Authentication: v1 — email + password against the local SQLite `users` table, matching PRD §11's baseline (strong hashing, secure sessions with expiry/revocation, rate limiting, authentication audit log). Because there is no server (Section 3A), "session" here means the local logged-in state kept in Hive, cleared on logout/timeout.

## 14. Testing Mandate — Not Optional, Industry Standard

- **Unit tests** for every formula in §12 and every validation rule in §9, using the PRD §7.9 worked-example numbers as fixtures.
- **Widget tests** for every form, dialog, table, and UI state (loading / empty / error) — including that required/optional indicators render correctly and validation messages match §9's specificity bar.
- **Integration tests** for full workflows: the PRD §7.9 end-to-end example, the §8 distribution flow (now a direct save, no approval step to simulate), and a PDF-export round trip (generate → verify content → confirm the share/print call is invoked).
- **Negative tests** for every case in the Acceptance Criteria document (AC-01 through AC-12), including the role-boundary cases in AC-09 (Member reaching for Investor data, Member attempting Delete/Edit anywhere).
- **Notification tests**: mock the WhatsApp/SMS provider and assert (a) the business record still saves when the mock fails, per §11, and (b) SMS is never attempted when the env flag is off.
- **Local data tests (new in v3):** CRUD round-trip for every SQLite table via `drift`; a migration test that applies pending migrations to a sample older-version database file and confirms existing data survives intact; an integration test that closes and relaunches the app and confirms all data (records + Hive settings) is still there.
- **Help tab tests (new in v3):** every module listed in Section 8A has a corresponding Help entry; Member's Help tab never renders the Investor sub-section; the embedded User Guide PDF opens without error.
- **Formula popup tests (new in v3):** for a sample record on every screen listed in Section 12A, assert the popup's three displayed numbers exactly match the output of the centralized calculation function — not a hand-typed duplicate.
- **UI tests** at 1280×720, 1366×768, and 1920×1080.

A feature is complete only when **UI + business logic + validation + persistence + error handling + role enforcement + audit + Help entry + formula popups (where it shows a computed figure) + tests** are all done — never mark something complete because its screen merely renders.

## 15. Windows Installer Requirements

Produce a proper Windows installer: correct installation, Start Menu shortcut, optional Desktop shortcut, correct app name/icon/version display, safe upgrade handling, proper uninstall. Business data (the SQLite database and Hive boxes, Section 3A) is stored outside the application's temporary/binary directory, and is preserved across upgrade/uninstall unless the user explicitly chooses to remove it. Bundle the `Land-Investment-System-User-Guide.pdf` as an installed asset so the Help tab (Section 8A) can open it even without an internet connection.

## 16. Phased Execution Rule

Do not build the remaining scope in one uncontrolled step. Phase 1 is done. **Immediately after Phase 1 and before Phase 2, set up the Local Data Layer (Section 3A) — the SQLite/`drift` schema and Hive boxes — since every phase from here on reads and writes through it, not through any placeholder/mock.** From Phase 3 onward, every feature phase's Definition of Done also includes: (a) its Help tab entry (Section 8A), and (b) formula-explainability popups for any computed figure it introduces (Section 12A). These two are not a separate later phase — they ship together with the feature that needs them, the same way audit logging does.

```
Phase 2  — Local Data Layer (SQLite via drift + Hive) + Authentication + two-role permission enforcement
Phase 3  — Project + landowner + land acquisition (+ Help entry, no formulas yet)
Phase 4  — Investors + ownership + investments (Admin-only, end to end) (+ Help entry + Ownership % formula popup)
Phase 5  — Expenses + financing + maintenance + actual cost (+ Help entry + Actual Project Cost formula popup)
Phase 6  — Parent land + plots + cost allocation (+ Help entry + Plot Cost Allocation formula popup)
Phase 7  — Buyers + sales + sale agreements (+ Help entry + Net Sale Proceeds & Profit/Loss formula popup)
Phase 8  — Payment schedules + installments + transactions (Sales/Purchases entries for Member) (+ Help entry)
Phase 9  — Receivables + payables + cash flow (+ Help entry + Receivables/Payables/Cash Flow formula popups)
Phase 10 — Profit/loss + investor profit + distributions (direct CRUD, no approval step) (+ Help entry + Investor Profit/ROI/Settlement formula popup)
Phase 11 — Audit log (+ Help entry)
Phase 12 — Documents + PDF report/statement generation & sharing + WhatsApp/SMS notifications (+ Help entry, embed User Guide PDF viewer per Section 8A)
Phase 13 — Dashboard + analytics + final UX polish (+ Break-Even / Commission formula popups if not already covered; final pass to confirm every computed figure app-wide has a popup)
Phase 14 — Complete unit/widget/integration/negative/UI/notification/local-data/Help-tab/formula-popup testing
Phase 15 — Windows release build + installer (bundle User Guide PDF) + shortcuts + uninstall/upgrade testing
```

After every phase: run static analysis, run the relevant tests, fix every error, verify business rules against the Acceptance Criteria document, verify UI/UX against Sections 7–9 above, verify role enforcement against Section 6, verify auditability, verify local data survives a restart (Section 3A). Do not move to the next phase until the current one is stable.

**At the end of every phase, report using this exact structure:**
- Completed features
- Remaining work
- Tests created
- Tests passed
- Known issues
- Business rules implemented
- UI/UX verification
- Help tab entries added
- Formula popups added
- Next phase

## 17. Final Rule

Do not take shortcuts. Do not fabricate financial calculations. Do not invent legal requirements — design to *support* compliance and state plainly, wherever relevant, that jurisdiction-specific legal/tax review is required before go-live (PRD §12). Never silently modify or hard-delete a financial transaction record — use `VOID`/`REVERSE` instead. Never let Member reach Investor data or perform Delete/Edit outside Sales/Purchases, through any path. Never let local data (Section 3A) live inside the app's install folder, and never let a migration run without a backup first. Never ship a computed financial figure without its "How is this calculated?" popup (Section 12A), and never let that popup's numbers come from anywhere but the same centralized function that produced the number on screen. Keep these pairs distinct everywhere, in code and in the UI:

```
profit            ≠  cash flow
sale value        ≠  cash received
capital           ≠  profit
receivable        ≠  revenue received
payable           ≠  expense paid
```

Every module must be complete end-to-end — UI, logic, validation, local persistence, error handling, role enforcement, audit, notifications, Help documentation, formula explainability, and tests — before it is considered finished.
