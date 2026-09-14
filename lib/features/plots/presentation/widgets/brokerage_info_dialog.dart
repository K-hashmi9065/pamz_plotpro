import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../domain/plot_model.dart';
import 'add_brokerage_dialog.dart';
import 'brokerage_pdf_dialog.dart';

class BrokerageInfoDialog extends ConsumerWidget {
  final PlotModel plot;

  const BrokerageInfoDialog({super.key, required this.plot});

  static Future<void> show(BuildContext context, PlotModel plot) {
    return showDialog(
      context: context,
      builder: (context) => BrokerageInfoDialog(plot: plot),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBroker = (plot.brokerName != null && plot.brokerName!.trim().isNotEmpty) ||
        (plot.brokerPhone != null && plot.brokerPhone!.trim().isNotEmpty) ||
        plot.brokerageCharge > 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.handshake_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Brokerage Information',
                              style: AppTypography.cardTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${plot.plotNumber} • Area: ${plot.formattedArea}',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            if (!hasBroker)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_off_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'No Brokerage Recorded',
                        style: AppTypography.cardTitle.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No broker or brokerage charge has been assigned to this plot yet.',
                        textAlign: TextAlign.center,
                        style: AppTypography.secondary.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          AddBrokerageDialog.show(context, plot);
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Brokerage Charge'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Broker Name
              _buildInfoRow(
                icon: Icons.person,
                label: 'Broker Name',
                value: plot.brokerName?.trim().isNotEmpty == true ? plot.brokerName! : '—',
              ),
              const SizedBox(height: 14),

              // Broker Phone
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Mobile Number',
                value: plot.brokerPhone?.trim().isNotEmpty == true ? plot.brokerPhone! : '—',
              ),
              const SizedBox(height: 14),

              // Brokerage Charge
              _buildInfoRow(
                icon: Icons.currency_rupee,
                label: 'Brokerage Charge',
                value: CalculationEngine.formatCurrency(plot.brokerageCharge),
                isHighlighted: true,
              ),
              const SizedBox(height: 18),

              // Note box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This brokerage charge is included in the project expenses and is also added directly to this plot\'s total cost calculation.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, size: 16, color: AppColors.accent),
                    label: const Text('Export / Share PDF'),
                    onPressed: () async {
                      final db = ref.read(appDatabaseProvider);
                      final prj = await (db.select(db.projects)
                            ..where((p) => p.id.equals(plot.projectId)))
                          .getSingleOrNull();

                      if (context.mounted) {
                        BrokeragePdfDialog.show(
                          context,
                          plot: plot,
                          projectName: prj?.name ?? 'Project',
                          projectCode: prj?.code ?? 'PRJ',
                          projectLocation: prj?.location ?? '—',
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Brokerage'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AddBrokerageDialog.show(context, plot);
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHighlighted ? AppColors.primary.withValues(alpha: 0.25) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isHighlighted ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: isHighlighted
                    ? AppTypography.cardTitle.copyWith(color: AppColors.primary, fontSize: 16)
                    : AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
