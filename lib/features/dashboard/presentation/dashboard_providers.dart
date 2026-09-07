import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../projects/presentation/projects_providers.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_models.dart';

enum DashboardDateRange {
  allTime('All Time'),
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days (Last Week)'),
  last15Days('Last 15 Days'),
  last30Days('Last 30 Days (Last Month)');

  final String label;
  const DashboardDateRange(this.label);
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DashboardRepository(db);
});

final selectedDashboardDateRangeProvider =
    StateProvider<DashboardDateRange>((ref) => DashboardDateRange.allTime);

final portfolioSummaryStreamProvider = StreamProvider<PortfolioSummaryModel>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  final projectId = ref.watch(selectedProjectFilterProvider);
  final dateRange = ref.watch(selectedDashboardDateRangeProvider);
  return repo.watchPortfolioSummary(projectId: projectId, dateRange: dateRange);
});
