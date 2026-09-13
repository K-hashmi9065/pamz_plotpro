import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../shared/widgets/page/custom_data_table.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../domain/investor_model.dart';
import '../investors_providers.dart';
import 'investor_agreement_pdf_dialog.dart';

class InvestorProfileDialog extends ConsumerWidget {
  final InvestorModel investor;

  const InvestorProfileDialog({
    super.key,
    required this.investor,
  });

  static Future<void> show(BuildContext context, InvestorModel investor) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InvestorProfileDialog(investor: investor),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participationsAsync = ref.watch(investorProjectsStreamProvider(investor.id));
    final summaryAsync = ref.watch(investorFinancialSummaryFutureProvider(investor.id));
    final projectsAsync = ref.watch(projectsListStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 760,
        height: 640,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(investor.name, style: AppTypography.cardTitle),
                        Text(
                          'Phone: ${investor.phone}  •  PAN: ${investor.pan ?? "N/A"}  •  Email: ${investor.email ?? "N/A"}',
                          style: AppTypography.secondary.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Financial Summary Metrics Cards
            summaryAsync.when(
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Text('Error loading summary: $err', style: AppTypography.secondary),
              data: (summary) {
                return Row(
                  children: [
                    _buildMetricCard('Total Capital Invested', CalculationEngine.formatCurrency(summary.totalInvestedCapital), AppColors.accent),
                    const SizedBox(width: 12),
                    _buildMetricCard('Profit Share Earned', CalculationEngine.formatCurrency(summary.totalProfitEarned), AppColors.successText),
                    const SizedBox(width: 12),
                    _buildMetricCard('Withdrawn Payouts', CalculationEngine.formatCurrency(summary.totalWithdrawnPayouts), AppColors.warningText),
                    const SizedBox(width: 12),
                    _buildMetricCard('Net Balance Remaining', CalculationEngine.formatCurrency(summary.netRemainingBalance), AppColors.primary),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),

            // Project Participations Table
            Text(
              'Project Participations & Equity Ownership',
              style: AppTypography.secondary.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: participationsAsync.when(
                loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
                error: (err, stack) => Text('Error loading participations: $err'),
                data: (participations) {
                  return CustomDataTable(
                    columns: const [
                      DataTableColumn(label: 'Project Name'),
                      DataTableColumn(label: 'Contribution', width: 150),
                      DataTableColumn(label: 'Ownership %', width: 110),
                      DataTableColumn(label: 'Method', width: 120),
                      DataTableColumn(label: 'Agreement PDF', width: 120, alignment: Alignment.center),
                    ],
                    rows: participations.map((p) {
                      final projects = projectsAsync.value ?? [];
                      final proj = projects.where((projItem) => projItem.id == p.projectId).firstOrNull;

                      return [
                        Text(
                          p.investorName, // Contains Project Name
                          style: AppTypography.tableCell.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          CalculationEngine.formatCurrency(p.investedAmount),
                          style: AppTypography.amountMedium.copyWith(fontSize: 13),
                        ),
                        Text(
                          '${p.ownershipPercent.toStringAsFixed(2)}%',
                          style: AppTypography.tableCell.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.successText,
                          ),
                        ),
                        Text(
                          p.ownershipMethod.name.toUpperCase(),
                          style: AppTypography.secondary.copyWith(fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: AppColors.accent, size: 18),
                          tooltip: 'Generate / View Investor Agreement PDF',
                          onPressed: () {
                            if (proj != null) {
                              InvestorAgreementPdfDialog.show(
                                context,
                                investorName: investor.name,
                                investorPhone: investor.phone,
                                investorPan: investor.pan,
                                investorEmail: investor.email,
                                projectName: proj.name,
                                projectCode: proj.code,
                                projectLocation: proj.location,
                                projectLandAreaSqFt: proj.landAreaSqFt,
                                investedAmount: p.investedAmount,
                                ownershipPercent: p.ownershipPercent,
                                ownershipMethod: p.ownershipMethod,
                                agreementDate: p.createdAt,
                              );
                            }
                          },
                        ),
                      ];
                    }).toList(),
                    emptyMessage: 'This investor has not been allocated to any project yet.',
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerText,
                    side: const BorderSide(color: AppColors.dangerText),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete Investor'),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final repo = ref.read(investorsRepositoryProvider);

                    final summary = await repo.getInvestorFinancialSummary(investor.id);

                    if (!context.mounted) return;

                    if (!summary.canBeDeleted) {
                      showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.block, color: AppColors.dangerText, size: 24),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cannot Delete Investor',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          content: SizedBox(
                            width: 440,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Investor "${investor.name}" has active invested capital or unwithdrawn profit earnings.',
                                  style: AppTypography.body,
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total Invested Capital:', style: AppTypography.secondary),
                                          Text(CalculationEngine.formatCurrency(summary.totalInvestedCapital), style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Profit Share Earned:', style: AppTypography.secondary),
                                          Text(CalculationEngine.formatCurrency(summary.totalProfitEarned), style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total Withdrawn:', style: AppTypography.secondary),
                                          Text(CalculationEngine.formatCurrency(summary.totalWithdrawnPayouts), style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Unsettled Balance:', style: AppTypography.secondary),
                                          Text(
                                            CalculationEngine.formatCurrency(summary.netRemainingBalance),
                                            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.dangerText),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'All invested money and profit share must be fully withdrawn and settled in Profit & Loss Settlement before this investor profile can be deleted.',
                                  style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(dialogCtx).pop(),
                              child: const Text('Understand'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.delete_forever_outlined, color: AppColors.dangerText, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Confirm Delete Investor',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          content: Text(
                            'Are you sure you want to delete investor "${investor.name}"?\n\n'
                            'All invested capital and profit distributions (Total Settled: ${CalculationEngine.formatCurrency(summary.totalWithdrawnPayouts)}) have been fully withdrawn. This action cannot be undone.',
                            style: AppTypography.body,
                          ),
                          actions: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(dialogCtx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerText),
                              onPressed: () => Navigator.of(dialogCtx).pop(true),
                              child: const Text('Delete Investor'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await repo.deleteInvestor(investor.id, userId: 'admin_user');
                        navigator.pop(); // Close profile dialog
                        messenger.showSnackBar(
                          SnackBar(content: Text('Investor "${investor.name}" deleted successfully!')),
                        );
                      }
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.secondary.copyWith(fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
