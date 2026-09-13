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
  final installments = ref.watch(installmentsListStreamProvider).value ?? [];
  final expenses = ref.watch(expensesListStreamProvider).value ?? [];
  final projects = ref.watch(projectsListStreamProvider).value ?? [];

  final results = <ProjectProfitLossModel>[];
  for (final project in projects) {
    final projectSales = sales.where((s) => s.projectId == project.id).toList();
    double totalAgreedSales = 0.0;
    double directSaleExpenses = 0.0;
    final projectSaleIds = <String>{};
    for (final s in projectSales) {
      totalAgreedSales += s.agreedPrice;
      directSaleExpenses += s.saleExpenses;
      projectSaleIds.add(s.id);
    }

    // Exclude landowner payment installments
    final paInstIds = installments
        .where((i) => i.purchaseAgreementId != null)
        .map((i) => i.id)
        .toSet();

    final projectSaleInstallments = installments
        .where((i) => i.saleId != null && projectSaleIds.contains(i.saleId))
        .toList();

    // Only collect transactions linked to plot sales (excluding landowner outflows)
    final projectSaleTxs = txs
        .where((t) =>
            t.projectId == project.id &&
            !t.isVoided &&
            (t.installmentId == null || !paInstIds.contains(t.installmentId)))
        .toList();

    double cashCollected =
        projectSaleTxs.fold(0.0, (sum, t) => sum + t.amount);

    // Fallback to plot sales installment paid amounts if direct transactions aren't logged
    if (cashCollected == 0.0 && projectSaleInstallments.isNotEmpty) {
      cashCollected = projectSaleInstallments.fold(
          0.0, (sum, inst) => sum + inst.paidAmount);
    }

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
