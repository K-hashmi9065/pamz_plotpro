import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/projects_repository.dart';
import '../domain/project_model.dart';

export '../../../core/database/database_provider.dart';
import '../../../core/database/database_provider.dart';

/// ProjectsRepository provider
final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProjectsRepository(db);
});

/// Reactive stream provider for all projects
final projectsListStreamProvider = StreamProvider<List<ProjectModel>>((ref) {
  final repo = ref.watch(projectsRepositoryProvider);
  return repo.watchAllProjects();
});

/// Single project by ID stream provider
final projectDetailStreamProvider =
    StreamProvider.family<ProjectModel?, String>((ref, id) {
  final repo = ref.watch(projectsRepositoryProvider);
  return repo.watchProjectById(id);
});

final projectByIdProvider = projectDetailStreamProvider;
