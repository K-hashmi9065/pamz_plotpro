import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/landowners/data/landowners_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late LandownersRepository landownersRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    landownersRepo = LandownersRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 3 - Projects & Landowners Integration Tests', () {
    test('AC-01.1: Project creation fails without name or land area', () async {
      expect(
        () => projectsRepo.createProject(
          name: '',
          location: 'Nagpur Highway',
          landAreaSqFt: 100000,
          userId: 'admin_user',
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => projectsRepo.createProject(
          name: 'Green Acres',
          location: 'Nagpur Highway',
          landAreaSqFt: 0,
          userId: 'admin_user',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('AC-01.2: Closed project rejects edits', () async {
      final project = await projectsRepo.createProject(
        name: 'Closed Project Alpha',
        location: 'Sector 4',
        landAreaSqFt: 50000,
        status: ProjectStatus.closed,
        userId: 'admin_user',
      );

      final updatedModel = project.copyWith(name: 'Attempted Renaming');

      expect(
        () => projectsRepo.updateProject(updatedModel, userId: 'admin_user'),
        throwsA(isA<StateError>()),
      );
    });

    test('AC-01.3: Project financial boundary isolation', () async {
      final projA = await projectsRepo.createProject(
        name: 'Project A',
        location: 'Location A',
        landAreaSqFt: 100000,
        purchasePrice: 10000000,
        userId: 'admin_user',
      );

      final projB = await projectsRepo.createProject(
        name: 'Project B',
        location: 'Location B',
        landAreaSqFt: 200000,
        purchasePrice: 20000000,
        userId: 'admin_user',
      );

      expect(projA.purchasePrice, equals(10000000));
      expect(projB.purchasePrice, equals(20000000));
      expect(projA.id, isNot(equals(projB.id)));
    });

    test('AC-02.1: Purchase agreement generates expected installment schedule', () async {
      final proj = await projectsRepo.createProject(
        name: 'Project Land Test',
        location: 'City Outskirts',
        landAreaSqFt: 150000,
        userId: 'admin_user',
      );

      final landowner = await landownersRepo.createLandowner(
        name: 'Suraj Verma',
        phone: '+91 9999988888',
        userId: 'admin_user',
      );

      final agreement = await landownersRepo.createPurchaseAgreement(
        projectId: proj.id,
        landownerId: landowner.id,
        totalPrice: 20000000, // ₹2,00,00,000
        agreementDate: DateTime.now(),
        installmentCount: 5,
        userId: 'admin_user',
      );

      expect(agreement.totalPrice, equals(20000000));

      final installments = await (db.select(db.installments)
            ..where((tbl) => tbl.purchaseAgreementId.equals(agreement.id)))
          .get();

      expect(installments.length, equals(5));
      expect(installments.first.dueAmount, equals(4000000)); // ₹40,00,000 per installment
    });

    test('AC-02.3: Cash limit threshold verification (Section 269ST)', () {
      final amountBelowLimit = 150000.0;
      final amountAboveLimit = 250000.0;

      expect(amountBelowLimit >= AppConstants.cashTransactionLimit, isFalse);
      expect(amountAboveLimit >= AppConstants.cashTransactionLimit, isTrue);
    });

    test('Project creation and edit saves length and breadth dimensions to database and prefills correctly', () async {
      final project = await projectsRepo.createProject(
        name: 'Project Dimension Test',
        location: 'Sector 9',
        landAreaSqFt: 1500,
        measurementUnit: 'Dimensions (L × B in Ft & In)',
        lengthFt: 50.0,
        lengthIn: 0.0,
        breadthFt: 30.0,
        breadthIn: 0.0,
        userId: 'admin_user',
      );

      expect(project.lengthFt, equals(50.0));
      expect(project.lengthIn, equals(0.0));
      expect(project.breadthFt, equals(30.0));
      expect(project.breadthIn, equals(0.0));

      final fetchedFromDb = await projectsRepo.getProjectById(project.id);
      expect(fetchedFromDb, isNotNull);
      expect(fetchedFromDb!.lengthFt, equals(50.0));
      expect(fetchedFromDb.lengthIn, equals(0.0));
      expect(fetchedFromDb.breadthFt, equals(30.0));
      expect(fetchedFromDb.breadthIn, equals(0.0));

      // Test editing dimensions
      final updatedProject = fetchedFromDb.copyWith(
        lengthFt: 60.0,
        lengthIn: 6.0,
        breadthFt: 40.0,
        breadthIn: 0.0,
        landAreaSqFt: 2420.0,
      );
      await projectsRepo.updateProject(updatedProject, userId: 'admin_user');

      final refetched = await projectsRepo.getProjectById(project.id);
      expect(refetched, isNotNull);
      expect(refetched!.lengthFt, equals(60.0));
      expect(refetched.lengthIn, equals(6.0));
      expect(refetched.breadthFt, equals(40.0));
      expect(refetched.breadthIn, equals(0.0));
      expect(refetched.landAreaSqFt, equals(2420.0));
    });
  });
}
