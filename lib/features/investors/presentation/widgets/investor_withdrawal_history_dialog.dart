import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/pdf/investor_statement_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../shared/widgets/page/custom_data_table.dart';
import '../../../../shared/widgets/page/status_badge.dart';
import '../../../audit_log/presentation/audit_log_screen.dart';
import '../../../profit_loss_settlement/domain/profit_loss_models.dart';
import '../../../profit_loss_settlement/presentation/profit_loss_providers.dart';
import '../../../profit_loss_settlement/presentation/widgets/payout_disbursement_dialog.dart';
import '../../../projects/domain/project_model.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../domain/investor_model.dart';
import '../../domain/project_investor_model.dart';
import 'investor_statement_pdf_dialog.dart';

class InvestorWithdrawalHistoryDialog extends ConsumerWidget {
  final ProjectInvestorModel projectInvestor;
  final String projectName;
  final String projectCode;

  const InvestorWithdrawalHistoryDialog({
    super.key,
    required this.projectInvestor,
    required this.projectName,
    required this.projectCode,
  });

  static Future<void> show(
    BuildContext context, {
    required ProjectInvestorModel projectInvestor,
    required String projectName,
    required String projectCode,
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
            width: 900,
            height: 640,
            child: InvestorWithdrawalHistoryDialog(
              projectInvestor: projectInvestor,
              projectName: projectName,
              projectCode: projectCode,
            ),
          ),
        ),
      ),
    );
  }

  double _parseAmountFromLog(String details) {
    final match = RegExp(r'₹([0-9.,]+)').firstMatch(details);
    if (match != null) {
      final amtStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amtStr) ?? 0.0;
    }
    return 0.0;
  }

  String _parseReferenceFromLog(String details) {
    final match = RegExp(r'Ref:\s*(.*)$').firstMatch(details);
    if (match != null) {
      return match.group(1)?.trim() ?? 'BANK_TRANSFER';
    }
    return 'BANK_TRANSFER';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogs = ref.watch(auditLogsStreamProvider).value ?? [];
    final withdrawalLogs = allLogs.where((l) {
      return l.action == 'DISBURSE_INVESTOR_PAYOUT' &&
          (l.entityId == projectInvestor.id || l.details.contains(projectInvestor.id));
    }).toList();

    final double totalWithdrawn = withdrawalLogs.fold(
      0.0,
      (sum, log) => sum + _parseAmountFromLog(log.details),
    );

    final pnlList = ref.watch(projectProfitLossStreamProvider).value ?? [];
    final pnl = pnlList.firstWhere(
      (p) => p.projectId == projectInvestor.projectId,
      orElse: () => ProjectProfitLossModel(
        projectId: projectInvestor.projectId,
        projectName: projectName,
        totalAgreedSales: 0,
        directSaleExpenses: 0,
        actualProjectCost: 0,
        cashCollected: 0,
      ),
    );
    final double netProfitPool = pnl.cashCollected - pnl.actualProjectCost;
    final double distributablePool = netProfitPool > 0 ? netProfitPool : 0.0;
    final double profitShare = CalculationEngine.calculateInvestorProfitShare(
      distributableProfit: distributablePool,
      ownershipPercent: projectInvestor.ownershipPercent,
    );
    final double totalAmount = projectInvestor.investedAmount + profitShare;
    final double remainingBalance =
        (totalAmount - totalWithdrawn).clamp(0.0, double.infinity);

    final payoutModel = InvestorPayoutModel(
      id: projectInvestor.id,
      investorId: projectInvestor.investorId,
      investorName: projectInvestor.investorName,
      projectId: projectInvestor.projectId,
      capitalInvested: projectInvestor.investedAmount,
      ownershipPercent: projectInvestor.ownershipPercent,
      distributableProfitPool: distributablePool,
      payoutsDisbursed: totalWithdrawn,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdrawal History: ${projectInvestor.investorName}',
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: 2),
            Text(
              'Project: $projectName ($projectCode)',
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
              final prj = await (db.select(db.projects)
                    ..where((p) => p.id.equals(projectInvestor.projectId)))
                  .getSingleOrNull();
              final inv = await (db.select(db.investors)
                    ..where((i) => i.id.equals(projectInvestor.investorId)))
                  .getSingleOrNull();

              final rawPi = await (db.select(db.projectInvestors)
                    ..where((pi) =>
                        pi.investorId.equals(projectInvestor.investorId)))
                  .get();
              final allPi = rawPi
                  .where((pi) => pi.projectId == projectInvestor.projectId)
                  .toList();
              final investments = allPi.map((pi) {
                final method = OwnershipMethod.values.firstWhere(
                  (m) => m.name == pi.ownershipMethod,
                  orElse: () => OwnershipMethod.capitalBased,
                );
                return ProjectInvestorModel(
                  id: pi.id,
                  projectId: pi.projectId,
                  investorId: pi.investorId,
                  investorName: projectInvestor.investorName,
                  investedAmount: pi.investedAmount,
                  ownershipPercent: pi.ownershipPercent,
                  ownershipMethod: method,
                  createdAt: pi.createdAt,
                );
              }).toList();

              final withdrawals = withdrawalLogs.map((log) {
                return InvestorWithdrawalRecord(
                  date: log.timestamp,
                  amount: _parseAmountFromLog(log.details),
                  reference: _parseReferenceFromLog(log.details),
                  disbursedBy: log.userId,
                );
              }).toList();
              withdrawals.sort((a, b) => b.date.compareTo(a.date));

              final projectModel = prj != null
                  ? ProjectModel(
                      id: prj.id,
                      name: prj.name,
                      code: prj.code,
                      location: prj.location,
                      landAreaSqFt: prj.landAreaSqFt,
                      purchasePrice: prj.purchasePrice,
                      actualCost: prj.actualCost,
                      status: ProjectStatus.values.firstWhere(
                          (s) => s.name == prj.status,
                          orElse: () => ProjectStatus.active),
                      createdAt: prj.createdAt,
                    )
                  : ProjectModel(
                      id: projectInvestor.projectId,
                      name: projectName,
                      code: projectCode,
                      location: '',
                      landAreaSqFt: 0,
                      purchasePrice: 0,
                      actualCost: 0,
                      status: ProjectStatus.active,
                      createdAt: DateTime.now(),
                    );

              final investorModel = inv != null
                  ? InvestorModel(
                      id: inv.id,
                      name: inv.name,
                      phone: inv.phone,
                      email: inv.email,
                      pan: inv.pan,
                      createdAt: inv.createdAt,
                    )
                  : null;

              if (context.mounted) {
                InvestorStatementPdfDialog.show(
                  context,
                  project: projectModel,
                  investor: investorModel,
                  investorName: projectInvestor.investorName,
                  ownershipPercent: projectInvestor.ownershipPercent,
                  investments: investments,
                  withdrawals: withdrawals,
                  profitShare: profitShare,
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
              PayoutDisbursementDialog.show(
                context,
                payout: payoutModel,
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Withdrawal'),
          ),
          const SizedBox(width: 12),
        ],
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
                    title: 'Contributed Capital',
                    value: CalculationEngine.formatCurrency(projectInvestor.investedAmount),
                    color: AppColors.textPrimary,
                    icon: Icons.account_balance_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Profit Share',
                    value: CalculationEngine.formatCurrency(profitShare),
                    color: profitShare >= 0 ? AppColors.successText : AppColors.dangerText,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Amount (Capital + Profit)',
                    value: CalculationEngine.formatCurrency(totalAmount),
                    color: AppColors.textPrimary,
                    icon: Icons.pie_chart_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Withdrawn',
                    value: CalculationEngine.formatCurrency(totalWithdrawn),
                    color: totalWithdrawn > 0 ? AppColors.warningText : AppColors.textSecondary,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Available Remaining Balance',
                    value: CalculationEngine.formatCurrency(remainingBalance),
                    color: AppColors.accent,
                    icon: Icons.savings_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Text(
              'Withdrawal Transaction Records (${withdrawalLogs.length})',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 10),

            Expanded(
              child: withdrawalLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No withdrawals recorded for ${projectInvestor.investorName} yet.',
                            style: AppTypography.secondary,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              PayoutDisbursementDialog.show(
                                context,
                                payout: payoutModel,
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Record First Withdrawal'),
                          ),
                        ],
                      ),
                    )
                  : CustomDataTable(
                      columns: const [
                        DataTableColumn(label: 'Date & Time', width: 170),
                        DataTableColumn(label: 'Withdrawal Amount', width: 160),
                        DataTableColumn(label: 'Payment Reference', width: 180),
                        DataTableColumn(label: 'Status', width: 130),
                        DataTableColumn(label: 'Logged User', width: 120),
                      ],
                      rows: withdrawalLogs.map((log) {
                        final amt = _parseAmountFromLog(log.details);
                        final ref = _parseReferenceFromLog(log.details);
                        final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp);

                        return [
                          Text(dateStr, style: AppTypography.tableCell),
                          Text(
                            CalculationEngine.formatCurrency(amt),
                            style: AppTypography.amountMedium.copyWith(
                              fontSize: 14,
                              color: AppColors.warningText,
                            ),
                          ),
                          Text(
                            ref,
                            style: AppTypography.tableCell.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const StatusBadge(
                            label: 'DISBURSED',
                            type: BadgeType.success,
                          ),
                          Text(log.userId, style: AppTypography.secondary),
                        ];
                      }).toList(),
                    ),
            ),
          ],
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
