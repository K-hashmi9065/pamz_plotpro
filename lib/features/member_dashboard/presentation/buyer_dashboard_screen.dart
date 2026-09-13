import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../buyers_sales/domain/sale_model.dart';
import '../../buyers_sales/presentation/sales_providers.dart';
import '../../buyers_sales/presentation/widgets/customer_invoice_pdf_dialog.dart';
import '../../projects/presentation/projects_providers.dart' hide projectByIdProvider;
import 'member_dashboard_providers.dart';
import 'member_dashboard_widgets.dart';

final _currencyFmt =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _dateFmt = DateFormat('dd MMM yyyy');

class BuyerDashboardScreen extends ConsumerWidget {
  const BuyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(buyerSalesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'My Purchases',
            subtitle: 'Your plots, payment status and transaction history.',
            icon: Icons.home_outlined,
            actions: const [],
          ),
          const SizedBox(height: 8),
          salesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style:
                      AppTypography.secondary.copyWith(color: AppColors.danger)),
            ),
            data: (sales) {
              if (sales.isEmpty) {
                return MemberEmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'No purchases yet',
                  subtitle: 'Your plot purchases will appear here.',
                );
              }

              // Aggregate totals
              double totalAgreed = 0;
              // Build project-wise grouping
              final Map<String, List<Sale>> projectSales = {};
              for (final sale in sales) {
                totalAgreed += sale.agreedPrice;
                projectSales
                    .putIfAbsent(sale.projectId, () => [])
                    .add(sale);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: MemberSummaryCard(
                            icon: Icons.receipt_long_outlined,
                            label: 'Total Purchases',
                            value: sales.length.toString(),
                            color: AppColors.accent,
                          )),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MemberSummaryCard(
                            icon: Icons.handshake_outlined,
                            label: 'Total Agreed',
                            value: _currencyFmt.format(totalAgreed),
                            color: AppColors.info,
                          )),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _BuyerTotalPaidCard(sales: sales),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _BuyerDuesCard(
                              sales: sales, totalAgreed: totalAgreed),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Project-wise sections
                  ...projectSales.entries.map((entry) {
                    return _ProjectSaleSection(
                        projectId: entry.key, sales: entry.value);
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Project-wise section ──────────────────────────────────────────────────────

class _ProjectSaleSection extends ConsumerWidget {
  final String projectId;
  final List<Sale> sales;

  const _ProjectSaleSection(
      {required this.projectId, required this.sales});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return projectAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (project) {
        final projectName = project?.name ?? 'Unknown Project';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberSectionHeader(title: projectName, icon: Icons.business_outlined),
            const SizedBox(height: 12),
            ...sales.map((sale) => _SaleCard(sale: sale)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _SaleCard extends ConsumerWidget {
  final Sale sale;
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync =
        ref.watch(saleInstallmentsProvider(sale.id));
    final transactionsAsync =
        ref.watch(saleTransactionsProvider(sale.id));
    final plotsAsync = ref.watch(salePlotsProvider(sale));
    final plots = plotsAsync.value ?? [];
    final transactions = transactionsAsync.value ?? [];

    return installmentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (installments) {
        final totalPaid = transactions.isNotEmpty
            ? transactions.fold(0.0, (s, t) => s + t.amount)
            : installments.fold(0.0, (s, i) => s + i.paidAmount);
        final remaining = (sale.agreedPrice - totalPaid).clamp(0.0, double.infinity);
        final paidInstallments =
            installments.where((i) => i.paidAmount > 0).toList();

        final plotNumbers = plots.map((p) => p.plotNumber).toList();
        final plotIdLabel = plotNumbers.isNotEmpty
            ? (plotNumbers.length == 1
                ? 'Plot No: ${plotNumbers.first}'
                : 'Plots: ${plotNumbers.join(", ")}')
            : null;

        String? plotAreaDisplay;
        if (plots.isNotEmpty) {
          if (plots.length == 1) {
            plotAreaDisplay = plots.first.formattedArea;
          } else {
            final totalSqFt = plots.fold(0.0, (sum, p) => sum + p.areaSqFt);
            plotAreaDisplay =
                '${NumberFormat('#,##,###.##').format(totalSqFt)} sq ft (${(totalSqFt / 1125.0).toStringAsFixed(2)} Kattha)';
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Sale · ${sale.saleType}',
                                style: AppTypography.cardTitle.copyWith(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              if (plotIdLabel != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.tag_rounded,
                                          size: 13, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        plotIdLabel,
                                        style: AppTypography.caption.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Sale Date: ${_dateFmt.format(sale.saleDate)}',
                                style: AppTypography.secondary
                                    .copyWith(fontSize: 12.5),
                              ),
                              if (plotAreaDisplay != null) ...[
                                Text('•',
                                    style: AppTypography.secondary
                                        .copyWith(fontSize: 12.5)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.square_foot_rounded,
                                        size: 14,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      plotAreaDisplay,
                                      style: AppTypography.secondary.copyWith(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusBadge(status: sale.status),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 28),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_outlined, size: 13, color: AppColors.accent),
                          label: const Text('Invoice PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          onPressed: () {
                            final projects = ref.read(projectsListStreamProvider).value ?? [];
                            final proj = projects.where((p) => p.id == sale.projectId).firstOrNull;
                            final buyers = ref.read(buyersListStreamProvider).value ?? [];
                            final buyer = buyers.where((b) => b.id == sale.buyerId).firstOrNull;

                            final saleModel = SaleModel(
                              id: sale.id,
                              projectId: sale.projectId,
                              buyerId: sale.buyerId,
                              buyerName: buyer?.name ?? 'Customer',
                              agreedPrice: sale.agreedPrice,
                              saleDate: sale.saleDate,
                              saleType: SaleType.values.firstWhere(
                                (t) => t.name == sale.saleType,
                                orElse: () => SaleType.plotWise,
                              ),
                              status: sale.status,
                              saleExpenses: sale.saleExpenses,
                              createdAt: sale.createdAt,
                            );

                            CustomerInvoicePdfDialog.show(
                              context,
                              sale: saleModel,
                              buyer: buyer,
                              projectName: proj?.name ?? 'Project',
                              projectCode: proj?.code ?? 'PRJ',
                              projectLocation: proj?.location ?? '',
                              plots: plots,
                              transactions: transactions,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // Financial row
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: MemberFinancialTile(
                        label: 'Agreed Price',
                        value: _currencyFmt.format(sale.agreedPrice),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: MemberFinancialTile(
                        label: 'Total Paid',
                        value: _currencyFmt.format(totalPaid),
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: MemberFinancialTile(
                        label: 'Remaining',
                        value: _currencyFmt.format(remaining),
                        color: remaining > 0
                            ? AppColors.danger
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              // Payment history
              if (transactions.isNotEmpty || paidInstallments.isNotEmpty) ...[
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment History (${transactions.isNotEmpty ? transactions.length : paidInstallments.length} Records)',
                            style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          if (remaining <= 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 13, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    'All Payments Cleared',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (transactions.isNotEmpty)
                        ...transactions.map((tx) => _TransactionRow(tx: tx))
                      else
                        ...paidInstallments.map((inst) => _InstallmentRow(inst: inst)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction tx;
  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paid on: ${_dateFmt.format(tx.paymentDate)}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mode: ${tx.paymentMethod.toUpperCase()}${tx.referenceNumber != null && tx.referenceNumber!.trim().isNotEmpty ? " • Ref: ${tx.referenceNumber!.trim()}" : ""}',
                  style: AppTypography.secondary.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFmt.format(tx.amount),
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CLEARED / PAID',
                  style: AppTypography.caption.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
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

class _InstallmentRow extends StatelessWidget {
  final Installment inst;
  const _InstallmentRow({required this.inst});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${inst.installmentNumber}',
              style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Due: ${_dateFmt.format(inst.dueDate)}',
              style: AppTypography.secondary.copyWith(fontSize: 12.5),
            ),
          ),
          Text(
            _currencyFmt.format(inst.paidAmount),
            style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

// ── Buyer total paid (reads all transactions & installments) ─────────────────

class _BuyerTotalPaidCard extends ConsumerWidget {
  final List<Sale> sales;
  const _BuyerTotalPaidCard({required this.sales});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double total = 0;
    for (final sale in sales) {
      final txs = ref.watch(saleTransactionsProvider(sale.id)).valueOrNull ?? [];
      if (txs.isNotEmpty) {
        total += txs.fold(0.0, (s, t) => s + t.amount);
      } else {
        final inst = ref.watch(saleInstallmentsProvider(sale.id)).valueOrNull ?? [];
        total += inst.fold(0.0, (s, i) => s + i.paidAmount);
      }
    }
    return MemberSummaryCard(
      icon: Icons.check_circle_outline,
      label: 'Total Paid',
      value: _currencyFmt.format(total),
      color: AppColors.success,
    );
  }
}

class _BuyerDuesCard extends ConsumerWidget {
  final List<Sale> sales;
  final double totalAgreed;
  const _BuyerDuesCard({required this.sales, required this.totalAgreed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double totalPaid = 0;
    for (final sale in sales) {
      final txs = ref.watch(saleTransactionsProvider(sale.id)).valueOrNull ?? [];
      if (txs.isNotEmpty) {
        totalPaid += txs.fold(0.0, (s, t) => s + t.amount);
      } else {
        final inst = ref.watch(saleInstallmentsProvider(sale.id)).valueOrNull ?? [];
        totalPaid += inst.fold(0.0, (s, i) => s + i.paidAmount);
      }
    }
    final dues = (totalAgreed - totalPaid).clamp(0.0, double.infinity);
    return MemberSummaryCard(
      icon: Icons.warning_amber_outlined,
      label: 'Remaining / Dues',
      value: _currencyFmt.format(dues),
      color: dues > 0 ? AppColors.danger : AppColors.success,
    );
  }
}


// ── Local widgets (buyer-specific only) ───────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Text(status,
          style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accent)),
    );
  }
}
