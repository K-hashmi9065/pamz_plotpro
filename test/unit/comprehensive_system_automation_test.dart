import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/data/installments_repository.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/data/sales_repository.dart';
import 'package:land_investment_and_sales_management/features/expenses/data/expenses_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late SalesRepository salesRepo;
  late InstallmentsRepository installmentsRepo;
  late ExpensesRepository expensesRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    salesRepo = SalesRepository(db);
    installmentsRepo = InstallmentsRepository(db);
    expensesRepo = ExpensesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Automated Comprehensive System & Edge Case Tests', () {
    test('1. Land Measurement: Feet & Inches and Kattha/Dhur Breakdown', () {
      // Dimensions: 50 ft 6 in x 30 ft 0 in
      final calculatedSqFt = LandUnitConverter.dimensionsToSqFt(
        lengthFt: 50.0,
        lengthIn: 6.0,
        breadthFt: 30.0,
        breadthIn: 0.0,
      );

      expect(calculatedSqFt, equals(1515.0)); // 50.5 * 30.0 = 1515 SqFt

      // Kattha & Dhur breakdown
      final breakdown = LandUnitConverter.sqFtToKattaDhur(calculatedSqFt);
      expect(breakdown.katta, equals(1)); // 1515 / 1361.25 = 1 Katta + remainder
      expect(breakdown.dhur, greaterThan(0.0));
    });

    test('2. Installments: Foreign Key project_id resolution from Sale avoids SQLite constraint failure', () async {
      // Create project
      final proj = await projectsRepo.createProject(
        name: 'Green Valley Project',
        location: 'Sector 42',
        landAreaSqFt: 36450.0,
        purchasePrice: 5000000.0,
        userId: 'admin_user',
      );

      // Create buyer
      final buyer = await salesRepo.createBuyer(
        name: 'Rajesh Sharma',
        phone: '9876543210',
        userId: 'admin_user',
      );

      // Create sale agreement
      final sale = await salesRepo.createSaleAgreement(
        projectId: proj.id,
        buyerId: buyer.id,
        saleType: SaleType.plotWise,
        agreedPrice: 1500000.0,
        saleDate: DateTime.now(),
        userId: 'admin_user',
      );

      // Create installment with short ID and link to sale
      const shortInstId = 'inst_01';
      await db.into(db.installments).insert(
            InstallmentsCompanion(
              id: const drift.Value(shortInstId),
              saleId: drift.Value(sale.id),
              installmentNumber: const drift.Value(1),
              dueDate: drift.Value(DateTime.now().add(const Duration(days: 15))),
              dueAmount: const drift.Value(500000.0),
              paidAmount: const drift.Value(0.0),
              status: drift.Value(InstallmentStatus.pending.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // Call recordPayment passing sale.id as projectId (simulating previous UI bug)
      // The repository must resolve the real proj.id automatically and NOT throw SQLite 787 Foreign Key error!
      final tx = await installmentsRepo.recordPayment(
        projectId: sale.id, // Passed sale.id instead of proj.id
        installmentId: shortInstId,
        amount: 200000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.bankTransfer,
        userId: 'admin_user',
      );

      expect(tx.projectId, equals(proj.id)); // Successfully resolved to real project ID!
      expect(tx.amount, equals(200000.0));

      // Verify installment updated to partiallyPaid
      final updatedInst = await (db.select(db.installments)..where((tbl) => tbl.id.equals(shortInstId))).getSingle();
      expect(updatedInst.paidAmount, equals(200000.0));
      expect(updatedInst.status, equals(InstallmentStatus.partiallyPaid.name));
    });

    test('3. Transaction Voiding: Safe handling of short transaction IDs and reversal', () async {
      final proj = await projectsRepo.createProject(
        name: 'Sunrise Estates',
        location: 'North Zone',
        landAreaSqFt: 18225.0,
        purchasePrice: 2500000.0,
        userId: 'admin_user',
      );

      const instId = 'inst_short_02';
      await db.into(db.installments).insert(
            InstallmentsCompanion(
              id: const drift.Value(instId),
              installmentNumber: const drift.Value(1),
              dueDate: drift.Value(DateTime.now()),
              dueAmount: const drift.Value(300000.0),
              paidAmount: const drift.Value(100000.0),
              status: drift.Value(InstallmentStatus.partiallyPaid.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      const shortTxId = 'tx_001'; // Length 6 (< 8)
      await db.into(db.transactions).insert(
            TransactionsCompanion(
              id: const drift.Value(shortTxId),
              projectId: drift.Value(proj.id),
              installmentId: const drift.Value(instId),
              amount: const drift.Value(100000.0),
              paymentDate: drift.Value(DateTime.now()),
              paymentMethod: drift.Value(PaymentMethod.cash.name),
              createdBy: const drift.Value('admin_user'),
            ),
          );

      // Verify substring check works safely without RangeError
      final safeDisplayId = shortTxId.length > 8 ? shortTxId.substring(0, 8) : shortTxId;
      expect(safeDisplayId, equals('tx_001'));

      // Void the transaction
      await installmentsRepo.voidTransaction(
        transactionId: shortTxId,
        voidReason: 'Cheque bounced',
        userId: 'admin_user',
      );

      final voidedTx = await (db.select(db.transactions)..where((tbl) => tbl.id.equals(shortTxId))).getSingle();
      expect(voidedTx.isVoided, isTrue);
      expect(voidedTx.voidReason, equals('Cheque bounced'));

      // Verify installment balance was reversed (100000 -> 0)
      final reversedInst = await (db.select(db.installments)..where((tbl) => tbl.id.equals(instId))).getSingle();
      expect(reversedInst.paidAmount, equals(0.0));
      expect(reversedInst.status, equals(InstallmentStatus.pending.name));
    });

    test('4. Expenses: Logging capitalized expenses updates Project actualCost', () async {
      final proj = await projectsRepo.createProject(
        name: 'Royal Palms',
        location: 'Central Road',
        landAreaSqFt: 10000.0,
        purchasePrice: 1000000.0,
        userId: 'admin_user',
      );

      expect(proj.actualCost, equals(1000000.0)); // Initial purchase price

      await expensesRepo.addExpense(
        projectId: proj.id,
        category: ExpenseCategory.development,
        amount: 250000.0,
        expenseDate: DateTime.now(),
        vendor: 'ABC Infrastructure',
        isCapitalized: true, // Capitalized adds to actualCost
        notes: 'Road construction',
        userId: 'admin_user',
      );

      final updatedProj = await (db.select(db.projects)..where((p) => p.id.equals(proj.id))).getSingle();
      expect(updatedProj.actualCost, equals(1250000.0));
    });
  });
}
