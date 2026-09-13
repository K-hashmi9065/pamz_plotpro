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

      // Allocated cost should equal ₹1,00,000 (i.e. 1,000 / 1,000 * 2,27,00,000)
      expect(plot12.allocatedCost, equals(100000.0));

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

    test('AC-05.3: Road parcel recognition, dimension formatting, and availability', () async {
      final project = await projectsRepo.createProject(
        name: 'Road Test Project',
        location: 'Sector 8',
        landAreaSqFt: 50000,
        userId: 'admin_user',
      );

      final roadPlot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Access Road (AXPN0001)',
        areaSqFt: 7200,
        lengthFt: 120,
        lengthIn: 0,
        breadthFt: 60,
        breadthIn: 0,
        status: PlotStatus.reserved,
        userId: 'admin_user',
      );

      expect(roadPlot.isRoad, isTrue);
      expect(roadPlot.isAvailable, isFalse);
      expect(roadPlot.isSold, isFalse);
      expect(roadPlot.formattedLength, equals('120 ft'));
      expect(roadPlot.formattedBreadth, equals('60 ft'));

      // Road with zero length/breadth should format as dash
      final zeroRoad = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Internal Road #1',
        areaSqFt: 3600,
        userId: 'admin_user',
      );
      expect(zeroRoad.isRoad, isTrue);
      expect(zeroRoad.formattedLength, equals('—'));
      expect(zeroRoad.formattedBreadth, equals('—'));
    });

    test('Batch Creation: createPlotsBatch creates multiple plots with identical length & breadth', () async {
      final project = await projectsRepo.createProject(
        name: 'Township Batch Subdivide',
        location: 'Highway Sector 9',
        landAreaSqFt: 129600,
        purchasePrice: 11520000,
        userId: 'admin_user',
      );

      final plotNumbers = [
        'AXPN0001',
        'AXPN0002',
        'AXPN0003',
        'AXPN0004',
        'AXPN0005',
        'AXPN0006',
        'AXPN0007',
        'AXPN0008',
        'AXPN0009',
        'AXPN0010',
      ];

      final createdPlots = await plotsRepo.createPlotsBatch(
        projectId: project.id,
        plotNumbers: plotNumbers,
        areaSqFt: 12240,
        lengthFt: 120,
        lengthIn: 0,
        breadthFt: 102,
        breadthIn: 0,
        expectedPrice: 4460800,
        status: PlotStatus.available,
        userId: 'admin_user',
      );

      expect(createdPlots.length, equals(10));
      for (int i = 0; i < 10; i++) {
        expect(createdPlots[i].plotNumber, equals(plotNumbers[i]));
        expect(createdPlots[i].areaSqFt, equals(12240));
        expect(createdPlots[i].lengthFt, equals(120));
        expect(createdPlots[i].breadthFt, equals(102));
        expect(createdPlots[i].status, equals(PlotStatus.available));
        // Plot area = 12240 sq ft, total area = 129600 sq ft, cost = 12240 * (11520000 / 129600) = 1088000.0
        expect(createdPlots[i].allocatedCost, equals(1088000.0));
      }
    });

    test('Auto-generate road numbers: generateNextRoadNumber increments properly', () async {
      final initialRoad = await plotsRepo.generateNextRoadNumber();
      expect(initialRoad, equals('ROAD-01'));

      final project = await projectsRepo.createProject(
        name: 'Road Numbering Project',
        location: 'Sector 10',
        landAreaSqFt: 50000,
        userId: 'admin_user',
      );

      await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: initialRoad,
        areaSqFt: 5000,
        status: PlotStatus.reserved,
        userId: 'admin_user',
      );

      final nextRoad = await plotsRepo.generateNextRoadNumber();
      expect(nextRoad, equals('ROAD-02'));
    });
  });
}


