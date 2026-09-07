import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/plots/data/plots_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late PlotsRepository plotsRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    plotsRepo = PlotsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 6 - Plots & Area-Based Cost Allocation Integration Tests', () {
    test('AC-05.1: Area-based cost allocation computes exact plot cost', () async {
      // Parent land with Actual Cost ₹2,27,00,000 and area 2,27,000 sq. ft.
      final project = await projectsRepo.createProject(
        name: 'Plot Cost Allocation Project',
        location: 'Highway Sector',
        landAreaSqFt: 227000,
        purchasePrice: 22700000, // ₹2,27,00,000
        userId: 'admin_user',
      );

      // Create Plot #12 with area 1,000 sq. ft.
      final plot12 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot #12',
        areaSqFt: 1000,
        expectedPrice: 250000,
        userId: 'admin_user',
      );

      // Allocated cost should equal ₹1,00,000 (i.e. 1,000 / 1,000 * 2,27,00,000 when only plot12 exists)
      expect(plot12.allocatedCost, equals(22700000.0));

      // Now add Plot #13 with area 2,26,000 sq. ft. (bringing total plot area to 2,27,000 sq. ft.)
      await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot #13',
        areaSqFt: 226000,
        expectedPrice: 50000000,
        userId: 'admin_user',
      );

      final plotsList = await (db.select(db.plots)..where((tbl) => tbl.projectId.equals(project.id))).get();
      final updatedPlot12 = plotsList.firstWhere((p) => p.plotNumber == 'Plot #12');
      final updatedPlot13 = plotsList.firstWhere((p) => p.plotNumber == 'Plot #13');

      // Plot #12 allocated cost = (1,000 / 2,27,000) * 2,27,00,000 = ₹1,00,000 (AC-05.1)
      expect(updatedPlot12.allocatedCost, equals(100000.0));
      expect(updatedPlot13.allocatedCost, equals(22600000.0));
    });

    test('AC-05.2: Sold plot availability check returns false', () async {
      final project = await projectsRepo.createProject(
        name: 'Sold Plot Project',
        location: 'Sector 5',
        landAreaSqFt: 10000,
        userId: 'admin_user',
      );

      final plot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot #101',
        areaSqFt: 1200,
        status: PlotStatus.sold,
        userId: 'admin_user',
      );

      expect(plot.isAvailable, isFalse);
      expect(plot.isSold, isTrue);
    });
  });
}
