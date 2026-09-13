import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../shared/widgets/page/custom_data_table.dart';
import '../../../../shared/widgets/page/status_badge.dart';
import '../../../installments_payments/domain/installment_model.dart';
import '../../../installments_payments/presentation/installments_providers.dart';
import '../../../projects/domain/project_model.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../domain/purchase_agreement_model.dart';
import '../landowners_providers.dart';
import 'landowner_invoice_pdf_dialog.dart';
import 'landowner_payment_dialog.dart';

class LandownerPaymentHistoryDialog extends ConsumerWidget {
  final PurchaseAgreementModel purchaseAgreement;
  final ProjectModel project;

  const LandownerPaymentHistoryDialog({
    super.key,
    required this.purchaseAgreement,
    required this.project,
  });

  static Future<void> show(
    BuildContext context, {
    required PurchaseAgreementModel purchaseAgreement,
    required ProjectModel project,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        backgroundColor: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 920,
            height: 680,
            child: LandownerPaymentHistoryDialog(
              purchaseAgreement: purchaseAgreement,
              project: project,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync = ref.watch(installmentsListStreamProvider);
    final transactionsAsync = ref.watch(transactionsListStreamProvider);

    final allInstallments = installmentsAsync.value ?? [];
    final rawPaInstallments = allInstallments
        .where((i) => i.purchaseAgreementId == purchaseAgreement.id)
        .toList()
      ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

    // Ensure single agreement installments reflect the full purchase agreement due
    final paInstallments = rawPaInstallments.map((inst) {
      if (rawPaInstallments.length == 1 && inst.dueAmount < purchaseAgreement.totalPrice) {
        final newDue = purchaseAgreement.totalPrice;
        final newStatus = inst.paidAmount >= newDue
            ? InstallmentStatus.paid
            : (inst.paidAmount > 0
                ? InstallmentStatus.partiallyPaid
                : InstallmentStatus.pending);
        return InstallmentModel(
          id: inst.id,
          projectId: inst.projectId,
          saleId: inst.saleId,
          purchaseAgreementId: inst.purchaseAgreementId,
          installmentNumber: inst.installmentNumber,
          dueDate: inst.dueDate,
          dueAmount: newDue,
          paidAmount: inst.paidAmount,
          status: newStatus,
          createdAt: inst.createdAt,
          buyerName: inst.buyerName,
          projectName: inst.projectName,
          plotInfo: inst.plotInfo,
        );
      }
      return inst;
    }).toList();

    final installmentIds = paInstallments.map((i) => i.id).toSet();

    final allTransactions = transactionsAsync.value ?? [];
    final paTransactions = allTransactions
        .where((tx) =>
            !tx.isVoided &&
            (installmentIds.contains(tx.installmentId) ||
                (tx.projectId == project.id && tx.installmentId == null)))
        .toList();

    final double totalPaid = paInstallments.fold(
      0.0,
      (sum, i) => sum + i.paidAmount,
    );
    final double remainingBalance =
        (purchaseAgreement.totalPrice - totalPaid).clamp(0.0, double.infinity);

    final int paidCount = paInstallments
        .where((i) => i.status == InstallmentStatus.paid)
        .length;
    final int totalCount = paInstallments.length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Landowner Payment History: ${project.landownerName ?? "Landowner"}',
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 2),
              Text(
                'Project: ${project.name} (${project.code}) | Agreement Date: ${DateFormat("dd MMM yyyy").format(purchaseAgreement.agreementDate)}',
                style: AppTypography.secondary.copyWith(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: AppColors.surface,
          elevation: 1,
          actions: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.accent),
              label: const Text('Share Statement PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () async {
                final db = ref.read(appDatabaseProvider);
                final paInsts = await (db.select(db.installments)
                      ..where((i) => i.purchaseAgreementId.equals(purchaseAgreement.id)))
                    .get();
                final instIds = paInsts.map((i) => i.id).toSet();
                final allTxs = await (db.select(db.transactions)
                      ..where((t) => t.projectId.equals(project.id)))
                    .get();
                final txs = allTxs.where((t) {
                  if (t.isVoided) return false;
                  if (t.installmentId != null && instIds.contains(t.installmentId)) return true;
                  if (t.installmentId == null) return true;
                  return false;
                }).toList();
                txs.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

                final landowners = ref.read(landownersListStreamProvider).value ?? [];
                final landowner = landowners
                    .where((l) =>
                        l.id == (project.landownerId ?? purchaseAgreement.landownerId))
                    .firstOrNull;

                if (context.mounted) {
                  LandownerInvoicePdfDialog.show(
                    context,
                    project: project,
                    agreement: purchaseAgreement,
                    landowner: landowner,
                    transactions: txs,
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () {
                final pendingInst = paInstallments.firstWhere(
                  (i) => i.remainingAmount > 0,
                  orElse: () => paInstallments.isNotEmpty
                      ? paInstallments.first
                      : InstallmentModel(
                          id: '',
                          purchaseAgreementId: purchaseAgreement.id,
                          installmentNumber: 1,
                          dueDate: DateTime.now(),
                          dueAmount: remainingBalance,
                          paidAmount: 0,
                          status: InstallmentStatus.pending,
                          createdAt: DateTime.now(),
                        ),
                );
                LandownerPaymentDialog.show(
                  context,
                  project: project,
                  agreement: purchaseAgreement,
                  installment: pendingInst.id.isNotEmpty ? pendingInst : null,
                );
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Record Land Payment'),
            ),
            const SizedBox(width: 12),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.schedule_outlined, size: 16),
                text: 'Payment & Installment Schedule',
              ),
              Tab(
                icon: Icon(Icons.receipt_long_outlined, size: 16),
                text: 'Transaction Logs & Receipts',
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary KPI Cards (Arranged in 2 balanced rows)
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Purchase Price',
                      value: CalculationEngine.formatCurrency(
                        purchaseAgreement.totalPrice,
                      ),
                      color: AppColors.textPrimary,
                      icon: Icons.account_balance_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Total Paid to Landowner',
                      value: CalculationEngine.formatCurrency(totalPaid),
                      color: AppColors.successText,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Remaining Dues / Balance',
                      value: CalculationEngine.formatCurrency(remainingBalance),
                      color: remainingBalance > 0
                          ? AppColors.warningText
                          : AppColors.successText,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Installment Progress',
                      value: totalCount > 0
                          ? '$paidCount of $totalCount Completed'
                          : 'Single Payment',
                      color: AppColors.textPrimary,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Recorded Transactions',
                      value: '${paTransactions.length} Paid Logs',
                      color: AppColors.accent,
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Installment Schedule
                    paInstallments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 48,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No installment schedule found for this land purchase agreement.',
                                  style: AppTypography.secondary,
                                ),
                              ],
                            ),
                          )
                        : CustomDataTable(
                            columns: const [
                              DataTableColumn(label: 'Installment', width: 110),
                              DataTableColumn(label: 'Due Date', width: 130),
                              DataTableColumn(label: 'Scheduled Due', width: 150),
                              DataTableColumn(label: 'Paid Amount', width: 150),
                              DataTableColumn(label: 'Remaining Dues', width: 150),
                              DataTableColumn(label: 'Status', width: 120),
                              DataTableColumn(
                                label: 'Action',
                                width: 90,
                                alignment: Alignment.center,
                              ),
                            ],
                            rows: paInstallments.map((inst) {
                              final isPaid =
                                  inst.status == InstallmentStatus.paid;
                              return [
                                Text(
                                  '#${inst.installmentNumber}',
                                  style: AppTypography.tableCell.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(inst.dueDate),
                                  style: AppTypography.tableCell,
                                ),
                                Text(
                                  CalculationEngine.formatCurrency(
                                    inst.dueAmount,
                                  ),
                                  style: AppTypography.amountMedium,
                                ),
                                Text(
                                  CalculationEngine.formatCurrency(
                                    inst.paidAmount,
                                  ),
                                  style: AppTypography.amountMedium.copyWith(
                                    color: inst.paidAmount > 0
                                        ? AppColors.successText
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  CalculationEngine.formatCurrency(
                                    inst.remainingAmount,
                                  ),
                                  style: AppTypography.amountMedium.copyWith(
                                    color: inst.remainingAmount > 0
                                        ? AppColors.warningText
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                StatusBadge(
                                  label: inst.status ==
                                          InstallmentStatus.partiallyPaid
                                      ? 'PARTIALLY PAID'
                                      : inst.status.name.toUpperCase(),
                                  type: isPaid
                                      ? BadgeType.success
                                      : inst.status ==
                                              InstallmentStatus.partiallyPaid
                                          ? BadgeType.warning
                                          : BadgeType.info,
                                ),
                                isPaid
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AppColors.successText,
                                        size: 18,
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.payment,
                                          color: AppColors.accent,
                                          size: 18,
                                        ),
                                        tooltip: 'Pay Installment #${inst.installmentNumber}',
                                        onPressed: () {
                                          LandownerPaymentDialog.show(
                                            context,
                                            project: project,
                                            agreement: purchaseAgreement,
                                            installment: inst,
                                          );
                                        },
                                      ),
                              ];
                            }).toList(),
                          ),

                    // Tab 2: Transaction Logs
                    paTransactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No payment transactions recorded for this landowner yet.',
                                  style: AppTypography.secondary,
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    LandownerPaymentDialog.show(
                                      context,
                                      project: project,
                                      agreement: purchaseAgreement,
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Record First Payment'),
                                ),
                              ],
                            ),
                          )
                        : CustomDataTable(
                            columns: const [
                              DataTableColumn(label: 'Payment Date', width: 160),
                              DataTableColumn(label: 'Paid Amount', width: 160),
                              DataTableColumn(label: 'Payment Method', width: 150),
                              DataTableColumn(label: 'Reference / UTR', width: 160),
                              DataTableColumn(label: 'Logged By', width: 120),
                              DataTableColumn(label: 'Status', width: 110),
                            ],
                            rows: paTransactions.map((tx) {
                              final dateStr = DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(tx.paymentDate);

                              return [
                                Text(dateStr, style: AppTypography.tableCell),
                                Text(
                                  CalculationEngine.formatCurrency(tx.amount),
                                  style: AppTypography.amountMedium.copyWith(
                                    color: AppColors.successText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  tx.paymentMethod.name.toUpperCase(),
                                  style: AppTypography.tableCell.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  tx.referenceNumber?.isNotEmpty == true
                                      ? tx.referenceNumber!
                                      : '—',
                                  style: AppTypography.tableCell,
                                ),
                                Text(tx.createdBy, style: AppTypography.secondary),
                                const StatusBadge(
                                  label: 'PAID',
                                  type: BadgeType.success,
                                ),
                              ];
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.secondary.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
