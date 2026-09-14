import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/plots/data/plots_repository.dart';
import 'package:land_investment_and_sales_management/features/plots/domain/plot_model.dart';
import 'package:land_investment_and_sales_management/features/expenses/data/expenses_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late PlotsRepository plotsRepo;
  late ExpensesRepository expensesRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    plotsRepo = PlotsRepository(db);
    expensesRepo = ExpensesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PlotsRepository - Isolated Brokerage & Area-Wise General Expense Tests', () {
    test('recordPlotBrokerage updates plot details and isolates brokerage to that specific plot', () async {
      // 1. Create a project
      final project = await projectsRepo.createProject(
        name: 'Royal Greens Project',
        location: 'North Ring Road',
        landAreaSqFt: 10000,
        purchasePrice: 1000000, // ₹10,00,000
        userId: 'admin_user',
      );

      // 2. Create Plot #01 (4,000 sq ft) and Plot #02 (6,000 sq ft)
      final plot1 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot #01',
        areaSqFt: 4000,
        expectedPrice: 600000,
        userId: 'admin_user',
      );
      final plot2 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot #02',
        areaSqFt: 6000,
        expectedPrice: 900000,
        userId: 'admin_user',
      );

      expect(plot1.brokerName, isNull);
      expect(plot1.brokerageCharge, equals(0.0));
      expect(plot1.hasBrokerage, isFalse);

      // 3. Record Brokerage for Plot #01 only: ₹25,000
      await plotsRepo.recordPlotBrokerage(
        plotId: plot1.id,
        brokerName: 'Ramesh Sharma',
        brokerPhone: '+91 9876543210',
        brokerageCharge: 25000,
        userId: 'admin_user',
      );

      // 4. Verify Plot 1 record in DB
      final updatedPlot1Row = await (db.select(db.plots)..where((tbl) => tbl.id.equals(plot1.id))).getSingle();
      final updatedPlot1 = plotsRepo.toModel(updatedPlot1Row);

      expect(updatedPlot1.brokerName, equals('Ramesh Sharma'));
      expect(updatedPlot1.brokerPhone, equals('+91 9876543210'));
      expect(updatedPlot1.brokerageCharge, equals(25000.0));
      expect(updatedPlot1.hasBrokerage, isTrue);

      // 5. Verify that an expense was recorded under project as category brokerage
      final expenses = await (db.select(db.expenses)..where((tbl) => tbl.projectId.equals(project.id))).get();
      expect(expenses.length, equals(1));
      expect(expenses.first.category, equals(ExpenseCategory.brokerage.name));
      expect(expenses.first.amount, equals(25000.0));
      expect(expenses.first.vendor, equals('Ramesh Sharma'));
      expect(expenses.first.isCapitalized, isTrue);
      expect(expenses.first.notes, contains('Plot #Plot #01'));

      // 6. Verify Project actualCost: 1,000,000 purchase + 25,000 brokerage = 1,025,000
      final updatedProject = await (db.select(db.projects)..where((tbl) => tbl.id.equals(project.id))).getSingle();
      expect(updatedProject.actualCost, equals(1025000.0));

      // 7. Verify Plot cost allocation:
      // Plot 1 (4,000 / 10,000 = 40%): Base Land Cost = 400,000 + 0 gen expense + 25,000 brokerage = 425,000
      // Plot 2 (6,000 / 10,000 = 60%): Base Land Cost = 600,000 + 0 gen expense + 0 brokerage = 600,000
      final updatedPlot2Row = await (db.select(db.plots)..where((tbl) => tbl.id.equals(plot2.id))).getSingle();

      expect(updatedPlot1Row.allocatedCost, equals(425000.0));
      expect(updatedPlot2Row.allocatedCost, equals(600000.0));
      expect(updatedPlot1Row.allocatedCost + updatedPlot2Row.allocatedCost, equals(1025000.0));
    });

    test('User prompt scenario: 5 plots of 1 Kattha each, 5000 general project expense, 2000 brokerage on Plot 1', () async {
      final oneKatthaSqFt = LandUnitConverter.kattaDhurToSqFt(1, 0); // 1363.0 sq ft
      final totalLandAreaSqFt = oneKatthaSqFt * 5; // 6815.0 sq ft

      // 1. Create project with purchase price = 50,000
      final project = await projectsRepo.createProject(
        name: 'Township Project',
        location: 'Highway',
        landAreaSqFt: totalLandAreaSqFt,
        purchasePrice: 50000,
        userId: 'admin_user',
      );

      // 2. Create 5 plots of 1 Kattha each
      final plots = <PlotModel>[];
      for (int i = 1; i <= 5; i++) {
        final p = await plotsRepo.createPlot(
          projectId: project.id,
          plotNumber: 'AXPN000$i',
          areaSqFt: oneKatthaSqFt,
          expectedPrice: 20000,
          userId: 'admin_user',
        );
        plots.add(p);
      }

      // 3. Add General Project Expense of ₹5,000 (e.g. Earth filling / Development)
      await expensesRepo.addExpense(
        projectId: project.id,
        category: ExpenseCategory.development,
        amount: 5000,
        expenseDate: DateTime.now(),
        isCapitalized: true,
        notes: 'Earth leveling across entire land',
        userId: 'admin_user',
      );

      // 4. Add Brokerage Charge of ₹2,000 for Plot #1 only
      await plotsRepo.recordPlotBrokerage(
        plotId: plots[0].id,
        brokerName: 'Anil Broker',
        brokerPhone: '9876543210',
        brokerageCharge: 2000,
        userId: 'admin_user',
      );

      // 5. Fetch updated plots from database
      final updatedPlotRows = await (db.select(db.plots)..where((tbl) => tbl.projectId.equals(project.id))).get();
      
      // Plot 1:
      // Base Land Cost = (1/5) * 50000 = 10000
      // Allocated General Expense = (1/5) * 5000 = 1000
      // Direct Brokerage = 2000
      // Total Expense = 1000 + 2000 = 3000
      // Total Allocated Cost = 10000 + 3000 = 13000
      final p1 = updatedPlotRows.firstWhere((r) => r.plotNumber == 'AXPN0001');
      expect(p1.brokerageCharge, equals(2000.0));
      expect(p1.allocatedCost, equals(13000.0));

      // Plots 2..5:
      // Base Land Cost = 10000
      // Allocated General Expense = 1000
      // Direct Brokerage = 0
      // Total Expense = 1000 + 0 = 1000
      // Total Allocated Cost = 10000 + 1000 = 11000
      for (int i = 2; i <= 5; i++) {
        final pi = updatedPlotRows.firstWhere((r) => r.plotNumber == 'AXPN000$i');
        expect(pi.brokerageCharge, equals(0.0));
        expect(pi.allocatedCost, equals(11000.0));
      }

      // Check total project actualCost: 50000 (land) + 5000 (development) + 2000 (brokerage) = 57000
      final projRow = await (db.select(db.projects)..where((tbl) => tbl.id.equals(project.id))).getSingle();
      expect(projRow.actualCost, equals(57000.0));

      // Sum of all plot allocated costs = 13000 + (4 * 11000) = 57000
      final totalPlotsCost = updatedPlotRows.fold<double>(0.0, (sum, p) => sum + p.allocatedCost);
      expect(totalPlotsCost, equals(57000.0));
    });

    test('recordPlotBrokerage validates invalid arguments', () async {
      expect(
        () => plotsRepo.recordPlotBrokerage(
          plotId: 'non-existent-id',
          brokerName: 'Test Broker',
          brokerPhone: '123456',
          brokerageCharge: 1000,
          userId: 'admin',
        ),
        throwsA(isA<ArgumentError>()),
      );

      final project = await projectsRepo.createProject(
        name: 'Validation Project',
        location: 'City',
        landAreaSqFt: 5000,
        purchasePrice: 500000,
        userId: 'admin',
      );

      final plot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot #V1',
        areaSqFt: 2500,
        userId: 'admin',
      );

      expect(
        () => plotsRepo.recordPlotBrokerage(
          plotId: plot.id,
          brokerName: '',
          brokerPhone: '123456',
          brokerageCharge: 1000,
          userId: 'admin',
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => plotsRepo.recordPlotBrokerage(
          plotId: plot.id,
          brokerName: 'Broker',
          brokerPhone: '123456',
          brokerageCharge: 0,
          userId: 'admin',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
