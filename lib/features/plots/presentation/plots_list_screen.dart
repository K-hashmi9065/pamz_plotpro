import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/utils/land_unit_converter.dart';
import '../../../core/widgets/formula_explainability_dialog.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../projects/presentation/projects_providers.dart';
import 'plots_providers.dart';
import 'widgets/plot_details_dialog.dart';
import 'widgets/plot_subdivision_dialog.dart';

final plotsSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final plotsStatusFilterProvider = StateProvider.autoDispose<PlotStatus?>((ref) => null);
final plotsSelectedProjectIdProvider = StateProvider.autoDispose<String?>((ref) => null);

class PlotsListScreen extends ConsumerWidget {
  const PlotsListScreen({super.key});

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

  String _formatSqFt(double sqFt, String unit) {
    if (sqFt <= 0) return '0 $unit';
    if (unit.toLowerCase().contains('katta') || unit.toLowerCase().contains('kattha')) {
      final totalKatta = sqFt / LandUnitConverter.sqFtPerKatta;
      final kd = LandUnitConverter.sqFtToKattaDhur(sqFt);
      final kattaStr = totalKatta == totalKatta.roundToDouble()
          ? totalKatta.toInt().toString()
          : double.parse(totalKatta.toStringAsFixed(2)).toString().replaceAll(RegExp(r'\.0+$'), '');
      if (kd.dhur > 0 && totalKatta != totalKatta.roundToDouble()) {
        return '$kattaStr Kattha (${kd.katta}K ${kd.dhur}D)';
      }
      return '$kattaStr Kattha';
    }
    return LandUnitConverter.formatLandMeasurement(areaSqFt: sqFt, measurementUnit: unit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(plotsSearchQueryProvider);
    final statusFilter = ref.watch(plotsStatusFilterProvider);
    final selectedProjectId = ref.watch(plotsSelectedProjectIdProvider);

    final currentRole = ref.watch(currentRoleProvider);
    final plotsAsync = ref.watch(plotsListStreamProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Parent Land & Plot Subdivision',
          subtitle:
              'Subdivide parent land into plots, allocate project cost, and manage plot availability.',
          icon: Icons.grid_view_outlined,
          actions: [
            if (currentRole.isAdmin)
              ElevatedButton.icon(
                onPressed: () => PlotSubdivisionDialog.show(
                  context,
                  preselectedProjectId: selectedProjectId,
                ),
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Subdivide Plot'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 260,
                height: 38,
                child: TextField(
                  onChanged: (val) => ref.read(plotsSearchQueryProvider.notifier).state = val,
                  decoration: const InputDecoration(
                    hintText: 'Search plot number...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: AppTypography.input.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),

              // Project Selector Dropdown
              projectsAsync.when(
                data: (projects) => Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedProjectId,
                      hint: Text('All Projects', style: AppTypography.secondary),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Projects'),
                        ),
                        ...projects.map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.name} (${p.code})'),
                            )),
                      ],
                      onChanged: (val) => ref.read(plotsSelectedProjectIdProvider.notifier).state = val,
                      style: AppTypography.body.copyWith(fontSize: 13),
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),

            // Status Filter Dropdown
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<PlotStatus?>(
                  value: statusFilter,
                  hint: Text('All Plot Statuses', style: AppTypography.secondary),
                  items: [
                    const DropdownMenuItem<PlotStatus?>(
                      value: null,
                      child: Text('All Plot Statuses'),
                    ),
                    ...PlotStatus.values.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase()),
                        )),
                  ],
                  onChanged: (val) => ref.read(plotsStatusFilterProvider.notifier).state = val,
                ),
              ),
            ),
          ],
        ),
      ),
        const SizedBox(height: 16),

        // Selected Project Land Breakdown Card
        if (selectedProjectId != null) ...[
          projectsAsync.when(
            data: (projects) {
              final selectedProject = projects.cast<dynamic>().firstWhere(
                    (p) => p.id == selectedProjectId,
                    orElse: () => null,
                  );
              if (selectedProject == null) return const SizedBox.shrink();

              final allPlots = plotsAsync.value ?? [];
              final projectPlots = allPlots.where((p) => p.projectId == selectedProjectId).toList();
              final double totalLandSqFt = selectedProject.landAreaSqFt;
              final double plottedSqFt = projectPlots.fold(0.0, (sum, p) => sum + p.areaSqFt);
              final double remainingSqFt = (totalLandSqFt - plottedSqFt).clamp(0.0, double.infinity);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
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
                          Row(
                            children: [
                              Text(
                                selectedProject.name,
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              Text(' (${selectedProject.code})', style: AppTypography.secondary),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Total Land: ${_formatSqFt(totalLandSqFt, selectedProject.measurementUnit)}',
                                style: AppTypography.secondary.copyWith(fontSize: 12),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Plotted Area: ${_formatSqFt(plottedSqFt, selectedProject.measurementUnit)} (${projectPlots.length} plots)',
                                style: AppTypography.secondary.copyWith(fontSize: 12),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Remaining Unallocated Land: ${_formatSqFt(remainingSqFt, selectedProject.measurementUnit)}',
                                style: AppTypography.body.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: remainingSqFt > 0 ? AppColors.successText : AppColors.warningText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      onPressed: () => PlotSubdivisionDialog.show(
                        context,
                        preselectedProjectId: selectedProjectId,
                      ),
                      icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                      label: const Text('Subdivide Land into Plot'),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],

        // Plots Data Table
        Expanded(
          child: plotsAsync.when(
            loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Center(
              child: Text(
                'Error loading plots: $err',
                style: AppTypography.body.copyWith(color: AppColors.dangerText),
              ),
            ),
            data: (plotsList) {
              final filtered = plotsList.where((p) {
                if (selectedProjectId != null && p.projectId != selectedProjectId) {
                  return false;
                }
                if (statusFilter != null && p.status != statusFilter) {
                  return false;
                }
                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  return p.plotNumber.toLowerCase().contains(q);
                }
                return true;
              }).toList();

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Plot Number', width: 130),
                  DataTableColumn(label: 'Plot Area', width: 130),
                  DataTableColumn(label: 'Allocated Cost', width: 180),
                  DataTableColumn(label: 'Expected Price', width: 160),
                  DataTableColumn(label: 'Status', width: 150),
                  DataTableColumn(label: 'Actions', width: 120, alignment: Alignment.center),
                ],
                rows: filtered.map((plot) {
                  return [
                    InkWell(
                      onTap: () => PlotDetailsDialog.show(context, plot),
                      borderRadius: BorderRadius.circular(4),
                      child: Text(
                        plot.plotNumber,
                        style: AppTypography.tableCell.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      plot.formattedArea,
                      style: AppTypography.tableCell,
                    ),
                    Row(
                      children: [
                        Text(
                          CalculationEngine.formatCurrency(plot.allocatedCost),
                          style: AppTypography.amountMedium.copyWith(fontSize: 14),
                        ),
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
                      CalculationEngine.formatCurrency(plot.expectedPrice),
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.successText,
                      ),
                    ),
                    StatusBadge(
                      label: plot.status.name.toUpperCase(),
                      type: _getBadgeType(plot.status),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 18),
                      tooltip: 'Plot Details',
                      onPressed: () => PlotDetailsDialog.show(context, plot),
                    ),
                  ];
                }).toList(),
                emptyMessage: selectedProjectId != null
                    ? 'No plots created yet for this project. Use "Subdivide Land into Plot" to create plots.'
                    : 'No plots created matching criteria.',
              );
            },
          ),
        ),
      ],
    );
  }
}
