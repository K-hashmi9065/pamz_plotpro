import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/receivables_payables_repository.dart';
import '../domain/receivable_payable_models.dart';

final receivablesPayablesRepositoryProvider =
    Provider<ReceivablesPayablesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReceivablesPayablesRepository(db);
});

final buyerReceivablesStreamProvider =
    StreamProvider<List<BuyerReceivableModel>>((ref) {
  final repo = ref.watch(receivablesPayablesRepositoryProvider);
  return repo.watchBuyerReceivables();
});

final landownerPayablesStreamProvider =
    StreamProvider<List<LandownerPayableModel>>((ref) {
  final repo = ref.watch(receivablesPayablesRepositoryProvider);
  return repo.watchLandownerPayables();
});

final projectCashFlowStreamProvider =
    StreamProvider<List<ProjectCashFlowModel>>((ref) {
  final repo = ref.watch(receivablesPayablesRepositoryProvider);
  return repo.watchProjectCashFlows();
});
