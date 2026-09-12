import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/widgets/formula_explainability_dialog.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../domain/receivable_payable_models.dart';
import 'receivables_payables_providers.dart';

final receivablesPayablesTabProvider = StateProvider.autoDispose<int>((ref) => 0);
final receivablesPayablesSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class ReceivablesPayablesScreen extends ConsumerWidget {
  const ReceivablesPayablesScreen({super.key});

  BadgeType _getAgingBadgeType(String bucket) {
    switch (bucket) {
      case 'On Time':
      case 'Current':
        return BadgeType.info;
      case '1-30 Days Due':
      case '0-30 Days':
        return BadgeType.warning;
      case '31-60 Days Overdue':
      case '31-60 Days':
        return BadgeType.warning;
      case '61-90 Days Overdue':
      case '61-90 Days':
        return BadgeType.danger;
      case '90+ Days Overdue':
      case '90+ Days':
        return BadgeType.danger;
      default:
        return BadgeType.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(receivablesPayablesTabProvider);
    final searchQuery = ref.watch(receivablesPayablesSearchQueryProvider);

    final receivablesAsync = ref.watch(buyerReceivablesStreamProvider);
    final payablesAsync = ref.watch(landownerPayablesStreamProvider);
    final cashFlowsAsync = ref.watch(projectCashFlowStreamProvider);

    // Compute metric card summary values
    double totalReceivables = 0.0;
    int countOverdue90 = 0;
    if (receivablesAsync.hasValue) {
      for (final r in receivablesAsync.value!) {
        totalReceivables += r.balanceOutstanding;
        if (r.overdueDays > 90) countOverdue90++;
      }
    }

    double totalPayables = 0.0;
    if (payablesAsync.hasValue) {
      for (final p in payablesAsync.value!) {
        totalPayables += p.balanceOutstanding;
      }
    }

    double netCashPosition = 0.0;
    if (cashFlowsAsync.hasValue) {
      for (final cf in cashFlowsAsync.value!) {
        netCashPosition += cf.netCashFlow;
      }
    }

    final tabs = [
      'Customer Pending Dues',
      'Landowner Pending Payments',
      'Project Cash Flow',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Receivables, Payables & Cash Flow Ledger',
          subtitle:
              'Monitor customer pending dues, landowner purchase payables, and project cash flow liquidity.',
          icon: Icons.compare_arrows_outlined,
        ),
        const SizedBox(height: 16),

        // Summary Metric Cards
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Customer Pending Dues',
                amountDisplay: CalculationEngine.formatCurrency(totalReceivables),
                subtitle: countOverdue90 > 0
                    ? '$countOverdue90 dues delayed 90+ days'
                    : 'All customer dues on track',
                icon: Icons.call_received_outlined,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'Total Landowner Pending Dues',
                amountDisplay: CalculationEngine.formatCurrency(totalPayables),
                subtitle: 'Pending purchase agreement settlements',
                icon: Icons.call_made_outlined,
                color: AppColors.warningText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                title: 'Net Cash Flow Position',
                amountDisplay: CalculationEngine.formatCurrency(netCashPosition),
                subtitle: 'Inflows minus Land & Expense Outflows',
                icon: Icons.account_balance_outlined,
                color: netCashPosition >= 0 ? AppColors.successText : AppColors.dangerText,
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
                      onTap: () => ref.read(receivablesPayablesTabProvider.notifier).state = index,
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
                  onChanged: (val) => ref.read(receivablesPayablesSearchQueryProvider.notifier).state = val,
                  decoration: const InputDecoration(
                    hintText: 'Search buyer, landowner, project...',
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
              child: _buildTabView(context, ref, selectedTabIndex, searchQuery, receivablesAsync, payablesAsync, cashFlowsAsync),
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
    AsyncValue<List<BuyerReceivableModel>> receivablesAsync,
    AsyncValue<List<LandownerPayableModel>> payablesAsync,
    AsyncValue<List<ProjectCashFlowModel>> cashFlowsAsync,
  ) {
    switch (tabIndex) {
      case 0:
        return receivablesAsync.when(
          loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
          error: (err, s) => Center(
            child: Text('Error loading receivables: $err', style: AppTypography.secondary.copyWith(color: AppColors.dangerText)),
          ),
          data: (receivables) {
            final filtered = receivables.where((r) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return r.buyerName.toLowerCase().contains(q) ||
                  r.agingBucket.toLowerCase().contains(q);
            }).toList();

            return CustomDataTable(
              columns: const [
                DataTableColumn(label: 'Customer Name', width: 180),
                DataTableColumn(label: 'Inst #', width: 90),
                DataTableColumn(label: 'Due Date', width: 130),
                DataTableColumn(label: 'Delayed Days', width: 130),
                DataTableColumn(label: 'Due Status', width: 160),
                DataTableColumn(label: 'Pending Amount', width: 220),
              ],
              rows: filtered.map((r) {
                return [
                  Text(r.buyerName, style: AppTypography.tableCell.copyWith(fontWeight: FontWeight.bold)),
                  Text('#${r.installmentNumber}', style: AppTypography.tableCell),
                  Text(DateFormat('dd MMM yyyy').format(r.dueDate), style: AppTypography.secondary),
                  Text(
                    '${r.overdueDays} Days',
                    style: AppTypography.tableCell.copyWith(
                      color: r.overdueDays > 60 ? AppColors.dangerText : AppColors.textPrimary,
                      fontWeight: r.overdueDays > 60 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  StatusBadge(label: r.agingBucket, type: _getAgingBadgeType(r.agingBucket)),
                  Row(
                    children: [
                      Text(
                        CalculationEngine.formatCurrency(r.balanceOutstanding),
                        style: AppTypography.amountMedium.copyWith(color: AppColors.accent),
                      ),
                      const SizedBox(width: 4),
                      FormulaInfoButton(
                        figureTitle: 'Customer Balance Receivable',
                        plainWordsFormula:
                            'Balance Receivable = Total Agreed Sales − Cash Collected',
                        terms: [
                          FormulaTermDefinition(
                            term: 'Due Amount',
                            definition: 'Agreed installment payment value.',
                            valueDisplay: CalculationEngine.formatCurrency(r.dueAmount),
                          ),
                          FormulaTermDefinition(
                            term: 'Cash Collected',
                            definition: 'Total cleared non-voided receipts.',
                            valueDisplay: CalculationEngine.formatCurrency(r.paidAmount),
                          ),
                        ],
                        calculatedResultDisplay:
                            CalculationEngine.formatCurrency(r.balanceOutstanding),
                      ),
                    ],
                  ),
                ];
              }).toList(),
              emptyMessage: 'No outstanding buyer receivables found.',
            );
          },
        );

      case 1:
        return payablesAsync.when(
          loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
          error: (err, s) => Center(
            child: Text('Error loading payables: $err', style: AppTypography.secondary.copyWith(color: AppColors.dangerText)),
          ),
          data: (payables) {
            final filtered = payables.where((p) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return p.landownerName.toLowerCase().contains(q) ||
                  p.status.toLowerCase().contains(q);
            }).toList();

            return CustomDataTable(
              columns: const [
                DataTableColumn(label: 'Landowner Name', width: 200),
                DataTableColumn(label: 'Agreed Price', width: 160),
                DataTableColumn(label: 'Paid Amount', width: 160),
                DataTableColumn(label: 'Balance Payable', width: 220),
                DataTableColumn(label: 'Status', width: 140),
              ],
              rows: filtered.map((p) {
                return [
                  Text(p.landownerName, style: AppTypography.tableCell.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    CalculationEngine.formatCurrency(p.agreedPurchasePrice),
                    style: AppTypography.amountMedium,
                  ),
                  Text(
                    CalculationEngine.formatCurrency(p.paidAmount),
                    style: AppTypography.amountMedium.copyWith(color: AppColors.successText),
                  ),
                  Row(
                    children: [
                      Text(
                        CalculationEngine.formatCurrency(p.balanceOutstanding),
                        style: AppTypography.amountMedium.copyWith(color: AppColors.warningText),
                      ),
                      const SizedBox(width: 4),
                      FormulaInfoButton(
                        figureTitle: 'Landowner Balance Payable',
                        plainWordsFormula:
                            'Balance Payable = Total Purchase Price − Cash Paid',
                        terms: [
                          FormulaTermDefinition(
                            term: 'Agreed Purchase Price',
                            definition: 'Land purchase agreement contract value.',
                            valueDisplay: CalculationEngine.formatCurrency(p.agreedPurchasePrice),
                          ),
                          FormulaTermDefinition(
                            term: 'Cash Paid',
                            definition: 'Total disbursement payments made to landowner.',
                            valueDisplay: CalculationEngine.formatCurrency(p.paidAmount),
                          ),
                        ],
                        calculatedResultDisplay:
                            CalculationEngine.formatCurrency(p.balanceOutstanding),
                      ),
                    ],
                  ),
                  StatusBadge(
                    label: p.isFullyPaid ? 'SETTLED' : p.status.toUpperCase(),
                    type: p.isFullyPaid ? BadgeType.success : BadgeType.warning,
                  ),
                ];
              }).toList(),
              emptyMessage: 'No landowner purchase payables recorded.',
            );
          },
        );

      case 2:
      default:
        return cashFlowsAsync.when(
          loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
          error: (err, s) => Center(
            child: Text('Error loading cash flows: $err', style: AppTypography.secondary.copyWith(color: AppColors.dangerText)),
          ),
          data: (cashFlows) {
            final filtered = cashFlows.where((cf) {
              if (searchQuery.isEmpty) return true;
              return cf.projectName.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return CustomDataTable(
              columns: const [
                DataTableColumn(label: 'Project Name', width: 220),
                DataTableColumn(label: 'Total Inflows (+)', width: 170),
                DataTableColumn(label: 'Land Outflows (-)', width: 170),
                DataTableColumn(label: 'Expense Outflows (-)', width: 170),
                DataTableColumn(label: 'Net Cash Flow Position', width: 220),
              ],
              rows: filtered.map((cf) {
                final isPositive = cf.netCashFlow >= 0;

                return [
                  Text(cf.projectName, style: AppTypography.tableCell.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    CalculationEngine.formatCurrency(cf.totalInflows),
                    style: AppTypography.amountMedium.copyWith(color: AppColors.successText),
                  ),
                  Text(
                    CalculationEngine.formatCurrency(cf.totalLandOutflows),
                    style: AppTypography.amountMedium.copyWith(color: AppColors.warningText),
                  ),
                  Text(
                    CalculationEngine.formatCurrency(cf.totalExpenseOutflows),
                    style: AppTypography.amountMedium.copyWith(color: AppColors.dangerText),
                  ),
                  Row(
                    children: [
                      Text(
                        CalculationEngine.formatCurrency(cf.netCashFlow),
                        style: AppTypography.amountMedium.copyWith(
                          color: isPositive ? AppColors.successText : AppColors.dangerText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FormulaInfoButton(
                        figureTitle: 'Project Net Cash Flow',
                        plainWordsFormula:
                            'Net Cash Flow = Total Cash Inflows − (Land Outflows + Project Expense Outflows)',
                        terms: [
                          FormulaTermDefinition(
                            term: 'Total Cash Inflows',
                            definition: 'Cleared buyer installment receipts.',
                            valueDisplay: CalculationEngine.formatCurrency(cf.totalInflows),
                          ),
                          FormulaTermDefinition(
                            term: 'Land Outflows',
                            definition: 'Payments disbursed to landowners.',
                            valueDisplay: CalculationEngine.formatCurrency(cf.totalLandOutflows),
                          ),
                          FormulaTermDefinition(
                            term: 'Expense Outflows',
                            definition: 'Development, legal, and operational expenses.',
                            valueDisplay: CalculationEngine.formatCurrency(cf.totalExpenseOutflows),
                          ),
                        ],
                        calculatedResultDisplay:
                            CalculationEngine.formatCurrency(cf.netCashFlow),
                      ),
                    ],
                  ),
                ];
              }).toList(),
              emptyMessage: 'No project cash flow metrics available.',
            );
          },
        );
    }
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
