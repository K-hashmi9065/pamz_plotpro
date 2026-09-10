import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audit_log/presentation/audit_log_screen.dart';
import '../../buyers_sales/presentation/sales_providers.dart';
import '../../expenses/presentation/expenses_providers.dart';
import '../../installments_payments/presentation/installments_providers.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/profit_loss_repository.dart';
import '../domain/profit_loss_models.dart';

final profitLossRepositoryProvider = Provider<ProfitLossRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProfitLossRepository(db);
});

final projectProfitLossStreamProvider =
    StreamProvider<List<ProjectProfitLossModel>>((ref) {
  final sales = ref.watch(salesListStreamProvider).value ?? [];
  final txs = ref.watch(transactionsListStreamProvider).value ?? [];
  final expenses = ref.watch(expensesListStreamProvider).value ?? [];
  final projects = ref.watch(projectsListStreamProvider).value ?? [];

  final results = <ProjectProfitLossModel>[];
  for (final project in projects) {
    final projectSales = sales.where((s) => s.projectId == project.id).toList();
    double totalAgreedSales = 0.0;
    double directSaleExpenses = 0.0;
    for (final s in projectSales) {
      totalAgreedSales += s.agreedPrice;
      directSaleExpenses += s.saleExpenses;
    }

    final projectTxs = txs.where((t) => t.projectId == project.id && !t.isVoided).toList();
    final cashCollected = projectTxs.fold(0.0, (sum, t) => sum + t.amount);

    final projectExpenses = expenses.where((e) => e.projectId == project.id).toList();
    final totalCapitalized = projectExpenses
        .where((e) => e.isCapitalized)
        .fold(0.0, (sum, e) => sum + e.amount);
    final dynamicActualCost = project.purchasePrice + totalCapitalized;

    results.add(
      ProjectProfitLossModel(
        projectId: project.id,
        projectName: project.name,
        totalAgreedSales: totalAgreedSales,
        directSaleExpenses: directSaleExpenses,
        actualProjectCost: dynamicActualCost,
        cashCollected: cashCollected,
      ),
    );
  }

  return Stream.value(results);
});

final investorPayoutsStreamProvider =
    StreamProvider.family<List<InvestorPayoutModel>, ({String projectId, double profitPool})>(
        (ref, arg) {
  ref.watch(auditLogsStreamProvider);
  final repo = ref.watch(profitLossRepositoryProvider);
  return repo.watchInvestorPayoutsForProject(arg.projectId, arg.profitPool);
});
