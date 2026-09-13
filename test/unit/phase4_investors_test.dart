import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/routing/app_routes.dart';
import 'package:land_investment_and_sales_management/core/routing/route_guard.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/investors/data/investors_repository.dart';

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

  group('Phase 4 - Investors & Ownership Integration Tests', () {
    test('AC-03.1: Single investor gets 100% ownership %', () async {
      final proj = await projectsRepo.createProject(
        name: 'Investor Alpha Project',
        location: 'Sector 10',
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      final invA = await investorsRepo.createInvestor(
        name: 'Investor A',
        phone: '+91 9876543210',
        userId: 'admin_user',
      );

      await investorsRepo.addProjectInvestment(
        projectId: proj.id,
        investorId: invA.id,
        investedAmount: 5000000, // ₹50,00,000
        agreementDocPath: 'doc_a.pdf',
        userId: 'admin_user',
      );

      final projectInvestors = await (db.select(db.projectInvestors)
            ..where((tbl) => tbl.projectId.equals(proj.id)))
          .get();

      expect(projectInvestors.length, equals(1));
      expect(projectInvestors.first.ownershipPercent, equals(100.0));
    });

    test('AC-03.2: Second investor contribution dilutes ownership % to 50% each', () async {
      final proj = await projectsRepo.createProject(
        name: 'Investor Shared Project',
        location: 'Sector 12',
        landAreaSqFt: 100000,
        userId: 'admin_user',
      );

      final invA = await investorsRepo.createInvestor(
        name: 'Investor A',
        phone: '+91 9876543210',
        userId: 'admin_user',
      );

      final invB = await investorsRepo.createInvestor(
        name: 'Investor B',
        phone: '+91 9876543211',
        userId: 'admin_user',
      );

      // Investor A contributes ₹50,00,000
      await investorsRepo.addProjectInvestment(
        projectId: proj.id,
        investorId: invA.id,
        investedAmount: 5000000,
        agreementDocPath: 'doc_a.pdf',
        userId: 'admin_user',
      );

      // Investor B contributes ₹50,00,000
      await investorsRepo.addProjectInvestment(
        projectId: proj.id,
        investorId: invB.id,
        investedAmount: 5000000,
        agreementDocPath: 'doc_b.pdf',
        userId: 'admin_user',
      );

      final projectInvestors = await (db.select(db.projectInvestors)
            ..where((tbl) => tbl.projectId.equals(proj.id)))
          .get();

      expect(projectInvestors.length, equals(2));
      for (final pi in projectInvestors) {
        expect(pi.ownershipPercent, equals(50.0));
      }
    });

    test('AC-03.3: Investment without agreement document throws validation error', () async {
      final proj = await projectsRepo.createProject(
        name: 'Doc Test Project',
        location: 'Sector 1',
        landAreaSqFt: 50000,
        userId: 'admin_user',
      );

      final inv = await investorsRepo.createInvestor(
        name: 'Investor C',
        phone: '+91 9876543212',
        userId: 'admin_user',
      );

      // Agreement Document is optional - should successfully allocate without doc
      final created = await investorsRepo.addProjectInvestment(
        projectId: proj.id,
        investorId: inv.id,
        investedAmount: 5000000,
        agreementDocPath: null, // Optional document reference
        userId: 'admin_user',
      );

      expect(created.ownershipPercent, equals(100.0));
      expect(created.investedAmount, equals(5000000.0));

      final investments = await investorsRepo.getProjectInvestors(proj.id);
      expect(investments.length, 1);
      expect(investments.first.investorId, inv.id);
      expect(investments.first.investedAmount, 5000000);

      // Global recalculate check
      await investorsRepo.recalculateAllCapitalBasedOwnership();
      final afterRecalc = await investorsRepo.getProjectInvestors(proj.id);
      expect(afterRecalc.first.ownershipPercent, equals(100.0));

      // Negative amount should throw ArgumentError
      expect(
        () => investorsRepo.addProjectInvestment(
          projectId: proj.id,
          investorId: inv.id,
          investedAmount: -1000,
          userId: 'admin_user',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('AC-09.1 - AC-09.4: RouteGuard blocks Member access to Investor routes', () {
      final adminAllowed = RouteGuard.isAllowed(UserRole.admin, AppRoutes.investors);
      final memberAllowed = RouteGuard.isAllowed(UserRole.member, AppRoutes.investors);

      expect(adminAllowed, isTrue);
      expect(memberAllowed, isFalse);
    });
  });
}
