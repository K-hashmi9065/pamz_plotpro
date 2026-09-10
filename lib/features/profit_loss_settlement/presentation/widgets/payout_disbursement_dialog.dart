import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
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
          const SnackBar(content: Text('Investor payout recorded successfully!')),
        );
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
                      'Profit Share: ${CalculationEngine.formatCurrency(p.allocatedProfitShare)} (ROI: ${p.roiPercent.toStringAsFixed(2)}%)',
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
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
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
