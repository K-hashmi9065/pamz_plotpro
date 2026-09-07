import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../core/widgets/formula_explainability_dialog.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../projects/presentation/projects_providers.dart';
import 'expenses_providers.dart';
import 'widgets/expense_form_dialog.dart';

final expensesSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final expensesCategoryFilterProvider = StateProvider.autoDispose<ExpenseCategory?>((ref) => null);
final expensesSelectedProjectIdProvider = StateProvider.autoDispose<String?>((ref) => null);
final expensesDateRangeFilterProvider = StateProvider.autoDispose<DashboardDateRange>((ref) => DashboardDateRange.allTime);
final expensesIsCapitalizedFilterProvider = StateProvider.autoDispose<bool?>((ref) => null);

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(expensesSearchQueryProvider);
    final categoryFilter = ref.watch(expensesCategoryFilterProvider);
    final selectedProjectId = ref.watch(expensesSelectedProjectIdProvider);
    final dateRangeFilter = ref.watch(expensesDateRangeFilterProvider);
    final isCapitalizedFilter = ref.watch(expensesIsCapitalizedFilterProvider);

    final expensesAsync = ref.watch(expensesListStreamProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Expenses & Cost Allocation',
          subtitle:
              'Track development, legal, registration, and administrative costs rolling into Actual Project Cost.',
          icon: Icons.receipt_long_outlined,
          actions: [
            ElevatedButton.icon(
              onPressed: () => ExpenseFormDialog.show(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Log Expense'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Bar & Summary Cards
        expensesAsync.when(
          data: (expenses) {
            final filteredForSummary = expenses.where((e) {
              if (selectedProjectId != null && e.projectId != selectedProjectId) {
                return false;
              }
              if (!isDateInFilterRange(e.expenseDate, dateRangeFilter)) {
                return false;
              }
              return true;
            }).toList();

            final capitalizedTotal = filteredForSummary
                .where((e) => e.isCapitalized)
                .fold(0.0, (sum, e) => sum + e.amount);
            final periodTotal = filteredForSummary
                .where((e) => !e.isCapitalized)
                .fold(0.0, (sum, e) => sum + e.amount);

            return Column(
              children: [
                Row(
                  children: [
                    // Capitalized Cost Summary Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Capitalized Project Expenses',
                                  style: AppTypography.secondary,
                                ),
                                const SizedBox(width: 6),
                                FormulaInfoButton(
                                  figureTitle: 'Actual Project Cost Calculation',
                                  plainWordsFormula:
                                      'Actual Project Cost = Land Purchase Price + Capitalized Development/Legal Expenses',
                                  terms: [
                                    const FormulaTermDefinition(
                                      term: 'Land Purchase Price',
                                      definition: 'Agreed purchase price paid to landowner.',
                                      valueDisplay: '₹2,00,00,000',
                                    ),
                                    FormulaTermDefinition(
                                      term: 'Capitalized Expenses',
                                      definition: 'Sum of expenses flagged as isCapitalized = true.',
                                      valueDisplay: CalculationEngine.formatCurrency(capitalizedTotal),
                                    ),
                                  ],
                                  calculatedResultDisplay:
                                      CalculationEngine.formatCurrency(20000000 + capitalizedTotal),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CalculationEngine.formatCurrency(capitalizedTotal),
                              style: AppTypography.amountLarge.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Period Expense Summary Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Period Expenses (P&L Expensed)',
                              style: AppTypography.secondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CalculationEngine.formatCurrency(periodTotal),
                              style: AppTypography.amountLarge.copyWith(
                                color: AppColors.warningText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        ),

        // Filter Bar (Search, Project, Category, Date Range, Capitalization)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 220,
                height: 38,
                child: TextField(
                  onChanged: (val) => ref.read(expensesSearchQueryProvider.notifier).state = val,
                  decoration: const InputDecoration(
                    hintText: 'Search vendor, notes...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: AppTypography.input.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),

              // Project Filter Dropdown
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
                      onChanged: (val) => ref.read(expensesSelectedProjectIdProvider.notifier).state = val,
                      style: AppTypography.body.copyWith(fontSize: 13),
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
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
                    hint: Text('All Categories', style: AppTypography.secondary),
                    items: [
                      const DropdownMenuItem<ExpenseCategory?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...ExpenseCategory.values.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name.toUpperCase()),
                          )),
                    ],
                    onChanged: (val) => ref.read(expensesCategoryFilterProvider.notifier).state = val,
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
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(range.label, style: AppTypography.input.copyWith(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(expensesDateRangeFilterProvider.notifier).state = val;
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
                    hint: Text('All Asset Types', style: AppTypography.secondary),
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
                    onChanged: (val) => ref.read(expensesIsCapitalizedFilterProvider.notifier).state = val,
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Expenses Data Table
        Expanded(
          child: expensesAsync.when(
            loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Center(
              child: Text(
                'Error loading expenses: $err',
                style: AppTypography.body.copyWith(color: AppColors.dangerText),
              ),
            ),
            data: (expensesList) {
              final filtered = expensesList.where((e) {
                if (selectedProjectId != null && e.projectId != selectedProjectId) {
                  return false;
                }
                if (categoryFilter != null && e.category != categoryFilter) {
                  return false;
                }
                if (isCapitalizedFilter != null && e.isCapitalized != isCapitalizedFilter) {
                  return false;
                }
                if (!isDateInFilterRange(e.expenseDate, dateRangeFilter)) {
                  return false;
                }
                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  final matchVendor = e.vendorName?.toLowerCase().contains(q) ?? false;
                  final matchNotes = e.notes?.toLowerCase().contains(q) ?? false;
                  if (!matchVendor && !matchNotes) return false;
                }
                return true;
              }).toList();

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Expense Date', width: 130),
                  DataTableColumn(label: 'Category', width: 160),
                  DataTableColumn(label: 'Vendor / Receiver', width: 170),
                  DataTableColumn(label: 'Amount Paid', width: 150),
                  DataTableColumn(label: 'Accounting Type', width: 180),
                  DataTableColumn(label: 'Notes & Description'),
                ],
                rows: filtered.map((e) {
                  return [
                    Text(
                      DateFormat('dd MMM yyyy').format(e.expenseDate),
                      style: AppTypography.secondary,
                    ),
                    Text(
                      e.category.name.toUpperCase(),
                      style: AppTypography.tableCell.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      e.vendorName ?? '—',
                      style: AppTypography.tableCell,
                    ),
                    Text(
                      CalculationEngine.formatCurrency(e.amount),
                      style: AppTypography.amountMedium.copyWith(fontSize: 14),
                    ),
                    StatusBadge(
                      label: e.isCapitalized ? 'CAPITALIZED (COST)' : 'PERIOD EXPENSE (P&L)',
                      type: e.isCapitalized ? BadgeType.info : BadgeType.warning,
                    ),
                    Text(
                      e.notes ?? '—',
                      style: AppTypography.secondary,
                    ),
                  ];
                }).toList(),
                emptyMessage: 'No expense records found matching criteria.',
              );
            },
          ),
        ),
      ],
    );
  }
}
