import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/expenses_repository.dart';
import '../domain/expense_model.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExpensesRepository(db);
});

final expensesListStreamProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final repo = ref.watch(expensesRepositoryProvider);
  return repo.watchAllExpenses();
});

final projectExpensesStreamProvider =
    StreamProvider.family<List<ExpenseModel>, String>((ref, projectId) {
  final repo = ref.watch(expensesRepositoryProvider);
  return repo.watchExpensesForProject(projectId);
});
