import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/domain/project_model.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/landowners_repository.dart';
import '../domain/landowner_model.dart';
import '../domain/purchase_agreement_model.dart';

final landownersRepositoryProvider = Provider<LandownersRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LandownersRepository(db);
});

final landownersListStreamProvider = StreamProvider<List<LandownerModel>>((ref) {
  final repo = ref.watch(landownersRepositoryProvider);
  return repo.watchAllLandowners();
});

final projectAgreementsStreamProvider =
    StreamProvider.family<List<PurchaseAgreementModel>, String>((ref, projectId) {
  final repo = ref.watch(landownersRepositoryProvider);
  return repo.watchAgreementsForProject(projectId);
});

final landownerProjectsStreamProvider =
    StreamProvider.family<List<ProjectModel>, String>((ref, landownerId) {
  final repo = ref.watch(landownersRepositoryProvider);
  return repo.watchLandownerProjects(landownerId);
});

final allPurchaseAgreementsStreamProvider =
    StreamProvider<List<PurchaseAgreementModel>>((ref) {
  final repo = ref.watch(landownersRepositoryProvider);
  return repo.watchAllPurchaseAgreements();
});
