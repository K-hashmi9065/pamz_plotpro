---
title: "Land Investment, Development & Sales Management System"
---

# Land Investment, Development & Sales Management System
## Product Requirements Document (PRD)

<span class="doc-meta">
**Version:** 2.2 (roles simplified; notifications added) &nbsp;|&nbsp; **Status:** Draft for sign-off &nbsp;|&nbsp; **Owner:** Kamran Hashmi &nbsp;|&nbsp; **Currency:** INR (₹), configurable &nbsp;|&nbsp; **Primary jurisdiction:** India
</span>

---

## 0. Document Control & Change Log

This PRD merges two prior drafts into one requirements document:

- **Draft A** — an initial PRD scoped from handwritten project notes (plots, investor shares, expenses, commission).
- **Draft B** — a detailed enterprise-grade PRD covering roles, entities, payment architecture, ledger, RBAC and a phased roadmap.

**v2.0 — merge:**
- Kept Draft B's structure as the backbone — it is the more rigorous, audit-ready design (immutable ledger, Schedule → Installment → Transaction separation, project-as-financial-boundary principle).
- Folded in Draft A's plain-numbers worked example and simpler formula walkthroughs, useful for non-technical stakeholders.
- Reconciled formula naming so "cost," "profit," "cash received," and "distributable profit" are never used interchangeably anywhere in this document.
- Added Section 12 — Legal, Regulatory & Financial Compliance — covered in neither prior draft.
- Added a Glossary (Section 4) so Indian land-business terms (Khata, Guntha, DLC/Circle Rate) and platform terms (Ownership Method, Distributable Profit) are unambiguous.

**v2.1 — scope narrowed to business requirements:**
- Removed the Technical Architecture section (mobile/backend stack, API structure, database collections, entity-relationship diagram). This PRD now states *what* the system must do, not *how* it is built — implementation architecture belongs in a separate technical design document once the stack is finalized.
- User flows moved out into a standalone companion document, **User Flow**, so this PRD stays focused on requirements rather than screen-by-screen navigation.
- Companion documents: **User Flow** (screen-by-screen flow per role) and **Acceptance Criteria** (testable Given/When/Then per feature).

**v2.2 — roles simplified, notifications added:**
- Replaced the five-role model (Admin/Project Manager/Accountant/Investor-login/Buyer-login) with exactly two login roles — **Admin** and **Member** (§5). Investor, Land Owner, Buyer, and Agent/Broker are now purely data records, never login users.
- **Investor data is now Admin-only, with no exception** — a hard requirement, not a default (§5, §10, §11, and Critical Product Rule 17).
- **Removed the approval/reject workflow entirely.** Every module is now direct CRUD. §9 was retitled from "Approval Workflow, Audit & Data Integrity" to **"Audit & Data Integrity"** — the audit log and data-integrity rules remain (including "never hard-delete a financial transaction record," kept as an explicit, flagged design default rather than something you stated — see §9 for the reasoning and how to override it).
- Added detailed notification requirements (§10): **WhatsApp is mandatory** for every relevant action; **SMS is optional and must be togglable via environment configuration alone, with no code change**, so it can be fully disabled for clients who haven't purchased it.

---

## 1. Executive Summary

A centralized platform to manage land acquisition, landowner payments, investor/shareholder funding, expenses, plot subdivision, buyer sales, installment collection, receivables/payables, profit & loss, investor profit distribution, documents, and audit history — across multiple independent land projects.

**Core principle:** *Every project is an independent financial boundary.* Nothing (an expense, a payment, an investor contribution) exists without belonging to exactly one project.

---

## 2. Problem Statement

Land trading businesses typically run on spreadsheets, paper registers, and messaging apps. This causes:
- Incomplete or double-counted expenses, leading to an incorrect **actual project cost**.
- Ambiguous ownership — who funded what % of a project, and what they're owed at settlement.
- Installment errors — no clean distinction between what a buyer *agreed* to pay, what's *scheduled*, and what's *actually paid*.
- No audit trail — payment edits, price changes, and ownership changes are not traceable.
- Profit calculated from memory or a single spreadsheet cell, not from underlying transactions — a source of investor disputes.

**Goal:** one system that is the single source of truth for land, investors, buyers, and project finances — so profit and settlement figures are *derived*, never manually typed in.

---

## 3. Goals & Non-Goals

### In scope (v1 / MVP and near-term)
- Multi-project management, each an independent financial boundary.
- Land acquisition and landowner installment tracking.
- Expense tracking across defined categories, rolling up to actual project cost.
- Investor management with project-specific ownership %.
- Parent land → plot subdivision; plot-level cost allocation.
- Whole-land, plot-wise, multiple-plot, and mixed sales.
- Installment and partial payment support for both landowner-out and buyer-in cash flows.
- Receivables, payables, and cash-flow tracking.
- Project and plot-level profit/loss calculation.
- Investor profit calculation, ROI, and settlement.
- Distribution recording (direct CRUD, no approval gate — see §9).
- Two-role access control (Admin / Member) with Investor data restricted to Admin only.
- Documents, WhatsApp notifications (+ optional, config-gated SMS), and audit logs.
- Financial and portfolio reports.

### Explicitly out of scope for v1 (see Section 18 — Future Enhancements)
- Public buyer-facing marketplace / listing site.
- Online payment collection (UPI/payment gateway integration).
- GIS/map-based plot visualization.
- Accounting-software integration (Tally, Zoho Books).
- Multi-currency support (INR only for v1).

---

## 4. Glossary

| Term | Meaning |
|---|---|
| **Khata No. / Survey No.** | Land revenue record number identifying a specific parcel in Indian land records. |
| **Guntha / Bigha / Acre** | Traditional Indian land area units; system should store canonical area in sq. ft. and display in the locally used unit. |
| **DLC Rate / Circle Rate** | Government-notified minimum land valuation for stamp duty purposes; sale price below this can trigger tax consequences (see §12.4). |
| **Parent Land** | The originally acquired, undivided parcel before subdivision. |
| **Plot** | A subdivided, individually sellable unit of the parent land. |
| **Actual Project Cost** | Purchase price + all capitalized costs (acquisition, financing, registration, legal, brokerage, development, maintenance). Not the same as purchase price alone. |
| **Ownership %** | An investor's share of a *specific project's* capital pool — never a global attribute of the investor. |
| **Distributable Profit** | Realized project profit *after* deducting commissions, admin management fee (if any), and reserved amounts — the actual base for investor payouts. |
| **Settlement** | Original capital returned + profit earned − withdrawals already paid − adjustments. |
| **Realized Profit** | Profit from plots that are fully sold and paid for. |
| **Booked / Unrealized Profit** | Expected profit from plots that are sold/agreed but not yet fully collected — for forecasting only, not for distribution. |

---

## 5. Users & Roles

The system has exactly **two login roles**. There is no multi-step approval/reject workflow anywhere in the system — every permitted action is a direct Create/Read/Update/Delete (CRUD) operation (see §9 for how this interacts with financial audit integrity).

| Role | Access |
|---|---|
| **Admin** | Everything Member can do, plus full CRUD on every module — Projects (create/edit/delete), Investors and Investments (the only role that can see or manage investor data at all), Plots, Buyers, Sales, Expenses, Payments, Distributions, Settings, and user management. |
| **Member** | Can **create entries** and **view/read Sales (Income)** and **Purchases (Expenses)**. Read-only access to Projects (cannot create, edit, or delete a project). **No visibility into Investor data at all** — Investor screens, fields, reports, and API responses must be inaccessible to Member. |

Investors, Land Owners, Buyers, and Agents/Brokers are **not login users** — they are managed as data records by Admin (and, for Sales/Purchases only, entered by Member). Where PRD sections below still describe an "Investor view" or "Buyer view," read that as *the Admin viewing that party's data*, not a separate portal login — see the companion **User Flow** document, which reflects this directly.

Every relevant action (a payment recorded, a distribution created, an installment overdue, etc.) triggers an outbound notification to the concerned party — see §10 for channels (WhatsApp mandatory, SMS optional).

---

## 6. Core Domain Model

### 6.1 Project — the financial boundary
Fields: ID, code, name, description, location, status, dates, assigned manager, land area, valuation, purchase price, actual cost, sale revenue, profit/loss, timestamps.

**Status lifecycle:**
```
DRAFT → NEGOTIATION → PURCHASE_PENDING → PURCHASED → FUNDING → ACTIVE
→ MAINTENANCE → SALE_PENDING → SOLD → PROFIT_CALCULATED → DISTRIBUTION → CLOSED
                                                                  ↘ CANCELLED
```

### 6.2 Parent Land & Plots
```
Parent Land
 ├── Plot A
 ├── Plot B
 └── Plot C ...
```
**Parent Land** stores: landowner, survey/Khata info, area, purchase price, purchase date, registration, documents.
**Plot** stores: plot number, area, dimensions, facing, location, status, expected price, sale price, buyer, sale date.

**Plot status lifecycle:** `AVAILABLE → RESERVED → BOOKED → SALE_AGREEMENT → PARTIALLY_PAID → FULLY_PAID → SOLD` (or `CANCELLED` from any pre-SOLD state).

### 6.3 Landowner & Purchase Agreement
A landowner may sell into multiple projects. The Purchase Agreement stores: project, landowner, purchase price, agreement/registration dates, payment terms, payment schedule, documents, outstanding amount.

**Example landowner installment plan:**
```
Purchase Price = ₹2,00,00,000
Schedule: ₹50,00,000 + ₹25,00,000 + ₹25,00,000 + ₹50,00,000 + ₹50,00,000
```
Every *actual* payment is its own immutable transaction (project, agreement, landowner, amount, date, method, reference, account, receipt, audit fields) — the schedule is a plan, the transaction is what really happened.

### 6.4 Investors & Ownership
An investor can hold different ownership % in different projects — **ownership is never stored on the Investor record itself.**
```
Project → ProjectInvestor → Investor
```
`ProjectInvestor` stores: project ID, investor ID, invested amount, ownership %, ownership method, investment date, status.

**Ownership methods:** `CAPITAL_BASED` (formula-driven, default) or `MANUAL` (admin override, e.g. for a sweat-equity partner).
```
Ownership % = Investor Contribution / Total Share Capital × 100
```
A finalized project's ownership % should total 100% unless explicitly configured otherwise (e.g., an unfunded admin residual — see Open Question in §21).

Investor commitments may themselves be paid in installments; each actual investment payment is stored as its own transaction, same as landowner payments.

### 6.5 Buyers & Sales
A buyer may purchase multiple plots, across multiple projects. Sale record stores: project, buyer, sale type, agreement amount, sale date, sale expenses, net sale proceeds, payment schedule, status, documents.

**Sale types:**
1. **Whole Land Sale** — entire Parent Land → one buyer.
2. **Plot-Wise Sale** — individual plots → individual buyers.
3. **Multiple Plot Sale** — one buyer purchases several plots in one sale.
4. **Mixed Sale** — some plots sold individually, remaining parcel sold in bulk.

Modeled as `Sale → SaleItems → Plot/Parcel` so any combination above is representable without special-casing.

**Example buyer installment plan:**
```
Sale Agreement = ₹1,00,00,000
Schedule: ₹10,00,000 + ₹15,00,000 + ₹25,00,000 + ₹25,00,000 + ₹25,00,000
```

### 6.6 Expenses & Cost Categories
Categories: `PURCHASE, ACQUISITION, FINANCING, REGISTRATION, LEGAL, BROKERAGE, DEVELOPMENT, MAINTENANCE, TAX, MARKETING, ADMINISTRATION, OTHER.`

Each expense stores: project, category, amount, date, vendor/payee, payment status, reference, **capitalization flag** (does this roll into Actual Project Cost, or is it a period expense?), notes, documents, created-by/last-edited-by (no separate approval field — see §9).

> Which costs are capitalized vs. expensed is an accounting policy choice — confirm the treatment with your CA (see §12.5) and keep it configurable per category rather than hardcoded.

### 6.7 Payment Architecture
Three distinct concepts, never merged:

| Concept | Meaning |
|---|---|
| **Payment Schedule** | The expected plan (e.g., 5 landowner installments). |
| **Payment Installment** | One expected installment within that plan, with its own due date and status. |
| **Payment Transaction** | An actual, immutable money movement against an installment. |

**Party types:** `LAND_OWNER, BUYER, INVESTOR, VENDOR`
**Transaction types:** `LAND_PURCHASE, LAND_SALE, INVESTMENT, EXPENSE, REFUND`
**Installment statuses:** `PENDING, PARTIALLY_PAID, PAID, OVERDUE, CANCELLED`
**Payment methods:** `CASH, BANK_TRANSFER, UPI, CHEQUE, DEMAND_DRAFT, OTHER` — see §12.4 for cash-limit compliance implications.

**Financial distinctions the system must never blur:**
```
Agreement Amount ≠ Scheduled Amount ≠ Actual Paid Amount
```
Example: Sale Agreement ₹2,50,00,000, Received ₹1,00,00,000 → Outstanding ₹1,50,00,000. **Profit is never the same figure as cash received.**

For a ₹30,00,000 installment with ₹10,00,000 received:
```
Installment = ₹30,00,000
Paid        = ₹10,00,000
Remaining   = ₹20,00,000
Status      = PARTIALLY_PAID
```

### 6.8 Financial Ledger
An immutable `FinancialTransaction` ledger: transaction ID, project ID, type, reference, debit, credit, amount, date, account, description, status, created-by.

**Types:** `LAND_PURCHASE, OWNER_PAYMENT, INVESTOR_DEPOSIT, INVESTOR_REFUND, EXPENSE, MAINTENANCE, SALE_RECEIPT, BROKERAGE, PROFIT_DISTRIBUTION, LOSS_ADJUSTMENT.`

**Never hard-delete financial history.** Use status `ACTIVE, VOIDED, REVERSED, CANCELLED` instead.

---

## 7. Financial Formula Engine

All formulas below must live in one centralized, unit-tested calculation layer — never re-implemented inline in UI code or duplicated across screens and reports.

### 7.1 Actual Project Cost
```
Actual Project Cost
  = Purchase Cost
  + Capitalized Acquisition Costs
  + Capitalized Financing Costs
  + Capitalized Development Costs
  + Capitalized Maintenance
  + Other Capitalized Costs
```

### 7.2 Plot Cost Allocation
Three supported methods:

**Area-based (recommended default):**
```
Cost per sq.ft = Parent Land Cost (or Actual Project Cost) / Total Allocated Area
Plot Cost      = Plot Area × Cost per sq.ft
```
**Percentage-based:** assign a fixed % of total project cost to each plot (e.g., corner plots weighted higher).
**Manual:** admin assigns cost directly, per plot.

Plot actual cost = allocated land cost + allocated acquisition + financing + development + maintenance + other applicable costs.

### 7.3 Net Sale Proceeds & Profit/Loss
```
Net Sale Proceeds = Gross Sale Revenue − Sale Expenses (brokerage, marketing, legal on that sale)

Project Profit = Net Sale Proceeds − Actual Project Cost
Project Loss   = Actual Project Cost − Net Sale Proceeds   (if negative profit)

Plot Profit = Net Plot Sale Proceeds − Allocated Plot Actual Cost
```

### 7.4 Ownership %
```
Ownership % = Investor Contribution / Total Share Capital × 100
```

### 7.5 Investor Profit, ROI & Settlement
```
Investor Profit = Distributable Project Profit × Investor Ownership %

ROI % = Investor Profit / Investor Capital × 100

Settlement = Original Capital + Investor Profit − Withdrawals Already Paid − Adjustments
```
Capital and profit must **always** be displayed as two separate figures — never netted into one number in the UI, to avoid investor confusion at tax time (capital return is not taxable income; profit is).

### 7.6 Receivables, Payables & Cash Flow
```
Receivables : Total Receivable, Received, Outstanding, Overdue, Upcoming
Payables    : Total Payable, Paid, Outstanding, Overdue, Upcoming

Cash Flow:
  Money In  = Buyer Payments + Investor Investments + Other Receipts
  Money Out = Landowner Payments + Expenses + Development + Maintenance + Other Payments
  Net Cash Flow = Money In − Money Out
```

### 7.7 Break-Even (early-warning indicator)
```
Break-even Area Sold (sq.ft) = Actual Project Cost / Average Realized Rate per sq.ft
```
Once cumulative sold area crosses this threshold, the project has recovered its full cost.

### 7.8 Commission
```
Commission = Commission % × Plot/Sale Price      (percentage model)
           OR a fixed Flat Amount per plot/sale   (flat model)
```

### 7.9 End-to-End Worked Example
```
Project: Green Valley

Land Purchase   = ₹2,00,00,000
Financing       = ₹10,00,000
Registration    = ₹5,00,000
Legal           = ₹2,00,000
Development     = ₹8,00,000
Maintenance     = ₹2,00,000
────────────────────────────
Actual Cost     = ₹2,27,00,000

Investor A = ₹50,00,000 →  50,00,000 / 1,00,00,000 × 100 = 50%
Investor B = ₹30,00,000 →  30%
Investor C = ₹20,00,000 →  20%
(Total Share Capital raised = ₹1,00,00,000)

Gross Sale Revenue = ₹3,00,00,000
Sale Expenses       = ₹10,00,000
Net Sale Proceeds   = ₹2,90,00,000

Project Profit = 2,90,00,000 − 2,27,00,000 = ₹63,00,000

Investor A Profit = 63,00,000 × 50% = ₹31,50,000
Investor B Profit = 63,00,000 × 30% = ₹18,90,000
Investor C Profit = 63,00,000 × 20% = ₹12,60,000

Investor A Settlement = Capital 50,00,000 + Profit 31,50,000 = ₹81,50,000
  → If ₹60,00,000 already distributed to A, remaining settlement = ₹21,50,000

ROI (Investor A) = 31,50,000 / 50,00,000 × 100 = 63%
```

**A smaller worked example (plot-level, from original notes), showing the same math at buyer scale:**
```
Plot sold for            ₹3,90,000
Allocated plot cost       ₹3,00,000
Commission (agent)          ₹5,000
Plot Profit = 3,90,000 − 3,00,000 − 5,000 = ₹85,000

If an investor holds 25% of that project:
  Investor's share of this plot's profit = 25% × 85,000 = ₹21,250
```

---

## 8. Distribution Workflow

```
Sale Completed
  ↓
Payments Reconciled
  ↓
Costs Finalized
  ↓
Profit/Loss Calculated
  ↓
Ownership Validated  (must total 100%, or explicit exception recorded)
  ↓
Investor Profit Calculated
  ↓
Distribution Recorded by Admin  (direct CRUD — no separate approval step, see §9)
  ↓
Distribution Payment
  ↓
Settlement Completed
  ↓
Project Closed
```
There is no multi-step approval/review gate — Admin creates the distribution record directly and it is immediately available for payment processing. Distribution rules (interim vs. final-only, minimum payout thresholds) should be configurable per project — see Open Question in §18. Recording a distribution triggers a notification to each investor (§10).

---

## 9. Audit & Data Integrity

There is no approval/reject workflow in this system — every module is direct CRUD, performed by Admin (full) or Member (create + Sales/Purchases read, per §5). Nothing requires a second person's sign-off before taking effect. What replaces "approval" as the safety net is **traceability**: every action is logged, and financial transaction records are never silently altered.

**Audit log** captures: user, action, entity, entity ID, old value, new value, timestamp, device/IP reference where appropriate, reason. Logged events include project create/edit/delete, ownership change, expense edit, sale-price change, payment record/edit/reversal, distribution record, profit recalculation.

**Data integrity rules:**
- Amount > 0; Ownership between 0–100; Plot area > 0; Sale price > 0.
- Referenced entities must exist (no orphaned records).
- A plot must be `AVAILABLE` to be sold; a sold plot cannot be sold again.
- A `CLOSED` project cannot receive normal financial edits.
- A distribution cannot exceed the distributable amount.
- **Financial transaction records (payments, distributions) are never hard-deleted** — a correction is made by recording a linked reversal/void entry, so the original and the correction both remain visible in the audit trail. This is a data-integrity safeguard, not an approval gate — it does not require anyone's sign-off, Admin performs it directly as one of their CRUD actions. **Non-financial master data** (e.g., a Plot definition with no sale ever recorded against it) may be deleted outright by Admin, per §5's "full CRUD."
  > *This is an explicit design choice, not something you specified — flagged so you can override it if you'd rather Admin be able to hard-delete a payment/distribution record outright. Removing it would mean a mis-entered payment simply disappears with no trace, which is why it's kept as a default; say so if that's not what you want.*

---

## 10. Documents, Dashboards, Notifications & Reports

**Documents** attach to: projects, land, landowners, agreements, investors, buyers, plots, payments, expenses, distributions. Types: `LAND_DEED, SALE_DEED, PURCHASE_AGREEMENT, SALE_AGREEMENT, REGISTRATION, LEGAL_DOCUMENT, PAYMENT_RECEIPT, EXPENSE_RECEIPT, INVESTOR_AGREEMENT, BUYER_DOCUMENT, OTHER.`

**Dashboards:**

| Dashboard | Shows | Visible to |
|---|---|---|
| Project | Purchase cost, additional costs, actual cost, valuation, expected/realized revenue, receivables, payables, profit/loss, ROI, inventory, cash flow | Admin (full) · Member (read-only, **investor figures excluded** — see below) |
| Portfolio | Total projects, active/completed, total investment, actual cost, current value, revenue, realized profit, unrealized value, investors | Admin only (contains investor totals) |
| Investor | Investment, # of projects, ownership, current value, realized/pending profit, distributions | **Admin only** — not visible to Member under any circumstance (§5) |
| Buyer / Sales | Purchases, contract value, paid, outstanding, next installment, overdue amount | Admin (full) · Member (read/create, per §5's "Sales (Income)") |
| Landowner / Purchases | Purchase value, paid, outstanding, next payment, overdue, payment history | Admin (full) · Member (read/create, per §5's "Purchases (Expenses)") |

When Member views the Project dashboard, any investor-related figure (investor count, ownership %, investor capital, distributions) must be omitted from that view entirely — not shown-then-hidden client-side, but excluded at the point the data is served, so there's no way to inspect it via the API either.

**Notifications:** every relevant action notifies the concerned party — Admin/Member as system users, and non-login parties (Buyer, Landowner, Investor) via their stored contact number. Triggers include: payment recorded (Sales or Purchases), upcoming/overdue installment, receipt generated, distribution recorded, project status change.

- **WhatsApp is the primary, mandatory notification channel** — every relevant action must trigger a WhatsApp message to the concerned party.
- **SMS is an optional, additional channel**, off by default, toggled on **only** via environment/deployment configuration — not a code change. If a client has not purchased the SMS add-on, SMS sending must be fully inert (no charge incurred, no attempt made) with the rest of the system, including WhatsApp notifications, completely unaffected.
- A notification-channel failure (WhatsApp or SMS) must never block or roll back the underlying business action — the payment, sale, or distribution is saved regardless of whether the outbound message succeeds; a failed notification is logged and can be retried, not treated as a transaction failure.

**Reports:** project, investor, buyer, landowner, expense, profit/loss, cash-flow, receivable, payable, investment, portfolio — exportable as PDF, Excel, CSV.

**Maintenance module** (recurring project costs — security, cleaning, electricity, road maintenance, land clearing, property tax): maintenance ID, project, category, description, frequency (`ONE_TIME, WEEKLY, MONTHLY, QUARTERLY, YEARLY, CUSTOM`), amount, due date, vendor, status, payment, receipt.

**Unsold inventory & valuation:** track total/sold/unsold area, total/sold/available/reserved/booked plots. Distinguish **realized profit** from **unrealized value/potential profit**. Maintain historical valuations (date, value, valuer, method, notes, documents).

---

## 11. Security, RBAC & Authentication

Server-side authorization is mandatory — UI hiding is not security. Every API call validates, in order:
```
Authentication → Authorization → Role → Permission → Project Access → Resource Access → Validation → Business Rules
```
**Roles:** `ADMIN, MEMBER` — exactly two, per §5. No approval-related permission exists in this system (no `*_APPROVE` permission) since there is no approval workflow (§9); every permission below is a direct CRUD grant.

**Permissions:**
```
PROJECT_VIEW            — Admin, Member
PROJECT_CREATE/EDIT/DELETE — Admin only

SALES_VIEW, SALES_CREATE       — Admin, Member
PURCHASES_VIEW, PURCHASES_CREATE — Admin, Member
SALES_EDIT/DELETE, PURCHASES_EDIT/DELETE — Admin only

INVESTOR_VIEW, INVESTOR_CREATE/EDIT/DELETE — Admin only (never Member, no exceptions)
DISTRIBUTION_VIEW, DISTRIBUTION_CREATE/EDIT/DELETE — Admin only

PLOT_VIEW, BUYER_VIEW, LANDOWNER_VIEW — Admin, Member
PLOT_CREATE/EDIT/DELETE, BUYER_CREATE/EDIT/DELETE, LANDOWNER_CREATE/EDIT/DELETE — Admin only

EXPENSE_VIEW, EXPENSE_CREATE — Admin, Member
EXPENSE_EDIT/DELETE — Admin only

REPORT_VIEW  — Admin, Member (investor-related reports excluded for Member)
SETTINGS_MANAGE, USER_MANAGE — Admin only
```
This list should be treated as the starting permission set for implementation, not necessarily exhaustive — extend it the same way (view/create open to both, edit/delete and anything investor-related restricted to Admin) as new modules are built.

**Authentication:** v1 — email + password. Future — phone OTP, Google/Microsoft SSO, 2FA. Security baseline: strong password hashing, secure sessions/JWT with refresh tokens, expiry, revocation, rate limiting, authentication audit log.

---

## 12. Legal, Regulatory & Financial Compliance Considerations

This section did not exist in either prior draft and is the most important addition in v2.0. It is **factual context to design around, not legal advice** — the specific treatment for your business must be confirmed with a practicing Chartered Accountant and a property lawyer before go-live, since these rules vary by state and change over time.

### 12.1 Real Estate (Regulation and Development) Act, 2016 (RERA)
Plotted-layout development (not just apartment construction) can fall under state RERA rules once the land area crosses a state-specific threshold (commonly 500 sq. m. or 8+ plots, but this varies by state). If applicable: the project must be **registered with the state RERA authority before advertising or accepting any booking amount**, a **separate escrow account** is required for a defined percentage of buyer receipts (earmarked for development), and periodic disclosures are mandatory. **Design implication:** the system should support an "escrow-earmarked" flag on buyer receipts and a project-level "RERA registration no." field, even before you decide whether a given project needs registration.

### 12.2 SEBI — Collective Investment Scheme (CIS) risk
Pooling money from multiple investors, where a third party manages the funds and investors share in profits without day-to-day control, can meet the legal definition of a **Collective Investment Scheme under Section 11AA of the SEBI Act, 1992** — which requires SEBI registration if unregistered pooling crosses regulatory thresholds. This is a real structural risk for exactly the "many investors, percentage profit-share" model this PRD describes. **Mitigation commonly used in practice:** structure investor participation through a formal legal entity (Partnership Firm, LLP, or Private Limited Company) with each investor as a partner/shareholder/LLP-partner under a written agreement, rather than informal fund pooling by an individual. Confirm this structuring with a securities lawyer.

### 12.3 Benami Transactions (Prohibition) Act, 1988
If land title is registered in one person's or one entity's name but the purchase money actually came from investors without a clear, documented legal arrangement, this can be construed as a **benami transaction**, which carries significant penalties. **Design implication:** every `ProjectInvestor` record and its underlying agreement document (see §6.4, §10) must be treated as core compliance evidence, not optional metadata — the system should make it structurally difficult to record an investment without an attached agreement document.

### 12.4 Income Tax Act, 1961
- **Business income vs. capital gains:** land bought with the clear intent to subdivide and resell is normally treated as **stock-in-trade**, with profit taxed as business income (not capital gains). This affects how "Actual Project Cost" and "Profit" in §7 should map to your tax filings — confirm classification with your CA.
- **Section 43CA / 50C:** if a plot's sale price is below the government-notified stamp duty value (circle rate/DLC rate), tax authorities can treat the higher circle-rate value as the deemed sale consideration, and the buyer may face a separate tax exposure on the difference under Section 56(2)(x). **Design implication:** capture circle-rate value per plot alongside actual sale price, and flag sales priced below it.
- **TDS under Section 194-IA:** a buyer purchasing immovable property worth ₹50 lakh or more must deduct 1% TDS and deposit it with the government, issuing Form 16B to the seller. **Design implication:** for sales at/above this threshold, the buyer payment schedule should show a TDS line item separate from the amount the business actually receives.
- **Cash transaction limits:** Sections 269SS/269T restrict cash loans/deposits of ₹20,000 or more; Section 269ST restricts cash receipts of ₹2,00,000 or more in aggregate from one person for one transaction (or related transactions), with penalties under 271D/271E. **Design implication:** the system should hard-flag (not silently allow) any `CASH` payment method entry that would breach these thresholds.

### 12.5 GST on land and "developed" plots
Sale of land, by itself, is outside GST's scope (Schedule III, CGST Act). However, where a project includes development work (roads, drainage, common infrastructure) bundled into the plot price, some Authority for Advance Ruling (AAR) decisions have held that the development-cost portion of the consideration can attract GST — rulings have not been fully consistent across states. **Design implication:** keep "land cost" and "development cost" as clearly separable line items per plot (not merged into one sale price) so a tax treatment can be applied correctly whichever way this settles for your project — confirm current treatment with your CA before pricing plots.

### 12.6 Stamp Duty & Registration Act, 1908
Every purchase agreement and sale deed should be registered, with stamp duty per applicable state schedule. **Design implication:** the `documents` module (see §10) should treat registration number and stamp-duty-paid status as required fields before a Sale can move to `SOLD`.

### 12.7 KYC, FEMA & AML
Capture PAN and Aadhaar (or equivalent) for landowners, buyers, and investors as standard KYC — this also supports the cash-limit and CIS-related controls above. If any investor or buyer is an NRI, **FEMA** rules restrict NRIs from purchasing agricultural land, plantation property, or farmhouses in India, which may directly affect who can legally participate in a given project.

### 12.8 Summary — what this means for the build
1. Add a `RegulatoryFlags` sub-object to Project (RERA-applicable?, RERA reg. no., escrow required?).
2. Never let a `ProjectInvestor` be created without a linked agreement document.
3. Structure investor participation via a registered entity, not ad hoc pooling — a legal, not technical, decision, but the system should assume it (e.g., "Investing Entity" concept, not just "Investor").
4. Store circle-rate value per plot next to actual sale price.
5. Hard-flag cash transactions at/above statutory thresholds instead of silently accepting them.
6. Keep land cost and development cost as separate line items, always.
7. Block a Sale from reaching `SOLD` status until registration number + stamp duty status are recorded.
8. **None of the above is a substitute for sign-off from your CA and a property lawyer** — treat this section as the requirements checklist to bring to that conversation, not as legal certainty.

---

## 13. Testing Strategy

- **Unit:** ownership, cost allocation, profit, ROI, settlement, payment, cash-flow calculations — every formula in §7 gets direct test coverage with the worked example numbers as fixtures.
- **Integration:** full path — create project → land → investor → expense → sale → payment → profit → distribution.
- **Security:** role, permission, project-level, and resource-level authorization on every endpoint.
- See the companion **Acceptance Criteria** document for the specific Given/When/Then cases to automate.

---

## 14. MVP Roadmap

| Phase | Scope |
|---|---|
| **1 — Foundation** | Auth, RBAC, users, projects, landowners, parent land |
| **2 — Finance** | Purchase agreements, expenses, payment schedules, payment transactions, ledger |
| **3 — Investors** | Investors, ProjectInvestor, investments, ownership |
| **4 — Plots & Sales** | Subdivision, plots, buyers, sales, sale items, installments |
| **5 — Profit** | Actual cost, cost allocation, profit/loss, investor profit, distribution |
| **6 — Reporting** | Dashboards, reports, statements, exports, audit logs |

---

## 15. Future Enhancements
Mobile app polish · online buyer payments (UPI integration) · WhatsApp notifications · e-signatures · OCR for land documents · GIS/maps · land valuation analytics · Tally/accounting integration · bank reconciliation · advanced investor portfolio analytics.

---

## 16. Critical Product Rules
1. Project is the financial boundary.
2. Every financial record must include `projectId`.
3. Never rely on manually entered totals — always derive from transactions.
4. Store every actual payment as its own transaction.
5. Contract value and cash received are different figures.
6. Investor capital and investor profit are different figures.
7. Parent land and plots are different entities.
8. Revenue and cash flow are different.
9. Profit and cash flow are different.
10. Never hard-delete financial history.
11. Server-side authorization is mandatory.
12. Financial formulas must be centralized in a single calculation layer, never duplicated across screens or reports.
13. Ownership changes are direct Admin CRUD, but must always be captured in the audit log — no separate sign-off step exists or is required.
14. Cost allocation method must be configurable per project.
15. Profit distribution is a direct Admin CRUD action, immediately available for payment once recorded — no approval step, but the action itself must be logged (§9).
16. Compliance flags from §12 (RERA, TDS, cash limits, circle rate) are validated in the backend, not just shown as UI warnings.
17. Investor data (records, screens, reports, API responses) must never be reachable by the Member role — enforced server-side, not by hiding a UI element.
18. Every relevant action sends a WhatsApp notification to the concerned party; SMS is optional and must be togglable via environment configuration alone, with no code change (§10).

---

## 17. Success Criteria
The product succeeds when an administrator can manage the full chain —
**Land purchase → Landowner installments → Investor funding → Expenses → Subdivision → Plot sales → Buyer installments → Actual cost → Profit/Loss → Investor profit → Distribution → Project closure**
— without a separate spreadsheet for any core financial calculation, and the source of truth is always the underlying projects, agreements, payment transactions, expenses, ownership records, and the immutable financial ledger.

---

## 18. Open Questions (confirm before build)
1. Can an investor exit mid-project via a partial share transfer to another investor? Needs a dedicated "share transfer" flow with audit trail if yes.
2. Is the Admin's own capital treated as an "investor" with a formal ownership %, or excluded from the pool as owner's residual profit?
3. Are interim (partial, mid-project) profit distributions allowed, or only a final distribution at project close?
4. Which specific state(s) will projects be located in? (Needed to confirm RERA plotted-development thresholds — they differ by state.)
5. Will investor participation be structured through a formal entity (LLP/Pvt Ltd/Partnership) before the platform goes live, per §12.2?
6. §9 defaults to "financial transaction records are never hard-deleted, only voided/reversed" even though Admin otherwise has full CRUD including Delete. Confirm this default is correct, or explicitly allow hard delete of payment/distribution records too.
