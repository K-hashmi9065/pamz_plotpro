import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/utils/calculation_engine.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/plots/data/plots_repository.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/data/sales_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late PlotsRepository plotsRepo;
  late SalesRepository salesRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    plotsRepo = PlotsRepository(db);
    salesRepo = SalesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 7 - Buyers & Sales Integration Tests', () {
    test('Net sale proceeds calculation (PRD §7.3)', () {
      final agreedPrice = 3500000.0; // ₹35,00,000
      final saleExpenses = 50000.0; // ₹50,000

      final netProceeds = CalculationEngine.calculateNetSaleProceeds(
        agreedSalePrice: agreedPrice,
        directSaleExpenses: saleExpenses,
      );

      expect(netProceeds, equals(3450000.0)); // ₹34,50,000
    });

    test('Section 43CA / 50C circle rate warning trigger', () async {
      final project = await projectsRepo.createProject(
        name: 'Sales Compliance Project',
        location: 'Sector 20',
        landAreaSqFt: 50000,
        userId: 'admin_user',
      );

      final buyer = await salesRepo.createBuyer(
        name: 'Vikram Sharma',
        phone: '+91 9876500000',
        userId: 'admin_user',
      );

      // Agreed price ₹35,00,000 is below circle rate ₹40,00,000
      final sale = await salesRepo.createSaleAgreement(
        projectId: project.id,
        buyerId: buyer.id,
        saleType: SaleType.plotWise,
        agreedPrice: 3500000,
        circleRateValue: 4000000,
        saleDate: DateTime.now(),
        userId: 'admin_user',
      );

      expect(sale.isBelowCircleRate, isTrue);
    });

    test('Sale agreement updates linked plot status to SALE_AGREEMENT', () async {
      final project = await projectsRepo.createProject(
        name: 'Plot Sale Linking Project',
        location: 'Sector 21',
        landAreaSqFt: 50000,
        userId: 'admin_user',
      );

      final plot = await plotsRepo.createPlot(
        projectId: project.id,
        plotNumber: 'Plot #50',
        areaSqFt: 1500,
        userId: 'admin_user',
      );

      final buyer = await salesRepo.createBuyer(
        name: 'Anil Gupta',
        phone: '+91 9876511111',
        userId: 'admin_user',
      );

      await salesRepo.createSaleAgreement(
        projectId: project.id,
        buyerId: buyer.id,
        saleType: SaleType.plotWise,
        agreedPrice: 3000000,
        saleDate: DateTime.now(),
        plotIds: [plot.id],
        userId: 'admin_user',
      );

      final updatedPlot = await (db.select(db.plots)..where((tbl) => tbl.id.equals(plot.id))).getSingle();
      expect(updatedPlot.status, equals(PlotStatus.saleAgreement.name));
    });
  });
}
