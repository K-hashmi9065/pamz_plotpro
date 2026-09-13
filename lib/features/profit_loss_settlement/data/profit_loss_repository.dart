import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../domain/profit_loss_models.dart';

class ProfitLossRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ProfitLossRepository(this._db);

  /// Watch Profit & Loss summaries for all projects
  Stream<List<ProjectProfitLossModel>> watchAllProjectProfitLoss() {
    return _db.select(_db.projects).watch().asyncMap((projects) async {
      final results = <ProjectProfitLossModel>[];

      for (final project in projects) {
        // Sales for project
        final sales = await (_db.select(_db.sales)
              ..where((tbl) => tbl.projectId.equals(project.id)))
            .get();

        double totalAgreedSales = 0.0;
        double directSaleExpenses = 0.0;
        final saleIds = <String>{};
        for (final s in sales) {
          totalAgreedSales += s.agreedPrice;
          directSaleExpenses += s.saleExpenses;
          saleIds.add(s.id);
        }

        // Landowner payment installment IDs (to exclude from sales cash collected)
        final paInstallments = await (_db.select(_db.installments)
              ..where((tbl) => tbl.purchaseAgreementId.isNotNull()))
            .get();
        final paInstIds = paInstallments.map((i) => i.id).toSet();

        // Installments for project plot sales
        final saleInstallments = saleIds.isEmpty
            ? <Installment>[]
            : await (_db.select(_db.installments)
                  ..where((tbl) => tbl.saleId.isIn(saleIds)))
                .get();

        // Cash collected from non-voided plot sales transactions
        final txs = await (_db.select(_db.transactions)
              ..where((tbl) => tbl.projectId.equals(project.id) & tbl.isVoided.equals(false)))
            .get();

        double cashCollected = 0.0;
        for (final tx in txs) {
          if (tx.installmentId == null || !paInstIds.contains(tx.installmentId)) {
            cashCollected += tx.amount;
          }
        }
        if (cashCollected == 0.0 && saleInstallments.isNotEmpty) {
          cashCollected = saleInstallments.fold(0.0, (sum, inst) => sum + inst.paidAmount);
        }

        // Fetch all project expenses dynamically
        final expenses = await (_db.select(_db.expenses)
              ..where((tbl) => tbl.projectId.equals(project.id)))
            .get();
        final totalCapitalized = expenses
            .where((e) => e.isCapitalized)
            .fold(0.0, (sum, e) => sum + e.amount);
        final dynamicActualCost = project.purchasePrice + totalCapitalized;

        results.add(
          ProjectProfitLossModel(
            projectId: project.id,
            projectName: project.name,
            totalAgreedSales: totalAgreedSales,
            directSaleExpenses: directSaleExpenses,
            actualProjectCost: dynamicActualCost,
            cashCollected: cashCollected,
          ),
        );
      }

      return results;
    });
  }

  /// Watch investor payout settlements for a specific project
  Stream<List<InvestorPayoutModel>> watchInvestorPayoutsForProject(
    String projectId,
    double projectDistributableProfit,
  ) {
    final query = _db.select(_db.projectInvestors)
      ..where((tbl) => tbl.projectId.equals(projectId));

    return query.watch().asyncMap((allocations) async {
      final results = <InvestorPayoutModel>[];

      for (final alloc in allocations) {
        String investorName = 'Investor';
        final inv = await (_db.select(_db.investors)
              ..where((tbl) => tbl.id.equals(alloc.investorId)))
            .getSingleOrNull();

        if (inv != null) investorName = inv.name;

        // Sum payouts disbursed from audit logs for this investor/project
        final logs = await (_db.select(_db.auditLogs)
              ..where((tbl) =>
                  tbl.action.equals('DISBURSE_INVESTOR_PAYOUT') &
                  tbl.entityId.equals(alloc.id)))
            .get();

        double totalDisbursed = 0.0;
        for (final log in logs) {
          // Parse amount from details if stored
          final parts = log.details.split('₹');
          if (parts.length > 1) {
            final amtStr = parts[1].split(' ')[0].replaceAll(',', '');
            totalDisbursed += double.tryParse(amtStr) ?? 0.0;
          }
        }

        results.add(
          InvestorPayoutModel(
            id: alloc.id,
            investorId: alloc.investorId,
            investorName: investorName,
            projectId: alloc.projectId,
            capitalInvested: alloc.investedAmount,
            ownershipPercent: alloc.ownershipPercent,
            distributableProfitPool: projectDistributableProfit,
            payoutsDisbursed: totalDisbursed,
          ),
        );
      }

      return results;
    });
  }

  /// Record an investor payout / dividend distribution (Admin-only)
  Future<void> recordInvestorPayout({
    required String projectInvestorId,
    required double payoutAmount,
    required String paymentReference,
    required String userId,
  }) async {
    if (payoutAmount <= 0) {
      throw ArgumentError('Payout Amount * must be greater than zero.');
    }

    final alloc = await (_db.select(_db.projectInvestors)
          ..where((tbl) => tbl.id.equals(projectInvestorId)))
        .getSingleOrNull();

    if (alloc == null) {
      throw ArgumentError('Investor capital allocation record not found.');
    }

    // Insert audit log entry for payout distribution
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion(
            id: Value(_uuid.v4()),
            userId: Value(userId),
            action: const Value('DISBURSE_INVESTOR_PAYOUT'),
            entityType: const Value('ProjectInvestor'),
            entityId: Value(projectInvestorId),
            details: Value(
              'Disbursed profit payout of ₹${payoutAmount % 1 == 0 ? payoutAmount.toInt() : payoutAmount.round()} to investor. Ref: ${paymentReference.trim()}',
            ),
            timestamp: Value(DateTime.now()),
          ),
        );
  }
}
