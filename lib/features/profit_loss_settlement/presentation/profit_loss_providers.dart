import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/profit_loss_repository.dart';
import '../domain/profit_loss_models.dart';

final profitLossRepositoryProvider = Provider<ProfitLossRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProfitLossRepository(db);
});

final projectProfitLossStreamProvider =
    StreamProvider<List<ProjectProfitLossModel>>((ref) {
  final repo = ref.watch(profitLossRepositoryProvider);
  return repo.watchAllProjectProfitLoss();
});

final investorPayoutsStreamProvider =
    StreamProvider.family<List<InvestorPayoutModel>, ({String projectId, double profitPool})>(
        (ref, arg) {
  final repo = ref.watch(profitLossRepositoryProvider);
  return repo.watchInvestorPayoutsForProject(arg.projectId, arg.profitPool);
});
