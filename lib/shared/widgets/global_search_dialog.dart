import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/buyers_sales/domain/buyer_model.dart';
import '../../features/buyers_sales/domain/sale_model.dart';
import '../../features/buyers_sales/presentation/sales_providers.dart';
import '../../features/expenses/domain/expense_model.dart';
import '../../features/expenses/presentation/expenses_providers.dart';
import '../../features/installments_payments/domain/transaction_model.dart';
import '../../features/installments_payments/presentation/installments_providers.dart';
import '../../features/investors/domain/investor_model.dart';
import '../../features/investors/presentation/investors_providers.dart';
import '../../features/landowners/domain/landowner_model.dart';
import '../../features/landowners/presentation/landowners_providers.dart';
import '../../features/plots/domain/plot_model.dart';
import '../../features/plots/presentation/plots_providers.dart';
import '../../features/projects/domain/project_model.dart';
import '../../features/projects/presentation/projects_providers.dart';

enum SearchCategory {
  project,
  plot,
  landowner,
  investor,
  buyer,
  sale,
  expense,
  transaction,
}

class SearchResultItem {
  final String title;
  final String subtitle;
  final String categoryName;
  final SearchCategory category;
  final IconData icon;
  final String route;
  final String? badgeText;
  final Color? badgeColor;

  SearchResultItem({
    required this.title,
    required this.subtitle,
    required this.categoryName,
    required this.category,
    required this.icon,
    required this.route,
    this.badgeText,
    this.badgeColor,
  });
}

class GlobalSearchDialog extends ConsumerStatefulWidget {
  final String initialQuery;

  const GlobalSearchDialog({
    super.key,
    this.initialQuery = '',
  });

  static Future<void> show(BuildContext context, {String initialQuery = ''}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GlobalSearchDialog(initialQuery: initialQuery),
    );
  }

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<SearchResultItem> _performSearch({
    required List<ProjectModel> projects,
    required List<PlotModel> plots,
    required List<LandownerModel> landowners,
    required List<InvestorModel> investors,
    required List<BuyerModel> buyers,
    required List<SaleModel> sales,
    required List<ExpenseModel> expenses,
    required List<TransactionModel> transactions,
  }) {
    if (_query.trim().isEmpty) return [];

    final q = _query.toLowerCase().trim();
    final results = <SearchResultItem>[];

    // 1. Projects
    for (final p in projects) {
      if (p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          title: p.name,
          subtitle: 'Code: ${p.code} • ${p.location}',
          categoryName: 'Projects',
          category: SearchCategory.project,
          icon: Icons.business_outlined,
          route: AppRoutes.projects,
          badgeText: p.code,
          badgeColor: AppColors.primary,
        ));
      }
    }

    // 2. Plots
    for (final p in plots) {
      final proj = projects.cast<ProjectModel?>().firstWhere(
            (proj) => proj?.id == p.projectId,
            orElse: () => null,
          );
      final projName = proj != null ? proj.name : 'Project #${p.projectId.substring(0, 4)}';

      if (p.plotNumber.toLowerCase().contains(q) ||
          p.status.name.toLowerCase().contains(q) ||
          projName.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          title: 'Plot ${p.plotNumber}',
          subtitle: '$projName • ${_currencyFormat.format(p.expectedPrice)}',
          categoryName: 'Plots',
          category: SearchCategory.plot,
          icon: Icons.grid_view_outlined,
          route: AppRoutes.plots,
          badgeText: p.status.name.toUpperCase(),
          badgeColor: p.status.name.toLowerCase() == 'available'
              ? AppColors.successText
              : AppColors.warningText,
        ));
      }
    }

    // 3. Landowners
    for (final l in landowners) {
      if (l.name.toLowerCase().contains(q) ||
          l.phone.contains(q) ||
          (l.pan != null && l.pan!.toLowerCase().contains(q))) {
        results.add(SearchResultItem(
          title: l.name,
          subtitle: 'Phone: ${l.phone}${l.pan != null ? " • PAN: ${l.pan}" : ""}',
          categoryName: 'Landowners',
          category: SearchCategory.landowner,
          icon: Icons.landscape_outlined,
          route: AppRoutes.landowners,
          badgeText: 'Landowner',
          badgeColor: AppColors.accent,
        ));
      }
    }

    // 4. Investors
    for (final inv in investors) {
      if (inv.name.toLowerCase().contains(q) ||
          inv.phone.contains(q) ||
          (inv.email != null && inv.email!.toLowerCase().contains(q)) ||
          (inv.pan != null && inv.pan!.toLowerCase().contains(q))) {
        results.add(SearchResultItem(
          title: inv.name,
          subtitle: 'Phone: ${inv.phone}${inv.email != null ? " • ${inv.email}" : ""}',
          categoryName: 'Investors',
          category: SearchCategory.investor,
          icon: Icons.attach_money_outlined,
          route: AppRoutes.investors,
          badgeText: 'Investor',
          badgeColor: AppColors.primary,
        ));
      }
    }

    // 5. Buyers
    for (final b in buyers) {
      if (b.name.toLowerCase().contains(q) ||
          b.phone.contains(q) ||
          (b.email != null && b.email!.toLowerCase().contains(q))) {
        results.add(SearchResultItem(
          title: b.name,
          subtitle: 'Phone: ${b.phone}${b.email != null ? " • ${b.email}" : ""}',
          categoryName: 'Buyers',
          category: SearchCategory.buyer,
          icon: Icons.person_outline,
          route: AppRoutes.buyersSales,
          badgeText: 'Buyer',
          badgeColor: AppColors.infoText,
        ));
      }
    }

    // 6. Sales
    for (final s in sales) {
      if (s.buyerName.toLowerCase().contains(q) ||
          s.id.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          title: 'Sale to ${s.buyerName}',
          subtitle: 'Agreed Price: ${_currencyFormat.format(s.agreedPrice)} • Ref #${s.id.length > 8 ? s.id.substring(0, 8) : s.id}',
          categoryName: 'Sales Agreements',
          category: SearchCategory.sale,
          icon: Icons.shopping_bag_outlined,
          route: AppRoutes.buyersSales,
          badgeText: s.saleType.name.toUpperCase(),
          badgeColor: AppColors.successText,
        ));
      }
    }

    // 7. Expenses
    for (final e in expenses) {
      if ((e.vendor != null && e.vendor!.toLowerCase().contains(q)) ||
          e.category.name.toLowerCase().contains(q) ||
          (e.notes != null && e.notes!.toLowerCase().contains(q))) {
        results.add(SearchResultItem(
          title: '${e.category.name.toUpperCase()}${e.vendor != null ? " - ${e.vendor}" : ""}',
          subtitle: 'Amount: ${_currencyFormat.format(e.amount)}${e.notes != null ? " • ${e.notes}" : ""}',
          categoryName: 'Expenses',
          category: SearchCategory.expense,
          icon: Icons.receipt_long_outlined,
          route: AppRoutes.expenses,
          badgeText: e.category.name,
          badgeColor: AppColors.dangerText,
        ));
      }
    }

    // 8. Transactions
    for (final t in transactions) {
      if (t.paymentMethod.name.toLowerCase().contains(q) ||
          (t.referenceNumber != null && t.referenceNumber!.toLowerCase().contains(q)) ||
          (t.buyerName != null && t.buyerName!.toLowerCase().contains(q)) ||
          (t.projectName != null && t.projectName!.toLowerCase().contains(q))) {
        results.add(SearchResultItem(
          title: 'Payment ${_currencyFormat.format(t.amount)} (${t.paymentMethod.name})',
          subtitle: 'Ref: ${t.referenceNumber ?? "N/A"}${t.buyerName != null ? " • Buyer: ${t.buyerName}" : ""}',
          categoryName: 'Transactions',
          category: SearchCategory.transaction,
          icon: Icons.payments_outlined,
          route: AppRoutes.installments,
          badgeText: t.paymentMethod.name,
          badgeColor: AppColors.infoText,
        ));
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListStreamProvider);
    final plotsAsync = ref.watch(plotsListStreamProvider);
    final landownersAsync = ref.watch(landownersListStreamProvider);
    final investorsAsync = ref.watch(investorsListStreamProvider);
    final buyersAsync = ref.watch(buyersListStreamProvider);
    final salesAsync = ref.watch(salesListStreamProvider);
    final expensesAsync = ref.watch(expensesListStreamProvider);
    final transactionsAsync = ref.watch(transactionsListStreamProvider);

    final projects = projectsAsync.value ?? [];
    final plots = plotsAsync.value ?? [];
    final landowners = landownersAsync.value ?? [];
    final investors = investorsAsync.value ?? [];
    final buyers = buyersAsync.value ?? [];
    final sales = salesAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];
    final transactions = transactionsAsync.value ?? [];

    final searchResults = _performSearch(
      projects: projects,
      plots: plots,
      landowners: landowners,
      investors: investors,
      buyers: buyers,
      sales: sales,
      expenses: expenses,
      transactions: transactions,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          width: 660,
          constraints: const BoxConstraints(maxHeight: 560),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Input Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: (val) {
                          setState(() {
                            _query = val;
                          });
                        },
                        style: AppTypography.cardTitle,
                        decoration: InputDecoration(
                          hintText: 'Search land, plots, landowners, investors, sales, expenses...',
                          hintStyle: AppTypography.body.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        tooltip: 'Clear search',
                      ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ESC',
                              style: AppTypography.secondary.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results or Empty/Initial Hint View
              Expanded(
                child: _query.trim().isEmpty
                    ? _buildInitialHintView()
                    : searchResults.isEmpty
                        ? _buildNoResultsView()
                        : _buildSearchResultsList(searchResults),
              ),

              // Footer Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _query.isEmpty
                          ? 'Global system search'
                          : '${searchResults.length} result${searchResults.length == 1 ? '' : 's'} found',
                      style: AppTypography.secondary.copyWith(fontSize: 12),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.keyboard_return, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Press item to navigate',
                          style: AppTypography.secondary.copyWith(fontSize: 12),
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
    );
  }

  Widget _buildInitialHintView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search Tips',
            style: AppTypography.cardTitle.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildTipRow(Icons.business, 'Search Projects', 'Type project name or code e.g. "Green Valley" or "PROJ-01"'),
          _buildTipRow(Icons.grid_view, 'Search Plots', 'Type plot number or status e.g. "102" or "Available"'),
          _buildTipRow(Icons.landscape, 'Search Landowners', 'Type landowner name, phone number, or PAN card'),
          _buildTipRow(Icons.attach_money, 'Search Investors', 'Type investor name, phone, or email address'),
          _buildTipRow(Icons.person_outline, 'Search Buyers & Sales', 'Type buyer name, sale agreement reference, or phone'),
          _buildTipRow(Icons.receipt_long, 'Search Expenses', 'Type vendor name or category e.g. "Legal", "Fencing"'),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: AppTypography.secondary.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No results found for "$_query"',
              style: AppTypography.cardTitle.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching with a different keyword, code, or phone number.',
              style: AppTypography.secondary.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(List<SearchResultItem> results) {
    final grouped = <String, List<SearchResultItem>>{};
    for (final item in results) {
      grouped.putIfAbsent(item.categoryName, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final categoryName = grouped.keys.elementAt(index);
        final items = grouped[categoryName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                categoryName.toUpperCase(),
                style: AppTypography.secondary.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
            ),
            ...items.map((item) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(item.icon, size: 18, color: AppColors.textPrimary),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (item.badgeColor ?? AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.badgeText!,
                          style: AppTypography.secondary.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.badgeColor ?? AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  item.subtitle,
                  style: AppTypography.secondary.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.route);
                },
              );
            }),
            const Divider(height: 16, color: AppColors.border),
          ],
        );
      },
    );
  }
}
