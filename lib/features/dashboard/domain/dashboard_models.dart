class PortfolioSummaryModel {
  final int totalProjects;
  final double totalLandAreaSqFt;
  final double? _soldLandAreaSqFt;
  final double? _remainingLandAreaSqFt;
  final double totalCapitalInvested;
  final double totalAgreedSales;
  final double totalCashCollected;
  final double totalOutflows;
  final double netCashFlow;
  final double totalReceivables;
  final double totalPayables;
  final int totalAvailablePlots;
  final int? _totalBookedPlots;
  final int totalSoldPlots;

  const PortfolioSummaryModel({
    required this.totalProjects,
    required this.totalLandAreaSqFt,
    double? soldLandAreaSqFt,
    double? remainingLandAreaSqFt,
    required this.totalCapitalInvested,
    required this.totalAgreedSales,
    required this.totalCashCollected,
    required this.totalOutflows,
    required this.netCashFlow,
    required this.totalReceivables,
    required this.totalPayables,
    required this.totalAvailablePlots,
    int? totalBookedPlots,
    required this.totalSoldPlots,
  })  : _soldLandAreaSqFt = soldLandAreaSqFt,
        _remainingLandAreaSqFt = remainingLandAreaSqFt,
        _totalBookedPlots = totalBookedPlots;

  double get soldLandAreaSqFt => _soldLandAreaSqFt ?? 0.0;
  double get remainingLandAreaSqFt => _remainingLandAreaSqFt ?? 0.0;
  int get totalBookedPlots => _totalBookedPlots ?? 0;

  int get totalPlotsCount => (totalAvailablePlots) + totalBookedPlots + (totalSoldPlots);
}
