import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../core/widgets/formula_explainability_dialog.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../projects/presentation/projects_providers.dart';
import '../domain/installment_model.dart';
import '../domain/transaction_model.dart';
import 'installments_providers.dart';
import 'widgets/payment_record_dialog.dart';
import 'widgets/void_transaction_dialog.dart';

final installmentsTabProvider = StateProvider.autoDispose<int>((ref) => 0);
final installmentsSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);
final installmentsSelectedProjectIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final installmentsStatusFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);
final installmentsPaymentMethodFilterProvider =
    StateProvider.autoDispose<PaymentMethod?>((ref) => null);
final installmentsDateRangeFilterProvider =
    StateProvider.autoDispose<DashboardDateRange>(
      (ref) => DashboardDateRange.allTime,
    );

class InstallmentsListScreen extends ConsumerWidget {
  const InstallmentsListScreen({super.key});

  BadgeType _getBadgeType(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'CLEARED':
        return BadgeType.success;
      case 'PENDING':
      case 'PARTIAL':
      case 'CASH_WARNING':
        return BadgeType.warning;
      case 'OVERDUE':
      case 'VOIDED':
        return BadgeType.danger;
      default:
        return BadgeType.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(installmentsTabProvider);
    final searchQuery = ref.watch(installmentsSearchQueryProvider);
    final selectedProjectId = ref.watch(installmentsSelectedProjectIdProvider);
    final statusFilter = ref.watch(installmentsStatusFilterProvider);
    final paymentMethodFilter = ref.watch(
      installmentsPaymentMethodFilterProvider,
    );
    final dateRangeFilter = ref.watch(installmentsDateRangeFilterProvider);

    final currentRole = ref.watch(currentRoleProvider);
    final installmentsAsync = ref.watch(installmentsListStreamProvider);
    final transactionsAsync = ref.watch(transactionsListStreamProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);

    final isFilterActive =
        searchQuery.isNotEmpty ||
        selectedProjectId != null ||
        statusFilter != null ||
        paymentMethodFilter != null ||
        dateRangeFilter != DashboardDateRange.allTime;

    void resetFilters() {
      ref.read(installmentsSearchQueryProvider.notifier).state = '';
      ref.read(installmentsSelectedProjectIdProvider.notifier).state = null;
      ref.read(installmentsStatusFilterProvider.notifier).state = null;
      ref.read(installmentsPaymentMethodFilterProvider.notifier).state = null;
      ref.read(installmentsDateRangeFilterProvider.notifier).state =
          DashboardDateRange.allTime;
    }

    final tabs = ['Installments Schedule', 'Transactions Audit'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Installments & Payment Ledger',
          subtitle:
              'Track installment payment schedules, record buyer transactions, and audit voided payments.',
          icon: Icons.payments_outlined,
          actions: [
            ElevatedButton.icon(
              onPressed: () => PaymentRecordDialog.show(context),
              icon: const Icon(Icons.add_card, size: 18),
              label: const Text('Record Payment'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Navigation Tabs Row
        Row(
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
                    onTap: () {
                      ref.read(installmentsTabProvider.notifier).state = index;
                      ref
                              .read(installmentsStatusFilterProvider.notifier)
                              .state =
                          null;
                      ref
                              .read(
                                installmentsPaymentMethodFilterProvider
                                    .notifier,
                              )
                              .state =
                          null;
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surface
                            : Colors.transparent,
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
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter Bar (Search, Project, Status, Payment Method, Date Range, Reset)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Search Input
              SizedBox(
                width: 240,
                height: 38,
                child: TextField(
                  onChanged: (val) =>
                      ref.read(installmentsSearchQueryProvider.notifier).state =
                          val,
                  decoration: InputDecoration(
                    hintText: selectedTabIndex == 0
                        ? 'Search inst #, status...'
                        : 'Search tx ID, ref, method...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                      hint: Text(
                        'All Projects',
                        style: AppTypography.secondary,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Projects'),
                        ),
                        ...projects.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} (${p.code})'),
                          ),
                        ),
                      ],
                      onChanged: (val) => ref
                          .read(
                            installmentsSelectedProjectIdProvider.notifier,
                          )
                          .state = val,
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
                  child: DropdownButton<String?>(
                    value: statusFilter,
                    hint: Text('All Statuses', style: AppTypography.secondary),
                    items: selectedTabIndex == 0
                        ? const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('All Statuses'),
                            ),
                            DropdownMenuItem(
                              value: 'PENDING',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'PARTIAL',
                              child: Text('Partially Paid'),
                            ),
                            DropdownMenuItem(
                              value: 'PAID',
                              child: Text('Paid'),
                            ),
                            DropdownMenuItem(
                              value: 'OVERDUE',
                              child: Text('Overdue'),
                            ),
                          ]
                        : const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('All Statuses'),
                            ),
                            DropdownMenuItem(
                              value: 'CLEARED',
                              child: Text('Cleared'),
                            ),
                            DropdownMenuItem(
                              value: 'VOIDED',
                              child: Text('Voided'),
                            ),
                            DropdownMenuItem(
                              value: 'CASH_WARNING',
                              child: Text('Sec 269ST Warning'),
                            ),
                          ],
                    onChanged: (val) =>
                        ref
                                .read(installmentsStatusFilterProvider.notifier)
                                .state =
                            val,
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Payment Method Filter Dropdown (Active for Transactions Audit Tab)
              if (selectedTabIndex == 1) ...[
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentMethod?>(
                      value: paymentMethodFilter,
                      hint: Text(
                        'All Payment Methods',
                        style: AppTypography.secondary,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Payment Methods'),
                        ),
                        ...PaymentMethod.values.map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.name.toUpperCase()),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          ref
                                  .read(
                                    installmentsPaymentMethodFilterProvider
                                        .notifier,
                                  )
                                  .state =
                              val,
                      style: AppTypography.body.copyWith(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

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
                            .read(installmentsDateRangeFilterProvider.notifier)
                            .state = val;
                      }
                    },
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Reset Filters Button
              if (isFilterActive)
                TextButton.icon(
                  onPressed: resetFilters,
                  icon: const Icon(
                    Icons.clear_all,
                    size: 16,
                    color: AppColors.dangerText,
                  ),
                  label: Text(
                    'Reset Filters',
                    style: AppTypography.secondary.copyWith(
                      color: AppColors.dangerText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab Views with Smooth Switcher Animation
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
                statusFilter,
                paymentMethodFilter,
                dateRangeFilter,
                currentRole,
                installmentsAsync,
                transactionsAsync,
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
    String? statusFilter,
    PaymentMethod? paymentMethodFilter,
    DashboardDateRange dateRangeFilter,
    UserRole currentRole,
    AsyncValue<List<InstallmentModel>> installmentsAsync,
    AsyncValue<List<TransactionModel>> transactionsAsync,
  ) {
    if (tabIndex == 0) {
      return installmentsAsync.when(
        loading: () =>
            const CustomDataTable(columns: [], rows: [], isLoading: true),
        error: (err, stack) => Center(
          child: Text(
            'Error loading installments: $err',
            style: AppTypography.secondary.copyWith(
              color: AppColors.dangerText,
            ),
          ),
        ),
        data: (installments) {
          final filtered = installments.where((inst) {
            if (selectedProjectId != null && inst.projectId != selectedProjectId) {
              return false;
            }
            if (!isDateInFilterRange(inst.dueDate, dateRangeFilter)) {
              return false;
            }
            if (statusFilter != null) {
              final isOverdue =
                  inst.dueDate.isBefore(DateTime.now()) &&
                  inst.balanceRemaining > 0;
              final currentStatus = isOverdue
                  ? 'OVERDUE'
                  : (inst.paidAmount >= inst.dueAmount
                        ? 'PAID'
                        : (inst.paidAmount > 0 ? 'PARTIAL' : 'PENDING'));
              if (currentStatus != statusFilter) return false;
            }
            if (searchQuery.isNotEmpty) {
              final q = searchQuery.toLowerCase();
              final matchNum = inst.installmentNumber.toString().contains(q);
              final matchDue = inst.dueAmount.toString().contains(q);
              final matchBuyer =
                  inst.buyerName?.toLowerCase().contains(q) ?? false;
              final matchProject =
                  inst.projectName?.toLowerCase().contains(q) ?? false;
              final matchPlot =
                  inst.plotInfo?.toLowerCase().contains(q) ?? false;
              if (!matchNum &&
                  !matchDue &&
                  !matchBuyer &&
                  !matchProject &&
                  !matchPlot) {
                return false;
              }
            }
            return true;
          }).toList();

          return CustomDataTable(
            columns: const [
              DataTableColumn(label: 'Customer / Landowner', width: 185),
              DataTableColumn(label: 'Project', width: 135),
              DataTableColumn(label: 'Plot / Parcel', width: 105),
              DataTableColumn(label: 'Inst #', width: 65),
              DataTableColumn(label: 'Due Date', width: 105),
              DataTableColumn(label: 'Due Amount', width: 115),
              DataTableColumn(label: 'Paid Amount', width: 115),
              DataTableColumn(label: 'Outstanding Balance', width: 155),
              DataTableColumn(label: 'Status', width: 100),
              DataTableColumn(
                label: 'Actions',
                width: 85,
                alignment: Alignment.center,
              ),
            ],
            rows: filtered.map((inst) {
              final isOverdue =
                  inst.dueDate.isBefore(DateTime.now()) &&
                  inst.balanceRemaining > 0;
              final statusText = isOverdue
                  ? 'OVERDUE'
                  : (inst.paidAmount >= inst.dueAmount
                        ? 'PAID'
                        : (inst.paidAmount > 0 ? 'PARTIAL' : 'PENDING'));

              return [
                Text(
                  inst.buyerName ?? '—',
                  style: AppTypography.tableCell.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(inst.projectName ?? '—', style: AppTypography.tableCell),
                Text(inst.plotInfo ?? '—', style: AppTypography.secondary),
                Text(
                  '#${inst.installmentNumber}',
                  style: AppTypography.tableCell.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(inst.dueDate),
                  style: AppTypography.secondary,
                ),
                Text(
                  CalculationEngine.formatCurrency(inst.dueAmount),
                  style: AppTypography.amountMedium,
                ),
                Text(
                  CalculationEngine.formatCurrency(inst.paidAmount),
                  style: AppTypography.amountMedium.copyWith(
                    color: AppColors.successText,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      CalculationEngine.formatCurrency(inst.balanceRemaining),
                      style: AppTypography.amountMedium.copyWith(
                        color: inst.balanceRemaining > 0
                            ? AppColors.warningText
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FormulaInfoButton(
                      figureTitle: 'Installment Balance Remaining',
                      plainWordsFormula:
                          'Installment Balance = Scheduled Due Amount − Cleared Paid Amount',
                      terms: [
                        FormulaTermDefinition(
                          term: 'Scheduled Due Amount',
                          definition: 'Agreed installment payment value.',
                          valueDisplay: CalculationEngine.formatCurrency(
                            inst.dueAmount,
                          ),
                        ),
                        FormulaTermDefinition(
                          term: 'Cleared Paid Amount',
                          definition:
                              'Total cleared non-voided receipts for this installment.',
                          valueDisplay: CalculationEngine.formatCurrency(
                            inst.paidAmount,
                          ),
                        ),
                      ],
                      calculatedResultDisplay: CalculationEngine.formatCurrency(
                        inst.balanceRemaining,
                      ),
                    ),
                  ],
                ),
                StatusBadge(label: statusText, type: _getBadgeType(statusText)),
                if (inst.balanceRemaining > 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () =>
                        PaymentRecordDialog.show(context, installment: inst),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.successText,
                    size: 20,
                  ),
              ];
            }).toList(),
            emptyMessage: 'No installments schedule recorded.',
          );
        },
      );
    } else {
      return transactionsAsync.when(
        loading: () =>
            const CustomDataTable(columns: [], rows: [], isLoading: true),
        error: (err, stack) => Center(
          child: Text(
            'Error loading transactions audit: $err',
            style: AppTypography.secondary.copyWith(
              color: AppColors.dangerText,
            ),
          ),
        ),
        data: (transactions) {
          final filtered = transactions.where((tx) {
            if (selectedProjectId != null && tx.projectId != selectedProjectId) {
              return false;
            }
            if (!isDateInFilterRange(tx.paymentDate, dateRangeFilter)) {
              return false;
            }
            if (paymentMethodFilter != null &&
                tx.paymentMethod != paymentMethodFilter) {
              return false;
            }
            if (statusFilter != null) {
              if (statusFilter == 'CLEARED' &&
                  (tx.isVoided || tx.isCashOverLimit)) {
                return false;
              }
              if (statusFilter == 'VOIDED' && !tx.isVoided) {
                return false;
              }
              if (statusFilter == 'CASH_WARNING' && !tx.isCashOverLimit) {
                return false;
              }
            }
            if (searchQuery.isNotEmpty) {
              final q = searchQuery.toLowerCase();
              final matchId = tx.id.toLowerCase().contains(q);
              final matchRef =
                  tx.referenceNumber?.toLowerCase().contains(q) ?? false;
              final matchMethod = tx.paymentMethod.name.toLowerCase().contains(
                q,
              );
              final matchBuyer =
                  tx.buyerName?.toLowerCase().contains(q) ?? false;
              final matchProject =
                  tx.projectName?.toLowerCase().contains(q) ?? false;
              if (!matchId &&
                  !matchRef &&
                  !matchMethod &&
                  !matchBuyer &&
                  !matchProject) {
                return false;
              }
            }
            return true;
          }).toList();

          return CustomDataTable(
            columns: const [
              DataTableColumn(label: 'Tx ID', width: 100),
              DataTableColumn(label: 'Customer / Landowner', width: 185),
              DataTableColumn(label: 'Project', width: 135),
              DataTableColumn(label: 'Payment Date', width: 110),
              DataTableColumn(label: 'Method', width: 95),
              DataTableColumn(label: 'Reference #', width: 125),
              DataTableColumn(label: 'Paid Amount', width: 115),
              DataTableColumn(label: 'Sec 269ST Compliance', width: 165),
              DataTableColumn(label: 'Status', width: 95),
              DataTableColumn(
                label: 'Actions',
                width: 85,
                alignment: Alignment.center,
              ),
            ],
            rows: filtered.map((tx) {
              return [
                Text(
                  '#${tx.id.substring(0, tx.id.length > 8 ? 8 : tx.id.length)}',
                  style: AppTypography.tableCell.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tx.buyerName ?? '—',
                  style: AppTypography.tableCell.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(tx.projectName ?? '—', style: AppTypography.tableCell),
                Text(
                  DateFormat('dd MMM yyyy').format(tx.paymentDate),
                  style: AppTypography.secondary,
                ),
                Text(
                  tx.paymentMethod.name.toUpperCase(),
                  style: AppTypography.tableCell,
                ),
                Text(tx.referenceNumber ?? '—', style: AppTypography.secondary),
                Text(
                  CalculationEngine.formatCurrency(tx.amount),
                  style: AppTypography.amountMedium.copyWith(
                    color: tx.isVoided
                        ? AppColors.textDisabled
                        : AppColors.successText,
                    decoration: tx.isVoided ? TextDecoration.lineThrough : null,
                  ),
                ),
                StatusBadge(
                  label: tx.isCashOverLimit
                      ? 'VIOLATION (>= 2 Lakh)'
                      : 'COMPLIANT (< 2 Lakh)',
                  type: tx.isCashOverLimit
                      ? BadgeType.danger
                      : BadgeType.success,
                ),
                StatusBadge(
                  label: tx.isVoided ? 'VOIDED' : 'CLEARED',
                  type: tx.isVoided ? BadgeType.danger : BadgeType.success,
                ),
                if (!tx.isVoided && currentRole.isAdmin)
                  IconButton(
                    icon: const Icon(
                      Icons.block_outlined,
                      color: AppColors.dangerText,
                      size: 18,
                    ),
                    tooltip: 'Void Transaction (Sec 269ST / Error)',
                    onPressed: () =>
                        VoidTransactionDialog.show(context, transaction: tx),
                  )
                else if (tx.isVoided)
                  Tooltip(
                    message:
                        'Voided by ${tx.createdBy}: ${tx.voidReason ?? 'No reason given'}',
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  )
                else
                  Text('Non-Admin', style: AppTypography.secondary),
              ];
            }).toList(),
            emptyMessage: 'No transactions recorded.',
          );
        },
      );
    }
  }
}
