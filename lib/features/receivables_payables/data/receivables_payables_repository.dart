import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../domain/receivable_payable_models.dart';

class ReceivablesPayablesRepository {
  final AppDatabase _db;

  ReceivablesPayablesRepository(this._db);

  /// Watch all buyer receivables with aging analysis
  Stream<List<BuyerReceivableModel>> watchBuyerReceivables() {
    return _db.select(_db.installments).watch().asyncMap((installments) async {
      final results = <BuyerReceivableModel>[];
      final now = DateTime.now();

      for (final inst in installments) {
        // Customer receivables are only from customer plot/land sales
        if (inst.saleId == null || inst.saleId!.isEmpty) continue;

        final outstanding = inst.dueAmount - inst.paidAmount;
        if (outstanding <= 0) continue; // Only unpaid / partially paid

        String buyerName = 'Customer';
        String projectId = 'UNKNOWN_PROJECT';

        final sale = await (_db.select(_db.sales)
              ..where((tbl) => tbl.id.equals(inst.saleId!)))
            .getSingleOrNull();

        if (sale != null) {
          projectId = sale.projectId;
          final buyer = await (_db.select(_db.buyers)
                ..where((tbl) => tbl.id.equals(sale.buyerId)))
              .getSingleOrNull();
          if (buyer != null) buyerName = buyer.name;
        }

        final diffDays = now.difference(inst.dueDate).inDays;
        final overdueDays = diffDays < 0 ? 0 : diffDays;

        results.add(
          BuyerReceivableModel(
            installmentId: inst.id,
            saleId: inst.saleId ?? '',
            buyerName: buyerName,
            projectId: projectId,
            installmentNumber: inst.installmentNumber,
            dueDate: inst.dueDate,
            dueAmount: inst.dueAmount,
            paidAmount: inst.paidAmount,
            balanceOutstanding: outstanding < 0 ? 0.0 : outstanding,
            overdueDays: overdueDays,
          ),
        );
      }

      // Sort by highest overdue days first
      results.sort((a, b) => b.overdueDays.compareTo(a.overdueDays));
      return results;
    });
  }

  /// Watch all landowner payables
  Stream<List<LandownerPayableModel>> watchLandownerPayables() {
    return _db.select(_db.purchaseAgreements).watch().asyncMap((agreements) async {
      final results = <LandownerPayableModel>[];

      for (final pa in agreements) {
        String landownerName = 'Landowner';
        final landowner = await (_db.select(_db.landowners)
              ..where((tbl) => tbl.id.equals(pa.landownerId)))
            .getSingleOrNull();
        if (landowner != null) landownerName = landowner.name;

        // Sum installments linked to this purchase agreement
        final paInstallments = await (_db.select(_db.installments)
              ..where((tbl) => tbl.purchaseAgreementId.equals(pa.id)))
            .get();

        double paidAmount = 0.0;
        for (final inst in paInstallments) {
          paidAmount += inst.paidAmount;
        }

        final outstanding = pa.totalPrice - paidAmount;

        results.add(
          LandownerPayableModel(
            agreementId: pa.id,
            landownerId: pa.landownerId,
            landownerName: landownerName,
            projectId: pa.projectId,
            agreedPurchasePrice: pa.totalPrice,
            paidAmount: paidAmount,
            balanceOutstanding: outstanding < 0 ? 0.0 : outstanding,
            status: pa.status,
          ),
        );
      }

      return results;
    });
  }

  /// Watch project cash flow summaries
  Stream<List<ProjectCashFlowModel>> watchProjectCashFlows() {
    return _db.select(_db.projects).watch().asyncMap((projects) async {
      final results = <ProjectCashFlowModel>[];

      for (final project in projects) {
        final sales = await (_db.select(_db.sales)
              ..where((tbl) => tbl.projectId.equals(project.id)))
            .get();
        final saleIds = sales.map((s) => s.id).toSet();

        final saleInsts = saleIds.isEmpty
            ? <Installment>[]
            : await (_db.select(_db.installments)
                  ..where((tbl) => tbl.saleId.isIn(saleIds)))
                .get();
        // Landowner payment installments (to exclude from cash inflows)
        final paInsts = await (_db.select(_db.installments)
              ..where((tbl) => tbl.purchaseAgreementId.isNotNull()))
            .get();
        final paInstIds = paInsts.map((i) => i.id).toSet();

        // Inflows: Non-voided plot sales transactions for this project
        final txs = await (_db.select(_db.transactions)
              ..where((tbl) => tbl.projectId.equals(project.id) & tbl.isVoided.equals(false)))
            .get();
        double totalInflows = 0.0;
        for (final tx in txs) {
          if (tx.installmentId == null || !paInstIds.contains(tx.installmentId)) {
            totalInflows += tx.amount;
          }
        }
        if (totalInflows == 0.0 && saleInsts.isNotEmpty) {
          totalInflows = saleInsts.fold(0.0, (sum, inst) => sum + inst.paidAmount);
        }

        // Land Outflows: Purchase Agreements for this project
        final agreements = await (_db.select(_db.purchaseAgreements)
              ..where((tbl) => tbl.projectId.equals(project.id)))
            .get();
        double totalLandOutflows = 0.0;
        for (final pa in agreements) {
          final paInsts = await (_db.select(_db.installments)
                ..where((tbl) => tbl.purchaseAgreementId.equals(pa.id)))
              .get();
          totalLandOutflows += paInsts.fold(0.0, (sum, inst) => sum + inst.paidAmount);
        }

        // Expense Outflows: Project expenses
        final expenses = await (_db.select(_db.expenses)
              ..where((tbl) => tbl.projectId.equals(project.id)))
            .get();
        final totalExpenseOutflows = expenses.fold(0.0, (sum, exp) => sum + exp.amount);

        results.add(
          ProjectCashFlowModel(
            projectId: project.id,
            projectName: project.name,
            totalInflows: totalInflows,
            totalLandOutflows: totalLandOutflows,
            totalExpenseOutflows: totalExpenseOutflows,
          ),
        );
      }

      return results;
    });
  }
}
