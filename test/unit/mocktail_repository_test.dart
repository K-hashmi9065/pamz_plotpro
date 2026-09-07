import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/projects/domain/project_model.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/data/sales_repository.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/domain/buyer_model.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/data/installments_repository.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/domain/transaction_model.dart';

class MockProjectsRepository extends Mock implements ProjectsRepository {}
class MockSalesRepository extends Mock implements SalesRepository {}
class MockInstallmentsRepository extends Mock implements InstallmentsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(PaymentMethod.bankTransfer);
    registerFallbackValue(DateTime.now());
  });

  late MockProjectsRepository mockProjectsRepo;
  late MockSalesRepository mockSalesRepo;
  late MockInstallmentsRepository mockInstallmentsRepo;

  setUp(() {
    mockProjectsRepo = MockProjectsRepository();
    mockSalesRepo = MockSalesRepository();
    mockInstallmentsRepo = MockInstallmentsRepository();
  });

  group('Mocktail Repository & Business Logic Unit Tests', () {
    test('Mocktail: ProjectsRepository.createProject returns mocked ProjectModel', () async {
      final fakeProject = ProjectModel(
        id: 'proj_mock_123',
        code: 'PRJ-100',
        name: 'Mocktail Palms',
        location: 'Kishanganj East',
        status: ProjectStatus.active,
        landAreaSqFt: 54000.0,
        purchasePrice: 4000000.0,
        actualCost: 4000000.0,
        createdAt: DateTime.now(),
      );

      when(() => mockProjectsRepo.createProject(
            name: any(named: 'name'),
            location: any(named: 'location'),
            landAreaSqFt: any(named: 'landAreaSqFt'),
            purchasePrice: any(named: 'purchasePrice'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeProject);

      final project = await mockProjectsRepo.createProject(
        name: 'Mocktail Palms',
        location: 'Kishanganj East',
        landAreaSqFt: 54000.0,
        purchasePrice: 4000000.0,
        userId: 'admin_user',
      );

      expect(project.id, equals('proj_mock_123'));
      expect(project.name, equals('Mocktail Palms'));
      expect(project.code, equals('PRJ-100'));

      verify(() => mockProjectsRepo.createProject(
            name: 'Mocktail Palms',
            location: 'Kishanganj East',
            landAreaSqFt: 54000.0,
            purchasePrice: 4000000.0,
            userId: 'admin_user',
          )).called(1);
    });

    test('Mocktail: SalesRepository.createBuyer mocks buyer creation', () async {
      final fakeBuyer = BuyerModel(
        id: 'buyer_mock_456',
        name: 'Vikram Sharma',
        phone: '9876543210',
        email: 'vikram@example.com',
        createdAt: DateTime.now(),
      );

      when(() => mockSalesRepo.createBuyer(
            name: any(named: 'name'),
            phone: any(named: 'phone'),
            email: any(named: 'email'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeBuyer);

      final buyer = await mockSalesRepo.createBuyer(
        name: 'Vikram Sharma',
        phone: '9876543210',
        email: 'vikram@example.com',
        userId: 'admin_user',
      );

      expect(buyer.id, equals('buyer_mock_456'));
      expect(buyer.name, equals('Vikram Sharma'));
    });

    test('Mocktail: InstallmentsRepository.recordPayment handles transaction recording', () async {
      final fakeTx = TransactionModel(
        id: 'tx_mock_789',
        projectId: 'proj_mock_123',
        installmentId: 'inst_01',
        amount: 150000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.bankTransfer,
        isVoided: false,
        createdBy: 'admin_user',
        createdAt: DateTime.now(),
      );

      when(() => mockInstallmentsRepo.recordPayment(
            projectId: any(named: 'projectId'),
            installmentId: any(named: 'installmentId'),
            amount: any(named: 'amount'),
            paymentDate: any(named: 'paymentDate'),
            paymentMethod: any(named: 'paymentMethod'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => fakeTx);

      final tx = await mockInstallmentsRepo.recordPayment(
        projectId: 'proj_mock_123',
        installmentId: 'inst_01',
        amount: 150000.0,
        paymentDate: DateTime.now(),
        paymentMethod: PaymentMethod.bankTransfer,
        userId: 'admin_user',
      );

      expect(tx.id, equals('tx_mock_789'));
      expect(tx.amount, equals(150000.0));
      expect(tx.isVoided, isFalse);
    });
  });
}
