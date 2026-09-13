import '../../../core/database/app_database.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../domain/dashboard_models.dart';
import '../presentation/dashboard_providers.dart';

class DashboardRepository {
  final AppDatabase _db;

  DashboardRepository(this._db);

  /// Watch consolidated executive dashboard portfolio metrics with project and date range filtering
  Stream<PortfolioSummaryModel> watchPortfolioSummary({
    String? projectId,
    DashboardDateRange dateRange = DashboardDateRange.allTime,
  }) {
    return _db.select(_db.projects).watch().asyncMap((allProjects) async {
      final filteredProjects = projectId == null || projectId.isEmpty
          ? allProjects
          : allProjects.where((p) => p.id == projectId).toList();

      final totalProjects = filteredProjects.length;
      double totalLandAreaSqFt = 0.0;
      for (final p in filteredProjects) {
        totalLandAreaSqFt += p.landAreaSqFt;
      }

      final projectIds = filteredProjects.map((p) => p.id).toSet();

      // Total Capital Invested
      final allInvestments = await _db.select(_db.projectInvestors).get();
      double totalCapitalInvested = 0.0;
      for (final inv in allInvestments) {
        if (projectIds.contains(inv.projectId)) {
          if (isDateInFilterRange(inv.createdAt, dateRange)) {
            totalCapitalInvested += inv.investedAmount;
          }
        }
      }

      // Sales & Net proceeds
      final allSales = await _db.select(_db.sales).get();
      double totalAgreedSales = 0.0;
      for (final s in allSales) {
        if (projectIds.contains(s.projectId)) {
          if (isDateInFilterRange(s.saleDate, dateRange)) {
            totalAgreedSales += s.agreedPrice;
          }
        }
      }

      // Dues & Receivables
      final allInsts = await _db.select(_db.installments).get();
      final paInstIds = allInsts.where((i) => i.purchaseAgreementId != null).map((i) => i.id).toSet();

      // Cash Collected (Non-voided plot sales transactions)
      final allTxs = await (_db.select(_db.transactions)
            ..where((tbl) => tbl.isVoided.equals(false)))
          .get();
      double totalCashCollected = 0.0;
      for (final tx in allTxs) {
        if (projectIds.contains(tx.projectId)) {
          if (isDateInFilterRange(tx.paymentDate, dateRange)) {
            if (tx.installmentId == null || !paInstIds.contains(tx.installmentId)) {
              totalCashCollected += tx.amount;
            }
          }
        }
      }
      if (totalCashCollected == 0.0) {
        for (final inst in allInsts) {
          if (inst.saleId != null) {
            final sale = allSales.where((s) => s.id == inst.saleId).firstOrNull;
            if (sale != null && projectIds.contains(sale.projectId)) {
              if (isDateInFilterRange(inst.dueDate, dateRange)) {
                totalCashCollected += inst.paidAmount;
              }
            }
          }
        }
      }

      // Outflows: Land payments + Expenses
      final allExpenses = await _db.select(_db.expenses).get();
      double totalExpenses = 0.0;
      for (final exp in allExpenses) {
        if (projectIds.contains(exp.projectId)) {
          if (isDateInFilterRange(exp.expenseDate, dateRange)) {
            totalExpenses += exp.amount;
          }
        }
      }

      final allAgreements = await _db.select(_db.purchaseAgreements).get();
      double totalLandPaid = 0.0;
      for (final pa in allAgreements) {
        if (projectIds.contains(pa.projectId)) {
          if (isDateInFilterRange(pa.agreementDate, dateRange)) {
            final insts = await (_db.select(_db.installments)
                  ..where((tbl) => tbl.purchaseAgreementId.equals(pa.id)))
                .get();
            totalLandPaid += insts.fold(0.0, (sum, i) => sum + i.paidAmount);
          }
        }
      }

      final totalOutflows = totalExpenses + totalLandPaid;
      final netCashFlow = totalCashCollected - totalOutflows;

      double totalReceivables = 0.0;
      for (final inst in allInsts) {
        if (inst.saleId != null) {
          final sale = allSales.firstWhere(
            (s) => s.id == inst.saleId,
            orElse: () => Sale(
              id: '',
              projectId: '',
              buyerId: '',
              saleType: '',
              agreedPrice: 0,
              saleExpenses: 0,
              saleDate: DateTime.now(),
              status: '',
              createdAt: DateTime.now(),
            ),
          );
          if (projectIds.contains(sale.projectId)) {
            if (isDateInFilterRange(sale.saleDate, dateRange)) {
              final due = inst.dueAmount - inst.paidAmount;
              if (due > 0) totalReceivables += due;
            }
          }
        }
      }

      // Payables to Landowners
      double totalPayables = 0.0;
      for (final pa in allAgreements) {
        if (projectIds.contains(pa.projectId)) {
          if (isDateInFilterRange(pa.agreementDate, dateRange)) {
            final insts = await (_db.select(_db.installments)
                  ..where((tbl) => tbl.purchaseAgreementId.equals(pa.id)))
                .get();
            final paid = insts.fold(0.0, (sum, i) => sum + i.paidAmount);
            final bal = pa.totalPrice - paid;
            if (bal > 0) totalPayables += bal;
          }
        }
      }

      // Plot Status & Land Area Breakdown
      final allPlots = await _db.select(_db.plots).get();
      int totalAvailablePlots = 0;
      int totalBookedPlots = 0;
      int totalSoldPlots = 0;
      double soldLandAreaSqFt = 0.0;

      for (final plot in allPlots) {
        if (projectIds.contains(plot.projectId)) {
          final statusLower = plot.status.toLowerCase();
          if (statusLower == 'available') {
            totalAvailablePlots++;
          } else if (statusLower == 'booked' || statusLower == 'reserved') {
            totalBookedPlots++;
            soldLandAreaSqFt += plot.areaSqFt;
          } else if (statusLower == 'cancelled') {
            // ignore cancelled
          } else {
            // sold, fullyPaid, saleAgreement, partiallyPaid
            totalSoldPlots++;
            soldLandAreaSqFt += plot.areaSqFt;
          }
        }
      }

      final remainingLandAreaSqFt = (totalLandAreaSqFt - soldLandAreaSqFt).clamp(0.0, double.infinity);

      return PortfolioSummaryModel(
        totalProjects: totalProjects,
        totalLandAreaSqFt: totalLandAreaSqFt,
        soldLandAreaSqFt: soldLandAreaSqFt,
        remainingLandAreaSqFt: remainingLandAreaSqFt,
        totalCapitalInvested: totalCapitalInvested,
        totalAgreedSales: totalAgreedSales,
        totalCashCollected: totalCashCollected,
        totalOutflows: totalOutflows,
        netCashFlow: netCashFlow,
        totalReceivables: totalReceivables,
        totalPayables: totalPayables,
        totalAvailablePlots: totalAvailablePlots,
        totalBookedPlots: totalBookedPlots,
        totalSoldPlots: totalSoldPlots,
      );
    });
  }
}
