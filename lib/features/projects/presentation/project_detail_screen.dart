import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../core/utils/land_unit_converter.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../audit_log/presentation/audit_log_screen.dart';
import '../../buyers_sales/domain/buyer_model.dart';
import '../../buyers_sales/presentation/sales_providers.dart';
import '../../buyers_sales/presentation/widgets/buyer_form_dialog.dart';
import '../../buyers_sales/presentation/widgets/buyer_sale_pdf_dialog.dart';
import '../../buyers_sales/presentation/widgets/sale_agreement_dialog.dart';

import '../../dashboard/presentation/dashboard_providers.dart';
import '../../expenses/presentation/expenses_providers.dart';
import '../../expenses/presentation/widgets/expense_form_dialog.dart';
import '../../installments_payments/presentation/installments_providers.dart';
import '../../investors/domain/project_investor_model.dart';
import '../../investors/presentation/investors_providers.dart';
import '../../investors/presentation/widgets/investor_agreement_pdf_dialog.dart';
import '../../investors/presentation/widgets/investor_form_dialog.dart';
import '../../investors/presentation/widgets/investor_withdrawal_history_dialog.dart';
import '../../investors/presentation/widgets/investor_withdrawal_selection_dialog.dart';
import '../../investors/presentation/widgets/project_investment_dialog.dart';
import '../../landowners/presentation/landowners_providers.dart';
import '../../landowners/presentation/widgets/agreement_pdf_dialog.dart';
import '../../landowners/presentation/widgets/landowner_payment_dialog.dart';
import '../../landowners/presentation/widgets/landowner_payment_history_dialog.dart';
import '../../plots/presentation/plots_providers.dart';
import '../../plots/presentation/widgets/add_brokerage_dialog.dart';
import '../../plots/presentation/widgets/brokerage_info_dialog.dart';
import '../../plots/presentation/widgets/plot_details_dialog.dart';
import '../../plots/presentation/widgets/plot_subdivision_dialog.dart';
import '../../plots/presentation/widgets/road_creation_dialog.dart';
import '../../profit_loss_settlement/domain/profit_loss_models.dart';
import '../../profit_loss_settlement/presentation/profit_loss_providers.dart';
import '../../profit_loss_settlement/presentation/widgets/payout_disbursement_dialog.dart';
import '../domain/project_model.dart';
import 'projects_providers.dart';
import 'widgets/project_form_dialog.dart';
import 'widgets/project_overview_pdf_dialog.dart';

final projectDetailTabProvider = StateProvider.autoDispose.family<int, String>(
  (ref, projectId) => 0,
);

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  Future<void> _handleDeleteProject(
    BuildContext context,
    WidgetRef ref,
    ProjectModel project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.delete_forever_outlined,
              color: AppColors.dangerText,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('Confirm Delete Project', style: AppTypography.cardTitle),
          ],
        ),
        content: Text(
          'Are you sure you want to delete project "${project.name}" (${project.code})?\n\n'
          'WARNING: This will delete the project and all mapped plots, expenses, and agreements for this project.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerText,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete Project',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(projectsRepositoryProvider);
        await repo.deleteProject(
          project.id,
          userId: 'admin_user',
          cascade: true,
        );
        if (context.mounted) {
          Navigator.of(context).maybePop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Project "${project.name}" deleted successfully!'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting project: $e')));
        }
      }
    }
  }

  static Future<void> showAsDialog(BuildContext context, String projectId) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
        backgroundColor: AppColors.background,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SizedBox(
          width: 1180,
          height: 820,
          child: ProjectDetailScreen(projectId: projectId),
        ),
      ),
    );
  }

  BadgeType _getBadgeType(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
      case ProjectStatus.purchased:
      case ProjectStatus.closed:
        return BadgeType.success;
      case ProjectStatus.draft:
      case ProjectStatus.negotiation:
      case ProjectStatus.purchasePending:
      case ProjectStatus.funding:
        return BadgeType.warning;
      case ProjectStatus.cancelled:
        return BadgeType.danger;
      default:
        return BadgeType.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(projectDetailTabProvider(projectId));
    final projectAsync = ref.watch(projectDetailStreamProvider(projectId));
    final currentRole = ref.watch(currentRoleProvider);
    final plotsAsync = ref.watch(projectPlotsStreamProvider(projectId));
    final pnlListAsync = ref.watch(projectProfitLossStreamProvider);

    return projectAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          'Error loading project details: $err',
          style: const TextStyle(color: AppColors.dangerText),
        ),
      ),
      data: (project) {
        if (project == null) {
          return const Center(child: Text('Project not found.'));
        }

        double soldAreaSqFt = 0.0;
        double roadAreaSqFt = 0.0;
        int availPlots = 0;
        int bookedPlots = 0;
        int soldPlots = 0;
        int totalPlots = 0;
        int roadCount = 0;

        plotsAsync.whenData((plots) {
          for (final plot in plots) {
            if (plot.isRoad) {
              roadCount++;
              roadAreaSqFt += plot.areaSqFt;
              continue; // Road is non-sellable corridor, not counted as a marketable plot
            }
            totalPlots++;
            if (plot.status == PlotStatus.available) {
              availPlots++;
            } else if (plot.status == PlotStatus.booked ||
                plot.status == PlotStatus.reserved) {
              bookedPlots++;
              soldAreaSqFt += plot.areaSqFt;
            } else if (plot.status == PlotStatus.cancelled) {
              // ignore
            } else {
              soldPlots++;
              soldAreaSqFt += plot.areaSqFt;
            }
          }
        });

        final remainingAreaSqFt =
            (project.landAreaSqFt - soldAreaSqFt - roadAreaSqFt).clamp(
              0.0,
              double.infinity,
            );

        final totalKatta = LandUnitConverter.sqFtToKatta(project.landAreaSqFt);
        final totalKattaStr = totalKatta == totalKatta.roundToDouble()
            ? totalKatta.toInt().toString()
            : double.parse(totalKatta.toStringAsFixed(1))
                  .toString()
                  .replaceAll(RegExp(r'0+$'), '')
                  .replaceAll(RegExp(r'\.$'), '');
        final soldKatta = LandUnitConverter.sqFtToKatta(soldAreaSqFt);
        final soldKattaStr = soldKatta == soldKatta.roundToDouble()
            ? soldKatta.toInt().toString()
            : double.parse(soldKatta.toStringAsFixed(1))
                  .toString()
                  .replaceAll(RegExp(r'0+$'), '')
                  .replaceAll(RegExp(r'\.$'), '');
        final remKatta = LandUnitConverter.sqFtToKatta(remainingAreaSqFt);
        final remKattaStr = remKatta == remKatta.roundToDouble()
            ? remKatta.toInt().toString()
            : double.parse(remKatta.toStringAsFixed(1))
                  .toString()
                  .replaceAll(RegExp(r'0+$'), '')
                  .replaceAll(RegExp(r'\.$'), '');

        final expensesAsync = ref.watch(projectExpensesStreamProvider(projectId));
        double totalCapitalizedExpenses = 0.0;
        expensesAsync.whenData((expenses) {
          for (final exp in expenses) {
            if (exp.isCapitalized) {
              totalCapitalizedExpenses += exp.amount;
            }
          }
        });
        final realActualCost = project.purchasePrice + totalCapitalizedExpenses;

        ProjectProfitLossModel? projectPnl;
        pnlListAsync.whenData((pnlList) {
          projectPnl = pnlList.firstWhere(
            (p) => p.projectId == project.id,
            orElse: () => ProjectProfitLossModel(
              projectId: project.id,
              projectName: project.name,
              totalAgreedSales: 0,
              directSaleExpenses: 0,
              actualProjectCost: realActualCost,
              cashCollected: 0,
            ),
          );
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar: Title, Back button, Status
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                project.code,
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                project.name,
                                style: AppTypography.cardTitle,
                              ),
                              const SizedBox(width: 12),
                              StatusBadge(
                                label: project.status.name.toUpperCase(),
                                type: _getBadgeType(project.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                project.location,
                                style: AppTypography.secondary,
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Landowner: ${project.landownerName ?? "Not Assigned"}',
                                style: AppTypography.secondary.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (currentRole.isAdmin && !project.isClosed) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text(
                          'Edit Project',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => ProjectFormDialog.show(
                          context,
                          projectToEdit: project,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.dangerText,
                          size: 20,
                        ),
                        tooltip: 'Delete Project',
                        onPressed: () =>
                            _handleDeleteProject(context, ref, project),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Comprehensive Project Financials & Land Summary Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricItem(
                        label: 'Total Land Bought',
                        value:
                            '${CalculationEngine.indianNumberFormat.format(project.landAreaSqFt.round())} Sq.Ft.',
                        subValue: '($totalKattaStr Kattha)',
                      ),
                      _MetricItem(
                        label: 'Land Sold Area',
                        value:
                            '${CalculationEngine.indianNumberFormat.format(soldAreaSqFt.round())} Sq.Ft.',
                        subValue: '($soldKattaStr Kattha)',
                        valueColor: AppColors.successText,
                      ),
                      _MetricItem(
                        label: 'Remaining Land',
                        value:
                            '${CalculationEngine.indianNumberFormat.format(remainingAreaSqFt.round())} Sq.Ft.',
                        subValue: '($remKattaStr Kattha)',
                        valueColor: AppColors.accent,
                      ),
                      _MetricItem(
                        label: 'Plots Breakdown',
                        value:
                            '$availPlots Avail | $bookedPlots Booked | $soldPlots Sold',
                        subValue: roadCount > 0
                            ? 'Total $totalPlots Plots ($roadCount Road${roadCount > 1 ? "s" : ""})'
                            : 'Total $totalPlots Plots',
                      ),
                      _MetricItem(
                        label: 'Total Income',
                        value: CalculationEngine.formatCurrency(
                          projectPnl?.totalAgreedSales ?? 0.0,
                        ),
                        subValue:
                            'Collected: ${CalculationEngine.formatCurrency(projectPnl?.cashCollected ?? 0.0)}',
                        valueColor: AppColors.orangeText,
                      ),
                      _MetricItem(
                        label: 'Actual Cost',
                        value: CalculationEngine.formatCurrency(
                          realActualCost,
                        ),
                        subValue: 'Purchase + Expenses',
                        valueColor: AppColors.warningText,
                      ),
                      _MetricItem(
                        label: 'Net Project Profit',
                        value: CalculationEngine.formatCurrency(
                          (projectPnl?.totalAgreedSales ?? 0.0) > 0
                              ? ((projectPnl?.totalAgreedSales ?? 0.0) - realActualCost)
                              : ((projectPnl?.cashCollected ?? 0.0) - realActualCost),
                        ),
                        subValue:
                            ((projectPnl?.totalAgreedSales ?? 0.0) - realActualCost) >= 0
                            ? (((projectPnl?.cashCollected ?? 0.0) - realActualCost) >= 0
                                ? 'Realized Cash Profit'
                                : 'Agreed Profit (Recovery in progress)')
                            : 'Cost Recovery Pending',
                        valueColor:
                            ((projectPnl?.totalAgreedSales ?? 0.0) - realActualCost) >= 0
                            ? AppColors.successText
                            : AppColors.dangerText,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Navigation Tabs
                DefaultTabController(
                  length: 7,
                  initialIndex: selectedTabIndex,
                  child: TabBar(
                    dividerColor: AppColors.border,
                    dividerHeight: 1,
                    onTap: (index) =>
                        ref
                                .read(
                                  projectDetailTabProvider(projectId).notifier,
                                )
                                .state =
                            index,
                    isScrollable: true,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.accent,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.info_outline, size: 18),
                        text: 'Overview & Land',
                      ),
                      Tab(
                        icon: Icon(Icons.grid_view_outlined, size: 18),
                        text: 'Plots Directory',
                      ),
                      Tab(
                        icon: Icon(Icons.people_outline, size: 18),
                        text: 'Customers',
                      ),
                      Tab(
                        icon: Icon(Icons.pie_chart_outline, size: 18),
                        text: 'Investors',
                      ),
                      Tab(
                        icon: Icon(Icons.real_estate_agent_outlined, size: 18),
                        text: 'Landowner',
                      ),
                      Tab(
                        icon: Icon(Icons.receipt_long_outlined, size: 18),
                        text: 'Expenses',
                      ),
                      Tab(
                        icon: Icon(Icons.monetization_on_outlined, size: 18),
                        text: 'Profit & Loss',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tab View Contents with Smooth Animation
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    reverseDuration: const Duration(milliseconds: 160),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topLeft,
                        children: <Widget>[
                          ...previousChildren,
                          ?currentChild,
                        ],
                      );
                    },
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOutCubic,
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.01),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                    child: KeyedSubtree(
                      key: ValueKey(selectedTabIndex),
                      child: _buildDetailTabContent(
                        selectedTabIndex,
                        project,
                        currentRole.isAdmin,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTabContent(
    int tabIndex,
    ProjectModel project,
    bool isAdmin,
  ) {
    switch (tabIndex) {
      case 0:
        return _OverviewTab(project: project);
      case 1:
        return _PlotsTab(projectId: project.id);
      case 2:
        return _BuyersSalesTab(projectId: project.id);
      case 3:
        return _InvestorsTab(project: project, isAdmin: isAdmin);
      case 4:
        return _LandownerTab(project: project);
      case 5:
        return _ExpensesTab(projectId: project.id);
      case 6:
      default:
        return _ProfitLossTab(projectId: project.id);
    }
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color? valueColor;

  const _MetricItem({
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.secondary.copyWith(fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        if (subValue != null)
          Text(
            subValue!,
            style: AppTypography.secondary.copyWith(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final ProjectModel project;

  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotsAsync = ref.watch(projectPlotsStreamProvider(project.id));
    final pnlListAsync = ref.watch(projectProfitLossStreamProvider);
    final expensesAsync = ref.watch(projectExpensesStreamProvider(project.id));

    final totalKatta = LandUnitConverter.sqFtToKatta(project.landAreaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(1))
              .toString()
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Project Master Information & Land Breakdown',
                    style: AppTypography.sectionTitle,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text(
                    'Export / Share PDF',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    ProjectOverviewPdfDialog.show(
                      context,
                      project: project,
                      plots: plotsAsync.valueOrNull ?? [],
                      expenses: expensesAsync.valueOrNull ?? [],
                      pnlList: pnlListAsync.valueOrNull ?? [],
                    );
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            _infoRow('Project Code:', project.code),
            _infoRow('Project Name:', project.name),
            _infoRow('Location:', project.location),
            _infoRow('Landowner:', project.landownerName ?? 'Not Assigned'),
            Builder(
              builder: (context) {
                final bool hasDimensions = project.lengthFt != null &&
                    project.breadthFt != null &&
                    (project.lengthFt! > 0 || project.breadthFt! > 0);
                final double calculatedSqFt = hasDimensions
                    ? LandUnitConverter.dimensionsToSqFt(
                        lengthFt: project.lengthFt!,
                        lengthIn: project.lengthIn ?? 0.0,
                        breadthFt: project.breadthFt!,
                        breadthIn: project.breadthIn ?? 0.0,
                      )
                    : 0.0;
                final String calculatedAreaText = hasDimensions
                    ? '${CalculationEngine.indianNumberFormat.format(calculatedSqFt.round())} Sq. Ft. (${project.lengthFt?.toInt() ?? 0} ft ${project.lengthIn?.toInt() ?? 0} in × ${project.breadthFt?.toInt() ?? 0} ft ${project.breadthIn?.toInt() ?? 0} in)'
                    : 'NA';

                final bool hasActualArea =
                    project.displayArea != null && project.displayArea! > 0;
                final String actualAreaText = hasActualArea
                    ? '${CalculationEngine.indianNumberFormat.format(project.landAreaSqFt.round())} Sq. Ft. ($totalKattaStr Kattha)'
                    : 'NA';

                return Column(
                  children: [
                    _infoRow(
                      'Calculated Area (L × B):',
                      calculatedAreaText,
                      valueColor: hasDimensions ? AppColors.accent : AppColors.textSecondary,
                    ),
                    _infoRow(
                      'Actual Area (Registered):',
                      actualAreaText,
                      valueColor: hasActualArea ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ],
                );
              },
            ),

            plotsAsync.when(
              data: (plots) {
                double soldAreaSqFt = 0.0;
                double roadAreaSqFt = 0.0;
                int availCount = 0;
                int bookedCount = 0;
                int soldCount = 0;
                int totalPlotCount = 0;
                int roadCount = 0;

                for (final plot in plots) {
                  if (plot.isRoad) {
                    roadCount++;
                    roadAreaSqFt += plot.areaSqFt;
                    continue; // Skip roads from sellable plot count
                  }
                  totalPlotCount++;
                  if (plot.status == PlotStatus.available) {
                    availCount++;
                  } else if (plot.status == PlotStatus.booked ||
                      plot.status == PlotStatus.reserved) {
                    bookedCount++;
                    soldAreaSqFt += plot.areaSqFt;
                  } else if (plot.status == PlotStatus.cancelled) {
                    // ignore
                  } else {
                    soldCount++;
                    soldAreaSqFt += plot.areaSqFt;
                  }
                }

                final remainingAreaSqFt =
                    (project.landAreaSqFt - soldAreaSqFt - roadAreaSqFt).clamp(
                      0.0,
                      double.infinity,
                    );
                final soldKatthaStr = LandUnitConverter.sqFtToKatta(
                  soldAreaSqFt,
                ).toStringAsFixed(2);
                final remKatthaStr = LandUnitConverter.sqFtToKatta(
                  remainingAreaSqFt,
                ).toStringAsFixed(2);
                final roadKatthaStr = LandUnitConverter.sqFtToKatta(
                  roadAreaSqFt,
                ).toStringAsFixed(2);

                return Column(
                  children: [
                    _infoRow(
                      'Land Sold Area:',
                      '${CalculationEngine.indianNumberFormat.format(soldAreaSqFt.round())} Sq. Ft. ($soldKatthaStr Kattha)',
                      valueColor: AppColors.successText,
                    ),
                    if (roadAreaSqFt > 0)
                      _infoRow(
                        'Road / Pathway Area:',
                        '${CalculationEngine.indianNumberFormat.format(roadAreaSqFt.round())} Sq. Ft. ($roadKatthaStr Kattha) [$roadCount Road${roadCount > 1 ? "s" : ""}]',
                        valueColor: AppColors.textSecondary,
                      ),
                    _infoRow(
                      'Remaining Available Land:',
                      '${CalculationEngine.indianNumberFormat.format(remainingAreaSqFt.round())} Sq. Ft. ($remKatthaStr Kattha)',
                      valueColor: AppColors.accent,
                    ),
                    _infoRow(
                      'Plot Inventory Summary:',
                      '$availCount Available | $bookedCount Booked | $soldCount Sold ($totalPlotCount Total Plots)',
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),

            expensesAsync.when(
              data: (expenses) {
                final totalExpenseAmount = expenses.fold(
                  0.0,
                  (sum, e) => sum + e.amount,
                );
                final capitalizedExpenseAmount = expenses
                    .where((e) => e.isCapitalized)
                    .fold(0.0, (sum, e) => sum + e.amount);
                final realActualCost =
                    project.purchasePrice + capitalizedExpenseAmount;

                final pnl = pnlListAsync.valueOrNull?.firstWhere(
                  (p) => p.projectId == project.id,
                  orElse: () => ProjectProfitLossModel(
                    projectId: project.id,
                    projectName: project.name,
                    totalAgreedSales: 0,
                    directSaleExpenses: 0,
                    actualProjectCost: realActualCost,
                    cashCollected: 0,
                  ),
                );

                final cashCollected = pnl?.cashCollected ?? 0.0;
                final totalAgreedSales = pnl?.totalAgreedSales ?? 0.0;
                final netCashProfit = cashCollected - realActualCost;

                return Column(
                  children: [
                    _infoRow(
                      'Total Income (Sales Revenue):',
                      CalculationEngine.formatCurrency(totalAgreedSales),
                      valueColor: AppColors.orangeText,
                    ),
                    _infoRow(
                      'Cash Collected (Realized Income):',
                      CalculationEngine.formatCurrency(cashCollected),
                      valueColor: AppColors.successText,
                    ),
                    _infoRow(
                      'Actual Cost:',
                      CalculationEngine.formatCurrency(realActualCost),
                      valueColor: AppColors.warningText,
                    ),
                    _infoRow(
                      'Project Net Profit (Cash Collected − Actual Cost):',
                      CalculationEngine.formatCurrency(netCashProfit),
                      valueColor: netCashProfit >= 0
                          ? AppColors.successText
                          : AppColors.dangerText,
                    ),
                    _infoRow(
                      'Total Expense:',
                      CalculationEngine.formatCurrency(totalExpenseAmount),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),

            _infoRow(
              'Land Purchase Price:',
              CalculationEngine.formatCurrency(project.purchasePrice),
            ),
            _infoRow(
              'Description:',
              project.description ?? 'No description provided.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: Text(label, style: AppTypography.secondary),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlotsTab extends ConsumerWidget {
  final String projectId;

  const _PlotsTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotsAsync = ref.watch(projectPlotsStreamProvider(projectId));
    final projectAsync = ref.watch(projectDetailStreamProvider(projectId));
    final project = projectAsync.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Plots Directory & Inventory Status',
              style: AppTypography.sectionTitle,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => RoadCreationDialog.show(
                    context,
                    preselectedProjectId: projectId,
                  ),
                  icon: const Icon(Icons.add_road, size: 16),
                  label: const Text('Add Road'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => PlotSubdivisionDialog.show(
                    context,
                    preselectedProjectId: projectId,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add / Subdivide Plot'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (project != null) ...[
          plotsAsync.when(
            data: (plots) {
              final roadPlots = plots.where((p) => p.isRoad).toList();
              if (roadPlots.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.alt_route_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Project Access Road & Corridors (${roadPlots.length})',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...roadPlots.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '• ${r.plotNumber}:',
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dimensions (L × B): ${r.formattedLength} × ${r.formattedBreadth}',
                              style: AppTypography.secondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Area: ${r.formattedArea}',
                              style: AppTypography.secondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Cost: ${CalculationEngine.formatCurrency(r.allocatedCost)}',
                              style: AppTypography.amountMedium.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],

        Expanded(
          child: plotsAsync.when(
            loading: () =>
                const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Text('Error loading project plots: $err'),
            data: (plots) {
              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Plot No.', width: 120),
                  DataTableColumn(label: 'Plot Area', width: 120),
                  DataTableColumn(label: 'Brokerage Charge', width: 150),
                  DataTableColumn(label: 'Total Cost (Land + Exp.)', width: 175),
                  DataTableColumn(label: 'Sell Price', width: 130),
                  DataTableColumn(label: 'Profit / Loss', width: 140),
                  DataTableColumn(label: 'Status', width: 120),
                  DataTableColumn(
                    label: 'Actions',
                    width: 140,
                    alignment: Alignment.center,
                  ),
                ],
                rows: plots.map((p) {
                  final profitLoss = p.expectedPrice - p.allocatedCost;
                  final isProfit = profitLoss > 0;
                  final isLoss = profitLoss < 0;

                  return [
                    InkWell(
                      onTap: () => PlotDetailsDialog.show(context, p),
                      borderRadius: BorderRadius.circular(4),
                      child: Text(
                        p.plotNumber,
                        style: AppTypography.tableCell.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(p.formattedArea, style: AppTypography.tableCell),
                    p.isRoad
                        ? Text('—', style: AppTypography.secondary)
                        : InkWell(
                            onTap: () => p.hasBrokerage
                                ? BrokerageInfoDialog.show(context, p)
                                : AddBrokerageDialog.show(context, p),
                            borderRadius: BorderRadius.circular(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.handshake_outlined,
                                  size: 15,
                                  color: p.hasBrokerage ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  p.brokerageCharge > 0
                                      ? CalculationEngine.formatCurrency(p.brokerageCharge)
                                      : 'Add Brokerage',
                                  style: AppTypography.tableCell.copyWith(
                                    color: p.hasBrokerage ? AppColors.primary : AppColors.textSecondary,
                                    fontWeight: p.hasBrokerage ? FontWeight.w600 : FontWeight.normal,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Text(
                      CalculationEngine.formatCurrency(p.allocatedCost),
                      style: AppTypography.amountMedium,
                    ),
                    p.isRoad
                        ? Text('—', style: AppTypography.secondary)
                        : Text(
                            CalculationEngine.formatCurrency(p.expectedPrice),
                            style: AppTypography.amountMedium,
                          ),
                    p.isRoad
                        ? Text(
                            '—',
                            style: AppTypography.secondary,
                          )
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
                    p.isRoad
                        ? Text(
                            '—',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : StatusBadge(
                            label: p.status.name.toUpperCase(),
                            type: p.isAvailable
                                ? BadgeType.success
                                : (p.isSold
                                      ? BadgeType.info
                                      : BadgeType.warning),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.handshake_outlined,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          tooltip: 'Add Brokerage Charge',
                          onPressed: () => AddBrokerageDialog.show(
                            context,
                            p,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          tooltip: 'Plot Details',
                          onPressed: () => PlotDetailsDialog.show(context, p),
                        ),
                      ],
                    ),
                  ];
                }).toList(),
                emptyMessage:
                    'No plots mapped in this project yet. Click "Add / Subdivide Plot" to subdivide land.',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BuyersSalesTab extends ConsumerWidget {
  final String projectId;

  const _BuyersSalesTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesListStreamProvider);
    final installmentsAsync = ref.watch(installmentsListStreamProvider);
    final plotsAsync = ref.watch(projectPlotsStreamProvider(projectId));
    final auditLogsAsync = ref.watch(auditLogsStreamProvider);
    final buyersAsync = ref.watch(buyersListStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Customers & Sales Agreements',
              style: AppTypography.sectionTitle,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => BuyerFormDialog.show(context),
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Add Customer'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => SaleAgreementDialog.show(
                    context,
                    preselectedProjectId: projectId,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Record New Sale'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: salesAsync.when(
            loading: () =>
                const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Text('Error loading project sales: $err'),
            data: (allSales) {
              final projectSales = allSales
                  .where((s) => s.projectId == projectId)
                  .toList();
              final allInstallments = installmentsAsync.value ?? [];
              final allPlots = plotsAsync.value ?? [];
              final allLogs = auditLogsAsync.value ?? [];
              final allBuyers = buyersAsync.value ?? [];

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Customer Name'),
                  DataTableColumn(label: 'Plot ID', width: 130),
                  DataTableColumn(label: 'Sale Type', width: 130),
                  DataTableColumn(label: 'Agreed Price', width: 150),
                  DataTableColumn(label: 'Cash Paid', width: 150),
                  DataTableColumn(label: 'Remaining Dues', width: 160),
                  DataTableColumn(label: 'Sale Date', width: 130),
                  DataTableColumn(
                    label: 'Agreement PDF',
                    width: 130,
                    alignment: Alignment.center,
                  ),
                ],
                rows: projectSales.map((sale) {
                  final saleInsts = allInstallments
                      .where((i) => i.saleId == sale.id)
                      .toList();
                  final totalPaid = saleInsts.fold(
                    0.0,
                    (sum, i) => sum + i.paidAmount,
                  );
                  final remainingDues = (sale.agreedPrice - totalPaid).clamp(
                    0.0,
                    double.infinity,
                  );
                  final formattedDate = DateFormat(
                    'dd MMM yyyy',
                  ).format(sale.saleDate);

                  // Find linked plot(s) for this sale
                  final linkedPlotIds = <String>{};
                  for (final log in allLogs) {
                    if (log.entityType == 'Plot' &&
                        log.action == 'LINK_PLOT_SALE' &&
                        log.details.contains('SaleId:${sale.id}')) {
                      linkedPlotIds.add(log.entityId);
                    }
                  }

                  final matchedPlots = allPlots
                      .where((p) => linkedPlotIds.contains(p.id))
                      .toList();

                  // Fallback for single plot matching if audit log link not found
                  if (matchedPlots.isEmpty &&
                      sale.saleType != SaleType.wholeLand) {
                    final priceMatches = allPlots
                        .where(
                          (p) =>
                              !p.isRoad &&
                              (p.expectedPrice - sale.agreedPrice).abs() < 1.0,
                        )
                        .toList();
                    if (priceMatches.length == 1) {
                      matchedPlots.add(priceMatches.first);
                    }
                  }

                  final String plotDisplay;
                  if (sale.saleType == SaleType.wholeLand) {
                    plotDisplay = 'Whole Land';
                  } else if (matchedPlots.isNotEmpty) {
                    plotDisplay = matchedPlots
                        .map((p) => p.plotNumber)
                        .join(', ');
                  } else {
                    plotDisplay = '—';
                  }

                    final buyer = allBuyers.cast<BuyerModel?>().firstWhere(
                          (b) => b?.id == sale.buyerId,
                          orElse: () => null,
                        );

                    return [
                    Text(
                      sale.buyerName,
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    matchedPlots.length == 1
                        ? InkWell(
                            onTap: () => PlotDetailsDialog.show(
                              context,
                              matchedPlots.first,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            child: Text(
                              plotDisplay,
                              style: AppTypography.tableCell.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        : Text(
                            plotDisplay,
                            style: AppTypography.tableCell.copyWith(
                              fontWeight: FontWeight.w600,
                              color: plotDisplay == '—'
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                    Text(
                      sale.saleType.name.toUpperCase(),
                      style: AppTypography.tableCell.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(sale.agreedPrice),
                      style: AppTypography.amountMedium.copyWith(fontSize: 14),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(totalPaid),
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.successText,
                      ),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(remainingDues),
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        color: remainingDues > 0
                            ? AppColors.warningText
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(formattedDate, style: AppTypography.secondary),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          tooltip: 'Export / Share Customer Sale Agreement PDF',
                          onPressed: () {
                            final projectAsync = ref.read(
                              projectDetailStreamProvider(projectId),
                            );
                            final project = projectAsync.value;

                            BuyerSalePdfDialog.show(
                              context,
                              sale: sale,
                              buyer: buyer,
                              projectName: project?.name ?? 'Project',
                              projectCode: project?.code ?? 'PRJ',
                              projectLocation: project?.location ?? 'Location',
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          tooltip: 'Edit Customer Profile',
                          onPressed: () => BuyerFormDialog.show(
                            context,
                            buyer: buyer ??
                                BuyerModel(
                                  id: sale.buyerId,
                                  name: sale.buyerName,
                                  phone: '',
                                  createdAt: sale.saleDate,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ];
                }).toList(),
                emptyMessage: 'No buyer sales recorded for this project yet.',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InvestorsTab extends ConsumerWidget {
  final ProjectModel project;
  final bool isAdmin;

  const _InvestorsTab({required this.project, required this.isAdmin});

  double _getInvestorTotalWithdrawal(
    List<String> projectInvestorIds,
    String investorId,
    List<dynamic> logs,
  ) {
    double total = 0.0;
    final idsSet = projectInvestorIds.toSet();
    for (final log in logs) {
      if (log.action == 'DISBURSE_INVESTOR_PAYOUT' &&
          (idsSet.contains(log.entityId) ||
              idsSet.any((id) => log.details.contains(id)) ||
              log.details.contains(investorId))) {
        final match = RegExp(r'₹([0-9.,]+)').firstMatch(log.details);
        if (match != null) {
          final amtStr = match.group(1)!.replaceAll(',', '');
          total += double.tryParse(amtStr) ?? 0.0;
        }
      }
    }
    return total;
  }

  void _showAddWithdrawalDialog(
    BuildContext context,
    List<AggregatedProjectInvestorModel> aggregatedInvestors,
    List<dynamic> logs,
    double netProfitPool,
  ) {
    if (aggregatedInvestors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add an investor capital investment before recording a withdrawal.',
          ),
        ),
      );
      return;
    }

    final resolvedPayouts = aggregatedInvestors.map((agg) {
      final totalWithdrawn = _getInvestorTotalWithdrawal(
        agg.contributions.map((c) => c.id).toList(),
        agg.investorId,
        logs,
      );
      return InvestorPayoutModel(
        id: agg.primaryId,
        investorId: agg.investorId,
        investorName: agg.investorName,
        projectId: project.id,
        capitalInvested: agg.totalInvestedAmount,
        ownershipPercent: agg.totalOwnershipPercent,
        distributableProfitPool: netProfitPool > 0 ? netProfitPool : 0.0,
        payoutsDisbursed: totalWithdrawn,
      );
    }).toList();

    if (resolvedPayouts.length == 1) {
      PayoutDisbursementDialog.show(context, payout: resolvedPayouts.first);
      return;
    }

    final options = resolvedPayouts.map((p) {
      return InvestorWithdrawalOption(
        investorName: p.investorName,
        projectName: project.name,
        projectLocation: project.location,
        capitalInvested: p.capitalInvested,
        remainingPayoutBalance: p.remainingPayoutBalance,
        payout: p,
      );
    }).toList();

    InvestorWithdrawalSelectionDialog.show(
      context: context,
      options: options,
      preselectedInvestorName: null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isAdmin) {
      return const Center(
        child: Text('Investor details restricted to Admin only.'),
      );
    }

    final investorsAsync = ref.watch(
      projectInvestorsStreamProvider(project.id),
    );
    final allLogs = ref.watch(auditLogsStreamProvider).value ?? [];
    final pnlList = ref.watch(projectProfitLossStreamProvider).value ?? [];
    final projectExpenses =
        ref.watch(projectExpensesStreamProvider(project.id)).value ?? [];
    final double capitalizedExpenses = projectExpenses
        .where((e) => e.isCapitalized)
        .fold(0.0, (s, e) => s + e.amount);
    final double actualCost = project.purchasePrice + capitalizedExpenses;

    final pnl = pnlList.firstWhere(
      (p) => p.projectId == project.id,
      orElse: () => ProjectProfitLossModel(
        projectId: project.id,
        projectName: project.name,
        totalAgreedSales: 0,
        directSaleExpenses: 0,
        actualProjectCost: actualCost,
        cashCollected: 0,
      ),
    );
    final double netProfitPool = pnl.cashCollected - actualCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Investor Participations & Equity Capital',
              style: AppTypography.sectionTitle,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    final investors = investorsAsync.value ?? [];
                    final aggregated =
                        AggregatedProjectInvestorModel.aggregateList(investors);
                    _showAddWithdrawalDialog(
                      context,
                      aggregated,
                      allLogs,
                      netProfitPool,
                    );
                  },
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                  ),
                  label: const Text('Add Withdrawal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => ProjectInvestmentDialog.show(
                    context,
                    preselectedProjectId: project.id,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Capital Investment'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: investorsAsync.when(
            loading: () =>
                const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) =>
                Text('Error loading project investors: $err'),
            data: (investors) {
              final investorsList =
                  ref.watch(investorsListStreamProvider).value ?? [];
              final aggregatedInvestors =
                  AggregatedProjectInvestorModel.aggregateList(investors);

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Investor Name'),
                  DataTableColumn(label: 'Contributed Capital', width: 170),
                  DataTableColumn(label: 'Ownership %', width: 130),
                  DataTableColumn(label: 'Profit / Loss', width: 150),
                  DataTableColumn(label: 'Total Amount', width: 160),
                  DataTableColumn(label: 'Remaining Balance', width: 160),
                  DataTableColumn(label: 'Withdrawal', width: 150),
                  DataTableColumn(
                    label: 'Actions',
                    width: 150,
                    alignment: Alignment.center,
                  ),
                ],
                rows: aggregatedInvestors.map((agg) {
                  final fullInvestor = investorsList
                      .where((i) => i.id == agg.investorId)
                      .firstOrNull;
                  final double withdrawalAmt = _getInvestorTotalWithdrawal(
                    agg.contributions.map((c) => c.id).toList(),
                    agg.investorId,
                    allLogs,
                  );
                  final double investorProfit =
                      CalculationEngine.calculateInvestorProfitShare(
                    distributableProfit: netProfitPool,
                    ownershipPercent: agg.totalOwnershipPercent,
                  );
                  final double totalAmount =
                      agg.totalInvestedAmount + investorProfit;
                  final double remainingBalance =
                      (totalAmount - withdrawalAmt).clamp(0.0, double.infinity);

                  return [
                    Text(
                      agg.investorName,
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          CalculationEngine.formatCurrency(agg.totalInvestedAmount),
                          style: AppTypography.amountMedium,
                        ),
                        if (agg.contributions.length > 1)
                          Text(
                            '(${agg.contributions.length} investments)',
                            style: AppTypography.secondary.copyWith(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${agg.totalOwnershipPercent.toStringAsFixed(2)}%',
                      style: AppTypography.tableCell.copyWith(
                        color: AppColors.successText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      investorProfit >= 0
                          ? CalculationEngine.formatCurrency(investorProfit)
                          : '-${CalculationEngine.formatCurrency(investorProfit.abs())}',
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        color: investorProfit >= 0
                            ? AppColors.successText
                            : AppColors.dangerText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(totalAmount),
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(remainingBalance),
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: remainingBalance > 0
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        InvestorWithdrawalHistoryDialog.show(
                          context,
                          projectInvestor: agg.toPrimaryProjectInvestor(),
                          projectName: project.name,
                          projectCode: project.code,
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Tooltip(
                        message:
                            'Click to view withdrawal & contribution history for ${agg.investorName}',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CalculationEngine.formatCurrency(withdrawalAmt),
                              style: AppTypography.amountMedium.copyWith(
                                fontSize: 14,
                                color: withdrawalAmt > 0
                                    ? AppColors.warningText
                                    : AppColors.textSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.history,
                              size: 14,
                              color: withdrawalAmt > 0
                                    ? AppColors.warningText
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.history,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          tooltip: 'Withdrawal & Contribute History (${agg.investorName})',
                          onPressed: () {
                            InvestorWithdrawalHistoryDialog.show(
                              context,
                              projectInvestor: agg.toPrimaryProjectInvestor(),
                              projectName: project.name,
                              projectCode: project.code,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          tooltip: 'Generate / View Investor Agreement PDF',
                          onPressed: () {
                            InvestorAgreementPdfDialog.show(
                              context,
                              investorName: agg.investorName,
                              investorPhone: fullInvestor?.phone ?? '—',
                              investorPan: fullInvestor?.pan,
                              investorEmail: fullInvestor?.email,
                              projectName: project.name,
                              projectCode: project.code,
                              projectLocation: project.location,
                              projectLandAreaSqFt: project.landAreaSqFt,
                              investedAmount: agg.totalInvestedAmount,
                              ownershipPercent: agg.totalOwnershipPercent,
                              ownershipMethod: agg.contributions.first.ownershipMethod,
                              agreementDate: agg.firstInvestmentDate,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          tooltip: 'Edit Investor Profile',
                          onPressed: () => InvestorFormDialog.show(
                            context,
                            investor: fullInvestor,
                          ),
                        ),
                      ],
                    ),
                  ];
                }).toList(),
                emptyMessage: 'No investors added to this project yet.',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LandownerTab extends ConsumerWidget {
  final ProjectModel project;

  const _LandownerTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementsAsync = ref.watch(
      projectAgreementsStreamProvider(project.id),
    );
    final installmentsAsync = ref.watch(installmentsListStreamProvider);
    final landownersAsync = ref.watch(landownersListStreamProvider);

    final allInstallments = installmentsAsync.value ?? [];
    final allLandowners = landownersAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Associated Landowner', style: AppTypography.secondary),
                      Text(
                        project.landownerName ?? 'No Landowner Linked',
                        style: AppTypography.cardTitle,
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  LandownerPaymentDialog.show(
                    context,
                    project: project,
                  );
                },
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('Record Land Payment'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Land Purchase Agreements & Financial Terms',
          style: AppTypography.sectionTitle,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: agreementsAsync.when(
            loading: () =>
                const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Text('Error loading agreements: $err'),
            data: (agreements) {
              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Agreement Date', width: 140),
                  DataTableColumn(label: 'Total Purchase Price', width: 180),
                  DataTableColumn(label: 'Total Paid Amount', width: 170),
                  DataTableColumn(label: 'Remaining Balance', width: 170),
                  DataTableColumn(label: 'Status', width: 120),
                  DataTableColumn(
                    label: 'Payment History',
                    width: 140,
                    alignment: Alignment.center,
                  ),
                  DataTableColumn(
                    label: 'Agreement PDF',
                    width: 130,
                    alignment: Alignment.center,
                  ),
                ],
                rows: agreements.map((ag) {
                  final paInstallments = allInstallments
                      .where((i) => i.purchaseAgreementId == ag.id)
                      .toList();
                  final double totalPaid = paInstallments.fold(
                    0.0,
                    (sum, i) => sum + i.paidAmount,
                  );
                  final double remainingBalance = (ag.totalPrice - totalPaid)
                      .clamp(0.0, double.infinity);
                  final formattedDate =
                      DateFormat('dd MMM yyyy').format(ag.agreementDate);

                  final fullLandowner = allLandowners
                      .where((l) => l.id == ag.landownerId)
                      .firstOrNull;

                  return [
                    Text(
                      formattedDate,
                      style: AppTypography.tableCell,
                    ),
                    Text(
                      CalculationEngine.formatCurrency(ag.totalPrice),
                      style: AppTypography.amountMedium,
                    ),
                    InkWell(
                      onTap: () {
                        LandownerPaymentHistoryDialog.show(
                          context,
                          purchaseAgreement: ag,
                          project: project,
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Tooltip(
                        message: 'Click to view payment history',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CalculationEngine.formatCurrency(totalPaid),
                              style: AppTypography.amountMedium.copyWith(
                                fontSize: 14,
                                color: totalPaid > 0
                                    ? AppColors.successText
                                    : AppColors.textSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.history,
                              size: 14,
                              color: totalPaid > 0
                                  ? AppColors.successText
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(remainingBalance),
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: remainingBalance > 0
                            ? AppColors.warningText
                            : AppColors.textSecondary,
                      ),
                    ),
                    StatusBadge(label: ag.status, type: BadgeType.info),
                    IconButton(
                      icon: const Icon(
                        Icons.history,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      tooltip: 'Landowner Payment History',
                      onPressed: () {
                        LandownerPaymentHistoryDialog.show(
                          context,
                          purchaseAgreement: ag,
                          project: project,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      tooltip: 'Export Land Purchase Agreement PDF',
                      onPressed: () {
                        AgreementPdfDialog.show(
                          context,
                          landownerName: fullLandowner?.name ??
                              project.landownerName ??
                              'Landowner',
                          landownerPhone: fullLandowner?.phone ?? '—',
                          landownerPan: fullLandowner?.pan,
                          landownerEmail: fullLandowner?.email,
                          landownerAddress: fullLandowner?.address,
                          projectName: project.name,
                          projectCode: project.code,
                          projectLocation: project.location,
                          landAreaSqFt: project.landAreaSqFt,
                          totalPrice: ag.totalPrice,
                          installmentCount: paInstallments.isNotEmpty
                              ? paInstallments.length
                              : 5,
                          agreementDate: ag.agreementDate,
                        );
                      },
                    ),
                  ];
                }).toList(),
                emptyMessage:
                    'No purchase agreement recorded for this project yet.',
              );
            },
          ),
        ),
      ],
    );
  }
}

final expensesTabSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);
final expensesTabCategoryFilterProvider =
    StateProvider.autoDispose<ExpenseCategory?>((ref) => null);
final expensesTabDateRangeFilterProvider =
    StateProvider.autoDispose<DashboardDateRange>(
      (ref) => DashboardDateRange.allTime,
    );
final expensesTabCapitalizedFilterProvider = StateProvider.autoDispose<bool?>(
  (ref) => null,
);

class _ExpensesTab extends ConsumerWidget {
  final String projectId;

  const _ExpensesTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(expensesTabSearchQueryProvider);
    final categoryFilter = ref.watch(expensesTabCategoryFilterProvider);
    final dateRangeFilter = ref.watch(expensesTabDateRangeFilterProvider);
    final isCapitalizedFilter = ref.watch(expensesTabCapitalizedFilterProvider);

    final expensesAsync = ref.watch(projectExpensesStreamProvider(projectId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Project Expense Ledger & Cost Records',
              style: AppTypography.sectionTitle,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Project Expense'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => ExpenseFormDialog.show(
                context,
                preselectedProjectId: projectId,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 220,
                height: 38,
                child: TextField(
                  onChanged: (val) =>
                      ref.read(expensesTabSearchQueryProvider.notifier).state =
                          val,
                  decoration: const InputDecoration(
                    hintText: 'Search vendor, notes...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: AppTypography.input.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),

              // Category Dropdown Filter
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ExpenseCategory?>(
                    value: categoryFilter,
                    hint: Text(
                      'All Categories',
                      style: AppTypography.secondary,
                    ),
                    items: [
                      const DropdownMenuItem<ExpenseCategory?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...ExpenseCategory.values.map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name.toUpperCase()),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        ref
                                .read(
                                  expensesTabCategoryFilterProvider.notifier,
                                )
                                .state =
                            val,
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Date Range Filter Dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DashboardDateRange>(
                    value: dateRangeFilter,
                    items: DashboardDateRange.values.map((range) {
                      return DropdownMenuItem<DashboardDateRange>(
                        value: range,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              range.label,
                              style: AppTypography.input.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(
                              expensesTabDateRangeFilterProvider.notifier,
                            )
                            .state = val;
                      }
                    },
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Capitalized Status Dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<bool?>(
                    value: isCapitalizedFilter,
                    hint: Text(
                      'All Asset Types',
                      style: AppTypography.secondary,
                    ),
                    items: const [
                      DropdownMenuItem<bool?>(
                        value: null,
                        child: Text('All Asset Types'),
                      ),
                      DropdownMenuItem<bool?>(
                        value: true,
                        child: Text('CAPITALIZED ONLY'),
                      ),
                      DropdownMenuItem<bool?>(
                        value: false,
                        child: Text('PERIOD EXPENSE ONLY'),
                      ),
                    ],
                    onChanged: (val) =>
                        ref
                                .read(
                                  expensesTabCapitalizedFilterProvider.notifier,
                                )
                                .state =
                            val,
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: expensesAsync.when(
            loading: () =>
                const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Text('Error loading project expenses: $err'),
            data: (expenses) {
              final filtered = expenses.where((e) {
                if (categoryFilter != null && e.category != categoryFilter) {
                  return false;
                }
                if (isCapitalizedFilter != null &&
                    e.isCapitalized != isCapitalizedFilter) {
                  return false;
                }
                if (!isDateInFilterRange(e.expenseDate, dateRangeFilter)) {
                  return false;
                }
                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  final vendorMatch =
                      e.vendor?.toLowerCase().contains(q) ?? false;
                  final notesMatch =
                      e.notes?.toLowerCase().contains(q) ?? false;
                  if (!vendorMatch && !notesMatch) return false;
                }
                return true;
              }).toList();

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Date', width: 130),
                  DataTableColumn(label: 'Category', width: 170),
                  DataTableColumn(label: 'Amount', width: 160),
                  DataTableColumn(label: 'Capitalized', width: 130),
                  DataTableColumn(label: 'Notes & Description'),
                ],
                rows: filtered.map((e) {
                  return [
                    Text(
                      e.expenseDate.toString().split(' ')[0],
                      style: AppTypography.tableCell,
                    ),
                    Text(
                      e.category.name.toUpperCase(),
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(e.amount),
                      style: AppTypography.amountMedium,
                    ),
                    StatusBadge(
                      label: e.isCapitalized ? 'YES' : 'NO',
                      type: e.isCapitalized
                          ? BadgeType.success
                          : BadgeType.info,
                    ),
                    Text(
                      e.notes ?? e.vendor ?? '—',
                      style: AppTypography.tableCell,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ];
                }).toList(),
                emptyMessage:
                    'No expenses recorded for this project matching criteria.',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProfitLossTab extends ConsumerWidget {
  final String projectId;

  const _ProfitLossTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pnlListAsync = ref.watch(projectProfitLossStreamProvider);

    return pnlListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error loading Profit & Loss: $err'),
      data: (pnlList) {
        final pnl = pnlList.firstWhere(
          (item) => item.projectId == projectId,
          orElse: () => ProjectProfitLossModel(
            projectId: projectId,
            projectName: 'Project',
            totalAgreedSales: 0,
            directSaleExpenses: 0,
            actualProjectCost: 0,
            cashCollected: 0,
          ),
        );

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Financial Health & Profit / Loss Statement',
                  style: AppTypography.sectionTitle,
                ),
                const Divider(),
                const SizedBox(height: 12),
                _pnlRow(
                  'Total Agreed Sales Value:',
                  CalculationEngine.formatCurrency(pnl.totalAgreedSales),
                  isBold: true,
                ),
                _pnlRow(
                  'Direct Sale Expenses:',
                  CalculationEngine.formatCurrency(pnl.directSaleExpenses),
                ),
                _pnlRow(
                  'Net Sale Proceeds:',
                  CalculationEngine.formatCurrency(pnl.netSaleProceeds),
                ),
                _pnlRow(
                  'Actual Project Cost (Land + Expenses):',
                  CalculationEngine.formatCurrency(pnl.actualProjectCost),
                  isBold: true,
                ),
                _pnlRow(
                  'Gross Project Profit:',
                  CalculationEngine.formatCurrency(pnl.grossProjectProfit),
                  isBold: true,
                  isAccent: pnl.grossProjectProfit >= 0,
                  isDanger: pnl.grossProjectProfit < 0,
                ),
                _pnlRow(
                  'Cash Inflows Collected:',
                  CalculationEngine.formatCurrency(pnl.cashCollected),
                ),
                _pnlRow(
                  'Realized Profit (From Cash Receipts):',
                  CalculationEngine.formatCurrency(pnl.realizedProfit),
                ),
                _pnlRow(
                  'Distributable Profit (After Reserve):',
                  CalculationEngine.formatCurrency(pnl.distributableProfit),
                  isBold: true,
                  isAccent: pnl.distributableProfit >= 0,
                  isDanger: pnl.distributableProfit < 0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pnlRow(
    String label,
    String value, {
    bool isBold = false,
    bool isAccent = false,
    bool isDanger = false,
  }) {
    final Color valueColor = isDanger
        ? AppColors.dangerText
        : (isAccent ? AppColors.successText : AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  )
                : AppTypography.secondary,
          ),
          Text(
            value,
            style: isBold
                ? AppTypography.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  )
                : AppTypography.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
          ),
        ],
      ),
    );
  }
}
