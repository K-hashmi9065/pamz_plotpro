import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/dashboard/data/dashboard_repository.dart';
import 'package:land_investment_and_sales_management/features/dashboard/domain/dashboard_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DashboardRepository repo;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DashboardRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 11 - Executive Dashboard & System Settings Unit Tests', () {
    test('PortfolioSummaryModel total plots calculation', () {
      const summary = PortfolioSummaryModel(
        totalProjects: 3,
        totalLandAreaSqFt: 150000.0,
        soldLandAreaSqFt: 50000.0,
        remainingLandAreaSqFt: 100000.0,
        totalCapitalInvested: 10000000.0,
        totalAgreedSales: 12000000.0,
        totalCashCollected: 8000000.0,
        totalOutflows: 6000000.0,
        netCashFlow: 2000000.0,
        totalReceivables: 4000000.0,
        totalPayables: 1000000.0,
        totalAvailablePlots: 25,
        totalBookedPlots: 0,
        totalSoldPlots: 15,
      );

      expect(summary.totalPlotsCount, equals(40));
    });

    test('DashboardRepository aggregates portfolio metrics across projects', () async {
      final p1Id = uuid.v4();
      final p2Id = uuid.v4();

      // Create 2 Projects
      await db.into(db.projects).insert(
            ProjectsCompanion(
              id: drift.Value(p1Id),
              code: const drift.Value('PRJ-001'),
              name: const drift.Value('Sunrise Heights'),
              location: const drift.Value('Sector 1'),
              landAreaSqFt: const drift.Value(50000.0),
              status: drift.Value(ProjectStatus.active.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      await db.into(db.projects).insert(
            ProjectsCompanion(
              id: drift.Value(p2Id),
              code: const drift.Value('PRJ-002'),
              name: const drift.Value('Valley View'),
              location: const drift.Value('Sector 2'),
              landAreaSqFt: const drift.Value(75000.0),
              status: drift.Value(ProjectStatus.active.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      // Add Plots for P1
      await db.into(db.plots).insert(
            PlotsCompanion(
              id: drift.Value(uuid.v4()),
              projectId: drift.Value(p1Id),
              plotNumber: const drift.Value('A-1'),
              areaSqFt: const drift.Value(1500.0),
              status: drift.Value(PlotStatus.available.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      await db.into(db.plots).insert(
            PlotsCompanion(
              id: drift.Value(uuid.v4()),
              projectId: drift.Value(p1Id),
              plotNumber: const drift.Value('A-2'),
              areaSqFt: const drift.Value(1500.0),
              status: drift.Value(PlotStatus.sold.name),
              createdAt: drift.Value(DateTime.now()),
            ),
          );

      final summary = await repo.watchPortfolioSummary().first;

      expect(summary.totalProjects, equals(2));
      expect(summary.totalLandAreaSqFt, equals(125000.0));
      expect(summary.totalAvailablePlots, equals(1));
      expect(summary.totalSoldPlots, equals(1));
    });

    test('Audit log records system administrative events', () async {
      await db.into(db.auditLogs).insert(
            AuditLogsCompanion(
              id: drift.Value(uuid.v4()),
              userId: const drift.Value('admin_user'),
              action: const drift.Value('SYSTEM_BACKUP'),
              entityType: const drift.Value('Database'),
              entityId: const drift.Value('DB_01'),
              details: const drift.Value('Created backup copy of land_investment.sqlite'),
              timestamp: drift.Value(DateTime.now()),
            ),
          );

      final logs = await db.select(db.auditLogs).get();
      expect(logs.length, equals(1));
      expect(logs.first.action, equals('SYSTEM_BACKUP'));
    });
  });
}
