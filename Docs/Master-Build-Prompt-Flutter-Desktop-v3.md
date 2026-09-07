# Master Build Prompt
## Land Investment, Development & Sales Management System — Flutter Windows Desktop

<span class="doc-meta">Version 3 — updated from v2 (PRD v2.2 / User Flow v1.1 / Acceptance Criteria v1.1) to add: fully local persistence via Hive + SQLite (no server), an in-app "Help / User Guide" tab that embeds the attached user-guide PDF and a role-based walkthrough of the User Flow document, and a mandatory "How is this calculated?" formula-disclosure affordance next to every computed financial figure on every screen.</span>

---

## How to Use This Prompt

1. Keep this file in the project repo alongside:
   - `Land-Investment-System-PRD.md` (v2.2) — business requirements: entities, formulas, roles, workflows, legal/compliance considerations.
   - `Land-Investment-System-User-Flow.md` (v1.1) — screen-by-screen navigation per role. This is also the source content for the in-app walkthrough in Section 12.
   - `Land-Investment-System-Acceptance-Criteria.md` (v1.1) — Given/When/Then test cases per feature.
   - `Land-Investment-System-User-Guide.pdf` — the end-user guide, bundled as an in-app asset and rendered inside the app per Section 12. This is new in v3.
   - The existing `land_investment_app/` codebase — Phase 1 is already built (Section 3).
2. Paste this whole document as the task prompt to your coding agent (e.g. Claude Code), with the repo open and the four documents above attached.
3. **This prompt defines *how* to build it** (architecture, UI/UX standards, validation conventions, testing mandate, phasing). **The PRD defines *what* to build.** Implement business rules exactly as the PRD states them. If something is genuinely ambiguous, stop and flag it as an open question (PRD §18) rather than guessing.
4. Work strictly in the phases in Section 19. Do not generate the whole application in one uncontrolled step.

---

## 1. Role

You are a Senior Flutter Desktop Engineer, Product Architect, Financial Software UX Specialist, QA Engineer, and Compliance-Aware Business Analyst. Build like a serious financial/business system, not a CRUD demo: every financial operation must be traceable and auditable, and financial transaction records are corrected through a logged reversal, never a silent edit.

## 2. Mission

Build a production-ready Windows desktop application: **Land Investment, Development & Sales Management System**, exactly as specified in the attached PRD (v2.2) — land acquisition, landowners, investors/ownership (Admin-only), expenses, parent land & plot subdivision, buyers & sales, installments, receivables/payables/cash flow, profit & loss, investor profit distribution, audit history, documents & PDF-shareable reports, WhatsApp/SMS notifications — built for exactly two roles, **Admin** and **Member**, with **no approval/review workflow anywhere**: every permitted action is direct CRUD. The app is **fully local/offline**, storing all data on the Windows machine via the persistence layer in Section 7 — there is no remote backend.

## 3. Already-Built Foundation — Phase 1 (do not redo, do not fork)

Phase 1 (project foundation, theme, application shell, and full navigation) is complete and unaffected by the PRD's v2.2 role/workflow changes, or by v3's persistence and Help-tab additions — build on top of it; do not create a parallel/duplicate theme, router, or shell.

| Piece | Location | Notes |
|---|---|---|
| Color system | `lib/core/theme/app_colors.dart` | The only place colors are defined. Semantic: green=paid/completed/profit/positive cash flow; amber=pending/upcoming/warning/partial; red=overdue/loss/failed/critical; blue=info/active. Never color alone — pair with icon/text/badge. |
| Typography | `lib/core/theme/app_typography.dart` | Inter font. Page title 26px / section title 20px / card title 17px / body 15px / secondary 13px / table header 13px / table cell 14px / button 15px / input 15px. `amountLarge` (28px/700) and `amountMedium` (18px/700) exist specifically so every currency figure is the most visually prominent thing on its screen — use them for all money, never `body`/`bodyMedium`. |
| Theme assembly | `lib/core/theme/app_theme.dart` | Single light `ThemeData`. No dark theme. |
| Routing | `lib/core/routing/app_routes.dart` + `app_router.dart` | Single source of truth for all routes, registered inside one `ShellRoute`. **Add one new route in v3**: the Help/User Guide screen (Section 12), reachable to both roles. |
| Navigation tree | `lib/core/navigation/nav_item.dart` + `nav_items_data.dart` | Full sidebar structure. Investors section renders conditionally — present for Admin, entirely absent (not just disabled) from the tree Member sees, consistent with PRD §5/§11's "Member must have no visibility into Investor data at all." **Add in v3**: a "Help / User Guide" item pinned near the bottom of the sidebar, visible to both roles (Section 12). |
| Shell | `lib/shared/widgets/app_shell.dart`, `sidebar/`, `top_bar/`, `breadcrumb/` | Persistent sidebar + top bar + breadcrumb wrapping every route. |
| Reusable page pieces | `lib/shared/widgets/page/page_header.dart`, `states/placeholder_page.dart` | `PageHeader` is the standard title row every screen uses; replace `PlaceholderPage` module-by-module as each feature is built. **Add in v3**: a shared `FormulaInfoButton` widget (Section 11) used beside every computed figure app-wide. |
| State | `lib/shared/providers/navigation_providers.dart` | Riverpod `StateNotifierProvider` for sidebar expand/collapse. |
| Stack | Flutter, `flutter_riverpod`, `go_router`, `google_fonts`, `window_manager`, Clean Architecture / feature-first | Matches `lib/features/<name>/{data,domain,presentation}/` — follow this structure for every feature added from Phase 2 on. **Add in v3**: `drift` (or `sqflite_common_ffi`) and `hive`/`hive_flutter` per Section 7. |

## 4. Core Development Principle

Every financial operation must be traceable, auditable, and validated. There is **no approval/review workflow** in this system (PRD §9) — every module is direct CRUD, scoped by role (Admin: full; Member: create + read on Sales/Purchases, read-only on Projects, no access to Investors — PRD §5/§11).

What replaces "approval" as the safety net is traceability, not a second person's sign-off:
- Statuses model each entity's own natural lifecycle (Project: `DRAFT…CLOSED`; Plot: `AVAILABLE…SOLD`; Installment: `PENDING…OVERDUE`) — none of these are approval gates, they describe where that record actually is.
- **Financial transaction records (payments, distributions) are never hard-deleted** — a correction is a new linked `VOID`/`REVERSE` entry, so both the original and the correction stay visible in the audit trail. This is a data-integrity default carried from PRD §9, applied directly by Admin with no one else's sign-off required — not an approval control. (PRD §18 Open Question 6 leaves room to change this if the client wants literal hard delete on transactions too — check before assuming either way.)
- Non-financial master data with no transactions ever recorded against it (e.g. a Plot nobody has sold) may be hard-deleted outright by Admin — ordinary CRUD, not subject to the rule above.

## 5. Compliance & Financial Law Principle

Do not invent laws, tax rules, accounting standards, securities regulations, or statutory requirements. PRD §12 already documents the India-context considerations relevant here — RERA applicability to plotted layouts, SEBI Collective Investment Scheme risk in pooled investor funding, the Benami Transactions Act, Income Tax Act provisions (business-income treatment, Section 43CA/50C circle-rate risk, TDS u/s 194-IA, cash-transaction limits u/s 269SS/269T/269ST), GST ambiguity on developed land, Stamp Duty & Registration, and KYC/FEMA — each already translated into a concrete design implication in PRD §12.8. Implement those exactly as listed; do not add new legal claims, and do not remove the "not legal certainty — jurisdiction-specific review required" framing anywhere it appears in UI copy (compliance flags, report footers, Settings/About, and the Help/User Guide screen in Section 12).

## 6. Roles & Permissions — Exactly Two, No Exceptions

Implement precisely the two-role model in PRD §5/§11 — do not add a third role, and do not soften the Investor restriction "for convenience."

| | Admin | Member |
|---|---|---|
| Projects | Full CRUD | Read-only |
| Sales (Income) / Purchases (Expenses) | Full CRUD | Create + Read |
| Plots, Buyers, Landowners | Full CRUD | Read-only |
| Expenses | Full CRUD | Create + Read |
| **Investors / Investments / Ownership / Distributions** | **Full CRUD** | **No access whatsoever** — no route, no local repository result, no partial/redacted view |
| Reports | All | All except anything investor-related |
| Help / User Guide (Section 12) | Full | Full, minus any Investor-referencing walkthrough steps |
| Settings / User management | Full | None |

Enforce this **in the local data/repository layer, never by hiding a widget** — since v3 has no remote server (Section 7), the repository classes sitting between the UI and the local SQLite database are the trust boundary: a Member's repository call for Investor data must throw an authorization error before it ever reaches the database, and a Project dashboard query built for Member must omit investor figures at the query/repository level, not filter them out after the fact in the UI (PRD §10, Acceptance Criteria AC-09.1–AC-09.4).

## 7. Data Layer — Local Persistence (Hive + SQLite)

This is a fully offline Windows desktop app — there is no remote backend. All persistence lives on local disk, under the OS-appropriate app-data directory (never inside the installer's Program Files/binary folder — this ties directly into Section 18's "preserved across upgrade/uninstall" requirement).

Use two local stores, each for what it's actually good at. Do not use Hive for anything needing relational integrity, and do not use SQLite for simple non-financial UI state:

- **SQLite (via `drift` — preferred, for its type-safe queries and built-in migrations — or `sqflite_common_ffi` for desktop) is the system of record for every relational/financial entity**: Projects, Landowners, Investors/Investments/Ownership, Expenses, Parent Land & Plots, Buyers & Sales, Installments/Payment Schedules, Receivables/Payables, Profit & Loss records, Distributions, Audit Log, Documents metadata, and Users/Auth. These entities have foreign-key relationships, need transactional multi-table writes (e.g. a payment write must also write an audit row and update an installment status atomically), and are queried with joins/aggregates for every report in Section 13 — exactly what SQLite/drift is built for and Hive is not.
- **Hive is for lightweight, non-relational local app state only**: the current logged-in session token/expiry, UI preferences (sidebar collapsed state, last-used filters, table column widths, window size/position), and cached non-financial reference data. **Never store a financial transaction, an audit entry, or anything from Section 15's centralized calculation layer in Hive** — it has no schema, no foreign keys, and no transactional guarantees strong enough for records that Section 4 requires to be traceable and auditable.
- Every write to a financial entity happens inside a single SQLite transaction (a database transaction, not to be confused with a business "Transaction" record) — a payment insert + installment status update + audit row insert either all succeed or all roll back together.
- With no server, "server-side enforcement" language elsewhere in this document means **the local data/repository layer** — it must be exactly as strict as if it were remote. A Member must not be able to reach Investor tables through any repository call, and this is enforced in the data-access layer itself, not just by hiding a widget (Section 6 applies in full).
- Define the SQLite schema (tables, foreign keys, indexes) once, in one place, migrated with drift's/sqflite's migration mechanism — never hand-edit the database file structure ad hoc. Every schema change ships as a versioned migration so app upgrades (Section 18) never silently lose or corrupt existing user data.
- **Back up before migrating**: on first launch after an app update that includes a schema migration, copy the existing database file before running the migration, so a failed migration cannot destroy the user's only copy of their financial records.

## 8. UI/UX Standards — Financial/Enterprise Software, Industry Standard

**Light theme only.** Design inspiration: banking software, accounting software, ERP systems, investment management dashboards. Avoid gaming-style UI, gradients, oversized cards, unnecessary animation, tiny or low-contrast text, confusing icons, excessive rounded containers, unnecessary popups. Prioritize clarity, accuracy, readability, consistency, and efficient desktop workflows over decoration.

Reuse the color system and typography scale from Section 3 exactly — do not redefine per screen. Every currency figure uses `amountLarge`/`amountMedium` and must visually dominate secondary metadata on its page. Use Indian number formatting everywhere (₹1,00,000 / ₹10,00,000 / ₹1,00,00,000) and one consistent date format (e.g. `03 Sep 2026`). Font must stay legible at every size in the scale — no text below the `secondary` (13px) tier anywhere, no low-contrast gray-on-white combinations outside the defined `textSecondary`/`textDisabled` tokens.

## 9. Desktop UX Conventions

Reuse the already-built persistent sidebar, top bar, breadcrumb, and `PageHeader`. Every listing screen needs search, filter, sort, date-range filter, status filter, pagination, correct currency/date formatting, status badges, and explicit empty/loading/error states. Support keyboard navigation. Test every screen at 1280×720, 1366×768, and 1920×1080 — no overflow, no clipped content, no overlapping widgets, no broken dialogs.

## 10. Form & Validation Standards — Mandatory/Optional Indication, Industry Standard

Every field is marked **required** or **optional**, one convention app-wide: `Field Name *` for required, `Field Name (Optional)` for optional — never ambiguous. Validate at both the field level and the business-rule boundary (in the local data/repository layer, never UI-only). Every validation message is specific and actionable, referencing the real value where relevant — *"Payment amount cannot exceed the outstanding balance of ₹20,00,000"*, *"Total ownership cannot exceed 100%"*, *"This project code already exists"* — never *"Something went wrong."* Confirmation dialogs (with a reason field where the action is high-impact) are required for: voiding/reversing a transaction, changing ownership, closing a project, recording a distribution. Disable the submit button while a request is in flight so a double-click can never create a duplicate financial transaction.

## 11. In-App "How Is This Calculated?" Formula Disclosure

Every screen that displays a computed/derived financial figure — Actual Project Cost, Plot Cost Allocation, Net Sale Proceeds & Profit/Loss, Ownership %, Investor Profit/ROI/Settlement, Receivables/Payables/Cash Flow, Break-Even, Commission, or any other figure produced by Section 15's centralized calculation layer — must carry a small **"ⓘ How is this calculated?"** affordance next to the figure: a shared `FormulaInfoButton` widget (Section 3), placed consistently beside every `amountLarge`/`amountMedium` value app-wide.

- Tapping it opens a lightweight popover/dialog (not a full-page navigation) showing three things: the plain-language name of the formula, the formula itself in the same terms PRD §7 uses, and — wherever the screen has real values to plug in — this specific record's actual numbers substituted into the formula, not just the abstract version. For example: *"Profit = Net Sale Proceeds − Actual Plot Cost = ₹18,50,000 − ₹12,00,000 = ₹6,50,000."*
- The formula text shown must come from one shared source, co-located with (or generated from) the centralized calculation functions in Section 15 — never hand-typed separately per screen. Otherwise a formula change in the calculation layer silently drifts out of sync with what the popover tells the user, which is worse than showing nothing.
- This applies uniformly to every role that can see the figure at all — a Member viewing their permitted Sales/Purchases figures gets the same explanatory affordance as Admin viewing Investor figures; it is never withheld as a "power-user" feature.
- Keep the popover consistent with Section 9's "no unnecessary popups" restraint — this is the one deliberate, useful exception, because financial-software users routinely need to verify a number, and hiding the formula erodes trust in the system.

## 12. In-App Help — "User Guide" Tab & Role-Based User Flow Walkthrough

Add a persistent navigation item — visible to both Admin and Member, positioned near the bottom of the sidebar alongside Settings rather than mixed in with the financial modules — labeled **"Help / User Guide."** This is a first-class screen, not a placeholder, shipped in the phase noted in Section 19.

The Help screen has two parts:

1. **Embedded PDF User Guide.** Bundle the attached `Land-Investment-System-User-Guide.pdf` as an app asset (e.g. `assets/docs/user_guide.pdf`) and render it in-app with a maintained Flutter PDF viewer for desktop — confirm the current best option against `pub.dev` when this phase starts rather than assuming a version now (`syncfusion_flutter_pdfviewer` and `flutter_pdfview` are common choices with Windows-desktop support). Provide page navigation and zoom, plus a "Save As / Print" action that reuses the same PDF share plumbing built in Section 13 — the user must be able to get the guide onto their own disk or a printer, not just scroll it on screen. If a later app update ships a revised guide, only the bundled asset changes; there is no in-app editing of the guide itself.
2. **Role-based User Flow walkthrough.** Alongside the PDF, render a lightweight in-app step list (not the PDF itself) that mirrors the attached `Land-Investment-System-User-Flow.md` for whichever role is currently logged in — Admin sees the full flow, including Investors; Member sees only the screens Member can reach, consistent with Section 6 (never show Member a walkthrough step referencing Investor screens, even as inert reference material). Structure it the way the source document is structured — by role, then by module, then by screen — so it works as an in-app table of contents for a first-time user: "Recording a Sale," "Adding an Installment Payment," "Viewing Cash Flow," etc., each with a short plain-language description of what that screen does and which fields matter.

This Help screen does not replace the PDF report exports in Section 13 — those are business documents about the user's *data*. The Help screen is onboarding/reference material about how to *operate the software*, and it sits outside the audit trail, formula, and role-data-restriction machinery that governs financial screens — except that Section 6's Investor-visibility restriction still applies to what the walkthrough displays for Member.

## 13. Documents, Reports & PDF Generation/Sharing

Every report and statement listed in PRD §10 (Project, Portfolio, Investor, Buyer/Sales, Landowner/Purchases, Profit/Loss, Cash-flow, Receivable, Payable, Investment, Portfolio, Audit) must be **exportable as PDF** (Excel/CSV where the PRD specifies it too), and that PDF must be **shareable directly from the app** — save-as, print, and hand off to the OS save/print dialog, not just "visible on screen."

- Use a maintained Flutter PDF-generation approach capable of producing the document in-memory and handing it to Windows' native save/print flow (e.g. the `pdf` + `printing` package pairing is a common, well-supported choice) — confirm the current best option against `pub.dev` when this phase starts rather than assuming a specific version now.
- An Investor Statement PDF must show **Capital Contributed and Profit Earned as two separate, clearly labeled figures**, never netted into one number (PRD §7.5, Acceptance Criteria AC-11.2) — Investors have no login of their own, so this PDF (generated and shared by Admin) is their only view into their position.
- Any legal/financial report that touches the PRD §12 compliance considerations (e.g. anything referencing circle rate, TDS, or cash-transaction flags) must carry the same "not legal certainty" disclaimer in the exported PDF that appears in-app — the disclaimer travels with the document, not just the screen.
- A Member-requested report must never contain investor-related data, in the PDF or anywhere else (Acceptance Criteria AC-11.3).

## 14. Notifications — WhatsApp (Mandatory) + SMS (Optional, Config-Gated)

Per PRD §10: every relevant action (payment recorded, installment overdue, distribution recorded, project status change) notifies the concerned party — a system user (Admin/Member) or a non-login party (Buyer, Landowner, Investor) reached via their stored contact number.

- **WhatsApp is mandatory** for every relevant action — this is not optional and not deployment-configurable off.
- **SMS is optional**, off by default, toggled **only via environment/deployment configuration, never a code change**. If a client hasn't purchased the SMS add-on, SMS sending must be fully inert — no attempt made, no charge incurred — while WhatsApp and everything else keeps working normally.
- A notification-channel failure (WhatsApp or SMS) must **never** block, roll back, or fail the underlying business action — the payment/sale/distribution saves regardless; a failed send is logged for retry (Acceptance Criteria AC-12.5). Write this as a hard architectural boundary: the notification call must not be awaited inline in a way that can fail the transaction — fire it after the business write commits to SQLite (Section 7), or queue it.

## 15. Financial Precision & Business Rule Centralization

Never use unsafe floating-point arithmetic for money — use a fixed-precision/decimal approach and one explicit, documented rounding policy. Every formula in PRD §7 (Actual Project Cost, Plot Cost Allocation, Net Sale Proceeds & Profit/Loss, Ownership %, Investor Profit/ROI/Settlement, Receivables/Payables/Cash Flow, Break-Even, Commission) lives in one centralized, independently unit-tested calculation layer — never re-implemented inline in a widget, provider, or screen. If two screens need the same number, they call the same function. This is also the single source the Section 11 formula-disclosure popovers read from.

## 16. Security & Authentication

Enforce Section 6's role table in the local data/repository layer on every action, not just by hiding a button — a Member must not be able to reach Investor data or edit anything beyond Sales/Purchases entries by any path, including a repository/DAO call invoked directly. Authentication: v1 — email + password checked against the local SQLite users table (strong hashing, e.g. bcrypt/argon2; session token held via Hive per Section 7 with expiry/revocation; rate limiting on login attempts; authentication audit log written to SQLite).

## 17. Testing Mandate — Not Optional, Industry Standard

- **Unit tests** for every formula in §15 and every validation rule in §9, using the PRD §7.9 worked-example numbers as fixtures.
- **Widget tests** for every form, dialog, table, and UI state (loading / empty / error) — including that required/optional indicators render correctly, validation messages match §10's specificity bar, and every `FormulaInfoButton` (Section 11) opens and shows correct substituted values.
- **Integration tests** for full workflows: the PRD §7.9 end-to-end example, the §8 distribution flow (a direct save, no approval step to simulate), a PDF-export round trip (generate → verify content → confirm the share/print call is invoked), and a database-migration round trip (seed a v(n) database → migrate → verify no data loss, per Section 7).
- **Negative tests** for every case in the Acceptance Criteria document (AC-01 through AC-12), including the role-boundary cases in AC-09 (Member hitting an Investor repository call, Member attempting Delete/Edit anywhere).
- **Notification tests**: mock the WhatsApp/SMS provider and assert (a) the business record still saves when the mock fails, per §14, and (b) SMS is never attempted when the env flag is off.
- **UI tests** at 1280×720, 1366×768, and 1920×1080, including the Help/User Guide screen (Section 12) and its embedded PDF viewer.

A feature is complete only when **UI + business logic + validation + persistence + error handling + role enforcement + audit + tests** are all done — never mark something complete because its screen merely renders.

## 18. Windows Installer Requirements

Produce a proper Windows installer: correct installation, Start Menu shortcut, optional Desktop shortcut, correct app name/icon/version display, safe upgrade handling, proper uninstall. The SQLite database and Hive box files (Section 7) are stored outside the application's temporary/binary directory, and are preserved across upgrade/uninstall unless the user explicitly chooses to remove them.

## 19. Phased Execution Rule

Do not build the remaining scope in one uncontrolled step. Phase 1 is done. Continue:

```
Phase 2  — Local data layer (SQLite/drift schema + migrations; Hive for session/UI state) + Authentication + two-role permission enforcement (Admin/Member)
Phase 3  — Project + landowner + land acquisition
Phase 4  — Investors + ownership + investments (Admin-only, end to end)
Phase 5  — Expenses + financing + maintenance + actual cost
Phase 6  — Parent land + plots + cost allocation
Phase 7  — Buyers + sales + sale agreements
Phase 8  — Payment schedules + installments + transactions (Sales/Purchases entries for Member)
Phase 9  — Receivables + payables + cash flow
Phase 10 — Profit/loss + investor profit + distributions (direct CRUD, no approval step)
Phase 11 — Audit log
Phase 12 — Documents + PDF report/statement generation & sharing + WhatsApp/SMS notifications
Phase 13 — "How is this calculated?" formula-disclosure popovers across every computed-figure screen (Section 11)
Phase 14 — In-app Help/User Guide tab: embedded PDF viewer + role-based User Flow walkthrough (Section 12)
Phase 15 — Dashboard + analytics + final UX polish
Phase 16 — Complete unit/widget/integration/negative/UI/notification testing
Phase 17 — Windows release build + installer + shortcuts + uninstall/upgrade testing
```

After every phase: run static analysis, run the relevant tests, fix every error, verify business rules against the Acceptance Criteria document, verify UI/UX against Sections 8–10 above, verify role enforcement against Section 6, verify auditability. Do not move to the next phase until the current one is stable.

**At the end of every phase, report using this exact structure:**
- Completed features
- Remaining work
- Tests created
- Tests passed
- Known issues
- Business rules implemented
- UI/UX verification
- Next phase

## 20. Final Rule

Do not take shortcuts. Do not fabricate financial calculations. Do not invent legal requirements — design to *support* compliance and state plainly, wherever relevant, that jurisdiction-specific legal/tax review is required before go-live (PRD §12). Never silently modify or hard-delete a financial transaction record — use `VOID`/`REVERSE` instead. Never let Member reach Investor data or perform Delete/Edit outside Sales/Purchases, through any path. Never store a financial transaction, audit entry, or calculation-layer output in Hive — SQLite (Section 7) is the system of record for anything traceable/auditable. Never let a Section 11 formula popover show text that isn't generated from, or kept in sync with, the centralized calculation layer (Section 15). Keep these pairs distinct everywhere, in code and in the UI:

```
profit            ≠  cash flow
sale value        ≠  cash received
capital           ≠  profit
receivable        ≠  revenue received
payable           ≠  expense paid
```

Every module must be complete end-to-end — UI, logic, validation, persistence, error handling, role enforcement, audit, notifications, and tests — before it is considered finished.
