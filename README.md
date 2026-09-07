# PAMZ PlotPro — Land Investment & Sales Management System

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20Riverpod-blue)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Web%20%7C%20Mobile-brightgreen)

**PAMZ PlotPro** is an enterprise-grade, multi-project **Land Investment and Sales Management Platform** designed to manage complex real estate land acquisitions, plot subdivisions, investor capital allocations, buyer sales agreements, installment tracking, and profit/loss settlements with full audit transparency.

---

## 🌟 Key Features

### 🏢 1. Executive Dashboard & Portfolio Overview
- Multi-project aggregate statistics: Total Land Area, Investor Capital, Booked Sales Revenue, Net Liquidity, Buyer Dues, and Landowner Payables.
- Plot sales velocity graphs and real-time inventory breakdowns.
- Quick action workflows for Adding Projects, Recording Payments, and Generating Sales Contracts.

### 📐 2. Land Area & Unit Measurement Engine
- Flexible unit conversions supporting **Kattha, Dhur, Bigha, Square Feet, Ropani, Aana, and Square Yards**.
- **Dimensions Mode (`L × B in Ft & In`)**: Input precise length and breadth in feet and inches with auto-calculated total area.
- Initial default unit set to `Dimensions (L × B in Ft & In)` across projects and plot subdivision dialogs.

### 🧩 3. Plot Subdivision & Inventory Management
- Divide master project land into individual plots with allocated cost calculations.
- Track plot statuses (**Available**, **Booked**, **Sold**) with target vs agreed pricing metrics.
- Multi-project filtering and plot search capabilities.

### 🌾 4. Landowner Purchase Agreements
- Comprehensive Landowner Registry with contact, address, and PAN card tracking.
- Purchase agreements linked directly to target projects.
- Printable agreement PDF contracts with milestone payment schedules.

### 💼 5. Investor Capital & Profit Distribution
- Investor registration with project-level capital allocations.
- Dual ownership calculation engines:
  - **CAPITAL_BASED**: Auto-calculated ownership % based on contributed capital.
  - **CUSTOM**: Manual equity percentage assignment.
- Profit/Loss Ledger calculating net earnings and ROI distributions per investor.

### 👤 6. Buyers & Sales Contracts
- Buyer profiles and sales agreement creation.
- Circle rate threshold validation to prevent under-value compliance violations.
- Support for **Full Payment** and **Installment Plan** sales types.

### 💳 7. Installments & Payment Tracking
- Automated installment schedule generation with due dates and statuses.
- Payment recording supporting **Cash, Cheque, Bank Transfer, and UPI**.
- **Cash Transaction Safeguard**: Automated warnings for cash transactions equal to or exceeding ₹200,000.
- Payment receipt generation and PDF printing.

### 📊 8. Receivables, Payables & Financial Ledgers
- Centralized ledger for pending buyer installments and landowner dues.
- Expense management with category classification and capitalization toggles.
- Net Cash Liquidity ledger (Inflows minus Land Purchase & Expenses).

### 🔍 9. Instant Global Search & Shortcuts
- Global search modal (**`Ctrl + K`** / **`Cmd + K`** or top header search bar).
- Real-time search across **8 entity modules**: Projects, Plots, Landowners, Investors, Buyers, Sales, Expenses, and Transactions.
- Category grouping, visual status badges, and one-click item navigation.

### 🎯 10. Searchable Entity Selection Modals
- Searchable dropdown fields for Projects, Landowners, Buyers, and Investors across all creation dialogs with auto-focused search inputs.

### 📑 11. Interactive User Guide & PDF Export
- In-app interactive documentation covering all system workflows and role features.
- Single-topic and complete manual **PDF Export & Printing**.

### 🔐 12. Security & Role-Based Access Control
- Centralized `UserRole` switcher (**Admin** vs **Member**).
- Route guards shielding financial settings, investor payouts, and audit logs.

---

## 🏗️ Architecture & Technology Stack

The project follows **Flutter Clean Architecture** principles with feature-first modularity:

```
lib/
├── core/                           # Shared infrastructure
│   ├── constants/                  # AppConstants, enums, limits
│   ├── database/                   # Drift / SQLite AppDatabase & DatabaseSeeder
│   ├── routing/                    # GoRouter configuration, AppRoutes & RouteGuard
│   ├── theme/                      # AppColors & AppTypography (Inter font)
│   ├── utils/                      # LandUnitConverter, CalculationEngine
│   └── widgets/                    # Reusable core widgets (LandMeasurementInputWidget, etc.)
├── features/                       # Modular business domain features
│   ├── audit_log/                  # Audit trail logs
│   ├── buyers_sales/               # Buyer registry & Sales contracts
│   ├── dashboard/                  # Executive dashboard metrics
│   ├── expenses/                   # Project expenses & categorization
│   ├── help_user_guide/            # Help guide & PDF export engine
│   ├── installments_payments/      # Installments, payment records & transactions
│   ├── investors/                  # Investor accounts, capital allocations & payouts
│   ├── landowners/                 # Landowner accounts & purchase agreements
│   ├── plots/                      # Plot inventory & subdivision
│   ├── profit_loss_settlement/     # P&L calculation & distribution ledger
│   ├── projects/                   # Project management & land details
│   ├── receivables_payables/       # Outstanding dues & receivables ledger
│   └── settings/                   # System configuration & preferences
├── shared/                         # Shared UI widgets & Riverpod providers
│   ├── providers/                  # Navigation & Role state providers
│   └── widgets/                    # AppShell, TopBar, Sidebar, GlobalSearchDialog, Dropdowns
└── main.dart                       # App entrypoint & Window initialization
```

### Core Libraries & Packages
| Category | Package | Purpose |
|---|---|---|
| **State Management** | `flutter_riverpod` | Reactive provider state management |
| **Routing** | `go_router` | Declarative routing with route guards |
| **Database** | `drift`, `sqlite3_flutter_libs` | Local relational database storage |
| **Responsive UI** | `flutter_screenutil` | Dynamic adaptive layout scaling |
| **Typography** | `google_fonts` | Inter font typography integration |
| **PDF & Print** | `pdf`, `printing` | User guide & agreement contract PDF rendering |
| **Utilities** | `intl`, `path_provider` | Currency formatting, dates & file storage |
| **Desktop Window** | `bitsdojo_window` / `window_manager` | Custom window titlebar & desktop frame handling |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
- [Dart SDK](https://dart.dev/get-started/sdk) (v3.3.0 or higher)
- C++ Build Tools (for Windows Desktop builds)

### Installation & Execution

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/land_investment_and_sales_management.git
   cd land_investment_and_sales_management
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Application**:
   - **Windows Desktop**:
     ```bash
     flutter run -d windows
     ```
   - **Chrome Web**:
     ```bash
     flutter run -d chrome
     ```

4. **Build Production Release (Windows)**:
   ```bash
   flutter build windows --release
   ```

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl + K` / `Cmd + K` | Open Global System Search |
| `Esc` | Close Search Modal / Cancel Dialog |

---

## 📄 License

Copyright © 2026 PAMZ PlotPro. All rights reserved.
