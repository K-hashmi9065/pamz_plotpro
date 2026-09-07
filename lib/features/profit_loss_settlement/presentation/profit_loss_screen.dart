import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/widgets/formula_explainability_dialog.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../domain/profit_loss_models.dart';
import 'profit_loss_providers.dart';
import 'widgets/payout_disbursement_dialog.dart';

final profitLossTabProvider = StateProvider.autoDispose<int>((ref) => 0);
final profitLossSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final profitLossSelectedProjectIdProvider = StateProvider.autoDispose<String?>((ref) => null);

class ProfitLossScreen extends ConsumerWidget {
  const ProfitLossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(profitLossTabProvider);
    final searchQuery = ref.watch(profitLossSearchQueryProvider);
    final selectedProjectId = ref.watch(profitLossSelectedProjectIdProvider);

    final currentRole = ref.watch(currentRoleProvider);
    final profitLossAsync = ref.watch(projectProfitLossStreamProvider);

    // Compute metric totals
    double totalSales = 0.0;
    double totalGrossProfit = 0.0;
    double totalDistributable = 0.0;

    if (profitLossAsync.hasValue) {
      for (final pl in profitLossAsync.value!) {
        totalSales += pl.totalAgreedSales;
        totalGrossProfit += pl.grossProjectProfit;
        totalDistributable += pl.distributableProfit;
      }
    }

    final tabs = [
      'Project P&L Summaries',
      'Investor ROI Settlements',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Profit & Loss / Investor Payout Ledger',
          subtitle:
              'Analyze project profit margins, audit realized vs booked profit, and manage investor ROI settlement distributions.',
          icon: Icons.trending_up_outlined,
        ),
        const SizedBox(height: 16),

        // Summary Metric Cards
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Booked Sales',
                amountDisplay: CalculationEngine.formatCurrency(totalSales),
                subtitle: 'Agreed sale price contract revenue',
                icon: Icons.sell_outlined,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'Total Gross Project Profit',
                amountDisplay: CalculationEngine.formatCurrency(totalGrossProfit),
                subtitle: 'Net proceeds minus land & capitalized cost',
                icon: Icons.show_chart_outlined,
                color: totalGrossProfit >= 0 ? AppColors.successText : AppColors.dangerText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'Distributable Profit Pool',
                amountDisplay: CalculationEngine.formatCurrency(totalDistributable),
                subtitle: 'Net profit pool for investor ROI share',
                icon: Icons.payments_outlined,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tab Navigation & Search Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedTabIndex == index;
                    return InkWell(
                      onTap: () => ref.read(profitLossTabProvider.notifier).state = index,
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          tabs[index],
                          style: AppTypography.body.copyWith(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 280,
                height: 38,
                child: TextField(
                  onChanged: (val) => ref.read(profitLossSearchQueryProvider.notifier).state = val,
                  decoration: const InputDecoration(
                    hintText: 'Search project or investor...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: AppTypography.input.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab Views with Smooth Animation
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.015, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(selectedTabIndex),
              child: _buildTabView(
                context,
                ref,
                selectedTabIndex,
                searchQuery,
                selectedProjectId,
                currentRole,
                profitLossAsync,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabView(
    BuildContext context,
    WidgetRef ref,
    int tabIndex,
    String searchQuery,
    String? selectedProjectId,
    UserRole currentRole,
    AsyncValue<List<ProjectProfitLossModel>> profitLossAsync,
  ) {
    if (tabIndex == 0) {
      return profitLossAsync.when(
        loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
        error: (err, s) => Center(
          child: Text('Error loading P&L summaries: $err', style: AppTypography.secondary.copyWith(color: AppColors.dangerText)),
        ),
        data: (projectsPL) {
          final filtered = projectsPL.where((pl) {
            if (searchQuery.isEmpty) return true;
            return pl.projectName.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          return CustomDataTable(
            columns: const [
              DataTableColumn(label: 'Project Name', width: 180),
              DataTableColumn(label: 'Booked Sales', width: 140),
              DataTableColumn(label: 'Net Proceeds', width: 140),
              DataTableColumn(label: 'Project Cost', width: 140),
              DataTableColumn(label: 'Gross Profit / Loss', width: 210),
              DataTableColumn(label: 'Distributable Pool'),
            ],
            rows: filtered.map((pl) {
              final isProfitable = pl.grossProjectProfit >= 0;

              return [
                Text(pl.projectName, style: AppTypography.tableCell.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  CalculationEngine.formatCurrency(pl.totalAgreedSales),
                  style: AppTypography.amountMedium,
                ),
                Text(
                  CalculationEngine.formatCurrency(pl.netSaleProceeds),
                  style: AppTypography.amountMedium.copyWith(color: AppColors.accent),
                ),
                Text(
                  CalculationEngine.formatCurrency(pl.actualProjectCost),
                  style: AppTypography.secondary,
                ),
                Row(
                  children: [
                    Text(
                      CalculationEngine.formatCurrency(pl.grossProjectProfit),
                      style: AppTypography.amountMedium.copyWith(
                        color: isProfitable ? AppColors.successText : AppColors.dangerText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FormulaInfoButton(
                      figureTitle: 'Gross Project Profit',
                      plainWordsFormula:
                          'Gross Project Profit = Net Sale Proceeds − Actual Project Cost',
                      terms: [
                        FormulaTermDefinition(
                          term: 'Net Sale Proceeds',
                          definition: 'Booked sales minus direct sale expenses (brokerage/legal).',
                          valueDisplay: CalculationEngine.formatCurrency(pl.netSaleProceeds),
                        ),
                        FormulaTermDefinition(
                          term: 'Actual Project Cost',
                          definition: 'Land purchase price plus capitalized development expenses.',
                          valueDisplay: CalculationEngine.formatCurrency(pl.actualProjectCost),
                        ),
                      ],
                      calculatedResultDisplay:
                          CalculationEngine.formatCurrency(pl.grossProjectProfit),
                    ),
                  ],
                ),
                Text(
                  CalculationEngine.formatCurrency(pl.distributableProfit),
                  style: AppTypography.amountMedium.copyWith(color: AppColors.successText),
                ),
              ];
            }).toList(),
            emptyMessage: 'No project P&L summaries recorded.',
          );
        },
      );
    } else {
      return profitLossAsync.when(
        loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
        error: (err, s) => Center(
          child: Text('Error loading P&L for investor payouts: $err'),
        ),
        data: (projectsPL) {
          if (projectsPL.isEmpty) {
            return const CustomDataTable(columns: [], rows: [], emptyMessage: 'No active projects.');
          }

          final selectedPl = selectedProjectId != null
              ? projectsPL.firstWhere((p) => p.projectId == selectedProjectId, orElse: () => projectsPL.first)
              : projectsPL.first;

          return _InvestorPayoutsTableView(
            projectPl: selectedPl,
            allProjects: projectsPL,
            onProjectSelected: (id) => ref.read(profitLossSelectedProjectIdProvider.notifier).state = id,
            searchQuery: searchQuery,
            currentRoleAdmin: currentRole.isAdmin,
          );
        },
      );
    }
  }
}

class _InvestorPayoutsTableView extends ConsumerWidget {
  final ProjectProfitLossModel projectPl;
  final List<ProjectProfitLossModel> allProjects;
  final ValueChanged<String> onProjectSelected;
  final String searchQuery;
  final bool currentRoleAdmin;

  const _InvestorPayoutsTableView({
    required this.projectPl,
    required this.allProjects,
    required this.onProjectSelected,
    required this.searchQuery,
    required this.currentRoleAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(
      investorPayoutsStreamProvider((
        projectId: projectPl.projectId,
        profitPool: projectPl.distributableProfit,
      )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Selected Project: ', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: projectPl.projectId,
              items: allProjects.map((p) {
                return DropdownMenuItem<String>(
                  value: p.projectId,
                  child: Text(p.projectName, style: AppTypography.input),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onProjectSelected(val);
              },
            ),
            const SizedBox(width: 20),
            StatusBadge(
              label: 'POOL: ${CalculationEngine.formatCurrency(projectPl.distributableProfit)}',
              type: BadgeType.success,
            ),
          ],
        ),
        const SizedBox(height: 12),

        Expanded(
          child: payoutsAsync.when(
            loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, s) => Center(
              child: Text('Error loading investor payouts: $err', style: AppTypography.secondary.copyWith(color: AppColors.dangerText)),
            ),
            data: (payouts) {
              final filtered = payouts.where((p) {
                if (searchQuery.isEmpty) return true;
                return p.investorName.toLowerCase().contains(searchQuery.toLowerCase());
              }).toList();

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Investor Name', width: 180),
                  DataTableColumn(label: 'Capital Invested', width: 150),
                  DataTableColumn(label: 'Ownership %', width: 130),
                  DataTableColumn(label: 'Profit Share', width: 180),
                  DataTableColumn(label: 'ROI %', width: 130),
                  DataTableColumn(label: 'Payouts Disbursed', width: 160),
                  DataTableColumn(label: 'Remaining Balance', width: 180),
                  DataTableColumn(label: 'Actions', width: 120, alignment: Alignment.center),
                ],
                rows: filtered.map((p) {
                  return [
                    Text(p.investorName, style: AppTypography.tableCell.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      CalculationEngine.formatCurrency(p.capitalInvested),
                      style: AppTypography.amountMedium,
                    ),
                    Text('${p.ownershipPercent.toStringAsFixed(2)}%', style: AppTypography.tableCell),
                    Row(
                      children: [
                        Text(
                          CalculationEngine.formatCurrency(p.allocatedProfitShare),
                          style: AppTypography.amountMedium.copyWith(color: AppColors.successText),
                        ),
                        const SizedBox(width: 4),
                        FormulaInfoButton(
                          figureTitle: 'Investor Profit Share',
                          plainWordsFormula:
                              'Profit Share = Distributable Profit Pool × (Investor Ownership % ÷ 100)',
                          terms: [
                            FormulaTermDefinition(
                              term: 'Distributable Profit Pool',
                              definition: 'Total net profit pool available for distribution.',
                              valueDisplay: CalculationEngine.formatCurrency(projectPl.distributableProfit),
                            ),
                            FormulaTermDefinition(
                              term: 'Investor Ownership %',
                              definition: 'Capital-based equity stake in project.',
                              valueDisplay: '${p.ownershipPercent.toStringAsFixed(2)}%',
                            ),
                          ],
                          calculatedResultDisplay:
                              CalculationEngine.formatCurrency(p.allocatedProfitShare),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${p.roiPercent.toStringAsFixed(2)}%',
                          style: AppTypography.tableCell.copyWith(
                            fontWeight: FontWeight.bold,
                            color: p.roiPercent >= 0 ? AppColors.successText : AppColors.dangerText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        FormulaInfoButton(
                          figureTitle: 'Investor ROI %',
                          plainWordsFormula:
                              'ROI % = (Investor Profit Share ÷ Capital Invested) × 100',
                          terms: [
                            FormulaTermDefinition(
                              term: 'Investor Profit Share',
                              definition: 'Allocated profit earned.',
                              valueDisplay: CalculationEngine.formatCurrency(p.allocatedProfitShare),
                            ),
                            FormulaTermDefinition(
                              term: 'Capital Invested',
                              definition: 'Total equity contributed by investor.',
                              valueDisplay: CalculationEngine.formatCurrency(p.capitalInvested),
                            ),
                          ],
                          calculatedResultDisplay: '${p.roiPercent.toStringAsFixed(2)}%',
                        ),
                      ],
                    ),
                    Text(
                      CalculationEngine.formatCurrency(p.payoutsDisbursed),
                      style: AppTypography.secondary,
                    ),
                    Text(
                      CalculationEngine.formatCurrency(p.remainingPayoutBalance),
                      style: AppTypography.amountMedium.copyWith(color: AppColors.accent),
                    ),
                    if (currentRoleAdmin && p.remainingPayoutBalance > 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => PayoutDisbursementDialog.show(context, payout: p),
                        child: const Text('Disburse', style: TextStyle(fontSize: 12)),
                      )
                    else if (p.remainingPayoutBalance <= 0)
                      const Icon(Icons.check_circle, color: AppColors.successText, size: 20)
                    else
                      Text('Non-Admin', style: AppTypography.secondary),
                  ];
                }).toList(),
                emptyMessage: 'No investor equity capital allocated for this project.',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String amountDisplay;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.amountDisplay,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.secondary.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  amountDisplay,
                  style: AppTypography.amountMedium.copyWith(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.secondary.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
