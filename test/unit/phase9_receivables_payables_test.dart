import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/utils/calculation_engine.dart';
import 'package:land_investment_and_sales_management/features/receivables_payables/data/receivables_payables_repository.dart';
import 'package:land_investment_and_sales_management/features/receivables_payables/domain/receivable_payable_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ReceivablesPayablesRepository repo;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ReceivablesPayablesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 9 - Receivables, Payables & Cash Flow Unit Tests', () {
    test('BuyerReceivableModel aging bucket classification', () {
      final current = BuyerReceivableModel(
        installmentId: '1',
        saleId: 's1',
        buyerName: 'Buyer A',
        projectId: 'p1',
        installmentNumber: 1,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        dueAmount: 50000,
        paidAmount: 0,
        balanceOutstanding: 50000,
        overdueDays: 0,
      );
      expect(current.agingBucket, equals('Current'));

      final bucket30 = BuyerReceivableModel(
        installmentId: '2',
        saleId: 's1',
        buyerName: 'Buyer B',
        projectId: 'p1',
        installmentNumber: 2,
        dueDate: DateTime.now().subtract(const Duration(days: 15)),
        dueAmount: 50000,
        paidAmount: 0,
        balanceOutstanding: 50000,
        overdueDays: 15,
      );
      expect(bucket30.agingBucket, equals('0-30 Days'));

      final bucket60 = BuyerReceivableModel(
        installmentId: '3',
        saleId: 's1',
        buyerName: 'Buyer C',
        projectId: 'p1',
        installmentNumber: 3,
        dueDate: DateTime.now().subtract(const Duration(days: 45)),
        dueAmount: 50000,
        paidAmount: 0,
        balanceOutstanding: 50000,
        overdueDays: 45,
      );
      expect(bucket60.agingBucket, equals('31-60 Days'));

      final bucket90 = BuyerReceivableModel(
        installmentId: '4',
        saleId: 's1',
        buyerName: 'Buyer D',
        projectId: 'p1',
        installmentNumber: 4,
        dueDate: DateTime.now().subtract(const Duration(days: 75)),
        dueAmount: 50000,
        paidAmount: 0,
        balanceOutstanding: 50000,
        overdueDays: 75,
      );
      expect(bucket90.agingBucket, equals('61-90 Days'));

      final bucketOver90 = BuyerReceivableModel(
        installmentId: '5',
        saleId: 's1',
        buyerName: 'Buyer E',
        projectId: 'p1',
        installmentNumber: 5,
        dueDate: DateTime.now().subtract(const Duration(days: 120)),
        dueAmount: 50000,
        paidAmount: 0,
        balanceOutstanding: 50000,
        overdueDays: 120,
      );
      expect(bucketOver90.agingBucket, equals('90+ Days'));
    });

    test('CalculationEngine net cash flow calculation (Inflows - Outflows)', () {
      final inflows = 5000000.0; // ₹50,00,000 collected from buyers
      final landOutflows = 2000000.0; // ₹20,00,000 paid to landowners
      final expenseOutflows = 500000.0; // ₹5,00,000 project expenses

      final netCashFlow = CalculationEngine.calculateNetCashFlow(
        totalCashInflows: inflows,
        totalCashOutflows: landOutflows + expenseOutflows,
      );

      expect(netCashFlow, equals(2500000.0)); // ₹25,00,000 net positive cash
    });

    test('watchProjectCashFlows aggregates inflows and outflows correctly', () async {
      final projectId = uuid.v4();

      // Create Project
      await db.into(db.projects).insert(
            ProjectsCompanion(
              id: drift.Value(projectId),
              code: const drift.Value('CF-PRJ-01'),
              name: drift.Value('Cash Flow Project'),
              location: const drift.Value('Sector 10'),
              status: drift.Value(ProjectStatus.active.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 1. Add non-voided transaction (+ ₹1,00,000 inflow)
      await db.into(db.transactions).insert(
            TransactionsCompanion(
              id: drift.Value(uuid.v4()),
              projectId: drift.Value(projectId),
              amount: const drift.Value(100000.0),
              paymentDate: drift.Value(DateTime.now()),
              paymentMethod: drift.Value(PaymentMethod.bankTransfer.name),
              isVoided: const drift.Value(false),
              createdBy: const drift.Value('admin'),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 2. Add voided transaction (should be excluded from inflows)
      await db.into(db.transactions).insert(
            TransactionsCompanion(
              id: drift.Value(uuid.v4()),
              projectId: drift.Value(projectId),
              amount: const drift.Value(50000.0),
              paymentDate: drift.Value(DateTime.now()),
              paymentMethod: drift.Value(PaymentMethod.cash.name),
              isVoided: const drift.Value(true),
              voidReason: const drift.Value('Duplicate'),
              createdBy: const drift.Value('admin'),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 3. Add expense (- ₹20,000 outflow)
      await db.into(db.expenses).insert(
            ExpensesCompanion(
              id: drift.Value(uuid.v4()),
              projectId: drift.Value(projectId),
              category: drift.Value(ExpenseCategory.legal.name),
              amount: const drift.Value(20000.0),
              expenseDate: drift.Value(DateTime.now()),
              isCapitalized: const drift.Value(true),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      final cashFlows = await repo.watchProjectCashFlows().first;
      expect(cashFlows.isNotEmpty, isTrue);

      final cf = cashFlows.firstWhere((item) => item.projectId == projectId);
      expect(cf.totalInflows, equals(100000.0));
      expect(cf.totalExpenseOutflows, equals(20000.0));
      expect(cf.netCashFlow, equals(80000.0));
    });
  });
}
