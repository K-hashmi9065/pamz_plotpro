---
title: "Land Investment System - Acceptance Criteria"
---

# Land Investment, Development & Sales Management System
## Acceptance Criteria

<span class="doc-meta">
**Version:** 1.1 &nbsp;|&nbsp; **Companion to:** PRD v2.2 &amp; User Flow v1.1 &nbsp;|&nbsp; **Format:** Given / When / Then, grouped by module. Each ID is stable and intended for direct use as automated test case references (e.g., in Jira/TestRail or your test suite).
</span>

---

## AC-01 · Project (Financial Boundary)

**AC-01.1**
> **Given** an Admin is creating a new project
> **When** they submit the form without a project name or land area
> **Then** the system rejects the submission with a validation error and creates no record.

**AC-01.2**
> **Given** a project exists with status `CLOSED`
> **When** any user attempts to add/edit an expense, payment, or investor on it
> **Then** the system blocks the action and shows "Project is closed — financial edits are disabled."

**AC-01.3**
> **Given** two separate projects, A and B
> **When** an expense is recorded against Project A
> **Then** Project B's Actual Project Cost, cash flow, and reports are completely unaffected.

---

## AC-02 · Landowner & Purchase Agreement

**AC-02.1**
> **Given** a purchase agreement with total price ₹2,00,00,000 and a 5-installment schedule
> **When** the Admin records a payment of ₹50,00,000 against installment 1
> **Then** installment 1 status becomes `PAID`, and Balance Payable becomes ₹1,50,00,000.

**AC-02.2**
> **Given** a landowner payment installment due date has passed with no payment recorded
> **When** the daily status job runs
> **Then** the installment status changes to `OVERDUE` and the Landowner Dashboard reflects it.

**AC-02.3**
> **Given** a payment is entered with method `CASH` and amount ≥ ₹2,00,000
> **When** the Admin attempts to save it
> **Then** the system shows a hard compliance flag referencing Section 269ST before allowing save, and logs the acknowledgement.

---

## AC-03 · Investors & Ownership

**AC-03.1**
> **Given** a project with no investors yet
> **When** Investor A contributes ₹50,00,000 as the only investor
> **Then** Investor A's Ownership % for this project = 100%.

**AC-03.2**
> **Given** Investor A holds 100% (₹50,00,000 of ₹50,00,000 total)
> **When** Investor B joins with a ₹50,00,000 contribution
> **Then** Total Share Capital becomes ₹1,00,00,000 and both A and B's Ownership % recalculate to 50% each, with no change to either investor's actual contributed amount.

**AC-03.3**
> **Given** an Admin is adding a new investor
> **When** no investor agreement document is attached
> **Then** the system refuses to save the `ProjectInvestor` record.

**AC-03.4**
> **Given** ownership method is set to `MANUAL` for a project
> **When** the Admin assigns ownership percentages directly
> **Then** the system warns (but does not block) if the total across all investors does not equal 100%.

---

## AC-04 · Expenses & Actual Cost

**AC-04.1**
> **Given** a project with Purchase Cost ₹2,00,00,000 and no other expenses
> **When** a `DEVELOPMENT` expense of ₹8,00,000 is added with the capitalization flag ON
> **Then** Actual Project Cost becomes ₹2,08,00,000.

**AC-04.2**
> **Given** the same setup as AC-04.1
> **When** a `MARKETING` expense of ₹3,00,000 is added with the capitalization flag OFF
> **Then** Actual Project Cost remains ₹2,08,00,000 (marketing tracked as a period expense, not capitalized).

---

## AC-05 · Plots & Cost Allocation

**AC-05.1**
> **Given** a parent land with Actual Project Cost ₹2,27,00,000 and total allocated area 2,27,000 sq. ft, using Area-based allocation
> **When** Plot #12 with area 1,000 sq. ft is created
> **Then** Plot #12's allocated cost = ₹1,00,000 (i.e., ₹100/sq.ft × 1,000).

**AC-05.2**
> **Given** a plot with status `SOLD`
> **When** any user attempts to initiate a new sale against the same plot
> **Then** the system blocks it with "Plot is not available for sale."

**AC-05.3**
> **Given** a project's cost allocation method is changed from Area-based to Manual mid-project
> **When** the change is confirmed
> **Then** the system requires the Admin to review/confirm each already-created plot's new manual cost before it takes effect — no silent recalculation.

---

## AC-06 · Sales & Buyer Installments

**AC-06.1**
> **Given** a sale of type `MULTIPLE_PLOTS` with 3 plots bundled for one buyer at a combined agreement amount of ₹1,00,00,000
> **When** the sale is created
> **Then** exactly 3 `SaleItem` records are created, each referencing this Sale and one Plot, and each Plot's status moves to `BOOKED`.

**AC-06.2**
> **Given** a sale agreement of ₹30,00,000 for one installment
> **When** the buyer pays ₹10,00,000 against it
> **Then** installment status = `PARTIALLY_PAID`, Paid = ₹10,00,000, Remaining = ₹20,00,000 — and Project Profit calculations are **not** affected by this partial payment (profit is derived from agreement value less cost, not cash received — see AC-07.1).

**AC-06.3**
> **Given** a sale where sale price is below the recorded circle-rate/DLC value for that plot
> **When** the Admin attempts to save the sale
> **Then** the system displays a compliance flag referencing Section 43CA/50C before allowing save.

**AC-06.4**
> **Given** a sale at status `SALE_AGREEMENT` with no registration number or stamp-duty-paid status recorded
> **When** the Admin attempts to move it to `SOLD`
> **Then** the transition is blocked until both fields are populated.

**AC-06.5**
> **Given** a sale is cancelled after two installments were already paid
> **When** the cancellation is confirmed
> **Then** the plot(s) revert to `AVAILABLE`, the sale status becomes `CANCELLED`, and the two prior payment transactions are `VOIDED` (not deleted) with a linked audit entry.

---

## AC-07 · Profit, Loss & ROI

**AC-07.1**
> **Given** Net Sale Proceeds ₹2,90,00,000 and Actual Project Cost ₹2,27,00,000
> **When** Profit & Loss is calculated
> **Then** Project Profit = ₹63,00,000, and this figure is independent of how much of the ₹2,90,00,000 has actually been *collected* in cash so far.

**AC-07.2**
> **Given** Actual Project Cost exceeds Net Sale Proceeds
> **When** Profit & Loss is calculated
> **Then** the system reports a Project Loss (not a negative "profit" label) and surfaces it distinctly on the dashboard.

**AC-07.3**
> **Given** Investor A has Ownership % 50% and Distributable Profit is ₹63,00,000
> **When** Investor Profit is calculated
> **Then** Investor A Profit = ₹31,50,000, and ROI = 31,50,000 / 50,00,000 × 100 = 63%.

**AC-07.4**
> **Given** a Profit & Loss run marked "forecast" (not Final)
> **When** the Admin views Distributions
> **Then** the forecast figures are visible for planning but cannot be used to create a Distribution Proposal — only a "Final" P&L run can.

---

## AC-08 · Distribution & Settlement

**AC-08.1**
> **Given** Admin creates a Distribution of ₹63,00,000 across 3 investors at 50/30/20%
> **When** it is saved
> **Then** it is immediately recorded and available for payout — there is no approval/review status to wait on.

**AC-08.2**
> **Given** a distribution where ₹60,00,000 has already been paid to Investor A historically
> **When** a new settlement is calculated for Investor A with total entitlement ₹81,50,000
> **Then** the remaining settlement shown = ₹21,50,000 (₹81,50,000 − ₹60,00,000).

**AC-08.3**
> **Given** a proposed distribution amount exceeds the project's currently distributable profit
> **When** the Admin attempts to save it
> **Then** the system rejects the save with "Distribution exceeds distributable amount" — a data-integrity check, independent of any approval workflow (there is none).

**AC-08.4**
> **Given** a Member (not Admin) attempts to create, edit, or delete a Distribution via any API path
> **Then** the request is rejected with an authorization error — Distribution management is Admin-only.

---

## AC-09 · Security & RBAC

**AC-09.1**
> **Given** a user with role `MEMBER`
> **When** they call any API to create, edit, or delete a Project, an Investor, a Plot, a Distribution, or Settings
> **Then** the API returns an authorization error regardless of what the UI shows (server-side enforcement, not UI-only) — Member's write access is limited to Sales and Purchases entries only.

**AC-09.2**
> **Given** a user with role `MEMBER`
> **When** they request any Investor-related screen, list, detail, or report — by navigation or by direct API/URL access
> **Then** the system returns an authorization error or empty/forbidden response; no investor name, contribution, ownership %, or distribution figure is ever returned to a Member under any request path.

**AC-09.3**
> **Given** a user with role `MEMBER`
> **When** they view a Project's dashboard
> **Then** investor-related figures (investor count, ownership %, investor capital, distributions) are omitted from the response entirely — not hidden client-side.

**AC-09.4**
> **Given** any financial transaction or distribution record
> **When** a user without the Admin role attempts to edit or delete it
> **Then** the action is blocked — Delete and Edit beyond Create/Read are Admin-only across every module (§5/§11 permission table).

---

## AC-10 · Audit & Data Integrity

**AC-10.1**
> **Given** any financial transaction (a payment or a distribution)
> **When** Admin attempts to delete it
> **Then** no hard-delete option exists for that record type — only Void/Reverse, which preserves the original record and creates a linked entry. (This is a data-integrity default, not an approval gate — Admin performs it directly, with no one else's sign-off required. See PRD §9 for how to override this default if you'd rather allow hard delete here too.)

**AC-10.2**
> **Given** a non-financial master record with no transactions ever recorded against it (e.g., a newly created Plot with no sale)
> **When** Admin deletes it
> **Then** the delete succeeds outright — this is ordinary CRUD, not subject to the Void/Reverse rule in AC-10.1.

**AC-10.3**
> **Given** an ownership percentage is changed on an active project
> **When** the change is saved
> **Then** an audit log entry is created capturing old value, new value, user, timestamp, and reason — saved directly by Admin, with no separate approval step.

**AC-10.4**
> **Given** a value is submitted for Amount, Ownership %, Plot Area, or Sale Price
> **When** the value is ≤ 0 (or Ownership % is outside 0–100)
> **Then** the system rejects the submission at the API layer, independent of any client-side validation.

---

## AC-11 · Reports & Exports

**AC-11.1**
> **Given** an Admin selects a Profit/Loss report for a date range with no qualifying data
> **When** they export it
> **Then** the system generates a valid, empty-state report file (PDF/Excel/CSV) rather than an error.

**AC-11.2**
> **Given** Admin exports an Investor's Statement (Investors have no login of their own — Admin generates and sends it on their behalf)
> **When** the PDF is generated
> **Then** Capital Contributed and Profit Earned appear as two separate, clearly labeled figures (never netted into one number).

**AC-11.3**
> **Given** a Member requests any investor-related report, by name or by filter
> **Then** the system does not generate it — either the report type is not offered to Member at all, or the request is rejected with an authorization error.

---

## AC-12 · Notifications (WhatsApp / SMS)

**AC-12.1**
> **Given** a buyer or landowner installment becomes `OVERDUE`
> **When** the daily status job runs
> **Then** a WhatsApp notification is sent to the concerned party, and the item appears on the Admin/Member Overdue widget within the same run.

**AC-12.2**
> **Given** Admin records a Distribution (§AC-08.1 — no approval step exists)
> **When** the save completes
> **Then** every investor in that distribution is sent a WhatsApp notification referencing their updated statement.

**AC-12.3**
> **Given** the SMS channel is disabled via environment/deployment configuration
> **When** any notification-triggering action occurs
> **Then** no SMS is sent and no SMS-provider call is attempted, while the WhatsApp notification for the same event still sends normally — and this required no code change to configure.

**AC-12.4**
> **Given** the SMS channel is enabled via environment/deployment configuration
> **When** a notification-triggering action occurs
> **Then** an SMS is sent to the concerned party's registered number, in addition to the WhatsApp notification.

**AC-12.5**
> **Given** the WhatsApp or SMS provider is unreachable or returns an error
> **When** a notification-triggering business action (e.g. recording a payment) is being saved
> **Then** the underlying business record still saves successfully; the notification failure is logged for retry and never blocks, rolls back, or fails the transaction it was attached to.
