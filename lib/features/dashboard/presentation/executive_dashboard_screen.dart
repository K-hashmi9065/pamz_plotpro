import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/widgets/formula_explainability_dialog.dart';
import '../../../features/auth/presentation/auth_provider.dart';
import '../../../features/auth/presentation/widgets/add_member_dialog.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../buyers_sales/presentation/widgets/sale_agreement_dialog.dart';
import '../../installments_payments/presentation/widgets/payment_record_dialog.dart';
import '../../../core/utils/land_unit_converter.dart';
import '../../plots/presentation/plots_providers.dart';
import '../../projects/domain/project_model.dart';
import '../../projects/presentation/project_detail_screen.dart';
import '../../projects/presentation/projects_providers.dart';
import '../../projects/presentation/widgets/project_form_dialog.dart';
import 'dashboard_providers.dart';

class ExecutiveDashboardScreen extends ConsumerWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentUserProvider)?.role ?? UserRole.admin;
    final selectedProjectId = ref.watch(selectedProjectFilterProvider);
    final selectedDateRange = ref.watch(selectedDashboardDateRangeProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);
    final summaryAsync = ref.watch(portfolioSummaryStreamProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Executive Dashboard & Portfolio Overview',
            subtitle:
                'Multi-project land summary, investor capital, sales revenue, net cash liquidity & plot inventory performance.',
            icon: Icons.dashboard_outlined,
            actions: [
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
                    isDense: true,
                    value: selectedDateRange,
                    items: DashboardDateRange.values.map((range) {
                      return DropdownMenuItem<DashboardDateRange>(
                        value: range,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(range.label, style: AppTypography.input.copyWith(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(selectedDashboardDateRangeProvider.notifier).state = val;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Project Filter Dropdown
              projectsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
                data: (projects) {
                  final validSelectedProject = projects.any((p) => p.id == selectedProjectId) ? selectedProjectId : null;

                  return Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isDense: true,
                        value: validSelectedProject,
                        hint: Text('All Portfolio Projects', style: AppTypography.input.copyWith(fontSize: 13)),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Portfolio Projects', style: AppTypography.input.copyWith(fontSize: 13)),
                          ),
                          ...projects.map((p) {
                            return DropdownMenuItem<String?>(
                              value: p.id,
                              child: Text(p.name, style: AppTypography.input.copyWith(fontSize: 13)),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          ref.read(selectedProjectFilterProvider.notifier).state = val;
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              // Add Member Button (Admin only)
              if (currentRole.isAdmin)
                SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    onPressed: () => AddMemberDialog.show(context),
                    icon: const Icon(Icons.person_add_outlined, size: 16),
                    label: const Text('Add Member'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 0),
                      minimumSize: const Size(0, 38),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Executive Metric Cards Grid
          summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading dashboard metrics: $err'),
            data: (summary) {
              final soldPercent = summary.totalPlotsCount > 0
                  ? (summary.totalSoldPlots / summary.totalPlotsCount * 100).round()
                  : 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ExecutiveMetricCard(
                          title: 'Portfolio Projects & Land Area',
                          amountDisplay: '${summary.totalProjects} Projects',
                          subtitle:
                              '${CalculationEngine.indianNumberFormat.format(summary.totalLandAreaSqFt.round())} Total Sq. Ft.',
                          icon: Icons.landscape_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ExecutiveMetricCard(
                          title: 'Investor Capital Invested',
                          amountDisplay: CalculationEngine.formatCurrency(summary.totalCapitalInvested),
                          subtitle: currentRole.isAdmin
                              ? 'Equity capital allocated'
                              : 'Restricted View (Admin Only)',
                          icon: Icons.pie_chart_outline,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ExecutiveMetricCard(
                          title: 'Booked Sales Revenue',
                          amountDisplay: CalculationEngine.formatCurrency(summary.totalAgreedSales),
                          subtitle: 'Agreed sale price contracts',
                          icon: Icons.sell_outlined,
                          color: AppColors.successText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _ExecutiveMetricCard(
                          title: 'Net Cash Flow Liquidity',
                          amountDisplay: CalculationEngine.formatCurrency(summary.netCashFlow),
                          subtitle: 'Inflows minus Land & Expenses',
                          icon: Icons.account_balance_outlined,
                          color: summary.netCashFlow >= 0 ? AppColors.successText : AppColors.dangerText,
                          formulaWidget: FormulaInfoButton(
                            figureTitle: 'Net Cash Flow Position',
                            plainWordsFormula:
                                'Net Cash Flow = Total Cash Inflows − (Land Outflows + Project Expense Outflows)',
                            terms: [
                              FormulaTermDefinition(
                                term: 'Total Cash Inflows',
                                definition: 'Cleared buyer installment receipts.',
                                valueDisplay: CalculationEngine.formatCurrency(summary.totalCashCollected),
                              ),
                              FormulaTermDefinition(
                                term: 'Total Outflows',
                                definition: 'Disbursed land purchase payments & project development expenses.',
                                valueDisplay: CalculationEngine.formatCurrency(summary.totalOutflows),
                              ),
                            ],
                            calculatedResultDisplay: CalculationEngine.formatCurrency(summary.netCashFlow),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ExecutiveMetricCard(
                          title: 'Customer Dues Receivable',
                          amountDisplay: CalculationEngine.formatCurrency(summary.totalReceivables),
                          subtitle: 'Outstanding customer installments',
                          icon: Icons.call_received_outlined,
                          color: AppColors.warningText,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ExecutiveMetricCard(
                          title: 'Landowner Payables',
                          amountDisplay: CalculationEngine.formatCurrency(summary.totalPayables),
                          subtitle: 'Pending land purchase dues',
                          icon: Icons.call_made_outlined,
                          color: AppColors.dangerText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Action Buttons & Plot Inventory Progress
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quick Actions Box
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quick Actions & Workflows', style: AppTypography.cardTitle),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: ElevatedButton.icon(
                                                onPressed: () => ProjectFormDialog.show(context),
                                                icon: const Icon(Icons.add_business, size: 18),
                                                label: const Text('Add Project'),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                                                onPressed: () => SaleAgreementDialog.show(context),
                                                icon: const Icon(Icons.handshake_outlined, size: 18),
                                                label: const Text('New Sale Agreement'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: OutlinedButton.icon(
                                                onPressed: () => PaymentRecordDialog.show(context),
                                                icon: const Icon(Icons.add_card, size: 18),
                                                label: const Text('Record Payment'),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: OutlinedButton.icon(
                                                onPressed: () => context.go(AppRoutes.profitLoss),
                                                icon: const Icon(Icons.trending_up, size: 18),
                                                label: const Text('View P&L Ledger'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                      // Plot Inventory Breakdown Card
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Plot Sales Velocity', style: AppTypography.cardTitle),
                                  StatusBadge(
                                    label: '$soldPercent% SOLD',
                                    type: soldPercent >= 50 ? BadgeType.success : BadgeType.info,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: summary.totalPlotsCount > 0
                                      ? summary.totalSoldPlots / summary.totalPlotsCount
                                      : 0.0,
                                  minHeight: 12,
                                  backgroundColor: AppColors.surfaceSubtle,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Avail: ${summary.totalAvailablePlots} Plots',
                                    style: AppTypography.secondary.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    'Booked: ${summary.totalBookedPlots} Plots',
                                    style: AppTypography.secondary.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  Text(
                                    'Sold: ${summary.totalSoldPlots} Plots',
                                    style: AppTypography.secondary.copyWith(
                                      color: AppColors.successText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _miniLandStat('Total Purchased', summary.totalLandAreaSqFt),
                                    _miniLandStat('Land Sold', summary.soldLandAreaSqFt, color: AppColors.successText),
                                    _miniLandStat('Remaining Land', summary.remainingLandAreaSqFt, color: AppColors.accent),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            },
          ),
          const SizedBox(height: 24),

          // Active Projects Portfolio Cards
          Text('Project Portfolio Breakdown', style: AppTypography.sectionTitle),
          const SizedBox(height: 12),

          projectsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => Text('Error loading projects: $e'),
            data: (projects) {
              final displayedProjects = selectedProjectId == null || selectedProjectId.isEmpty
                  ? projects
                  : projects.where((p) => p.id == selectedProjectId).toList();

              if (displayedProjects.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      selectedProjectId != null
                          ? 'No data found for selected project filter.'
                          : 'No projects registered yet. Click "Add Project" to get started.',
                      style: AppTypography.secondary,
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? (displayedProjects.length < 3 ? displayedProjects.length : 3) : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 235,
                    ),
                    itemCount: displayedProjects.length,
                    itemBuilder: (context, index) {
                      final proj = displayedProjects[index];
                      return _ProjectPortfolioCard(proj: proj);
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ExecutiveMetricCard extends StatelessWidget {
  final String title;
  final String amountDisplay;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? formulaWidget;

  const _ExecutiveMetricCard({
    required this.title,
    required this.amountDisplay,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.formulaWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.secondary.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        amountDisplay,
                        style: AppTypography.amountLarge.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (formulaWidget != null) ...[
                      const SizedBox(width: 6),
                      formulaWidget!,
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _miniLandStat(String label, double sqFt, {Color? color}) {
  final totalKatta = LandUnitConverter.sqFtToKatta(sqFt);
  final kattaStr = totalKatta == totalKatta.roundToDouble()
      ? totalKatta.toInt().toString()
      : double.parse(totalKatta.toStringAsFixed(1)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return Column(
    children: [
      Text(label, style: AppTypography.secondary.copyWith(fontSize: 10, color: AppColors.textMuted)),
      const SizedBox(height: 2),
      Text(
        '${CalculationEngine.indianNumberFormat.format(sqFt.round())} Sq.Ft.',
        style: AppTypography.body.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700, color: color ?? AppColors.textPrimary),
      ),
      Text(
        '($kattaStr Kattha)',
        style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textMuted),
      ),
    ],
  );
}

class _ProjectPortfolioCard extends ConsumerWidget {
  final ProjectModel proj;

  const _ProjectPortfolioCard({required this.proj});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotsAsync = ref.watch(projectPlotsStreamProvider(proj.id));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  proj.name,
                  style: AppTypography.cardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                label: proj.status.name.toUpperCase(),
                type: proj.status == ProjectStatus.active
                    ? BadgeType.success
                    : BadgeType.info,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  proj.location,
                  style: AppTypography.secondary.copyWith(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          plotsAsync.when(
            data: (plots) {
              double soldAreaSqFt = 0.0;
              int availCount = 0;
              int bookedCount = 0;
              int soldCount = 0;

              for (final plot in plots) {
                if (plot.status == PlotStatus.available) {
                  availCount++;
                } else if (plot.status == PlotStatus.booked || plot.status == PlotStatus.reserved) {
                  bookedCount++;
                  soldAreaSqFt += plot.areaSqFt;
                } else if (plot.status == PlotStatus.cancelled) {
                  // ignore
                } else {
                  soldCount++;
                  soldAreaSqFt += plot.areaSqFt;
                }
              }

              final remainingAreaSqFt = (proj.landAreaSqFt - soldAreaSqFt).clamp(0.0, double.infinity);
              final totalKatthaStr = LandUnitConverter.sqFtToKatta(proj.landAreaSqFt).toStringAsFixed(2);
              final soldKatthaStr = LandUnitConverter.sqFtToKatta(soldAreaSqFt).toStringAsFixed(2);
              final remKatthaStr = LandUnitConverter.sqFtToKatta(remainingAreaSqFt).toStringAsFixed(2);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Land Bought: ${CalculationEngine.indianNumberFormat.format(proj.landAreaSqFt.round())} Sq.Ft. ($totalKatthaStr Kattha)',
                    style: AppTypography.secondary.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Sold: ${CalculationEngine.indianNumberFormat.format(soldAreaSqFt.round())} Sq.Ft. ($soldKatthaStr Kattha)',
                        style: AppTypography.secondary.copyWith(fontSize: 11, color: AppColors.successText, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rem: ${CalculationEngine.indianNumberFormat.format(remainingAreaSqFt.round())} Sq.Ft. ($remKatthaStr Kattha)',
                    style: AppTypography.secondary.copyWith(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Plots: $availCount Avail | $bookedCount Booked | $soldCount Sold',
                    style: AppTypography.secondary.copyWith(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(height: 38, child: LinearProgressIndicator()),
            error: (e, s) => Text(
              'Land Area: ${CalculationEngine.indianNumberFormat.format(proj.landAreaSqFt.round())} Sq. Ft.',
              style: AppTypography.secondary,
            ),
          ),

          const Spacer(),
          const Divider(height: 16, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Actual Land Cost', style: AppTypography.caption.copyWith(fontSize: 10.5, color: AppColors.textMuted)),
                  Text(
                    CalculationEngine.formatCurrency(proj.actualCost),
                    style: AppTypography.amountMedium.copyWith(fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => ProjectDetailScreen.showAsDialog(context, proj.id),
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text(
                  'View Project',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
