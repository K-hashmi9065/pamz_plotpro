import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/landowners/data/landowners_repository.dart';
import 'package:land_investment_and_sales_management/features/investors/data/investors_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late LandownersRepository landownersRepo;
  late InvestorsRepository investorsRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    landownersRepo = LandownersRepository(db);
    investorsRepo = InvestorsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Core Business Relationship & Project Root Integration Tests', () {
    test('TEST 1 — Create Landowner First', () async {
      final landowner = await landownersRepo.createLandowner(
        name: 'Rajesh Kumar',
        phone: '+91 9876543210',
        email: 'rajesh@example.com',
        address: 'Civil Lines, Nagpur',
        userId: 'admin_user',
      );

      final landowners = await db.select(db.landowners).get();
      expect(landowners.length, equals(1));
      expect(landowners.first.name, equals('Rajesh Kumar'));
      expect(landowners.first.id, equals(landowner.id));
    });

    test('TEST 2 — Create Project Using Existing Landowner', () async {
      final landowner = await landownersRepo.createLandowner(
        name: 'Rajesh Kumar',
        phone: '+91 9876543210',
        userId: 'admin_user',
      );

      final projA = await projectsRepo.createProject(
        name: 'Kishanganj Green Valley',
        location: 'Kishanganj Outskirts',
        landownerId: landowner.id,
        landAreaSqFt: 100000,
        purchasePrice: 20000000,
        userId: 'admin_user',
      );

      final fetched = await projectsRepo.getProjectById(projA.id);
      expect(fetched, isNotNull);
      expect(fetched!.landownerId, equals(landowner.id));
      expect(fetched.landownerName, equals('Rajesh Kumar'));
    });

    test('TEST 3 — Create Project With New Landowner Inline', () async {
      final newLandowner = await landownersRepo.createLandowner(
        name: 'Amit Kumar',
        phone: '+91 9876543211',
        userId: 'admin_user',
      );

      final proj = await projectsRepo.createProject(
        name: 'Project B',
        location: 'Highway Sector 5',
        landownerId: newLandowner.id,
        landAreaSqFt: 150000,
        userId: 'admin_user',
      );

      expect(proj.landownerId, equals(newLandowner.id));
      expect(proj.landownerName, equals('Amit Kumar'));
    });

    test('TEST 4 — Same Landowner, Multiple Projects (1:N)', () async {
      final landowner = await landownersRepo.createLandowner(
        name: 'Rajesh Kumar',
        phone: '+91 9876543210',
        userId: 'admin_user',
      );

      final projA = await projectsRepo.createProject(
        name: 'Project A',
        location: 'Location A',
        landownerId: landowner.id,
        landAreaSqFt: 50000,
        userId: 'admin_user',
      );

      final projB = await projectsRepo.createProject(
        name: 'Project B',
        location: 'Location B',
        landownerId: landowner.id,
        landAreaSqFt: 75000,
        userId: 'admin_user',
      );

      expect(projA.landownerId, equals(landowner.id));
      expect(projB.landownerId, equals(landowner.id));
      expect(projA.id, isNot(equals(projB.id)));

      final landownerProjects = await landownersRepo.watchLandownerProjects(landowner.id).first;
      expect(landownerProjects.length, equals(2));
    });

    test('TEST 5 — Investor in One Project', () async {
      final projA = await projectsRepo.createProject(
        name: 'Project Alpha',
        location: 'Sector 1',
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      final invA = await investorsRepo.createInvestor(
        name: 'Investor A',
        phone: '+91 9999900001',
        userId: 'admin_user',
      );

      await investorsRepo.addProjectInvestment(
        projectId: projA.id,
        investorId: invA.id,
        investedAmount: 1000000, // ₹10L
        agreementDocPath: 'agreement_a.pdf',
        userId: 'admin_user',
      );

      final projectInvestors = await db.select(db.projectInvestors).get();
      expect(projectInvestors.length, equals(1));
      expect(projectInvestors.first.investedAmount, equals(1000000));
      expect(projectInvestors.first.ownershipPercent, equals(100.0));
    });

    test('TEST 6 — Same Investor in Multiple Projects (N:M)', () async {
      final proj1 = await projectsRepo.createProject(
        name: 'Project 1',
        location: 'Sector 1',
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      final proj2 = await projectsRepo.createProject(
        name: 'Project 2',
        location: 'Sector 2',
        landAreaSqFt: 200000,
        userId: 'admin_user',
      );

      final invA = await investorsRepo.createInvestor(
        name: 'Amit Kumar',
        phone: '+91 9876543210',
        userId: 'admin_user',
      );

      // Investor A in Project 1 -> ₹10L
      await investorsRepo.addProjectInvestment(
        projectId: proj1.id,
        investorId: invA.id,
        investedAmount: 1000000,
        agreementDocPath: 'agreement_1.pdf',
        userId: 'admin_user',
      );

      // Investor A in Project 2 -> ₹25L
      await investorsRepo.addProjectInvestment(
        projectId: proj2.id,
        investorId: invA.id,
        investedAmount: 2500000,
        agreementDocPath: 'agreement_2.pdf',
        userId: 'admin_user',
      );

      final participations = await investorsRepo.watchInvestorProjects(invA.id).first;
      expect(participations.length, equals(2));

      final p1 = participations.firstWhere((p) => p.projectId == proj1.id);
      final p2 = participations.firstWhere((p) => p.projectId == proj2.id);

      expect(p1.investedAmount, equals(1000000));
      expect(p2.investedAmount, equals(2500000));
    });

    test('TEST 7 — Project Data Isolation (Expenses)', () async {
      final projA = await projectsRepo.createProject(
        name: 'Project A',
        location: 'Loc A',
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      final projB = await projectsRepo.createProject(
        name: 'Project B',
        location: 'Loc B',
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      // Add expense ₹10L to Project A
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          id: 'exp_a',
          projectId: projA.id,
          category: 'DEVELOPMENT',
          amount: 1000000,
          expenseDate: DateTime.now(),
        ),
      );

      // Add expense ₹20L to Project B
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          id: 'exp_b',
          projectId: projB.id,
          category: 'MARKETING',
          amount: 2000000,
          expenseDate: DateTime.now(),
        ),
      );

      final expA = await (db.select(db.expenses)..where((tbl) => tbl.projectId.equals(projA.id))).get();
      final expB = await (db.select(db.expenses)..where((tbl) => tbl.projectId.equals(projB.id))).get();

      expect(expA.length, equals(1));
      expect(expA.first.amount, equals(1000000));

      expect(expB.length, equals(1));
      expect(expB.first.amount, equals(2000000));
    });

    test('TEST 8 — Landowner Payment Isolation', () async {
      final landowner = await landownersRepo.createLandowner(
        name: 'Rajesh Kumar',
        phone: '+91 9876543210',
        userId: 'admin_user',
      );

      final projA = await projectsRepo.createProject(
        name: 'Project A',
        location: 'Loc A',
        landownerId: landowner.id,
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      final projB = await projectsRepo.createProject(
        name: 'Project B',
        location: 'Loc B',
        landownerId: landowner.id,
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      final agreementA = await landownersRepo.createPurchaseAgreement(
        projectId: projA.id,
        landownerId: landowner.id,
        totalPrice: 20000000, // ₹2 Cr
        agreementDate: DateTime.now(),
        installmentCount: 2,
        userId: 'admin_user',
      );

      final agreementB = await landownersRepo.createPurchaseAgreement(
        projectId: projB.id,
        landownerId: landowner.id,
        totalPrice: 30000000, // ₹3 Cr
        agreementDate: DateTime.now(),
        installmentCount: 3,
        userId: 'admin_user',
      );

      expect(agreementA.totalPrice, equals(20000000));
      expect(agreementB.totalPrice, equals(30000000));

      final agsA = await landownersRepo.watchAgreementsForProject(projA.id).first;
      final agsB = await landownersRepo.watchAgreementsForProject(projB.id).first;

      expect(agsA.length, equals(1));
      expect(agsA.first.totalPrice, equals(20000000));

      expect(agsB.length, equals(1));
      expect(agsB.first.totalPrice, equals(30000000));
    });

    test('TEST 9 — Delete / Archive Safety (Prevent Broken Historical Data)', () async {
      final landowner = await landownersRepo.createLandowner(
        name: 'Landowner X',
        phone: '+91 9111122222',
        userId: 'admin_user',
      );

      final proj = await projectsRepo.createProject(
        name: 'Linked Project',
        location: 'Location X',
        landownerId: landowner.id,
        landAreaSqFt: 50000,
        userId: 'admin_user',
      );

      // Attempting to delete linked landowner should throw error
      expect(
        () => landownersRepo.deleteLandowner(landowner.id, userId: 'admin_user'),
        throwsA(isA<StateError>()),
      );

      // Attempting to delete linked project with land area/data should be protected
      await db.into(db.plots).insert(
        PlotsCompanion.insert(
          id: 'plot_1',
          projectId: proj.id,
          plotNumber: 'P-01',
          areaSqFt: 2000,
          status: 'AVAILABLE',
        ),
      );

      expect(
        () => projectsRepo.deleteProject(proj.id, userId: 'admin_user'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
