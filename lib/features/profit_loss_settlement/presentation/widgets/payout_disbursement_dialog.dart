import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/pdf/investor_statement_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../investors/domain/investor_model.dart';
import '../../../investors/domain/project_investor_model.dart';
import '../../../investors/presentation/widgets/investor_statement_pdf_dialog.dart';
import '../../../projects/domain/project_model.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../domain/profit_loss_models.dart';
import '../profit_loss_providers.dart';

class PayoutDisbursementDialog extends ConsumerStatefulWidget {
  final InvestorPayoutModel payout;

  const PayoutDisbursementDialog({
    super.key,
    required this.payout,
  });

  static Future<void> show(
    BuildContext context, {
    required InvestorPayoutModel payout,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PayoutDisbursementDialog(payout: payout),
    );
  }

  @override
  ConsumerState<PayoutDisbursementDialog> createState() => _PayoutDisbursementDialogState();
}

class _PayoutDisbursementDialogState extends ConsumerState<PayoutDisbursementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    final double maxAvailable = (widget.payout.capitalInvested +
            widget.payout.allocatedProfitShare -
            widget.payout.payoutsDisbursed)
        .clamp(0.0, double.infinity);
    _amountController.text =
        maxAvailable > 0 ? maxAvailable.round().toString() : '0';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedAmount = double.tryParse(_amountController.text) ?? 0.0;

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(profitLossRepositoryProvider);
      await repo.recordInvestorPayout(
        projectInvestorId: widget.payout.id,
        payoutAmount: parsedAmount,
        paymentReference: _referenceController.text.trim().isEmpty
            ? 'BANK_TRANSFER'
            : _referenceController.text.trim(),
        userId: 'active_user',
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Investor payout recorded! Opening Statement PDF...')),
        );

        final db = ref.read(appDatabaseProvider);
        final prj = await (db.select(db.projects)
              ..where((p) => p.id.equals(widget.payout.projectId)))
            .getSingleOrNull();
        final inv = await (db.select(db.investors)
              ..where((i) => i.id.equals(widget.payout.investorId)))
            .getSingleOrNull();

        final piRows = await (db.select(db.projectInvestors)
              ..where((pi) => pi.investorId.equals(widget.payout.investorId)))
            .get();
        final allPi = piRows.where((pi) => pi.projectId == widget.payout.projectId).toList();
        final investments = allPi.map((pi) {
          final method = OwnershipMethod.values.firstWhere(
            (m) => m.name == pi.ownershipMethod,
            orElse: () => OwnershipMethod.capitalBased,
          );
          return ProjectInvestorModel(
            id: pi.id,
            projectId: pi.projectId,
            investorId: pi.investorId,
            investorName: widget.payout.investorName,
            investedAmount: pi.investedAmount,
            ownershipPercent: pi.ownershipPercent,
            ownershipMethod: method,
            createdAt: pi.createdAt,
          );
        }).toList();

        final allLogs = await (db.select(db.auditLogs)
              ..where((l) => l.action.equals('DISBURSE_INVESTOR_PAYOUT')))
            .get();
        final logs = allLogs.where((l) => l.entityId == widget.payout.id || l.details.contains(widget.payout.id)).toList();
        final withdrawals = logs.map((log) {
          double amt = 0.0;
          final match = RegExp(r'₹([0-9.,]+)').firstMatch(log.details);
          if (match != null) {
            amt = double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0.0;
          }
          String ref = 'BANK_TRANSFER';
          final refMatch = RegExp(r'Ref:\s*(.*)$').firstMatch(log.details);
          if (refMatch != null) {
            ref = refMatch.group(1)?.trim() ?? 'BANK_TRANSFER';
          }
          return InvestorWithdrawalRecord(
            date: log.timestamp,
            amount: amt,
            reference: ref,
            disbursedBy: log.userId,
          );
        }).toList();
        withdrawals.sort((a, b) => b.date.compareTo(a.date));

        final projectModel = prj != null
            ? ProjectModel(
                id: prj.id,
                name: prj.name,
                code: prj.code,
                location: prj.location,
                landAreaSqFt: prj.landAreaSqFt,
                purchasePrice: prj.purchasePrice,
                actualCost: prj.actualCost,
                status: ProjectStatus.values.firstWhere(
                    (s) => s.name == prj.status,
                    orElse: () => ProjectStatus.active),
                createdAt: prj.createdAt,
              )
            : ProjectModel(
                id: widget.payout.projectId,
                name: 'Project',
                code: 'PRJ',
                location: '',
                landAreaSqFt: 0,
                purchasePrice: 0,
                actualCost: 0,
                status: ProjectStatus.active,
                createdAt: DateTime.now(),
              );

        final investorModel = inv != null
            ? InvestorModel(
                id: inv.id,
                name: inv.name,
                phone: inv.phone,
                email: inv.email,
                pan: inv.pan,
                createdAt: inv.createdAt,
              )
            : null;

        if (mounted) {
          InvestorStatementPdfDialog.show(
            context,
            project: projectModel,
            investor: investorModel,
            investorName: widget.payout.investorName,
            ownershipPercent: widget.payout.ownershipPercent,
            investments: investments,
            withdrawals: withdrawals,
            profitShare: widget.payout.allocatedProfitShare,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _errorMessageNotifier.value = e.toString().replaceAll('ArgumentError: ', '');
        _isSavingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payout;
    final double totalAmount = p.capitalInvested + p.allocatedProfitShare;
    final double availableBalance =
        (totalAmount - p.payoutsDisbursed).clamp(0.0, double.infinity);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Disburse Investor Payout', style: AppTypography.cardTitle),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isSavingNotifier,
                    builder: (context, isSaving, _) {
                      return IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.investorName,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contributed Capital: ${CalculationEngine.formatCurrency(p.capitalInvested)} | Ownership: ${p.ownershipPercent.toStringAsFixed(2)}%',
                      style: AppTypography.secondary,
                    ),
                    Text(
                      'Profit Share: ${CalculationEngine.formatCurrency(p.allocatedProfitShare)} (ROR: ${p.rorPercent.toStringAsFixed(2)}%)',
                      style: AppTypography.secondary.copyWith(color: AppColors.successText),
                    ),
                    Text(
                      'Total Amount (Capital + Profit): ${CalculationEngine.formatCurrency(totalAmount)}',
                      style: AppTypography.secondary.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Already Withdrawn: ${CalculationEngine.formatCurrency(p.payoutsDisbursed)}',
                      style: AppTypography.secondary.copyWith(color: AppColors.warningText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available for Withdrawal: ${CalculationEngine.formatCurrency(availableBalance)}',
                      style: AppTypography.secondary.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ValueListenableBuilder<String?>(
                valueListenable: _errorMessageNotifier,
                builder: (context, errorMessage, _) {
                  if (errorMessage == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      errorMessage,
                      style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                    ),
                  );
                },
              ),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Disbursement Amount (₹) *',
                  hintText: 'e.g. 150000',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Amount * is required';
                  }
                  final num = double.tryParse(val);
                  if (num == null || num <= 0) {
                    return 'Enter a valid positive payout amount';
                  }
                  if (num > availableBalance) {
                    return 'Withdrawal amount cannot exceed total available balance of ${CalculationEngine.formatCurrency(availableBalance)}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Bank Ref / UTR / Cheque No.',
                  hintText: 'e.g. UTR-9876543210',
                ),
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<bool>(
                valueListenable: _isSavingNotifier,
                builder: (context, isSaving, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.dangerText,
                          side: const BorderSide(color: AppColors.dangerBorder),
                        ),
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isSaving ? null : _submit,
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Disburse Payout'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
