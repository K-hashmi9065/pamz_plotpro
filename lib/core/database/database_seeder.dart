import 'package:drift/drift.dart';
import 'app_database.dart';

class DatabaseSeeder {
  /// Seed rich initial real-world operational data into SQLite database if empty.
  static Future<void> seedInitialDataIfEmpty(AppDatabase db) async {
    final existingProjects = await db.select(db.projects).get();
    if (existingProjects.isNotEmpty) {
      return; // Database already populated
    }

    final now = DateTime.now();

    // 1. Projects
    await db.into(db.projects).insert(
      ProjectsCompanion.insert(
        id: 'proj_001',
        code: 'PRJ-001',
        name: 'Green Acres Township',
        location: 'Nagpur Highway Sector 4',
        description: const Value('Prime residential plotting layout with 30ft asphalt roads and water layout.'),
        status: 'active',
        landAreaSqFt: const Value(227000.0),
        purchasePrice: const Value(20000000.0),
        actualCost: const Value(22700000.0),
        createdAt: Value(now.subtract(const Duration(days: 90))),
      ),
    );

    await db.into(db.projects).insert(
      ProjectsCompanion.insert(
        id: 'proj_002',
        code: 'PRJ-002',
        name: 'Sunrise Commercial Enclave',
        location: 'Ring Road Junction',
        description: const Value('High-density commercial land development parcel.'),
        status: 'active',
        landAreaSqFt: const Value(150000.0),
        purchasePrice: const Value(35000000.0),
        actualCost: const Value(38500000.0),
        createdAt: Value(now.subtract(const Duration(days: 60))),
      ),
    );

    // 2. Landowners & Agreements
    await db.into(db.landowners).insert(
      LandownersCompanion.insert(
        id: 'lo_001',
        name: 'Rameshwar Patil',
        phone: '+91 98220 11223',
        email: const Value('rameshwar.p@gmail.com'),
        address: const Value('Nagpur, MH'),
        pan: const Value('ABCDE1234F'),
        createdAt: Value(now.subtract(const Duration(days: 90))),
      ),
    );

    await db.into(db.purchaseAgreements).insert(
      PurchaseAgreementsCompanion.insert(
        id: 'pa_001',
        projectId: 'proj_001',
        landownerId: 'lo_001',
        totalPrice: 20000000.0,
        agreementDate: now.subtract(const Duration(days: 90)),
        status: 'executed',
        createdAt: Value(now.subtract(const Duration(days: 90))),
      ),
    );

    // 3. Investors & Project Capital Contributions
    await db.into(db.investors).insert(
      InvestorsCompanion.insert(
        id: 'inv_001',
        name: 'Rajesh Sharma',
        phone: '+91 98900 44556',
        email: const Value('rajesh.sharma@invest.com'),
        pan: const Value('FGHIJ5678K'),
        createdAt: Value(now.subtract(const Duration(days: 85))),
      ),
    );

    await db.into(db.investors).insert(
      InvestorsCompanion.insert(
        id: 'inv_002',
        name: 'Anita Verma',
        phone: '+91 97654 33221',
        email: const Value('anita.v@capital.com'),
        pan: const Value('KLMNO9012P'),
        createdAt: Value(now.subtract(const Duration(days: 85))),
      ),
    );

    await db.into(db.projectInvestors).insert(
      ProjectInvestorsCompanion.insert(
        id: 'pi_001',
        projectId: 'proj_001',
        investorId: 'inv_001',
        investedAmount: 15000000.0,
        ownershipPercent: 60.0,
        ownershipMethod: 'capitalBased',
        createdAt: Value(now.subtract(const Duration(days: 85))),
      ),
    );

    await db.into(db.projectInvestors).insert(
      ProjectInvestorsCompanion.insert(
        id: 'pi_002',
        projectId: 'proj_001',
        investorId: 'inv_002',
        investedAmount: 10000000.0,
        ownershipPercent: 40.0,
        ownershipMethod: 'capitalBased',
        createdAt: Value(now.subtract(const Duration(days: 85))),
      ),
    );

    // 4. Expenses (Capitalized & Operating)
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        id: 'exp_001',
        projectId: 'proj_001',
        category: 'legalRegistration',
        amount: 1500000.0,
        expenseDate: now.subtract(const Duration(days: 80)),
        vendor: const Value('High Court Legal Services'),
        isCapitalized: const Value(true),
        notes: const Value('Stamp duty, land title search and registration fees'),
        createdAt: Value(now.subtract(const Duration(days: 80))),
      ),
    );

    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        id: 'exp_002',
        projectId: 'proj_001',
        category: 'developmentInfrastructure',
        amount: 1200000.0,
        expenseDate: now.subtract(const Duration(days: 75)),
        vendor: const Value('Apex Earthmovers & Infra'),
        isCapitalized: const Value(true),
        notes: const Value('Internal 30ft road layout levelling and boundary demarcation'),
        createdAt: Value(now.subtract(const Duration(days: 75))),
      ),
    );

    // 5. Plots
    await db.into(db.plots).insert(
      PlotsCompanion.insert(
        id: 'plot_101',
        projectId: 'proj_001',
        plotNumber: 'Plot #101',
        areaSqFt: 1500.0,
        allocatedCost: const Value(150000.0),
        expectedPrice: const Value(350000.0),
        status: 'available',
        createdAt: Value(now.subtract(const Duration(days: 60))),
      ),
    );

    await db.into(db.plots).insert(
      PlotsCompanion.insert(
        id: 'plot_102',
        projectId: 'proj_001',
        plotNumber: 'Plot #102',
        areaSqFt: 2000.0,
        allocatedCost: const Value(200000.0),
        expectedPrice: const Value(480000.0),
        status: 'available',
        createdAt: Value(now.subtract(const Duration(days: 60))),
      ),
    );

    await db.into(db.plots).insert(
      PlotsCompanion.insert(
        id: 'plot_103',
        projectId: 'proj_001',
        plotNumber: 'Plot #103',
        areaSqFt: 1800.0,
        allocatedCost: const Value(180000.0),
        expectedPrice: const Value(420000.0),
        status: 'booked',
        createdAt: Value(now.subtract(const Duration(days: 50))),
      ),
    );

    await db.into(db.plots).insert(
      PlotsCompanion.insert(
        id: 'plot_104',
        projectId: 'proj_001',
        plotNumber: 'Plot #104 (Corner)',
        areaSqFt: 2400.0,
        allocatedCost: const Value(240000.0),
        expectedPrice: const Value(600000.0),
        status: 'sold',
        createdAt: Value(now.subtract(const Duration(days: 45))),
      ),
    );

    // 6. Buyers & Sales
    await db.into(db.buyers).insert(
      BuyersCompanion.insert(
        id: 'buy_001',
        name: 'Suresh Deshmukh',
        phone: '+91 94221 88990',
        email: const Value('suresh.d@gmail.com'),
        pan: const Value('PQRST3456Q'),
        aadhar: const Value('1234 5678 9012'),
        createdAt: Value(now.subtract(const Duration(days: 45))),
      ),
    );

    await db.into(db.sales).insert(
      SalesCompanion.insert(
        id: 'sale_001',
        projectId: 'proj_001',
        buyerId: 'buy_001',
        saleType: 'outright',
        agreedPrice: 600000.0,
        saleExpenses: const Value(15000.0),
        circleRateValue: const Value(550000.0),
        saleDate: now.subtract(const Duration(days: 45)),
        status: 'executed',
        createdAt: Value(now.subtract(const Duration(days: 45))),
      ),
    );

    // 7. Installments & Transactions
    await db.into(db.installments).insert(
      InstallmentsCompanion.insert(
        id: 'inst_001',
        saleId: const Value('sale_001'),
        installmentNumber: 1,
        dueDate: now.subtract(const Duration(days: 45)),
        dueAmount: 300000.0,
        paidAmount: const Value(300000.0),
        status: 'paid',
        createdAt: Value(now.subtract(const Duration(days: 45))),
      ),
    );

    await db.into(db.installments).insert(
      InstallmentsCompanion.insert(
        id: 'inst_002',
        saleId: const Value('sale_001'),
        installmentNumber: 2,
        dueDate: now.add(const Duration(days: 15)),
        dueAmount: 300000.0,
        paidAmount: const Value(100000.0),
        status: 'partiallyPaid',
        createdAt: Value(now.subtract(const Duration(days: 45))),
      ),
    );

    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        id: 'tx_001',
        projectId: 'proj_001',
        installmentId: const Value('inst_001'),
        amount: 300000.0,
        paymentDate: now.subtract(const Duration(days: 45)),
        paymentMethod: 'bankTransfer',
        referenceNumber: const Value('NEFT99887766'),
        createdBy: 'admin_user',
        createdAt: Value(now.subtract(const Duration(days: 45))),
      ),
    );

    await db.into(db.transactions).insert(
      TransactionsCompanion.insert(
        id: 'tx_002',
        projectId: 'proj_001',
        installmentId: const Value('inst_002'),
        amount: 100000.0,
        paymentDate: now.subtract(const Duration(days: 10)),
        paymentMethod: 'cheque',
        referenceNumber: const Value('CHQ-445566'),
        createdBy: 'admin_user',
        createdAt: Value(now.subtract(const Duration(days: 10))),
      ),
    );

    // 8. Audit Logs
    await db.into(db.auditLogs).insert(
      AuditLogsCompanion.insert(
        id: 'log_001',
        userId: 'admin_user',
        action: 'PROJECT_CREATE',
        entityType: 'Project',
        entityId: 'proj_001',
        details: 'Created Project Green Acres Township (PRJ-001) with 2,27,000 sq.ft land area.',
        timestamp: Value(now.subtract(const Duration(days: 90))),
      ),
    );
  }
}
