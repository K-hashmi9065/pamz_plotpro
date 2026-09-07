import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../shared/widgets/page/custom_data_table.dart';
import '../../domain/investor_model.dart';
import '../investors_providers.dart';

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
    final formattedDate = DateFormat('dd MMM yyyy').format(investor.createdAt);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.accent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Investor Profile: ${investor.name}',
                      style: AppTypography.cardTitle,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Profile info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone Number', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(investor.phone, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text('Email Address', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(investor.email ?? '—', style: AppTypography.body),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PAN Card', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(investor.pan ?? '—', style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text('Registered Date', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(formattedDate, style: AppTypography.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Project Participations (Multi-Project)',
              style: AppTypography.sectionTitle.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 10),

            // Participations table
            SizedBox(
              height: 220,
              child: participationsAsync.when(
                loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading participations: $err',
                    style: AppTypography.body.copyWith(color: AppColors.dangerText),
                  ),
                ),
                data: (participations) {
                  return CustomDataTable(
                    columns: const [
                      DataTableColumn(label: 'Project Name'),
                      DataTableColumn(label: 'Contribution', width: 160),
                      DataTableColumn(label: 'Ownership %', width: 130),
                      DataTableColumn(label: 'Method', width: 140),
                    ],
                    rows: participations.map((p) {
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
}
