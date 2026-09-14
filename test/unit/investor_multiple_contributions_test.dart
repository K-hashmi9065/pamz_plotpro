import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/investors/data/investors_repository.dart';
import 'package:land_investment_and_sales_management/features/investors/domain/project_investor_model.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late InvestorsRepository investorsRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    investorsRepo = InvestorsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Same-Investor Multiple Capital Contributions & Aggregation Tests', () {
    test('AggregatedProjectInvestorModel.aggregateList aggregates multiple contributions for same investor', () {
      final contributions = [
        ProjectInvestorModel(
          id: 'pi-1',
          projectId: 'prj-101',
          investorId: 'inv-farhan',
          investorName: 'Farhan',
          investedAmount: 50000.0,
          ownershipPercent: 20.83,
          ownershipMethod: OwnershipMethod.capitalBased,
          createdAt: DateTime(2026, 1, 1),
        ),
        ProjectInvestorModel(
          id: 'pi-2',
          projectId: 'prj-101',
          investorId: 'inv-imran',
          investorName: 'Imran',
          investedAmount: 100000.0,
          ownershipPercent: 41.67,
          ownershipMethod: OwnershipMethod.capitalBased,
          createdAt: DateTime(2026, 1, 2),
        ),
        ProjectInvestorModel(
          id: 'pi-3',
          projectId: 'prj-101',
          investorId: 'inv-gufran',
          investorName: 'Gufran',
          investedAmount: 40000.0,
          ownershipPercent: 16.67,
          ownershipMethod: OwnershipMethod.capitalBased,
          createdAt: DateTime(2026, 1, 3),
        ),
        ProjectInvestorModel(
          id: 'pi-4',
          projectId: 'prj-101',
          investorId: 'inv-farhan',
          investorName: 'Farhan',
          investedAmount: 50000.0,
          ownershipPercent: 20.83,
          ownershipMethod: OwnershipMethod.capitalBased,
          createdAt: DateTime(2026, 1, 4),
        ),
      ];

      final aggregated = AggregatedProjectInvestorModel.aggregateList(contributions);

      // Should have 3 unique investors (Farhan, Imran, Gufran)
      expect(aggregated.length, equals(3));

      final farhan = aggregated.firstWhere((a) => a.investorId == 'inv-farhan');
      expect(farhan.totalInvestedAmount, equals(100000.0));
      expect(farhan.totalOwnershipPercent, closeTo(41.66, 0.01));
      expect(farhan.contributions.length, equals(2));

      final imran = aggregated.firstWhere((a) => a.investorId == 'inv-imran');
      expect(imran.totalInvestedAmount, equals(100000.0));
      expect(imran.totalOwnershipPercent, closeTo(41.67, 0.01));
      expect(imran.contributions.length, equals(1));

      final gufran = aggregated.firstWhere((a) => a.investorId == 'inv-gufran');
      expect(gufran.totalInvestedAmount, equals(40000.0));
      expect(gufran.totalOwnershipPercent, closeTo(16.67, 0.01));
      expect(gufran.contributions.length, equals(1));
    });

    test('Adding multiple investments for same investor in database updates total capital and recalculates ownership', () async {
      final proj = await projectsRepo.createProject(
        name: 'PAMZ Project',
        location: 'KNE',
        landAreaSqFt: 129600,
        userId: 'admin_user',
      );

      final inv = await investorsRepo.createInvestor(
        name: 'Farhan',
        phone: '+91 9876543210',
        userId: 'admin_user',
      );

      // First contribution: ₹50,000
      await investorsRepo.addProjectInvestment(
        projectId: proj.id,
        investorId: inv.id,
        investedAmount: 50000,
        userId: 'admin_user',
      );

      var list = await investorsRepo.getProjectInvestors(proj.id);
      expect(list.length, equals(1));
      expect(list.first.ownershipPercent, equals(100.0));

      // Second contribution by same investor: ₹50,000
      await investorsRepo.addProjectInvestment(
        projectId: proj.id,
        investorId: inv.id,
        investedAmount: 50000,
        userId: 'admin_user',
      );

      list = await investorsRepo.getProjectInvestors(proj.id);
      expect(list.length, equals(2));

      final aggregated = AggregatedProjectInvestorModel.aggregateList(list);
      expect(aggregated.length, equals(1));
      expect(aggregated.first.totalInvestedAmount, equals(100000.0));
      expect(aggregated.first.totalOwnershipPercent, equals(100.0));
      expect(aggregated.first.contributions.length, equals(2));
    });
  });
}
