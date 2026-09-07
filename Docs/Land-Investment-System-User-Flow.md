---
title: "Land Investment System - User Flow"
---

# Land Investment, Development & Sales Management System
## User Flow

<span class="doc-meta">
**Version:** 1.1 &nbsp;|&nbsp; **Companion to:** PRD v2.2 &amp; Acceptance Criteria v1.1 &nbsp;|&nbsp; **Scope:** screen-by-screen navigation and decision points per role — not requirements, not how-to instructions
</span>

---

## 1. How to Read This Document

Each flow is shown as a sequence of screens/actions (`→`), with a system-triggered step shown as `↓`, and a branch point marked `⤷`. Flows are grouped by role, then by task. For *what* each step must satisfy, see the PRD; for detailed *how-to* instructions, see the User Guide.

---

## 2. Admin — Primary End-to-End Flow

```
Login → Dashboard (Portfolio View) → Projects → Create Project
→ Parent Land → Landowner → Purchase Agreement → Owner Payment Schedule
→ Owner Payments → Investors → Investments → Ownership (auto-calculated)
→ Expenses → Maintenance → Plots → Cost Allocation
→ Buyer → Sale → Buyer Payment Schedule → Payments
→ Sale Completion → Profit/Loss → Investor Profit
→ Distribution Approval → Distribution → Project Closure
```

This is the master flow — every sub-flow below is a zoomed-in view of one segment of it.

---

## 3. Admin — Sub-Flows

### 3.1 Create a New Project
```
Dashboard → Projects → "+ New Project"
→ Enter name, location, land area → Set status (DRAFT / NEGOTIATION)
→ Save
⤷ Project created, status = DRAFT
```

### 3.2 Land Acquisition
```
Project → Land → "+ Parent Land"
→ Enter Khata/Survey No., area, landowner details → Attach land deed
→ Save
→ Land → Purchase Agreement → "+ New Agreement"
→ Enter purchase price → Build installment schedule → Attach agreement document
→ Save
⤷ Agreement created; Balance Payable = full purchase price
```

### 3.3 Record a Landowner Payment
```
Agreement → Installments tab → Select due installment
→ "+ Record Payment" → Enter amount, date, method, reference → Upload receipt
↓ System recalculates installment status (PENDING → PARTIALLY_PAID → PAID)
↓ System recalculates project Balance Payable
⤷ If method = CASH and amount ≥ statutory limit → compliance flag shown before save is allowed
```

### 3.4 Onboard an Investor
```
Project → Investors → "+ Add Investor"
→ Select existing investor OR create new profile (with KYC: PAN/Aadhar)
→ Enter contribution amount + date → Attach investor agreement document
⤷ Save blocked if no agreement document attached
→ Save
↓ System recalculates Ownership % for every investor in this project
```

### 3.5 Subdivide Land into Plots
```
Project → Plots → "+ Subdivide"
→ Add plots (plot no., area, dimensions, facing) — one by one or bulk import
→ Choose cost allocation method: Area-based / Percentage-based / Manual
↓ System computes each plot's allocated cost
→ Review allocated costs → Publish plots as AVAILABLE
```

### 3.6 Sell a Plot or Land
```
Project → Sales → "+ New Sale"
→ Choose sale type: Whole Land / Plot-wise / Multiple Plots / Mixed
→ Select or create buyer (with KYC)
→ Add Sale Item(s) → plot(s)/parcel + agreed price
→ Enter circle-rate/DLC reference value
⤷ If sale price < circle rate → compliance flag shown before save
→ Build buyer payment schedule (down payment + installments)
→ (Optional) Add agent + commission rule
→ Save → Sale status = SALE_AGREEMENT, Plot status = BOOKED
      ⤷ Registration No. + stamp-duty status recorded → Sale status → SOLD
      ⤷ Not yet recorded → Sale stays at SALE_AGREEMENT
```

### 3.7 Record a Buyer Payment
```
Sale → Installments tab → Select due installment
→ "+ Record Payment" → Enter amount, date, method, reference → Upload receipt
↓ System recalculates installment status and Balance Receivable
⤷ Installment overdue → auto-flag OVERDUE → Buyer notified, Admin Overdue widget updated
```

### 3.8 Calculate Profit & Loss
```
Project → Profit & Loss → "Calculate"
↓ System derives Net Sale Proceeds, Actual Project Cost, Project Profit/Loss
⤷ Marked "Forecast" → visible for planning only, cannot feed a Distribution
⤷ Marked "Final" → becomes the base for Distribution
```

### 3.9 Record & Pay a Distribution
```
Profit & Loss (Final) → Distributions → "+ New Distribution"
↓ System computes each investor's payout (Ownership % × Distributable Profit)
→ Admin saves it directly — no approval/review step, immediately available for payment
→ Mark each investor payout as paid (+ proof)
↓ System generates investor statement automatically; each investor is notified (WhatsApp, + SMS if enabled)
⤷ Proposed amount > distributable profit → save is rejected (data-integrity check, not an approval)
```

### 3.10 Close a Project
```
All plots SOLD + all payments reconciled + all distributions settled
→ Project → "Close Project"
↓ Project status → CLOSED
⤷ Project becomes read-only for financial edits; remains visible in reports/history
```

---

## 4. Member Flow

The system has exactly two login roles (PRD §5). Member is a single, simpler role — there is no separate Project Manager or Accountant login anymore.

```
Login → Dashboard
→ Projects → View list (read-only — no "+ New Project", no edit, no delete)
→ Sales (Income) → "+ New Sale Entry" → record a buyer payment (same pattern as §3.7) → Save
→ Purchases (Expenses) → "+ New Purchase Entry" → record a landowner payment or expense (same pattern as §3.3 / §3.6) → Save
→ Sales / Purchases → View lists, search, filter
⤷ Investors → not shown in navigation at all for Member — no route, no data, no partial view
⤷ Project create/edit/delete, Plot management, Distribution, Settings → not available to Member; shown as Admin-only where visible at all, hidden entirely where they'd otherwise leak investor-adjacent data
```

---

## 5. Cross-Role Flow — Sale Payment to Distribution

This flow shows how one event (a buyer payment, entered by either role) ripples through the system without manual re-entry, and without any approval step:

```
Sale payment recorded (by Admin or Member)
  ↓ Payment Transaction created (immutable)
  ↓ Installment status updates; Balance Receivable recalculates
  ↓ Financial Ledger entry created
  ↓ WhatsApp notification sent to the buyer (+ SMS if enabled); Admin/Member dashboard reflects updated balance
  ↓ (Later) Admin runs Profit & Loss "Final" calculation → this payment's sale now counts toward Realized Profit
  ↓ Admin records a Distribution directly (§3.9 — no approval step) → Investor Profit computed from Distributable Profit
  ↓ Each investor is notified (WhatsApp + SMS if enabled) and can be sent their statement — investors have no login of their own, so this notification/statement is their only view into it
```

---

## 6. Notification Flow

Every relevant action notifies whichever party is concerned — a system user (Admin/Member) or a non-login party (Buyer, Landowner, Investor) reached via their stored phone number. This is the same underlying trigger mechanism regardless of who or what triggers it:

```
Trigger event (payment recorded, installment overdue, distribution recorded, project status change, etc.)
  ↓ System resolves the concerned party's contact details
  ↓ WhatsApp message sent (always — mandatory channel)
  ⤷ SMS also enabled in this deployment's configuration → SMS sent too
  ⤷ SMS not enabled/purchased → skipped entirely, silently, no error, no charge
  ↓ Delivery outcome logged
  ⤷ Send fails (either channel) → logged for retry; the underlying business record (payment/sale/distribution) is
     never rolled back or blocked because of a notification failure
```

---

## 7. Edge-Case Flows

### 7.1 Overdue Installment (Buyer or Landowner side)
```
Due date passes with no payment recorded
↓ Daily status job runs → Installment status → OVERDUE
↓ Concerned party notified via WhatsApp (+ SMS if enabled); Admin/Member Overdue widget updated
⤷ Admin/Member sends reminder OR records a late payment directly (§3.3 / §3.7)
```

### 7.2 Sale Cancellation (Admin only)
```
Sale (any status before SOLD) → "Cancel Sale"
→ Confirm cancellation
↓ Plot(s) revert to AVAILABLE
↓ Sale status → CANCELLED
↓ Any prior payment transactions → VOIDED (not deleted), linked audit entry created — direct Admin action, no approval step
⤷ Plot becomes sellable again
```

### 7.3 Refund (Admin only)
```
Original Payment Transaction → "+ Refund"
→ Enter refund amount, date, reason
↓ System creates a linked REFUND transaction (original transaction remains in history, unedited)
↓ Receivable/Payable and Ledger recalculate
```

### 7.4 Investor Exit Mid-Project (process to be confirmed — see PRD §18, Open Question 1)
```
Investor requests exit (communicated to Admin outside the system, since Investor has no login)
→ Admin records the outcome directly (no approval step)
⤷ Share transfer to another investor → new ProjectInvestor record + audit entry + updated Ownership % for all investors
⤷ Buyout by the project itself → treated as a Settlement (§7.5 of PRD) with an early-exit adjustment
```

---

## 8. Flow-to-Screen Quick Reference

| Flow | Primary Screens Touched | Who |
|---|---|---|
| Create Project | Projects List → New Project Form | Admin only |
| Land Acquisition | Land → Parent Land Form → Purchase Agreement Form | Admin only |
| Landowner Payment (Purchases) | Purchase Agreement / Purchases → Installments → Payment Entry | Admin, Member |
| Investor Onboarding | Investors → Add Investor Form → Investment Entry | Admin only — screen not shown to Member |
| Plot Subdivision | Plots → Subdivide Form → Cost Allocation Review | Admin only |
| Sale Creation | Sales → New Sale Form → Sale Items → Payment Schedule Builder | Admin only (Member can record payments against an existing sale, not create one — confirm against PRD if Member should also create sales) |
| Buyer Payment (Sales) | Sale / Sales → Installments → Payment Entry | Admin, Member |
| Profit Calculation | Profit & Loss → Calculate | Admin only |
| Distribution | Distributions → Record → Payout Entry (no approval step) | Admin only |
| Project Closure | Project → Close Project | Admin only |
| Investor Statement | Admin generates/sends from Investor Detail — no investor login/dashboard exists | Admin only |
| Buyer Payment History | Sales → Purchase Detail → Payment History | Admin, Member |

> The Sale Creation row flags a genuine gap in what you specified: "Member can create entries" is stated broadly, but the worked examples you gave were Sales/Purchases *payments*, not full Sale Agreement creation (which involves picking plots, pricing, and a payment schedule — closer to project-setup than a simple entry). I've defaulted to Sale Agreement creation being Admin-only and Member limited to recording payments against it, consistent with Member's read-only stance on Plots and Projects — confirm if Member should be able to originate a new sale outright.
