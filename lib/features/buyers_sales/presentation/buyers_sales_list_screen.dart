import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../core/widgets/formula_explainability_dialog.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../domain/sale_model.dart';
import 'sales_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../projects/domain/project_model.dart';
import '../../projects/presentation/projects_providers.dart';
import '../domain/buyer_model.dart';
import 'widgets/buyer_form_dialog.dart';
import 'widgets/buyer_sale_pdf_dialog.dart';
import 'widgets/sale_agreement_dialog.dart';

final buyersSalesSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final buyersSalesDateRangeFilterProvider = StateProvider.autoDispose<DashboardDateRange>((ref) => DashboardDateRange.allTime);
final buyersSalesSelectedProjectIdProvider = StateProvider.autoDispose<String?>((ref) => null);

class _BuyerSaleRowItem {
  final BuyerModel buyer;
  final SaleModel? sale;

  _BuyerSaleRowItem({required this.buyer, required this.sale});
}

class BuyersSalesListScreen extends ConsumerWidget {
  const BuyersSalesListScreen({super.key});

  Future<void> _handleDeleteBuyer(BuildContext context, WidgetRef ref, BuyerModel buyer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever_outlined, color: AppColors.dangerText, size: 24),
            const SizedBox(width: 8),
            Text('Confirm Delete Buyer', style: AppTypography.cardTitle),
          ],
        ),
        content: Text(
          'Are you sure you want to delete buyer "${buyer.name}" (${buyer.phone})?\n\n'
          'WARNING: This will delete the buyer profile and any sales/installments associated with this buyer.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerText),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Buyer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(salesRepositoryProvider);
        await repo.deleteBuyer(buyer.id, userId: 'admin_user');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Buyer "${buyer.name}" deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting buyer: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(buyersSalesSearchQueryProvider);
    final dateRangeFilter = ref.watch(buyersSalesDateRangeFilterProvider);
    final selectedProjectId = ref.watch(buyersSalesSelectedProjectIdProvider);

    final buyersAsync = ref.watch(buyersListStreamProvider);
    final salesAsync = ref.watch(salesListStreamProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Customers & Sales Agreements',
          subtitle:
              'Manage customer KYC profiles, execute whole-land or plot sales, and enforce DLC/Circle rate compliance.',
          icon: Icons.people_outline,
          actions: [
            OutlinedButton.icon(
              onPressed: () => BuyerFormDialog.show(context),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Add Customer'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => SaleAgreementDialog.show(context),
              icon: const Icon(Icons.handshake_outlined, size: 18),
              label: const Text('New Sale Agreement'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Bar (Search, Project, Date Range)
        Row(
          children: [
            SizedBox(
              width: 280,
              height: 38,
              child: TextField(
                onChanged: (val) => ref.read(buyersSalesSearchQueryProvider.notifier).state = val,
                decoration: const InputDecoration(
                  hintText: 'Search customer name, phone, sale type...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: AppTypography.input.copyWith(fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
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
                    onChanged: (val) => ref.read(buyersSalesSelectedProjectIdProvider.notifier).state = val,
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
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
                      ref.read(buyersSalesDateRangeFilterProvider.notifier).state = val;
                    }
                  },
                  style: AppTypography.body.copyWith(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sales & Buyers Data Table
        Expanded(
          child: buyersAsync.when(
            loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Center(
              child: Text(
                'Error loading buyers: $err',
                style: AppTypography.body.copyWith(color: AppColors.dangerText),
              ),
            ),
            data: (buyersList) {
              return salesAsync.when(
                loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading sales: $err',
                    style: AppTypography.body.copyWith(color: AppColors.dangerText),
                  ),
                ),
                data: (salesList) {
                  final List<_BuyerSaleRowItem> allItems = [];
                  final Set<String> processedSaleIds = {};

                  for (final buyer in buyersList) {
                    final buyerSales = salesList.where((s) => s.buyerId == buyer.id).toList();
                    if (buyerSales.isEmpty) {
                      allItems.add(_BuyerSaleRowItem(buyer: buyer, sale: null));
                    } else {
                      for (final sale in buyerSales) {
                        allItems.add(_BuyerSaleRowItem(buyer: buyer, sale: sale));
                        processedSaleIds.add(sale.id);
                      }
                    }
                  }

                  for (final sale in salesList) {
                    if (!processedSaleIds.contains(sale.id)) {
                      allItems.add(_BuyerSaleRowItem(
                        buyer: BuyerModel(
                          id: sale.buyerId,
                          name: sale.buyerName,
                          phone: '',
                          createdAt: sale.saleDate,
                        ),
                        sale: sale,
                      ));
                    }
                  }

                  final filtered = allItems.where((item) {
                    if (selectedProjectId != null && item.sale?.projectId != selectedProjectId) {
                      return false;
                    }
                    final dateToCheck = item.sale?.saleDate ?? item.buyer.createdAt;
                    if (!isDateInFilterRange(dateToCheck, dateRangeFilter)) {
                      return false;
                    }
                    if (searchQuery.isEmpty) return true;
                    final q = searchQuery.toLowerCase();
                    final nameMatch = item.buyer.name.toLowerCase().contains(q);
                    final phoneMatch = item.buyer.phone.toLowerCase().contains(q);
                    final saleTypeMatch = item.sale?.saleType.name.toLowerCase().contains(q) ?? false;
                    return nameMatch || phoneMatch || saleTypeMatch;
                  }).toList();

                  return CustomDataTable(
                    columns: const [
                      DataTableColumn(label: 'Customer Name'),
                      DataTableColumn(label: 'Sale Type', width: 150),
                      DataTableColumn(label: 'Agreed Price', width: 150),
                      DataTableColumn(label: 'Net Sale Proceeds', width: 180),
                      DataTableColumn(label: 'Sale Date', width: 130),
                      DataTableColumn(label: 'Compliance Status', width: 170),
                      DataTableColumn(label: 'Actions', width: 145, alignment: Alignment.center),
                    ],
                    rows: filtered.map((item) {
                      final buyer = item.buyer;
                      final sale = item.sale;
                      final hasAgreement = sale != null;

                      if (!hasAgreement) {
                        return [
                          Text(
                            buyer.name,
                            style: AppTypography.tableCell.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Registered Only', style: AppTypography.secondary),
                          Text('—', style: AppTypography.secondary),
                          Text('—', style: AppTypography.secondary),
                          Text(
                            DateFormat('dd MMM yyyy').format(buyer.createdAt),
                            style: AppTypography.secondary,
                          ),
                          const StatusBadge(label: 'NO SALE YET', type: BadgeType.info),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, color: AppColors.accent, size: 20),
                                tooltip: 'Execute Sale Agreement',
                                onPressed: () => SaleAgreementDialog.show(
                                  context,
                                  preselectedBuyerId: buyer.id,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
                                tooltip: 'Edit Buyer Profile',
                                onPressed: () => BuyerFormDialog.show(
                                  context,
                                  buyer: buyer,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.dangerText, size: 18),
                                tooltip: 'Delete Buyer',
                                onPressed: () => _handleDeleteBuyer(context, ref, buyer),
                              ),
                            ],
                          ),
                        ];
                      }

                      final formattedDate = DateFormat('dd MMM yyyy').format(sale.saleDate);
                      final isPlotSale = sale.saleType == SaleType.plotWise;
                      final isUnderDlc = sale.isBelowCircleRate;
                      final netProceeds = sale.agreedPrice - sale.saleExpenses;

                      return [
                        Text(
                          buyer.name,
                          style: AppTypography.tableCell.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isPlotSale ? 'Plot Sale' : 'Land / Bulk Sale',
                          style: AppTypography.tableCell,
                        ),
                        Text(
                          CalculationEngine.formatCurrency(sale.agreedPrice),
                          style: AppTypography.amountMedium.copyWith(fontSize: 14),
                        ),
                        Row(
                          children: [
                            Text(
                              CalculationEngine.formatCurrency(netProceeds),
                              style: AppTypography.amountMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.successText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            FormulaInfoButton(
                              figureTitle: 'Net Sale Proceeds (${buyer.name})',
                              plainWordsFormula:
                                  'Net Sale Proceeds = Agreed Sale Price − Direct Sale Expenses',
                              terms: [
                                FormulaTermDefinition(
                                  term: 'Agreed Sale Price',
                                  definition: 'Total sales agreement contract value.',
                                  valueDisplay: CalculationEngine.formatCurrency(sale.agreedPrice),
                                ),
                                FormulaTermDefinition(
                                  term: 'Direct Sale Expenses',
                                  definition: 'Brokerage commission & registration expenses.',
                                  valueDisplay: CalculationEngine.formatCurrency(sale.saleExpenses),
                                ),
                              ],
                              calculatedResultDisplay:
                                  CalculationEngine.formatCurrency(netProceeds),
                            ),
                          ],
                        ),
                        Text(
                          formattedDate,
                          style: AppTypography.secondary,
                        ),
                        StatusBadge(
                          label: isUnderDlc ? 'BELOW CIRCLE RATE (WARNING)' : 'CIRCLE RATE COMPLIANT',
                          type: isUnderDlc ? BadgeType.warning : BadgeType.success,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.accent, size: 18),
                              tooltip: 'View / Print Sale Deed PDF',
                              onPressed: () {
                                final projects = ref.read(projectsListStreamProvider).value ?? [];
                                final project = projects.cast<ProjectModel?>().firstWhere(
                                      (p) => p?.id == sale.projectId,
                                      orElse: () => null,
                                    );
                                BuyerSalePdfDialog.show(
                                  context,
                                  sale: sale,
                                  buyer: buyer,
                                  projectName: project?.name ?? 'Project',
                                  projectCode: project?.code ?? '',
                                  projectLocation: project?.location ?? '',
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
                              tooltip: 'Edit Buyer Profile',
                              onPressed: () => BuyerFormDialog.show(
                                context,
                                buyer: buyer,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.dangerText, size: 18),
                              tooltip: 'Delete Buyer Profile',
                              onPressed: () => _handleDeleteBuyer(context, ref, buyer),
                            ),
                          ],
                        ),
                      ];
                    }).toList(),
                    emptyMessage: 'No sales agreements or buyers recorded.',
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
