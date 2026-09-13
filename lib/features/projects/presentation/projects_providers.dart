import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../data/projects_repository.dart';
import '../domain/project_model.dart';

/// AppDatabase singleton provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

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
