import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/profit_loss_settlement/data/profit_loss_repository.dart';
import 'package:land_investment_and_sales_management/features/profit_loss_settlement/domain/profit_loss_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProfitLossRepository repo;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ProfitLossRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 10 - Profit & Loss & Investor Payout Unit Tests', () {
    test('ProjectProfitLossModel calculations (Gross, Net Proceeds, Distributable)', () {
      final pl = ProjectProfitLossModel(
        projectId: 'p1',
        projectName: 'Green Acres',
        totalAgreedSales: 10000000.0, // ₹1,00,00,000
        directSaleExpenses: 200000.0, // ₹2,00,000
        actualProjectCost: 6000000.0, // ₹60,00,000
        agentCommissions: 100000.0,
        adminManagementFee: 50000.0,
        contingencyReserve: 50000.0,
        cashCollected: 8000000.0, // ₹80,00,000
      );

      expect(pl.netSaleProceeds, equals(9800000.0)); // ₹98,00,000
      expect(pl.grossProjectProfit, equals(3800000.0)); // ₹38,00,000
      expect(pl.distributableProfit, equals(3600000.0)); // ₹36,00,000
      expect(pl.realizedProfit, equals(2000000.0)); // ₹20,00,000
    });

    test('InvestorPayoutModel ROI % and Settlement balance', () {
      final payout = InvestorPayoutModel(
        id: 'inv_alloc_1',
        investorId: 'inv_1',
        investorName: 'Rajesh Malhotra',
        projectId: 'p1',
        capitalInvested: 2000000.0, // ₹20,00,000 capital
        ownershipPercent: 25.0, // 25% ownership
        distributableProfitPool: 4000000.0, // ₹40,00,000 distributable profit
        payoutsDisbursed: 500000.0, // ₹5,00,000 already disbursed
      );

      expect(payout.allocatedProfitShare, equals(1000000.0)); // 25% of 40L = 10L
      expect(payout.roiPercent, equals(50.0)); // 10L / 20L * 100 = 50% ROI
      expect(payout.remainingPayoutBalance, equals(2500000.0)); // 20L + 10L - 5L = 25L
    });

    test('recordInvestorPayout inserts audit log and handles invalid input', () async {
      final projectInvestorId = uuid.v4();

      await db.into(db.projects).insert(
            ProjectsCompanion(
              id: const drift.Value('proj_1'),
              code: const drift.Value('PRJ-P1'),
              name: const drift.Value('PL Test Project'),
              location: const drift.Value('Test Location'),
              status: drift.Value(ProjectStatus.active.name),
              landAreaSqFt: const drift.Value(10000.0),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      await db.into(db.investors).insert(
            InvestorsCompanion(
              id: const drift.Value('inv_1'),
              name: const drift.Value('Test Investor'),
              phone: const drift.Value('9876543210'),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // Insert dummy project investor allocation
      await db.into(db.projectInvestors).insert(
            ProjectInvestorsCompanion(
              id: drift.Value(projectInvestorId),
              projectId: const drift.Value('proj_1'),
              investorId: const drift.Value('inv_1'),
              investedAmount: const drift.Value(1000000.0),
              ownershipPercent: const drift.Value(50.0),
              ownershipMethod: const drift.Value('capitalBased'),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // 1. Invalid amount <= 0 throws ArgumentError
      expect(
        () async => await repo.recordInvestorPayout(
          projectInvestorId: projectInvestorId,
          payoutAmount: 0.0,
          paymentReference: 'REF123',
          userId: 'admin_user',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // 2. Valid payout dispatches audit log
      await repo.recordInvestorPayout(
        projectInvestorId: projectInvestorId,
        payoutAmount: 250000.0,
        paymentReference: 'UTR-99887766',
        userId: 'admin_user',
      );

      final logs = await db.select(db.auditLogs).get();
      expect(logs.isNotEmpty, isTrue);

      final payoutLog = logs.firstWhere((l) => l.action == 'DISBURSE_INVESTOR_PAYOUT');
      expect(payoutLog.details, contains('Disbursed profit payout of ₹250000.0 to investor'));
      expect(payoutLog.details, contains('UTR-99887766'));
    });
  });
}
