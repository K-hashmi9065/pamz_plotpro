import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../domain/transaction_model.dart';
import '../installments_providers.dart';

class VoidTransactionDialog extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const VoidTransactionDialog({
    super.key,
    required this.transaction,
  });

  static Future<void> show(
    BuildContext context, {
    required TransactionModel transaction,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VoidTransactionDialog(transaction: transaction),
    );
  }

  @override
  ConsumerState<VoidTransactionDialog> createState() => _VoidTransactionDialogState();
}

class _VoidTransactionDialogState extends ConsumerState<VoidTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _reasonController.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(installmentsRepositoryProvider);
      await repo.voidTransaction(
        transactionId: widget.transaction.id,
        voidReason: _reasonController.text,
        userId: 'active_user',
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Transaction successfully voided & reversed!')),
        );
      }
    } catch (e) {
      _errorMessageNotifier.value = e.toString().replaceAll('ArgumentError: ', '').replaceAll('StateError: ', '');
      _isSavingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isSavingNotifier,
            builder: (context, isSaving, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Void Transaction (Admin Only)', style: AppTypography.cardTitle),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.dangerBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ REVERSAL NOTICE',
                          style: AppTypography.body.copyWith(
                            color: AppColors.dangerText,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This action will void Transaction ID: ${tx.id.length > 8 ? tx.id.substring(0, 8) : tx.id}... for ${CalculationEngine.formatCurrency(tx.amount)} and reverse the paid balance on the associated installment.',
                          style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
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
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Voiding *',
                      hintText: 'e.g. Bounced cheque / Duplicate payment entry correction',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Mandatory reason for voiding * is required'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                        ),
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
                            : const Text('Confirm Void & Reverse'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
