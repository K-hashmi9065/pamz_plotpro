import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/data/sales_repository.dart';
import 'package:land_investment_and_sales_management/features/expenses/data/expenses_repository.dart';
import 'package:land_investment_and_sales_management/features/investors/data/investors_repository.dart';
import 'package:land_investment_and_sales_management/features/plots/data/plots_repository.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late PlotsRepository plotsRepo;
  late ExpensesRepository expensesRepo;
  late InvestorsRepository investorsRepo;
  late SalesRepository salesRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    plotsRepo = PlotsRepository(db);
    expensesRepo = ExpensesRepository(db);
    investorsRepo = InvestorsRepository(db);
    salesRepo = SalesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Client Land Story & Business Model End-to-End Verification Test', () {
    test('1. Land Purchase & Dimensional Conversions (600 ft x 216 ft)', () {
      const lengthFt = 600.0;
      const breadthFt = 216.0;

      // 600 x 216 = 129,600 sq ft
      final totalAreaSqFt = LandUnitConverter.dimensionsToSqFt(
        lengthFt: lengthFt,
        lengthIn: 0,
        breadthFt: breadthFt,
        breadthIn: 0,
      );
      expect(totalAreaSqFt, equals(129600.0));

      // 129,600 / 1,125 = 115.20 Kattha
      final kattha = LandUnitConverter.sqFtToKatta(totalAreaSqFt);
      expect(kattha, equals(115.2));

      // 115.20 * 20 = 2,304 Dhur
      final dhur = LandUnitConverter.sqFtToDhur(totalAreaSqFt);
      expect(dhur, equals(2304.0));

      // 115.20 * 2.5 = 288.0 Decimal (or 129,600 / 450 = 288.0 Decimal)
      final decimalVal = LandUnitConverter.kattaToDecimal(kattha);
      expect(decimalVal, equals(288.0));

      // Purchase Rate = ₹1,00,000 / Kattha => Purchase Cost = ₹1,15,20,000
      const purchaseRatePerKattha = 100000.0;
      final landPurchaseCost = kattha * purchaseRatePerKattha;
      expect(landPurchaseCost, equals(11520000.0));
    });

    test('2. Project Expenses & Actual Project Cost (₹1,17,70,000)', () async {
      // 1. Create Project with base Land Purchase Cost
      final project = await projectsRepo.createProject(
        name: 'Grand Land Township',
        location: 'Prime Highway Corridor',
        landAreaSqFt: 129600.0,
        measurementUnit: 'Kattha',
        displayArea: 115.2,
        kattaValue: 115.2,
        lengthFt: 600,
        breadthFt: 216,
        purchasePrice: 11520000.0, // ₹1,15,20,000
        userId: 'admin_user',
      );

      // 2. Add Broker Charge ₹2,00,000 (Capitalized)
      await expensesRepo.addExpense(
        projectId: project.id,
        category: ExpenseCategory.brokerage,
        amount: 200000.0,
        expenseDate: DateTime.now(),
        vendor: 'Lead Broker',
        isCapitalized: true,
        userId: 'admin_user',
      );

      // 3. Add Development / Boundary Charge ₹50,000 (Capitalized)
      await expensesRepo.addExpense(
        projectId: project.id,
        category: ExpenseCategory.development,
        amount: 50000.0,
        expenseDate: DateTime.now(),
        vendor: 'Boundary Construction Co',
        isCapitalized: true,
        userId: 'admin_user',
      );

      final updatedProject = await (db.select(db.projects)..where((tbl) => tbl.id.equals(project.id))).getSingle();
      // Actual Project Cost = 1,15,20,000 + 2,00,000 + 50,000 = ₹1,17,70,000
      expect(updatedProject.actualCost, equals(11770000.0));
    });

    test('3. Road Corridor & Available Plot Area Separation (7,200 sq ft road + 122,400 sq ft plots)', () {
      const roadLengthFt = 600.0;
      const roadWidthFt = 12.0;

      // Road Area = 600 x 12 = 7,200 sq ft
      final roadAreaSqFt = LandUnitConverter.dimensionsToSqFt(
        lengthFt: roadLengthFt,
        lengthIn: 0,
        breadthFt: roadWidthFt,
        breadthIn: 0,
      );
      expect(roadAreaSqFt, equals(7200.0));

      // Road Kattha = 7,200 / 1,125 = 6.40 Kattha
      final roadKattha = LandUnitConverter.sqFtToKatta(roadAreaSqFt);
      expect(roadKattha, equals(6.4));

      // Road Dhur = 6.40 * 20 = 128 Dhur
      final roadDhur = LandUnitConverter.sqFtToDhur(roadAreaSqFt);
      expect(roadDhur, equals(128.0));

      // Available sellable Plot Area = 129,600 - 7,200 = 122,400 sq ft
      final availablePlotAreaSqFt = 129600.0 - roadAreaSqFt;
      expect(availablePlotAreaSqFt, equals(122400.0));
      expect(LandUnitConverter.sqFtToKatta(availablePlotAreaSqFt), equals(108.8));
    });

    test('4. Plot Dimensions & Subdivision into 10 Plots (Each 12,240 sq ft / 10.88 Kattha)', () {
      const plotLengthFt = 120.0;
      const plotBreadthFt = 102.0;

      // 120 x 102 = 12,240 sq ft
      final singlePlotArea = LandUnitConverter.dimensionsToSqFt(
        lengthFt: plotLengthFt,
        lengthIn: 0,
        breadthFt: plotBreadthFt,
        breadthIn: 0,
      );
      expect(singlePlotArea, equals(12240.0));

      // 12,240 / 1,125 = 10.88 Kattha
      final singlePlotKattha = LandUnitConverter.sqFtToKatta(singlePlotArea);
      expect(singlePlotKattha, equals(10.88));

      // 10.88 * 20 = 217.60 Dhur
      final singlePlotDhur = LandUnitConverter.sqFtToDhur(singlePlotArea);
      expect(singlePlotDhur, equals(217.6));

      // All 10 plots = 12,240 * 10 = 122,400 sq ft (108.80 Kattha, 2,176 Dhur)
      const numberOfPlots = 10;
      final totalPlotsArea = singlePlotArea * numberOfPlots;
      expect(totalPlotsArea, equals(122400.0));
      expect(LandUnitConverter.sqFtToKatta(totalPlotsArea), equals(108.8));
      expect(LandUnitConverter.sqFtToDhur(totalPlotsArea), equals(2176.0));

      // Consistency Check: 10 plots (122,400) + Road (7,200) = Total Land (129,600)
      expect(totalPlotsArea + 7200.0, equals(129600.0));
    });

    test('5, 6 & 7. Plot Sales, Total Revenue (₹4,46,08,000), Final Profit (₹3,28,38,000) & Margin', () {
      const katthaPerPlot = 10.88;

      // Plots 1-5 (5 plots @ ₹2,00,000/Kattha)
      final rateTier1 = 200000.0;
      final pricePerPlotTier1 = katthaPerPlot * rateTier1; // ₹21,76,000
      final revenueTier1 = pricePerPlotTier1 * 5; // ₹1,08,80,000
      expect(pricePerPlotTier1, equals(2176000.0));
      expect(revenueTier1, equals(10880000.0));

      // Plots 6-8 (3 plots @ ₹5,00,000/Kattha)
      final rateTier2 = 500000.0;
      final pricePerPlotTier2 = katthaPerPlot * rateTier2; // ₹54,40,000
      final revenueTier2 = pricePerPlotTier2 * 3; // ₹1,63,20,000
      expect(pricePerPlotTier2, equals(5440000.0));
      expect(revenueTier2, equals(16320000.0));

      // Plots 9-10 (2 plots @ ₹8,00,000/Kattha)
      final rateTier3 = 800000.0;
      final pricePerPlotTier3 = katthaPerPlot * rateTier3; // ₹87,04,000
      final revenueTier3 = pricePerPlotTier3 * 2; // ₹1,74,08,000
      expect(pricePerPlotTier3, equals(8704000.0));
      expect(revenueTier3, equals(17408000.0));

      // Total Sales Revenue = 1,08,80,000 + 1,63,20,000 + 1,74,08,000 = ₹4,46,08,000
      final totalSalesRevenue = revenueTier1 + revenueTier2 + revenueTier3;
      expect(totalSalesRevenue, equals(44608000.0));

      // Actual Project Cost = ₹1,17,70,000
      const actualProjectCost = 11770000.0;

      // Final Project Profit = 4,46,08,000 - 1,17,70,000 = ₹3,28,38,000
      final finalProfit = totalSalesRevenue - actualProjectCost;
      expect(finalProfit, equals(32838000.0));

      final profitMargin = (finalProfit / actualProjectCost) * 100.0;
      expect(profitMargin, closeTo(279.0, 0.05));
    });

    test('8. Multi-Plot to Single Buyer & 1 Plot to 1 Buyer Relationship', () async {
      final project = await projectsRepo.createProject(
        name: 'Township Phase 1',
        location: 'Highway',
        landAreaSqFt: 129600.0,
        purchasePrice: 11520000.0,
        userId: 'admin_user',
      );

      // Create 3 plots
      final p1 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot 1',
        areaSqFt: 12240,
        expectedPrice: 2176000,
        userId: 'admin_user',
      );
      final p2 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot 2',
        areaSqFt: 12240,
        expectedPrice: 2176000,
        userId: 'admin_user',
      );
      final p3 = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot 3',
        areaSqFt: 12240,
        expectedPrice: 2176000,
        userId: 'admin_user',
      );

      // Buyer A buys Plot 1 & Plot 2 (1 Buyer -> Multiple Plots)
      final buyerA = await salesRepo.createBuyer(
        name: 'Buyer A',
        phone: '+919876543210',
        userId: 'admin_user',
      );

      final saleA = await salesRepo.createSaleAgreement(
        projectId: project.id,
        buyerId: buyerA.id,
        saleType: SaleType.plotWise,
        agreedPrice: 4352000.0, // 21,76,000 * 2
        saleDate: DateTime.now(),
        plotIds: [p1.id, p2.id],
        userId: 'admin_user',
      );
      expect(saleA.agreedPrice, equals(4352000.0));

      // Buyer B buys Plot 3 (1 Buyer -> 1 Plot)
      final buyerB = await salesRepo.createBuyer(
        name: 'Buyer B',
        phone: '+919876543211',
        userId: 'admin_user',
      );

      final saleB = await salesRepo.createSaleAgreement(
        projectId: project.id,
        buyerId: buyerB.id,
        saleType: SaleType.plotWise,
        agreedPrice: 2176000.0,
        saleDate: DateTime.now(),
        plotIds: [p3.id],
        userId: 'admin_user',
      );
      expect(saleB.agreedPrice, equals(2176000.0));

      // Verify plots are booked
      final plots = await (db.select(db.plots)..where((tbl) => tbl.projectId.equals(project.id))).get();
      for (final p in plots) {
        expect(p.status, equals(PlotStatus.saleAgreement.name));
      }
    });

    test('10, 11 & 12. Investor Capital Share, Profit Distribution & Total Returns', () async {
      final project = await projectsRepo.createProject(
        name: 'Township Project',
        location: 'Highway',
        landAreaSqFt: 129600.0,
        purchasePrice: 11520000.0,
        userId: 'admin_user',
      );

      // Create 3 Investors
      final inv1 = await investorsRepo.createInvestor(name: 'Investor 1', phone: '+919000000001', userId: 'admin');
      final inv2 = await investorsRepo.createInvestor(name: 'Investor 2', phone: '+919000000002', userId: 'admin');
      final inv3 = await investorsRepo.createInvestor(name: 'Investor 3', phone: '+919000000003', userId: 'admin');

      // Add Capital: Inv1: ₹5L, Inv2: ₹10L, Inv3: ₹20L => Total ₹35L
      await investorsRepo.addProjectInvestment(
        projectId: project.id,
        investorId: inv1.id,
        investedAmount: 500000.0,
        userId: 'admin',
      );
      await investorsRepo.addProjectInvestment(
        projectId: project.id,
        investorId: inv2.id,
        investedAmount: 1000000.0,
        userId: 'admin',
      );
      await investorsRepo.addProjectInvestment(
        projectId: project.id,
        investorId: inv3.id,
        investedAmount: 2000000.0,
        userId: 'admin',
      );

      // Check Ownership %: 5/35 = 14.2857%, 10/35 = 28.5714%, 20/35 = 57.1429%
      final allocs = await investorsRepo.getProjectInvestors(project.id);
      final alloc1 = allocs.firstWhere((a) => a.investorId == inv1.id);
      final alloc2 = allocs.firstWhere((a) => a.investorId == inv2.id);
      final alloc3 = allocs.firstWhere((a) => a.investorId == inv3.id);

      expect(alloc1.ownershipPercent, equals(14.29)); // rounded to 2 decimals in engine
      expect(alloc2.ownershipPercent, equals(28.57));
      expect(alloc3.ownershipPercent, equals(57.14));

      // Total Distributable Project Profit = ₹3,28,38,000
      const totalProjectProfit = 32838000.0;

      // Exact mathematical profit shares:
      final profitShare1 = (5.0 / 35.0) * totalProjectProfit; // ₹46,91,142.86
      final profitShare2 = (10.0 / 35.0) * totalProjectProfit; // ₹93,82,285.71
      final profitShare3 = (20.0 / 35.0) * totalProjectProfit; // ₹1,87,64,571.43

      expect(profitShare1.round(), equals(4691143));
      expect(profitShare2.round(), equals(9382286));
      expect(profitShare3.round(), equals(18764571));
      expect((profitShare1 + profitShare2 + profitShare3).round(), equals(32838000));

      // Return to Investors = Original Capital + Profit Share
      final totalReturn1 = 500000.0 + profitShare1;
      final totalReturn2 = 1000000.0 + profitShare2;
      final totalReturn3 = 2000000.0 + profitShare3;

      expect(totalReturn1.round(), equals(5191143));
      expect(totalReturn2.round(), equals(10382286));
      expect(totalReturn3.round(), equals(20764571));
    });

    test('13 & 14. Realized Profit Before Closure & Remaining Unsold Inventory', () {
      // Plots 1-5: ₹1,08,80,000 + Plots 6-8: ₹1,63,20,000 = ₹2,72,00,000
      const currentRealizedSales = 10880000.0 + 16320000.0;
      expect(currentRealizedSales, equals(27200000.0));

      // Actual Cost = ₹1,17,70,000
      const actualProjectCost = 11770000.0;

      // Current Realized Profit = 2,72,00,000 - 1,17,70,000 = ₹1,54,30,000
      final currentProfit = currentRealizedSales - actualProjectCost;
      expect(currentProfit, equals(15430000.0));

      // Remaining Inventory: Plots 9 & 10 (Each 10.88 Kattha @ ₹8,00,000 = ₹87,04,000)
      const plot9Value = 10.88 * 800000.0; // ₹87,04,000
      const plot10Value = 10.88 * 800000.0; // ₹87,04,000
      const remainingInventoryValue = plot9Value + plot10Value; // ₹1,74,08,000
      expect(remainingInventoryValue, equals(17408000.0));

      // Potential Total Revenue = 2,72,00,000 + 1,74,08,000 = ₹4,46,08,000
      expect(currentRealizedSales + remainingInventoryValue, equals(44608000.0));
    });
  });
}
