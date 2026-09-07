import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/features/projects/data/projects_repository.dart';
import 'package:land_investment_and_sales_management/features/expenses/data/expenses_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProjectsRepository projectsRepo;
  late ExpensesRepository expensesRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    projectsRepo = ProjectsRepository(db);
    expensesRepo = ExpensesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 5 - Expenses & Cost Capitalization Integration Tests', () {
    test('AC-04.1: Capitalized expense increases Actual Project Cost', () async {
      // Purchase Price = ₹2,00,00,000
      final project = await projectsRepo.createProject(
        name: 'Expense Capitalization Project',
        location: 'Sector 15',
        landAreaSqFt: 150000,
        purchasePrice: 20000000,
        userId: 'admin_user',
      );

      expect(project.actualCost, equals(20000000));

      // Add DEVELOPMENT expense ₹8,00,000 with isCapitalized = true
      await expensesRepo.addExpense(
        projectId: project.id,
        category: ExpenseCategory.development,
        amount: 800000,
        expenseDate: DateTime.now(),
        isCapitalized: true,
        vendor: 'ABC Builders',
        userId: 'admin_user',
      );

      final updatedProject = await projectsRepo.getProjectById(project.id);
      expect(updatedProject!.actualCost, equals(20800000)); // ₹2,08,00,000
    });

    test('AC-04.2: Period expense (isCapitalized = false) does NOT alter Actual Project Cost', () async {
      final project = await projectsRepo.createProject(
        name: 'Period Expense Project',
        location: 'Sector 16',
        landAreaSqFt: 150000,
        purchasePrice: 20000000,
        userId: 'admin_user',
      );

      // Add DEVELOPMENT expense ₹8,00,000 (Capitalized)
      await expensesRepo.addExpense(
        projectId: project.id,
        category: ExpenseCategory.development,
        amount: 800000,
        expenseDate: DateTime.now(),
        isCapitalized: true,
        userId: 'admin_user',
      );

      // Add MARKETING expense ₹3,00,000 (Period expense / NOT capitalized)
      await expensesRepo.addExpense(
        projectId: project.id,
        category: ExpenseCategory.marketing,
        amount: 300000,
        expenseDate: DateTime.now(),
        isCapitalized: false,
        userId: 'admin_user',
      );

      final updatedProject = await projectsRepo.getProjectById(project.id);
      // Actual Cost remains ₹2,08,00,000 (marketing excluded)
      expect(updatedProject!.actualCost, equals(20800000));
    });

    test('AC-01.2: Adding expense to closed project is blocked', () async {
      final project = await projectsRepo.createProject(
        name: 'Closed Expense Project',
        location: 'Sector 17',
        landAreaSqFt: 50000,
        purchasePrice: 10000000,
        status: ProjectStatus.closed,
        userId: 'admin_user',
      );

      expect(
        () => expensesRepo.addExpense(
          projectId: project.id,
          category: ExpenseCategory.legal,
          amount: 50000,
          expenseDate: DateTime.now(),
          userId: 'admin_user',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
