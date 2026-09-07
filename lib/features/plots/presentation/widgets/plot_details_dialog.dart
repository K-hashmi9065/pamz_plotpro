import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../core/utils/land_unit_converter.dart';
import '../../../../core/widgets/formula_explainability_dialog.dart';
import '../../../../shared/widgets/page/status_badge.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../domain/plot_model.dart';


class PlotDetailsDialog extends ConsumerWidget {
  final PlotModel plot;

  const PlotDetailsDialog({
    super.key,
    required this.plot,
  });

  static Future<void> show(BuildContext context, PlotModel plot) {
    return showDialog(
      context: context,
      builder: (context) => PlotDetailsDialog(plot: plot),
    );
  }

  BadgeType _getBadgeType(PlotStatus status) {
    switch (status) {
      case PlotStatus.available:
        return BadgeType.success;
      case PlotStatus.reserved:
      case PlotStatus.booked:
      case PlotStatus.saleAgreement:
      case PlotStatus.partiallyPaid:
        return BadgeType.warning;
      case PlotStatus.sold:
      case PlotStatus.fullyPaid:
        return BadgeType.info;
      case PlotStatus.cancelled:
        return BadgeType.danger;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListStreamProvider);
    final formattedDate = DateFormat('dd MMM yyyy').format(plot.createdAt);

    // Multi-unit conversions for total plot area
    final kd = LandUnitConverter.sqFtToKattaDhur(plot.areaSqFt);
    final decimalVal = LandUnitConverter.sqFtToDecimal(plot.areaSqFt);
    final bighaVal = LandUnitConverter.sqFtToBigha(plot.areaSqFt);
    final sqMeterVal = (plot.areaSqFt / LandUnitConverter.sqFtPerSqMeter).toStringAsFixed(1);
    final costPerSqFt = plot.areaSqFt > 0 ? plot.allocatedCost / plot.areaSqFt : 0.0;
    final expectedPricePerSqFt = plot.areaSqFt > 0 ? plot.expectedPrice / plot.areaSqFt : 0.0;
    final expectedProfit = plot.expectedPrice > 0 ? (plot.expectedPrice - plot.allocatedCost) : 0.0;

    final lFt = plot.lengthFt ?? 0.0;
    final lIn = plot.lengthIn ?? 0.0;
    final bFt = plot.breadthFt ?? 0.0;
    final bIn = plot.breadthIn ?? 0.0;

    final lengthStr = '${lFt == lFt.roundToDouble() ? lFt.toInt() : lFt} feet ${lIn == lIn.roundToDouble() ? lIn.toInt() : lIn} inches';
    final breadthStr = '${bFt == bFt.roundToDouble() ? bFt.toInt() : bFt} feet ${bIn == bIn.roundToDouble() ? bIn.toInt() : bIn} inches';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 620,
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header with Title & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.grid_view_rounded, color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plot Details (${plot.plotNumber})',
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          projectsAsync.when(
                            data: (projects) {
                              final proj = projects.where((p) => p.id == plot.projectId).firstOrNull;
                              return Text(
                                proj != null
                                    ? 'Project: ${proj.name} (${proj.code})'
                                    : 'Project ID: ${plot.projectId}',
                                style: AppTypography.secondary.copyWith(fontSize: 12),
                              );
                            },
                            loading: () => Text('Loading project...', style: AppTypography.secondary.copyWith(fontSize: 12)),
                            error: (e, s) => Text('Project ID: ${plot.projectId}', style: AppTypography.secondary.copyWith(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StatusBadge(
                        label: plot.status.name.toUpperCase(),
                        type: _getBadgeType(plot.status),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // Land Dimensions & Measurement Cards Header
              Text(
                'Land Measurement & Dimensions Details',
                style: AppTypography.secondary.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              // Key Dimension & Area Summary Grid Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildDetailMetricCard(
                          title: 'Plot Length',
                          value: lengthStr,
                          icon: Icons.straighten,
                          accentColor: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        _buildDetailMetricCard(
                          title: 'Plot Breadth / Width',
                          value: breadthStr,
                          icon: Icons.straighten_outlined,
                          accentColor: AppColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDetailMetricCard(
                          title: 'Primary Measurement',
                          value: plot.formattedArea,
                          icon: Icons.square_foot,
                          accentColor: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        _buildDetailMetricCard(
                          title: 'Area in Square Feet',
                          value: '${plot.areaSqFt.toStringAsFixed(1)} sq.ft',
                          icon: Icons.aspect_ratio,
                          accentColor: AppColors.infoText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDetailMetricCard(
                          title: 'Kattha & Dhur Equivalent',
                          value: '${kd.katta} Kattha ${kd.dhur} Dhur',
                          icon: Icons.unfold_more,
                          accentColor: AppColors.successText,
                        ),
                        const SizedBox(width: 12),
                        _buildDetailMetricCard(
                          title: 'Decimal Equivalent',
                          value: '$decimalVal Dec',
                          icon: Icons.layers_outlined,
                          accentColor: AppColors.warningText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Multi-Unit Conversion Readout Table
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.table_chart_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            'Area Conversion Matrix',
                            style: AppTypography.secondary.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildUnitCell('Kattha', '${kd.katta}'),
                          _buildUnitCell('Dhur', '${kd.dhur}'),
                          _buildUnitCell('Decimal', '$decimalVal'),
                          _buildUnitCell('Bigha', '$bighaVal'),
                          _buildUnitCell('Sq Meters', sqMeterVal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Plot Financial Details Section
              Text(
                'Plot Financial Breakdown & Cost Allocation',
                style: AppTypography.secondary.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Allocated Cost Row with Formula Explainability
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Allocated Project Cost:', style: AppTypography.body),
                            const SizedBox(width: 4),
                            FormulaInfoButton(
                              figureTitle: 'Plot Cost Allocation (${plot.plotNumber})',
                              plainWordsFormula:
                                  'Allocated Plot Cost = (Plot Area / Total Project Area) * Actual Project Cost',
                              terms: [
                                FormulaTermDefinition(
                                  term: 'Plot Area',
                                  definition: 'Area of this specific plot in square feet.',
                                  valueDisplay: '${plot.areaSqFt.round()} sq.ft',
                                ),
                                const FormulaTermDefinition(
                                  term: 'Total Project Area',
                                  definition: 'Total area of all plots in this project.',
                                  valueDisplay: '2,27,000 sq.ft',
                                ),
                                const FormulaTermDefinition(
                                  term: 'Actual Project Cost',
                                  definition: 'Purchase price plus all capitalized expenses.',
                                  valueDisplay: '₹2,27,00,000',
                                ),
                              ],
                              calculatedResultDisplay:
                                  CalculationEngine.formatCurrency(plot.allocatedCost),
                            ),
                          ],
                        ),
                        Text(
                          CalculationEngine.formatCurrency(plot.allocatedCost),
                          style: AppTypography.amountMedium.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Expected Sale Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Expected Sale Price:', style: AppTypography.body),
                        Text(
                          plot.expectedPrice > 0
                              ? CalculationEngine.formatCurrency(plot.expectedPrice)
                              : 'Not Set (₹0)',
                          style: AppTypography.amountMedium.copyWith(
                            fontSize: 15,
                            color: plot.expectedPrice > 0 ? AppColors.successText : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Estimated Profit & Cost / Price per Sq Ft
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSubMetric(
                          label: 'Cost per Sq. Ft.',
                          value: '₹${costPerSqFt.toStringAsFixed(1)} / sq.ft',
                        ),
                        _buildSubMetric(
                          label: 'Expected Price / Sq. Ft.',
                          value: '₹${expectedPricePerSqFt.toStringAsFixed(1)} / sq.ft',
                        ),
                        _buildSubMetric(
                          label: 'Estimated Net Profit',
                          value: plot.expectedPrice > 0
                              ? CalculationEngine.formatCurrency(expectedProfit)
                              : 'N/A',
                          valueColor: expectedProfit >= 0 ? AppColors.successText : AppColors.dangerText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Metadata Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created Date: $formattedDate',
                    style: AppTypography.secondary.copyWith(fontSize: 12),
                  ),
                  Text(
                    'Measurement Unit Mode: ${plot.measurementUnit}',
                    style: AppTypography.secondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Close Action Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.secondary.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCell(String unitLabel, String unitValue) {
    return Column(
      children: [
        Text(
          unitLabel,
          style: AppTypography.secondary.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          unitValue,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildSubMetric({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.secondary.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
