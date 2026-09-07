import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/plots_repository.dart';
import '../domain/plot_model.dart';

final plotsRepositoryProvider = Provider<PlotsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PlotsRepository(db);
});

final plotsListStreamProvider = StreamProvider<List<PlotModel>>((ref) {
  final repo = ref.watch(plotsRepositoryProvider);
  return repo.watchAllPlots();
});

final projectPlotsStreamProvider =
    StreamProvider.family<List<PlotModel>, String>((ref, projectId) {
  final repo = ref.watch(plotsRepositoryProvider);
  return repo.watchPlotsForProject(projectId);
});
