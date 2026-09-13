import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../plots/data/plots_repository.dart';
import '../domain/expense_model.dart';

class ExpensesRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ExpensesRepository(this._db);

  ExpenseModel _toModel(Expense row) {
    final categoryEnum = ExpenseCategory.values.firstWhere(
      (c) => c.name == row.category,
      orElse: () => ExpenseCategory.other,
    );

    return ExpenseModel(
      id: row.id,
      projectId: row.projectId,
      category: categoryEnum,
      amount: row.amount,
      expenseDate: row.expenseDate,
      vendor: row.vendor,
      isCapitalized: row.isCapitalized,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }

  /// Watch all expenses stream
  Stream<List<ExpenseModel>> watchAllExpenses() {
    return _db.select(_db.expenses).watch().map(
          (rows) => rows.map(_toModel).toList(),
        );
  }

  /// Watch expenses for a specific project
  Stream<List<ExpenseModel>> watchExpensesForProject(String projectId) {
    final query = _db.select(_db.expenses)..where((tbl) => tbl.projectId.equals(projectId));
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Log a new project expense (AC-04.1 & AC-04.2: Capitalized vs Period expense)
  Future<ExpenseModel> addExpense({
    required String projectId,
    required ExpenseCategory category,
    required double amount,
    required DateTime expenseDate,
    String? vendor,
    bool isCapitalized = true,
    String? notes,
    required String userId,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Expense Amount * must be greater than zero.');
    }

    // Check project status (AC-01.2: Closed project rejects financial edits)
    final project = await (_db.select(_db.projects)..where((tbl) => tbl.id.equals(projectId))).getSingleOrNull();
    if (project != null && project.status == ProjectStatus.closed.name) {
      throw StateError('Project is closed — financial edits are disabled.');
    }

    final id = _uuid.v4();
    await _db.into(_db.expenses).insert(
          ExpensesCompanion(
            id: Value(id),
            projectId: Value(projectId),
            category: Value(category.name),
            amount: Value(amount),
            expenseDate: Value(expenseDate),
            vendor: Value(vendor?.trim()),
            isCapitalized: Value(isCapitalized),
            notes: Value(notes?.trim()),
            createdAt: Value(DateTime.now()),
          ),
        );

    // Recalculate Actual Project Cost if capitalized (AC-04.1 & AC-04.2)
    await syncProjectActualCost(projectId);

    // Write audit log
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('ADD_EXPENSE'),
            entityType: const Value('Expense'),
            entityId: Value(id),
            details: Value('Logged ${category.name.toUpperCase()} expense of ₹$amount (Capitalized: $isCapitalized).'),
            timestamp: Value(DateTime.now()),
          ),
        );

    final row = await (_db.select(_db.expenses)..where((tbl) => tbl.id.equals(id))).getSingle();
    return _toModel(row);
  }

  /// Recalculates and updates Actual Project Cost in SQLite database (PRD §7.1 / AC-04.1 / AC-04.2)
  Future<void> syncProjectActualCost(String projectId) async {
    final project = await (_db.select(_db.projects)..where((tbl) => tbl.id.equals(projectId))).getSingleOrNull();
    if (project == null) return;

    final projectExpenses = await (_db.select(_db.expenses)..where((tbl) => tbl.projectId.equals(projectId))).get();
    
    final capitalizedList = projectExpenses
        .where((e) => e.isCapitalized)
        .map((e) => e.amount)
        .toList();

    final newActualCost = CalculationEngine.calculateActualProjectCost(
      purchasePrice: project.purchasePrice,
      capitalizedExpenses: capitalizedList,
    );

    await (_db.update(_db.projects)..where((tbl) => tbl.id.equals(projectId))).write(
      ProjectsCompanion(
        actualCost: Value(newActualCost),
      ),
    );

    final plotsRepo = PlotsRepository(_db);
    await plotsRepo.recalculateProjectCostAllocation(projectId);
  }
}
