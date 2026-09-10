import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/investors_repository.dart';
import '../domain/investor_model.dart';
import '../domain/project_investor_model.dart';

final investorsRepositoryProvider = Provider<InvestorsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = InvestorsRepository(db);
  repo.recalculateAllCapitalBasedOwnership();
  return repo;
});

final investorsListStreamProvider = StreamProvider<List<InvestorModel>>((ref) {
  final repo = ref.watch(investorsRepositoryProvider);
  return repo.watchAllInvestors();
});

final projectInvestorsStreamProvider =
    StreamProvider.family<List<ProjectInvestorModel>, String>((ref, projectId) {
  final repo = ref.watch(investorsRepositoryProvider);
  return repo.watchProjectInvestors(projectId);
});

final investorProjectsStreamProvider =
    StreamProvider.family<List<ProjectInvestorModel>, String>((ref, investorId) {
  final repo = ref.watch(investorsRepositoryProvider);
  return repo.watchInvestorProjects(investorId);
});

final allProjectInvestorsStreamProvider =
    StreamProvider<List<ProjectInvestorModel>>((ref) {
  final repo = ref.watch(investorsRepositoryProvider);
  return repo.watchAllProjectInvestors();
});

final investorFinancialSummaryFutureProvider =
    FutureProvider.family<InvestorFinancialSummary, String>((ref, investorId) {
  final repo = ref.watch(investorsRepositoryProvider);
  return repo.getInvestorFinancialSummary(investorId);
});
