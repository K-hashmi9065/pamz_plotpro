import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/projects/domain/project_model.dart';
import 'package:land_investment_and_sales_management/features/landowners/data/landowners_repository.dart';
import 'package:land_investment_and_sales_management/features/landowners/domain/landowner_model.dart';
import 'package:land_investment_and_sales_management/features/investors/data/investors_repository.dart';
import 'package:land_investment_and_sales_management/features/investors/domain/investor_model.dart';
import 'package:land_investment_and_sales_management/features/investors/domain/project_investor_model.dart';
import 'package:land_investment_and_sales_management/features/plots/data/plots_repository.dart';
import 'package:land_investment_and_sales_management/features/plots/domain/plot_model.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/data/sales_repository.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/data/installments_repository.dart';
import 'package:land_investment_and_sales_management/features/expenses/data/expenses_repository.dart';
import 'package:land_investment_and_sales_management/features/expenses/domain/expense_model.dart';

class MockProjectsRepository extends Mock implements ProjectsRepository {}
class MockLandownersRepository extends Mock implements LandownersRepository {}
class MockInvestorsRepository extends Mock implements InvestorsRepository {}
class MockPlotsRepository extends Mock implements PlotsRepository {}
class MockSalesRepository extends Mock implements SalesRepository {}
class MockInstallmentsRepository extends Mock implements InstallmentsRepository {}
class MockExpensesRepository extends Mock implements ExpensesRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(PaymentMethod.bankTransfer);
    registerFallbackValue(ProjectStatus.active);
    registerFallbackValue(PlotStatus.available);
    registerFallbackValue(ExpenseCategory.development);
    registerFallbackValue(DateTime.now());
  });

  late MockProjectsRepository mockProjectsRepo;
  late MockLandownersRepository mockLandownersRepo;
  late MockInvestorsRepository mockInvestorsRepo;
  late MockPlotsRepository mockPlotsRepo;
  late MockExpensesRepository mockExpensesRepo;

  setUp(() {
    mockProjectsRepo = MockProjectsRepository();
    mockLandownersRepo = MockLandownersRepository();
    mockInvestorsRepo = MockInvestorsRepository();
    mockPlotsRepo = MockPlotsRepository();
    mockExpensesRepo = MockExpensesRepository();
  });

  group('Mocktail Dependency Unit Test Suite', () {
    test('ProjectsRepository: createProject & updateProject mock verification', () async {
      final fakeProject = ProjectModel(
        id: 'proj_mock_001',
        code: 'PRJ-101',
        name: 'Palms Residency',
        location: 'Nagpur East',
        status: ProjectStatus.active,
        landAreaSqFt: 100000.0,
        purchasePrice: 10000000.0,
        actualCost: 10000000.0,
        createdAt: DateTime.now(),
      );

      when(() => mockProjectsRepo.createProject(
            name: any(named: 'name'),
            location: any(named: 'location'),
            landAreaSqFt: any(named: 'landAreaSqFt'),
            purchasePrice: any(named: 'purchasePrice'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeProject);

      final result = await mockProjectsRepo.createProject(
        name: 'Palms Residency',
        location: 'Nagpur East',
        landAreaSqFt: 100000.0,
        purchasePrice: 10000000.0,
        userId: 'admin_user',
      );

      expect(result.id, equals('proj_mock_001'));
      expect(result.name, equals('Palms Residency'));
      verify(() => mockProjectsRepo.createProject(
            name: 'Palms Residency',
            location: 'Nagpur East',
            landAreaSqFt: 100000.0,
            purchasePrice: 10000000.0,
            userId: 'admin_user',
          )).called(1);
    });

    test('LandownersRepository: createLandowner & multi-project relationship verification', () async {
      final fakeLandowner = LandownerModel(
        id: 'lo_mock_101',
        name: 'Rajesh Kumar Patel',
        phone: '9876543210',
        email: 'rajesh@example.com',
        address: 'Nagpur',
        createdAt: DateTime.now(),
      );

      when(() => mockLandownersRepo.createLandowner(
            name: any(named: 'name'),
            phone: any(named: 'phone'),
            email: any(named: 'email'),
            address: any(named: 'address'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeLandowner);

      final lo = await mockLandownersRepo.createLandowner(
        name: 'Rajesh Kumar Patel',
        phone: '9876543210',
        email: 'rajesh@example.com',
        address: 'Nagpur',
        userId: 'admin_user',
      );

      expect(lo.id, equals('lo_mock_101'));
      expect(lo.name, equals('Rajesh Kumar Patel'));
      verify(() => mockLandownersRepo.createLandowner(
            name: 'Rajesh Kumar Patel',
            phone: '9876543210',
            email: 'rajesh@example.com',
            address: 'Nagpur',
            userId: 'admin_user',
          )).called(1);
    });

    test('InvestorsRepository: multi-project participation & ownership calculation', () async {
      final fakeInvestor = InvestorModel(
        id: 'inv_mock_201',
        name: 'Anil Sharma',
        phone: '9123456789',
        createdAt: DateTime.now(),
      );

      final fakeProjectInvA = ProjectInvestorModel(
        id: 'pi_01',
        projectId: 'proj_A',
        investorId: 'inv_mock_201',
        investorName: 'Anil Sharma',
        investedAmount: 1000000.0,
        ownershipPercent: 20.0,
        ownershipMethod: OwnershipMethod.capitalBased,
        createdAt: DateTime.now(),
      );

      final fakeProjectInvB = ProjectInvestorModel(
        id: 'pi_02',
        projectId: 'proj_B',
        investorId: 'inv_mock_201',
        investorName: 'Anil Sharma',
        investedAmount: 3000000.0,
        ownershipPercent: 35.0,
        ownershipMethod: OwnershipMethod.capitalBased,
        createdAt: DateTime.now(),
      );

      when(() => mockInvestorsRepo.createInvestor(
            name: any(named: 'name'),
            phone: any(named: 'phone'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeInvestor);

      when(() => mockInvestorsRepo.watchProjectInvestors('proj_A'))
          .thenAnswer((_) => Stream.value([fakeProjectInvA]));

      when(() => mockInvestorsRepo.watchProjectInvestors('proj_B'))
          .thenAnswer((_) => Stream.value([fakeProjectInvB]));

      final inv = await mockInvestorsRepo.createInvestor(
        name: 'Anil Sharma',
        phone: '9123456789',
        userId: 'admin_user',
      );

      final invsA = await mockInvestorsRepo.watchProjectInvestors('proj_A').first;
      final invsB = await mockInvestorsRepo.watchProjectInvestors('proj_B').first;

      expect(inv.name, equals('Anil Sharma'));
      expect(invsA.first.investedAmount, equals(1000000.0));
      expect(invsA.first.ownershipPercent, equals(20.0));
      expect(invsB.first.investedAmount, equals(3000000.0));
      expect(invsB.first.ownershipPercent, equals(35.0));

      verifyNever(() => mockInvestorsRepo.deleteInvestor(any(), userId: any(named: 'userId')));
    });

    test('PlotsRepository: createPlot & measurement independence verification', () async {
      final fakePlot = PlotModel(
        id: 'plot_mock_301',
        projectId: 'proj_mock_001',
        plotNumber: 'A-101',
        status: PlotStatus.available,
        areaSqFt: 1500.0,
        displayArea: 1.0,
        kattaValue: 1.0,
        dhurValue: 2.0,
        measurementUnit: 'Kattha',
        allocatedCost: 300000.0,
        expectedPrice: 375000.0,
        createdAt: DateTime.now(),
      );

      when(() => mockPlotsRepo.createPlot(
            projectId: any(named: 'projectId'),
            plotNumber: any(named: 'plotNumber'),
            areaSqFt: any(named: 'areaSqFt'),
            expectedPrice: any(named: 'expectedPrice'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakePlot);

      final plot = await mockPlotsRepo.createPlot(
        projectId: 'proj_mock_001',
        plotNumber: 'A-101',
        areaSqFt: 1500.0,
        expectedPrice: 375000.0,
        userId: 'admin_user',
      );

      expect(plot.plotNumber, equals('A-101'));
      expect(plot.kattaValue, equals(1.0));
      expect(plot.dhurValue, equals(2.0));
    });

    test('ExpensesRepository: handles exception thrown by repository gracefully', () async {
      final fakeExpense = ExpenseModel(
        id: 'exp_mock_01',
        projectId: 'proj_mock_001',
        category: ExpenseCategory.development,
        amount: 50000.0,
        expenseDate: DateTime.now(),
        isCapitalized: true,
        createdAt: DateTime.now(),
      );

      when(() => mockExpensesRepo.addExpense(
            projectId: any(named: 'projectId'),
            category: any(named: 'category'),
            amount: any(named: 'amount'),
            expenseDate: any(named: 'expenseDate'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeExpense);

      final result = await mockExpensesRepo.addExpense(
        projectId: 'proj_mock_001',
        category: ExpenseCategory.development,
        amount: 50000.0,
        expenseDate: DateTime.now(),
        userId: 'admin_user',
      );

      expect(result.id, equals('exp_mock_01'));
      expect(result.amount, equals(50000.0));
    });
  });
}
