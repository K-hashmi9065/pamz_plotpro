import '../../features/dashboard/presentation/dashboard_providers.dart';

/// Returns true if [date] falls within the specified [dateRange].
bool isDateInFilterRange(DateTime date, DashboardDateRange dateRange) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  switch (dateRange) {
    case DashboardDateRange.allTime:
      return true;
    case DashboardDateRange.today:
      return !date.isBefore(startOfToday);
    case DashboardDateRange.yesterday:
      final startOfYesterday = DateTime(now.year, now.month, now.day - 1);
      return !date.isBefore(startOfYesterday) && date.isBefore(startOfToday);
    case DashboardDateRange.last7Days:
      return date.isAfter(now.subtract(const Duration(days: 7)));
    case DashboardDateRange.last15Days:
      return date.isAfter(now.subtract(const Duration(days: 15)));
    case DashboardDateRange.last30Days:
      return date.isAfter(now.subtract(const Duration(days: 30)));
  }
}
