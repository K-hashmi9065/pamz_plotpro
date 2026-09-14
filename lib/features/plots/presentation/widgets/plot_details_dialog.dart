import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../core/utils/land_unit_converter.dart';
import '../../../../core/widgets/formula_explainability_dialog.dart';
import '../../../../shared/widgets/page/status_badge.dart';
import '../../../audit_log/presentation/audit_log_screen.dart';
import '../../../buyers_sales/domain/sale_model.dart';
import '../../../buyers_sales/presentation/sales_providers.dart';
import '../../../buyers_sales/presentation/widgets/customer_invoice_pdf_dialog.dart';
import '../../../buyers_sales/presentation/widgets/sale_agreement_dialog.dart';
import '../../../installments_payments/domain/installment_model.dart';
import '../../../installments_payments/domain/transaction_model.dart';
import '../../../installments_payments/presentation/installments_providers.dart';
import '../../../installments_payments/presentation/widgets/payment_record_dialog.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../domain/plot_model.dart';
import '../plots_providers.dart';
import 'add_brokerage_dialog.dart';
import 'brokerage_info_dialog.dart';
import 'plot_edit_dialog.dart';

class PlotDetailsDialog extends ConsumerWidget {
  final PlotModel plot;

  const PlotDetailsDialog({
    super.key,
    required this.plot,
  });

  static Future<void> show(BuildContext context, PlotModel plot) {
    return showDialog(
      context: context,
      builder: (context) => PlotDetailsDialog(plot: plot),
    );
  }

  Future<void> _handleDeletePlot(BuildContext context, WidgetRef ref) async {
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

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(plotsRepositoryProvider);
        await repo.deletePlot(plot.id, userId: 'admin_user');
        if (context.mounted) {
          Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotsAsync = ref.watch(plotsListStreamProvider);
    final plot = plotsAsync.value?.where((p) => p.id == this.plot.id).firstOrNull ?? this.plot;

    final projectsAsync = ref.watch(projectsListStreamProvider);
    final salesAsync = ref.watch(salesListStreamProvider);
    final installmentsAsync = ref.watch(installmentsListStreamProvider);
    final transactionsAsync = ref.watch(transactionsListStreamProvider);

    final formattedDate = DateFormat('dd MMM yyyy').format(plot.createdAt);

    // Multi-unit conversions for total plot area
    final decimalVal = LandUnitConverter.sqFtToDecimal(plot.areaSqFt);
    final totalKatta = LandUnitConverter.sqFtToKatta(plot.areaSqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final totalDhur = LandUnitConverter.sqFtToDhur(plot.areaSqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final bighaVal = LandUnitConverter.sqFtToBigha(plot.areaSqFt);
    final sqMeterVal = (plot.areaSqFt / LandUnitConverter.sqFtPerSqMeter).toStringAsFixed(1);
    final costPerSqFt = plot.areaSqFt > 0 ? plot.allocatedCost / plot.areaSqFt : 0.0;
    final expectedPricePerSqFt = plot.areaSqFt > 0 ? plot.expectedPrice / plot.areaSqFt : 0.0;

    final lFt = plot.lengthFt ?? 0.0;
    final lIn = plot.lengthIn ?? 0.0;
    final bFt = plot.breadthFt ?? 0.0;
    final bIn = plot.breadthIn ?? 0.0;

    final lengthStr = (lFt == 0 && lIn == 0)
        ? '—'
        : '${lFt == lFt.roundToDouble() ? lFt.toInt() : lFt} feet ${lIn == lIn.roundToDouble() ? lIn.toInt() : lIn} inches';
    final breadthStr = (bFt == 0 && bIn == 0)
        ? '—'
        : '${bFt == bFt.roundToDouble() ? bFt.toInt() : bFt} feet ${bIn == bIn.roundToDouble() ? bIn.toInt() : bIn} inches';

    final allSales = salesAsync.value ?? [];
    final allInstallments = installmentsAsync.value ?? [];
    final allTransactions = transactionsAsync.value ?? [];
    final allLogs = ref.watch(auditLogsStreamProvider).value ?? [];

    final bool isPlotSoldOrBooked = plot.status != PlotStatus.available &&
        plot.status != PlotStatus.cancelled &&
        !plot.isRoad;

    // Check if there is an active sale agreement for this specific plot
    SaleModel? matchedSale;
    if (isPlotSoldOrBooked && allSales.isNotEmpty) {
      final projectSales = allSales.where((s) => s.projectId == plot.projectId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 1. Direct match via LINK_PLOT_SALE audit log for this specific plot
      final plotLogs = allLogs.where((l) =>
          l.entityType == 'Plot' &&
          l.entityId == plot.id &&
          l.action == 'LINK_PLOT_SALE'
      ).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      for (final log in plotLogs) {
        final match = RegExp(r'SaleId:([^;]+)').firstMatch(log.details);
        if (match != null) {
          final saleId = match.group(1);
          final found = projectSales.where((s) => s.id == saleId).firstOrNull;
          if (found != null) {
            matchedSale = found;
            break;
          }
        }
      }

      // 2. If not matched by explicit audit log, match candidate sales not linked to any other plot
      if (matchedSale == null) {
        final Set<String> otherPlotLinkedSaleIds = {};
        for (final log in allLogs) {
          if (log.entityType == 'Plot' &&
              log.action == 'LINK_PLOT_SALE' &&
              log.entityId != plot.id) {
            final match = RegExp(r'SaleId:([^;]+)').firstMatch(log.details);
            if (match != null) {
              otherPlotLinkedSaleIds.add(match.group(1)!);
            }
          }
        }

        final unlinkedSales = projectSales
            .where((s) => !otherPlotLinkedSaleIds.contains(s.id))
            .toList();

        // Exact price matching first
        final priceMatch = unlinkedSales
            .where((s) => (s.agreedPrice - plot.expectedPrice).abs() < 1.0)
            .firstOrNull;

        if (priceMatch != null) {
          matchedSale = priceMatch;
        } else if (unlinkedSales.isNotEmpty && plotLogs.isEmpty) {
          if (unlinkedSales.length == 1) {
            matchedSale = unlinkedSales.first;
          }
        }
      }
    }

    final double sellingPrice = matchedSale != null ? matchedSale.agreedPrice : plot.expectedPrice;

    // Parent project calculations for area-wise allocated expense
    final parentProject = (projectsAsync.value ?? []).where((p) => p.id == plot.projectId).firstOrNull;
    final double totalProjectArea = (parentProject != null && parentProject.landAreaSqFt > 0)
        ? parentProject.landAreaSqFt
        : plot.areaSqFt;
    final double basePurchaseCost = (parentProject != null && totalProjectArea > 0)
        ? (plot.areaSqFt / totalProjectArea) * parentProject.purchasePrice
        : 0.0;

    final projectPlots = (plotsAsync.value ?? []).where((p) => p.projectId == plot.projectId).toList();
    final double totalProjectBrokerages = projectPlots.fold(0.0, (sum, p) => sum + p.brokerageCharge);
    final double totalProjectCapitalizedExpenses = (parentProject != null)
        ? (parentProject.actualCost - parentProject.purchasePrice).clamp(0.0, double.infinity)
        : 0.0;
    final double generalProjectExpenses = (totalProjectCapitalizedExpenses - totalProjectBrokerages).clamp(0.0, double.infinity);

    final double allocatedProjectExpense = (totalProjectArea > 0)
        ? CalculationEngine.calculatePlotAllocatedExpense(
            plotAreaSqFt: plot.areaSqFt,
            totalProjectAreaSqFt: totalProjectArea,
            totalProjectExpense: generalProjectExpenses,
          )
        : 0.0;
    final double plotTotalExpense = CalculationEngine.calculatePlotTotalExpense(
      allocatedExpense: allocatedProjectExpense,
      brokerageCharge: plot.brokerageCharge,
    );

    final double actualPlotCost = plot.allocatedCost;

    // Collect transactions & installments for this sale
    List<InstallmentModel> relevantInstallments = [];
    List<TransactionModel> relevantTransactions = [];

    if (isPlotSoldOrBooked && matchedSale != null) {
      relevantInstallments = allInstallments.where((inst) => inst.saleId == matchedSale!.id).toList();
      final instIds = relevantInstallments.map((i) => i.id).toSet();
      relevantTransactions = allTransactions
          .where((t) => t.installmentId != null && instIds.contains(t.installmentId!) && !t.isVoided)
          .toList()
        ..sort((a, b) {
          final cmp = b.paymentDate.compareTo(a.paymentDate);
          if (cmp != 0) return cmp;
          return b.createdAt.compareTo(a.createdAt);
        });
    }

    // Total income collected for this plot
    double totalIncomeReceived = 0.0;
    if (isPlotSoldOrBooked) {
      totalIncomeReceived = relevantTransactions.fold(0.0, (sum, t) => sum + t.amount);
      if (totalIncomeReceived == 0.0 && relevantInstallments.isNotEmpty) {
        totalIncomeReceived = relevantInstallments.fold(0.0, (sum, inst) => sum + inst.paidAmount);
      }
    }

    final double remainingBalanceDue = isPlotSoldOrBooked
        ? (sellingPrice - totalIncomeReceived).clamp(0.0, double.infinity)
        : 0.0;
    final bool isFullyPaid = isPlotSoldOrBooked &&
        sellingPrice > 0 &&
        (totalIncomeReceived >= (sellingPrice - 0.01) || remainingBalanceDue <= 0.01);
    final double netProfit = sellingPrice > 0 ? (sellingPrice - actualPlotCost) : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        width: 960,
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Full Visibility
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.grid_view_rounded, color: AppColors.accent, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plot Details: #${plot.plotNumber}',
                                style: AppTypography.cardTitle.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 3),
                              projectsAsync.when(
                                data: (projects) {
                                  final proj = projects.where((p) => p.id == plot.projectId).firstOrNull;
                                  return Text(
                                    proj != null
                                        ? 'Project: ${proj.name} (${proj.code})'
                                        : 'Project ID: ${plot.projectId}',
                                    style: AppTypography.secondary.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  );
                                },
                                loading: () => Text('Loading project...', style: AppTypography.secondary.copyWith(fontSize: 13)),
                                error: (e, s) => Text('Project ID: ${plot.projectId}', style: AppTypography.secondary.copyWith(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Edit Plot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () {
                          PlotEditDialog.show(context, plot);
                        },
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.handshake_outlined, size: 15),
                        label: const Text('Add Brokerage Charge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () {
                          AddBrokerageDialog.show(
                            context,
                            plot,
                          );
                        },
                      ),
                      if (isFullyPaid)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.verified, size: 15),
                          label: const Text('All Payments Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'All agreement payments for Plot #${plot.plotNumber} have been fully cleared and received from ${matchedSale?.buyerName ?? "the customer"} (${CalculationEngine.formatCurrency(totalIncomeReceived)}). Remaining balance: ₹0.',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                        )
                      else if (isPlotSoldOrBooked)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.payments_outlined, size: 15),
                          label: const Text('Add Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () {
                            final unpaidInst = relevantInstallments.where((i) => !i.isFullyPaid).firstOrNull;
                            PaymentRecordDialog.show(
                              context,
                              installment: unpaidInst,
                              projectId: plot.projectId,
                            );
                          },
                        )
                      else if (!plot.isRoad)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.storefront_outlined, size: 15),
                          label: const Text('Book / Sell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () {
                            SaleAgreementDialog.show(
                              context,
                              preselectedProjectId: plot.projectId,
                            );
                          },
                        ),
                      if (plot.isRoad)
                        const StatusBadge(label: 'ROAD', type: BadgeType.info)
                      else if (!isFullyPaid)
                        StatusBadge(
                          label: plot.status.name.toUpperCase(),
                          type: _getBadgeType(plot.status),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.dangerText, size: 20),
                        tooltip: 'Delete Plot',
                        onPressed: () => _handleDeletePlot(context, ref),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // Land Dimensions & Measurement Cards Header
              Text(
                'Land Measurement & Dimensions Details',
                style: AppTypography.sectionTitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 12),

              // Measurement Cards Grid (Responsive 2-column)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: _buildDimensionCard(
                          icon: Icons.straighten_outlined,
                          title: 'Plot Length',
                          value: (lFt > 0 || lIn > 0) ? lengthStr : 'NA',
                        ),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: _buildDimensionCard(
                          icon: Icons.straighten_outlined,
                          title: 'Plot Breadth / Width',
                          value: (bFt > 0 || bIn > 0) ? breadthStr : 'NA',
                        ),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: _buildDimensionCard(
                          icon: Icons.square_foot_outlined,
                          title: 'Actual Registered Area',
                          value: (plot.displayArea != null && plot.displayArea! > 0)
                              ? LandUnitConverter.formatLandMeasurement(
                                  areaSqFt: plot.areaSqFt,
                                  measurementUnit: plot.measurementUnit,
                                  displayArea: plot.displayArea,
                                  kattaValue: plot.kattaValue,
                                  dhurValue: plot.dhurValue,
                                )
                              : 'NA',
                        ),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: _buildDimensionCard(
                          icon: Icons.crop_free_outlined,
                          title: 'Calculated Area (L × B)',
                          value: (lFt > 0 || bFt > 0)
                              ? '${LandUnitConverter.dimensionsToSqFt(lengthFt: lFt, lengthIn: lIn, breadthFt: bFt, breadthIn: bIn).toStringAsFixed(1)} sq.ft'
                              : 'NA',
                        ),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: _buildDimensionCard(
                          icon: Icons.swap_vert_circle_outlined,
                          title: 'Kattha Equivalent',
                          value: '$totalKattaStr Kattha',
                        ),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth - 16) / 2,
                        child: _buildDimensionCard(
                          icon: Icons.layers_outlined,
                          title: 'Decimal Equivalent',
                          value: '$decimalVal Dec',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Multi-Unit Conversion Readout Table
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.table_chart_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            'Area Conversion Matrix',
                            style: AppTypography.secondary.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildUnitCell('Kattha', totalKattaStr),
                          _buildUnitCell('Dhur', totalDhurStr),
                          _buildUnitCell('Decimal', '$decimalVal'),
                          _buildUnitCell('Bigha', '$bighaVal'),
                          _buildUnitCell('Sq Meters', sqMeterVal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Comprehensive Plot Financial Breakdown & Customer Ledger
              Text(
                'Plot Financial Breakdown & Customer Sales Ledger',
                style: AppTypography.sectionTitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selling Price to Customer Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              isPlotSoldOrBooked && matchedSale != null
                                  ? 'Total Plot Sell Price (Agreed to Customer):'
                                  : 'Total Plot Sell Price (Kitne me bechenge):',
                              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (isPlotSoldOrBooked && matchedSale != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Customer: ${matchedSale.buyerName}',
                                  style: AppTypography.secondary.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          sellingPrice > 0 ? CalculationEngine.formatCurrency(sellingPrice) : 'Not Set (₹0)',
                          style: AppTypography.amountMedium.copyWith(
                            fontSize: 16,
                            color: AppColors.orangeText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Plot Brokerage Charge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.handshake_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Plot Brokerage Charge:', style: AppTypography.body),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => plot.hasBrokerage
                                  ? BrokerageInfoDialog.show(context, plot)
                                  : AddBrokerageDialog.show(context, plot),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      plot.hasBrokerage ? Icons.info_outline : Icons.add,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      plot.hasBrokerage
                                          ? 'Broker: ${plot.brokerName ?? "Assigned"}'
                                          : ' Add Brokerage',
                                      style: AppTypography.secondary.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          plot.brokerageCharge > 0 ? CalculationEngine.formatCurrency(plot.brokerageCharge) : '₹0',
                          style: AppTypography.amountMedium.copyWith(
                            fontSize: 15,
                            color: plot.brokerageCharge > 0 ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Actual Cost Row with Formula Explainability
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Actual Cost (Land Cost + Expenses):', style: AppTypography.body),
                            const SizedBox(width: 4),
                            FormulaInfoButton(
                              figureTitle: 'Plot Actual Cost (${plot.plotNumber})',
                              plainWordsFormula:
                                  'Total Cost = Base Land Cost + Plot Total Expense (Allocated Project Expense + Plot Brokerage)',
                              terms: [
                                FormulaTermDefinition(
                                  term: 'Base Land Purchase Cost',
                                  definition: 'Proportionate base land purchase cost allocated by area.',
                                  valueDisplay: CalculationEngine.formatCurrency(basePurchaseCost),
                                ),
                                FormulaTermDefinition(
                                  term: 'Allocated Project Expense',
                                  definition: 'Area-wise division of master project expenses across plots.',
                                  valueDisplay: CalculationEngine.formatCurrency(allocatedProjectExpense),
                                ),
                                FormulaTermDefinition(
                                  term: 'Direct Plot Brokerage Charge',
                                  definition: 'Direct brokerage commission recorded for this plot.',
                                  valueDisplay: CalculationEngine.formatCurrency(plot.brokerageCharge),
                                ),
                                FormulaTermDefinition(
                                  term: 'Plot Total Expense',
                                  definition: 'Allocated Project Expense + Direct Plot Brokerage Charge.',
                                  valueDisplay: CalculationEngine.formatCurrency(plotTotalExpense),
                                ),
                              ],
                              calculatedResultDisplay: CalculationEngine.formatCurrency(actualPlotCost),
                            ),
                          ],
                        ),
                        Text(
                          CalculationEngine.formatCurrency(actualPlotCost),
                          style: AppTypography.amountMedium.copyWith(
                            fontSize: 15,
                            color: AppColors.warningText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Total Income Received Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Income Received (Paid by Customer):', style: AppTypography.body),
                        Text(
                          isPlotSoldOrBooked
                              ? CalculationEngine.formatCurrency(totalIncomeReceived)
                              : '₹0 (Not Sold)',
                          style: AppTypography.amountMedium.copyWith(
                            fontSize: 15,
                            color: isPlotSoldOrBooked ? AppColors.successText : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Remaining Balance Due Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Remaining Balance Due:', style: AppTypography.body),
                        Text(
                          isFullyPaid
                              ? '₹0 (All Payments Paid)'
                              : isPlotSoldOrBooked
                                  ? CalculationEngine.formatCurrency(remainingBalanceDue)
                                  : '₹0 (Plot is Available)',
                          style: AppTypography.amountMedium.copyWith(
                            fontSize: 15,
                            color: isFullyPaid
                                ? AppColors.successText
                                : isPlotSoldOrBooked && remainingBalanceDue > 0
                                    ? AppColors.dangerText
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Estimated Profit & Unit Rates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSubMetric(
                          label: 'Cost per Sq. Ft.',
                          value: '₹${costPerSqFt.toStringAsFixed(1)} / sq.ft',
                        ),
                        _buildSubMetric(
                          label: 'Expected Price / Sq. Ft.',
                          value: '₹${expectedPricePerSqFt.toStringAsFixed(1)} / sq.ft',
                        ),
                        _buildSubMetric(
                          label: 'Estimated Net Profit',
                          value: sellingPrice > 0 ? CalculationEngine.formatCurrency(netProfit) : 'N/A',
                          valueColor: netProfit >= 0 ? AppColors.successText : AppColors.dangerText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Customer Payment History Section (Jab Customer ne Payment Diya)
              Text(
                'Customer Payment History (Jab Customer ne Payment Diya)',
                style: AppTypography.sectionTitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history_edu_outlined, size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text(
                                isPlotSoldOrBooked && matchedSale != null
                                    ? 'Payment Transactions for Customer: ${matchedSale.buyerName}'
                                    : 'Plot Payment Schedule & Receipts',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (isPlotSoldOrBooked && matchedSale != null) ...[
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: const Size(0, 28),
                                  ),
                                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 13, color: AppColors.accent),
                                  label: const Text('Share Invoice PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  onPressed: () async {
                                    final projects = ref.read(projectsListStreamProvider).value ?? [];
                                    final proj = projects.where((p) => p.id == plot.projectId).firstOrNull;
                                    final buyers = ref.read(buyersListStreamProvider).value ?? [];
                                    final buyer = buyers.where((b) => b.id == matchedSale!.buyerId).firstOrNull;
                                    final db = ref.read(appDatabaseProvider);
                                    final saleInsts = await (db.select(db.installments)..where((i) => i.saleId.equals(matchedSale!.id))).get();
                                    final instIds = saleInsts.map((i) => i.id).toSet();
                                    final allTxs = await db.select(db.transactions).get();
                                    final txs = allTxs
                                        .where((t) =>
                                            !t.isVoided &&
                                            t.installmentId != null &&
                                            instIds.contains(t.installmentId))
                                        .toList();
                                    txs.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

                                    if (context.mounted) {
                                      CustomerInvoicePdfDialog.show(
                                        context,
                                        sale: matchedSale!,
                                        buyer: buyer,
                                        projectName: proj?.name ?? 'Project',
                                        projectCode: proj?.code ?? 'PRJ',
                                        projectLocation: proj?.location ?? '',
                                        plots: [plot],
                                        transactions: txs,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (isFullyPaid)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, size: 14, color: AppColors.successText),
                                      const SizedBox(width: 5),
                                      Text(
                                        'All Agreement Payments Paid',
                                        style: AppTypography.secondary.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.successText,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (isPlotSoldOrBooked)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: const Size(0, 28),
                                  ),
                                  icon: const Icon(Icons.add, size: 13),
                                  label: const Text('Add Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  onPressed: () {
                                    final unpaidInst = relevantInstallments.where((i) => !i.isFullyPaid).firstOrNull;
                                    PaymentRecordDialog.show(
                                      context,
                                      installment: unpaidInst,
                                      projectId: plot.projectId,
                                    );
                                  },
                                )
                              else if (!plot.isRoad)
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: const Size(0, 28),
                                  ),
                                  icon: const Icon(Icons.assignment_outlined, size: 13),
                                  label: const Text('Create Sale Agreement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                  onPressed: () {
                                    SaleAgreementDialog.show(
                                      context,
                                      preselectedProjectId: plot.projectId,
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isPlotSoldOrBooked && relevantTransactions.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: relevantTransactions.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = relevantTransactions[index];
                          final formattedTxDate = DateFormat('dd MMM yyyy').format(tx.paymentDate);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: AppColors.successText, size: 18),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Paid on: $formattedTxDate',
                                          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Mode: ${tx.paymentMethod.name.toUpperCase()} ${tx.referenceNumber != null && tx.referenceNumber!.isNotEmpty ? "• Ref: ${tx.referenceNumber}" : ""}',
                                          style: AppTypography.secondary.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CalculationEngine.formatCurrency(tx.amount),
                                      style: AppTypography.amountMedium.copyWith(
                                        fontSize: 14,
                                        color: AppColors.successText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const StatusBadge(label: 'CLEARED / PAID', type: BadgeType.success),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else if (isPlotSoldOrBooked && relevantInstallments.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: relevantInstallments.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final inst = relevantInstallments[index];
                          final formattedDueDate = DateFormat('dd MMM yyyy').format(inst.dueDate);
                          final isPaid = inst.paidAmount >= inst.dueAmount;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isPaid ? Icons.check_circle : Icons.schedule,
                                      color: isPaid ? AppColors.successText : AppColors.warningText,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Installment #${inst.installmentNumber} • Due: $formattedDueDate',
                                          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Paid: ${CalculationEngine.formatCurrency(inst.paidAmount)} of ${CalculationEngine.formatCurrency(inst.dueAmount)}',
                                          style: AppTypography.secondary.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                StatusBadge(
                                  label: isPaid ? 'PAID' : inst.status.name.toUpperCase(),
                                  type: isPaid ? BadgeType.success : BadgeType.warning,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                !isPlotSoldOrBooked
                                    ? 'This plot is currently Available (Not Sold). No customer payments or installments exist for this plot yet. Click "+ Create Sale Agreement" to sell or book this plot to a customer.'
                                    : 'No payment transactions recorded for this plot yet. Once installments/receipts are recorded, payment dates and amounts will be tracked here.',
                                style: AppTypography.secondary.copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Metadata Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created Date: $formattedDate',
                    style: AppTypography.secondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.handshake_outlined, size: 16),
                    label: Text(plot.hasBrokerage ? 'Edit Brokerage' : 'Add Brokerage Charge'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AddBrokerageDialog.show(context, plot);
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionCard({
    required String title,
    required String value,
    required IconData icon,
    Color accentColor = AppColors.accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.secondary.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
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

  Widget _buildUnitCell(String unitLabel, String unitValue) {
    return Column(
      children: [
        Text(
          unitLabel,
          style: AppTypography.secondary.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          unitValue,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildSubMetric({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.secondary.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
