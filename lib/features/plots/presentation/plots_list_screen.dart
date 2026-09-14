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
import 'widgets/add_brokerage_dialog.dart';
import 'widgets/brokerage_info_dialog.dart';
import 'widgets/plot_details_dialog.dart';
import 'widgets/plot_edit_dialog.dart';
import 'widgets/plot_subdivision_dialog.dart';
import 'widgets/road_creation_dialog.dart';
import '../domain/plot_model.dart';

final plotsSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final plotsStatusFilterProvider = StateProvider.autoDispose<PlotStatus?>((ref) => null);
final plotsSelectedProjectIdProvider = StateProvider.autoDispose<String?>((ref) => null);

class PlotsListScreen extends ConsumerWidget {
  const PlotsListScreen({super.key});

  Future<void> _handleDeletePlot(BuildContext context, WidgetRef ref, PlotModel plot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever_outlined, color: AppColors.dangerText, size: 24),
            const SizedBox(width: 8),
            Text('Confirm Delete Plot', style: AppTypography.cardTitle),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Plot #${plot.plotNumber}?\n\n'
          'The project cost allocation will automatically recalculate across all remaining plots.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerText),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Plot', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(plotsRepositoryProvider);
        await repo.deletePlot(plot.id, userId: 'admin_user');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plot #${plot.plotNumber} deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting plot: $e')),
          );
        }
      }
    }
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

  String _formatSqFt(double sqFt, String unit) {
    if (sqFt <= 0) return '0 $unit';
    if (unit.toLowerCase().contains('katta') || unit.toLowerCase().contains('kattha')) {
      final totalKatta = LandUnitConverter.sqFtToKatta(sqFt);
      final kattaStr = totalKatta == totalKatta.roundToDouble()
          ? totalKatta.toInt().toString()
          : double.parse(totalKatta.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
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
            if (currentRole.isAdmin) ...[
              OutlinedButton.icon(
                onPressed: () => RoadCreationDialog.show(
                  context,
                  preselectedProjectId: selectedProjectId,
                ),
                icon: const Icon(Icons.add_road, size: 18),
                label: const Text('Add Road'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => PlotSubdivisionDialog.show(
                  context,
                  preselectedProjectId: selectedProjectId,
                ),
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Subdivide Plot'),
              ),
            ],
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
              final sellablePlots = projectPlots.where((p) => !p.isRoad).toList();
              final roadPlots = projectPlots.where((p) => p.isRoad).toList();
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
                                'Plotted Area: ${_formatSqFt(plottedSqFt, selectedProject.measurementUnit)} (${sellablePlots.length} plots${roadPlots.isNotEmpty ? " + ${roadPlots.length} road" : ""})',
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
                  DataTableColumn(label: 'Plot Number', width: 120),
                  DataTableColumn(label: 'Plot Area', width: 120),
                  DataTableColumn(label: 'Brokerage Charge', width: 150),
                  DataTableColumn(label: 'Total Cost (Land + Exp.)', width: 180),
                  DataTableColumn(label: 'Sell Price', width: 130),
                  DataTableColumn(label: 'Profit / Loss', width: 140),
                  DataTableColumn(label: 'Status', width: 120),
                  DataTableColumn(label: 'Actions', width: 180, alignment: Alignment.center),
                ],
                rows: filtered.map((plot) {
                  final profitLoss = plot.expectedPrice - plot.allocatedCost;
                  final isProfit = profitLoss > 0;
                  final isLoss = profitLoss < 0;

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
                    plot.isRoad
                        ? Text('—', style: AppTypography.secondary)
                        : InkWell(
                            onTap: () => plot.hasBrokerage
                                ? BrokerageInfoDialog.show(context, plot)
                                : AddBrokerageDialog.show(context, plot),
                            borderRadius: BorderRadius.circular(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.handshake_outlined,
                                  size: 15,
                                  color: plot.hasBrokerage ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  plot.brokerageCharge > 0
                                      ? CalculationEngine.formatCurrency(plot.brokerageCharge)
                                      : 'Add Brokerage',
                                  style: AppTypography.tableCell.copyWith(
                                    color: plot.hasBrokerage ? AppColors.primary : AppColors.textSecondary,
                                    fontWeight: plot.hasBrokerage ? FontWeight.w600 : FontWeight.normal,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Row(
                      children: [
                        Text(
                          CalculationEngine.formatCurrency(plot.allocatedCost),
                          style: AppTypography.amountMedium.copyWith(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Builder(
                          builder: (context) {
                            final projectsList = projectsAsync.value ?? [];
                            final prj = projectsList.where((p) => p.id == plot.projectId).firstOrNull;
                            final totalArea = (prj != null && prj.landAreaSqFt > 0) ? prj.landAreaSqFt : plot.areaSqFt;
                            final double basePurchase = (prj != null && totalArea > 0)
                                ? (plot.areaSqFt / totalArea) * prj.purchasePrice
                                : 0.0;
                            final double totalExpenses = (prj != null)
                                ? (prj.actualCost - prj.purchasePrice).clamp(0.0, double.infinity)
                                : 0.0;
                            final double allocatedExpense = (totalArea > 0)
                                ? CalculationEngine.calculatePlotAllocatedExpense(
                                    plotAreaSqFt: plot.areaSqFt,
                                    totalProjectAreaSqFt: totalArea,
                                    totalProjectExpense: totalExpenses,
                                  )
                                : 0.0;
                            final double plotTotalExpense = CalculationEngine.calculatePlotTotalExpense(
                              allocatedExpense: allocatedExpense,
                              brokerageCharge: plot.brokerageCharge,
                            );

                            return FormulaInfoButton(
                              figureTitle: 'Plot Cost & Expense Allocation (${plot.plotNumber})',
                              plainWordsFormula:
                                  'Total Plot Cost = Base Land Cost + Area-wise Allocated Expenses + Direct Brokerage',
                              terms: [
                                FormulaTermDefinition(
                                  term: 'Plot Area',
                                  definition: 'Area of this specific plot in square feet.',
                                  valueDisplay: '${plot.areaSqFt.round()} sq.ft (${plot.formattedArea})',
                                ),
                                FormulaTermDefinition(
                                  term: 'Base Land Purchase Cost',
                                  definition: 'Proportionate base land acquisition cost allocated by area.',
                                  valueDisplay: CalculationEngine.formatCurrency(basePurchase),
                                ),
                                FormulaTermDefinition(
                                  term: 'Allocated Project Expense',
                                  definition: 'Area-wise division of master project expenses across plots.',
                                  valueDisplay: CalculationEngine.formatCurrency(allocatedExpense),
                                ),
                                FormulaTermDefinition(
                                  term: 'Plot Brokerage Charge',
                                  definition: 'Direct brokerage commission recorded for this plot.',
                                  valueDisplay: CalculationEngine.formatCurrency(plot.brokerageCharge),
                                ),
                                FormulaTermDefinition(
                                  term: 'Plot Total Expense',
                                  definition: 'Allocated Project Expense + Direct Plot Brokerage Charge.',
                                  valueDisplay: CalculationEngine.formatCurrency(plotTotalExpense),
                                ),
                              ],
                              calculatedResultDisplay:
                                  CalculationEngine.formatCurrency(plot.allocatedCost),
                            );
                          },
                        ),
                      ],
                    ),
                    plot.isRoad
                        ? Text('—', style: AppTypography.secondary)
                        : Text(
                            CalculationEngine.formatCurrency(plot.expectedPrice),
                            style: AppTypography.amountMedium.copyWith(
                              fontSize: 14,
                              color: AppColors.successText,
                            ),
                          ),
                    plot.isRoad
                        ? Text('—', style: AppTypography.secondary)
                        : Text(
                            profitLoss == 0
                                ? '₹0'
                                : '${isProfit ? '+' : ''}${CalculationEngine.formatCurrency(profitLoss)}',
                            style: AppTypography.amountMedium.copyWith(
                              color: isProfit
                                  ? AppColors.successText
                                  : isLoss
                                      ? AppColors.dangerText
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                    plot.isRoad
                        ? Text('—', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary))
                        : StatusBadge(
                            label: plot.status.name.toUpperCase(),
                            type: _getBadgeType(plot.status),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.handshake_outlined, size: 17, color: AppColors.accent),
                          tooltip: 'Add Brokerage Charge',
                          onPressed: () => AddBrokerageDialog.show(
                            context,
                            plot,
                          ),
                        ),
                        if (currentRole.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.accent),
                            tooltip: 'Edit Plot',
                            onPressed: () => PlotEditDialog.show(context, plot),
                          ),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 17),
                          tooltip: 'Plot Details',
                          onPressed: () => PlotDetailsDialog.show(context, plot),
                        ),
                        if (currentRole.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.dangerText),
                            tooltip: 'Delete Plot',
                            onPressed: () => _handleDeletePlot(context, ref, plot),
                          ),
                      ],
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
