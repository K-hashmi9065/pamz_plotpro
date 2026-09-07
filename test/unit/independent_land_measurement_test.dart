import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/utils/calculation_engine.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';
import 'package:land_investment_and_sales_management/features/plots/data/plots_repository.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';

void main() {
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

  group('INDEPENDENT LAND MEASUREMENT SYSTEM TESTS', () {
    test('TEST 1: Project (5 Acre) & Plot (2500 Sq Ft) stored independently', () async {
      // 1. Create Project with 5 Acre
      final double acreSqFt = LandUnitConverter.unitToSqFt(unit: 'Acre', displayArea: 5.0);
      final project = await projectsRepo.createProject(
        name: 'Kishanganj Green Valley',
        location: 'Kishanganj',
        landAreaSqFt: acreSqFt,
        measurementUnit: 'Acre',
        displayArea: 5.0,
        userId: 'admin',
      );

      expect(project.measurementUnit, equals('Acre'));
      expect(project.displayArea, equals(5.0));
      expect(project.formattedArea, equals('5 Acre'));

      // 2. Create Plot inside project with 2500 Sq Ft
      final plot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-01',
        areaSqFt: 2500.0,
        measurementUnit: 'Square Feet',
        displayArea: 2500.0,
        userId: 'admin',
      );

      expect(plot.measurementUnit, equals('Square Feet'));
      expect(plot.displayArea, equals(2500.0));
      expect(plot.formattedArea, equals('2500 Sq Ft'));

      // 3. Verify Project unit remains 5 Acre
      final refetchedProject = await projectsRepo.getProjectById(project.id);
      expect(refetchedProject!.formattedArea, equals('5 Acre'));
      expect(refetchedProject.measurementUnit, equals('Acre'));
    });

    test('TEST 2: Project (10 Acre) & Plot (1 Katta + 2 Dhur) independent measurement', () async {
      final double acreSqFt = LandUnitConverter.unitToSqFt(unit: 'Acre', displayArea: 10.0);
      final project = await projectsRepo.createProject(
        name: 'Valley Estate',
        location: 'Sector 9',
        landAreaSqFt: acreSqFt,
        measurementUnit: 'Acre',
        displayArea: 10.0,
        userId: 'admin',
      );

      final double kattaDhurSqFt = LandUnitConverter.unitToSqFt(
        unit: 'Katta + Dhur',
        displayArea: 0.0,
        kattaValue: 1.0,
        dhurValue: 2.0,
      );

      final plot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-01',
        areaSqFt: kattaDhurSqFt,
        measurementUnit: 'Katta + Dhur',
        kattaValue: 1.0,
        dhurValue: 2.0,
        userId: 'admin',
      );

      expect(plot.measurementUnit, equals('Katta + Dhur'));
      expect(plot.kattaValue, equals(1.0));
      expect(plot.dhurValue, equals(2.0));
      expect(plot.formattedArea, equals('1 Kattha + 2 Dhur'));

      final refetchedProject = await projectsRepo.getProjectById(project.id);
      expect(refetchedProject!.measurementUnit, equals('Acre'));
    });

    test('TEST 3: Multiple Plots in Same Project with Different Measurement Units', () async {
      final double projectSqFt = LandUnitConverter.unitToSqFt(unit: 'Acre', displayArea: 5.0);
      final project = await projectsRepo.createProject(
        name: 'Multi-Unit Project',
        location: 'Zone A',
        landAreaSqFt: projectSqFt,
        measurementUnit: 'Acre',
        displayArea: 5.0,
        userId: 'admin',
      );

      // Plot A-01: 1 Katta + 2 Dhur
      final plot1SqFt = LandUnitConverter.unitToSqFt(
        unit: 'Katta + Dhur',
        displayArea: 0.0,
        kattaValue: 1.0,
        dhurValue: 2.0,
      );
      final plot1 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-01',
        areaSqFt: plot1SqFt,
        measurementUnit: 'Katta + Dhur',
        kattaValue: 1.0,
        dhurValue: 2.0,
        userId: 'admin',
      );

      // Plot A-02: 2500 Sq Ft
      final plot2 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-02',
        areaSqFt: 2500.0,
        measurementUnit: 'Square Feet',
        displayArea: 2500.0,
        userId: 'admin',
      );

      // Plot A-03: 2 Dhur
      final plot3SqFt = LandUnitConverter.unitToSqFt(
        unit: 'Dhur',
        displayArea: 2.0,
      );
      final plot3 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-03',
        areaSqFt: plot3SqFt,
        measurementUnit: 'Dhur',
        displayArea: 2.0,
        userId: 'admin',
      );

      expect(plot1.formattedArea, equals('1 Kattha + 2 Dhur'));
      expect(plot2.formattedArea, equals('2500 Sq Ft'));
      expect(plot3.formattedArea, equals('2 Dhur'));

      expect(plot1.measurementUnit, equals('Katta + Dhur'));
      expect(plot2.measurementUnit, equals('Square Feet'));
      expect(plot3.measurementUnit, equals('Dhur'));
    });

    test('TEST 4: Editing Project measurement does NOT modify existing Plot measurements', () async {
      final project = await projectsRepo.createProject(
        name: 'Edit Test Project',
        location: 'Loc',
        landAreaSqFt: 217800.0, // 5 Acre
        measurementUnit: 'Acre',
        displayArea: 5.0,
        userId: 'admin',
      );

      final plotSqFt = LandUnitConverter.unitToSqFt(unit: 'Katta + Dhur', displayArea: 0.0, kattaValue: 1.0, dhurValue: 2.0);
      final plot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-01',
        areaSqFt: plotSqFt,
        measurementUnit: 'Katta + Dhur',
        kattaValue: 1.0,
        dhurValue: 2.0,
        userId: 'admin',
      );

      // Edit Project measurement to Bigha
      final updatedProject = project.copyWith(
        measurementUnit: 'Bigha',
        displayArea: 8.0,
      );
      await projectsRepo.updateProject(updatedProject, userId: 'admin');

      // Fetch plot and verify it remains 1 Katta + 2 Dhur
      final plots = await plotsRepo.watchPlotsForProject(project.id).first;
      final refetchedPlot = plots.firstWhere((p) => p.id == plot.id);

      expect(refetchedPlot.measurementUnit, equals('Katta + Dhur'));
      expect(refetchedPlot.formattedArea, equals('1 Kattha + 2 Dhur'));
    });

    test('TEST 5: Editing Plot measurement does NOT modify Project measurement', () async {
      final project = await projectsRepo.createProject(
        name: 'Plot Edit Project',
        location: 'Loc',
        landAreaSqFt: 217800.0,
        measurementUnit: 'Acre',
        displayArea: 5.0,
        userId: 'admin',
      );

      final plot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-01',
        areaSqFt: 2500.0,
        measurementUnit: 'Square Feet',
        displayArea: 2500.0,
        userId: 'admin',
      );

      // Edit Plot measurement
      final updatedPlot = plot.copyWith(
        measurementUnit: 'Katta',
        displayArea: 2.0,
        areaSqFt: 2722.5,
      );
      await plotsRepo.updatePlot(updatedPlot, userId: 'admin');

      final refetchedProject = await projectsRepo.getProjectById(project.id);
      expect(refetchedProject!.measurementUnit, equals('Acre'));
      expect(refetchedProject.displayArea, equals(5.0));
      expect(refetchedProject.formattedArea, equals('5 Acre'));
    });

    test('TEST 6: Project and Plot independent measurement persistence in DB', () async {
      final project = await projectsRepo.createProject(
        name: 'Persistence Project',
        location: 'Loc',
        landAreaSqFt: 43560.0,
        measurementUnit: 'Acre',
        displayArea: 1.0,
        userId: 'admin',
      );

      await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'P-10',
        areaSqFt: 1361.25,
        measurementUnit: 'Katta',
        displayArea: 1.0,
        userId: 'admin',
      );

      // Re-query directly from DB table rows
      final pRow = await (db.select(db.projects)..where((tbl) => tbl.id.equals(project.id))).getSingle();
      expect(pRow.measurementUnit, equals('Acre'));
      expect(pRow.displayArea, equals(1.0));

      final plotRows = await (db.select(db.plots)..where((tbl) => tbl.projectId.equals(project.id))).get();
      expect(plotRows.first.measurementUnit, equals('Katta'));
      expect(plotRows.first.displayArea, equals(1.0));
    });

    test('TEST 7: Plot List & Reports show each Plot\'s own original measurement', () async {
      final project = await projectsRepo.createProject(
        name: 'Report Test Project',
        location: 'Loc',
        landAreaSqFt: 217800.0,
        measurementUnit: 'Acre',
        displayArea: 5.0,
        userId: 'admin',
      );

      final p1SqFt = LandUnitConverter.unitToSqFt(unit: 'Katta + Dhur', displayArea: 0.0, kattaValue: 1.0, dhurValue: 2.0);
      await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-01',
        areaSqFt: p1SqFt,
        measurementUnit: 'Katta + Dhur',
        kattaValue: 1.0,
        dhurValue: 2.0,
        status: PlotStatus.available,
        userId: 'admin',
      );

      await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-02',
        areaSqFt: 2500.0,
        measurementUnit: 'Square Feet',
        displayArea: 2500.0,
        status: PlotStatus.sold,
        userId: 'admin',
      );

      final p3SqFt = LandUnitConverter.unitToSqFt(unit: 'Dhur', displayArea: 2.0);
      await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-03',
        areaSqFt: p3SqFt,
        measurementUnit: 'Dhur',
        displayArea: 2.0,
        status: PlotStatus.available,
        userId: 'admin',
      );

      final plots = await plotsRepo.watchPlotsForProject(project.id).first;
      final formattedDisplays = plots.map((p) => p.formattedArea).toList();

      expect(formattedDisplays, contains('1 Kattha + 2 Dhur'));
      expect(formattedDisplays, contains('2500 Sq Ft'));
      expect(formattedDisplays, contains('2 Dhur'));
    });

    test('TEST 8: Remaining Land calculation normalizes plot units without altering original plot units', () async {
      final double projectSqFt = LandUnitConverter.unitToSqFt(unit: 'Acre', displayArea: 5.0); // 217,800 Sq Ft
      final project = await projectsRepo.createProject(
        name: 'Calculation Project',
        location: 'Loc',
        landAreaSqFt: projectSqFt,
        measurementUnit: 'Acre',
        displayArea: 5.0,
        userId: 'admin',
      );

      // Plot A-01: 2500 Sq Ft
      final p1 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-01',
        areaSqFt: 2500.0,
        measurementUnit: 'Square Feet',
        displayArea: 2500.0,
        userId: 'admin',
      );

      // Plot A-02: 1 Katta + 2 Dhur (1,361.25 + 136.125 = 1,497.375 Sq Ft)
      final p2SqFt = LandUnitConverter.unitToSqFt(unit: 'Katta + Dhur', displayArea: 0.0, kattaValue: 1.0, dhurValue: 2.0);
      final p2 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-02',
        areaSqFt: p2SqFt,
        measurementUnit: 'Katta + Dhur',
        kattaValue: 1.0,
        dhurValue: 2.0,
        userId: 'admin',
      );

      // Plot A-03: 2 Dhur (136.125 Sq Ft)
      final p3SqFt = LandUnitConverter.unitToSqFt(unit: 'Dhur', displayArea: 2.0);
      final p3 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'A-03',
        areaSqFt: p3SqFt,
        measurementUnit: 'Dhur',
        displayArea: 2.0,
        userId: 'admin',
      );

      final plots = [p1, p2, p3];
      final remainingLandStr = CalculationEngine.calculateRemainingProjectLand(
        projectLandAreaSqFt: project.landAreaSqFt,
        projectMeasurementUnit: project.measurementUnit,
        plotAreasSqFt: plots.map((p) => p.areaSqFt).toList(),
      );

      // Total plots sq ft = 2500 + 1497.375 + 136.125 = 4133.5 Sq Ft
      // Remaining = 217,800 - 4133.5 = 213,666.5 Sq Ft = 4.91 Acre
      expect(remainingLandStr, contains('Acre'));

      // Original plot measurements must remain completely unchanged
      expect(p1.formattedArea, equals('2500 Sq Ft'));
      expect(p2.formattedArea, equals('1 Kattha + 2 Dhur'));
      expect(p3.formattedArea, equals('2 Dhur'));
    });
  });
}
