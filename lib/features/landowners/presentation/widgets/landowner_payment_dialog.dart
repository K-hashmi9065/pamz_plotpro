import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../installments_payments/domain/installment_model.dart';
import '../../../installments_payments/presentation/installments_providers.dart';
import '../../../projects/domain/project_model.dart';
import '../../domain/purchase_agreement_model.dart';
import '../landowners_providers.dart';

class LandownerPaymentDialog extends ConsumerStatefulWidget {
  final ProjectModel project;
  final PurchaseAgreementModel? initialAgreement;
  final InstallmentModel? initialInstallment;

  const LandownerPaymentDialog({
    super.key,
    required this.project,
    this.initialAgreement,
    this.initialInstallment,
  });

  static Future<void> show(
    BuildContext context, {
    required ProjectModel project,
    PurchaseAgreementModel? agreement,
    InstallmentModel? installment,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LandownerPaymentDialog(
        project: project,
        initialAgreement: agreement,
        initialInstallment: installment,
      ),
    );
  }

  @override
  ConsumerState<LandownerPaymentDialog> createState() =>
      _LandownerPaymentDialogState();
}

class _LandownerPaymentDialogState
    extends ConsumerState<LandownerPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.bankTransfer;
  String? _selectedInstallmentId;

  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier =
      ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedInstallmentId = widget.initialInstallment?.id;
    if (widget.initialInstallment != null) {
      _amountController.text =
          widget.initialInstallment!.remainingAmount.round().toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit(PurchaseAgreementModel agreement, double remainingDues) async {
    if (!_formKey.currentState!.validate()) return;

    final parsedAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (parsedAmount <= 0) return;

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(installmentsRepositoryProvider);
      await repo.recordLandownerPayment(
        projectId: widget.project.id,
        purchaseAgreementId: agreement.id,
        installmentId: _selectedInstallmentId,
        amount: parsedAmount,
        paymentDate: _paymentDate,
        paymentMethod: _paymentMethod,
        referenceNumber: _referenceController.text.trim().isEmpty
            ? 'BANK_TRANSFER'
            : _referenceController.text.trim(),
        userId: 'active_user',
        landownerName: widget.project.landownerName,
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Landowner payment of ${CalculationEngine.formatCurrency(parsedAmount)} recorded successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _errorMessageNotifier.value =
            e.toString().replaceAll('ArgumentError: ', '');
        _isSavingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agreementsAsync =
        ref.watch(projectAgreementsStreamProvider(widget.project.id));
    final installmentsAsync = ref.watch(installmentsListStreamProvider);

    final agreements = agreementsAsync.value ?? [];
    final agreement = widget.initialAgreement ??
        (agreements.isNotEmpty
            ? agreements.first
            : PurchaseAgreementModel(
                id: 'AUTO_${widget.project.id}',
                projectId: widget.project.id,
                landownerId: widget.project.landownerId ?? 'UNKNOWN',
                totalPrice: widget.project.purchasePrice,
                agreementDate: widget.project.createdAt,
                status: 'ACTIVE',
                createdAt: widget.project.createdAt,
              ));

    final allInstallments = installmentsAsync.value ?? [];
    final paInstallments = allInstallments
        .where((i) => i.purchaseAgreementId == agreement.id)
        .toList()
      ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

    final double totalPaid = paInstallments.fold(
      0.0,
      (sum, i) => sum + i.paidAmount,
    );
    final double remainingDues =
        (agreement.totalPrice - totalPaid).clamp(0.0, double.infinity);

    // If amount controller is empty, prefill with selected installment or next pending installment
    if (_amountController.text.isEmpty) {
      if (_selectedInstallmentId != null) {
        final matched = paInstallments
            .where((i) => i.id == _selectedInstallmentId)
            .firstOrNull;
        if (matched != null) {
          _amountController.text = matched.remainingAmount.round().toString();
        }
      } else {
        final nextPending = paInstallments.firstWhere(
          (i) => i.remainingAmount > 0,
          orElse: () => paInstallments.isNotEmpty
              ? paInstallments.first
              : InstallmentModel(
                  id: '',
                  purchaseAgreementId: agreement.id,
                  installmentNumber: 1,
                  dueDate: DateTime.now(),
                  dueAmount: remainingDues,
                  paidAmount: 0,
                  status: InstallmentStatus.pending,
                  createdAt: DateTime.now(),
                ),
        );
        _amountController.text = nextPending.remainingAmount > 0
            ? nextPending.remainingAmount.round().toString()
            : remainingDues.round().toString();
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 520,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: AppColors.accent,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Record Landowner Payment',
                        style: AppTypography.cardTitle,
                      ),
                    ],
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isSavingNotifier,
                    builder: (context, isSaving, _) {
                      return IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        onPressed:
                            isSaving ? null : () => Navigator.of(context).pop(),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Landowner & Project Summary Banner
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Landowner: ${widget.project.landownerName ?? "Not Assigned"}',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Project: ${widget.project.code}',
                          style: AppTypography.secondary.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price: ${CalculationEngine.formatCurrency(agreement.totalPrice)}',
                          style: AppTypography.secondary,
                        ),
                        Text(
                          'Paid: ${CalculationEngine.formatCurrency(totalPaid)}',
                          style: AppTypography.secondary.copyWith(
                            color: AppColors.successText,
                          ),
                        ),
                        Text(
                          'Balance Dues: ${CalculationEngine.formatCurrency(remainingDues)}',
                          style: AppTypography.secondary.copyWith(
                            color: remainingDues > 0
                                ? AppColors.warningText
                                : AppColors.successText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                      style: AppTypography.secondary.copyWith(
                        color: AppColors.dangerText,
                      ),
                    ),
                  );
                },
              ),

              // Installment selector if installments exist
              if (paInstallments.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: paInstallments.any((i) => i.id == _selectedInstallmentId)
                      ? _selectedInstallmentId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Target Installment (Optional)',
                    hintText: 'Auto-distribute or select installment',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Auto-distribute across pending dues'),
                    ),
                    ...paInstallments.map((inst) {
                      final dueStr =
                          DateFormat('dd MMM yyyy').format(inst.dueDate);
                      final rem = inst.remainingAmount;
                      return DropdownMenuItem<String?>(
                        value: inst.id,
                        child: Text(
                          '#${inst.installmentNumber} (Due: $dueStr | Rem: ${CalculationEngine.formatCurrency(rem)})',
                          style: AppTypography.input.copyWith(
                            color: rem <= 0
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedInstallmentId = val;
                      if (val != null) {
                        final matched = paInstallments
                            .where((i) => i.id == val)
                            .firstOrNull;
                        if (matched != null) {
                          _amountController.text =
                              matched.remainingAmount.round().toString();
                        }
                      } else {
                        _amountController.text =
                            remainingDues.round().toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
              ],

              // Payment Amount & Method
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Payment Amount (₹) *',
                        hintText: 'e.g. 500000',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Amount * is required';
                        }
                        final num = double.tryParse(val);
                        if (num == null || num <= 0) {
                          return 'Enter a valid positive amount';
                        }
                        if (num > remainingDues && remainingDues > 0) {
                          return 'Amount cannot exceed remaining dues of ${CalculationEngine.formatCurrency(remainingDues)}';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<PaymentMethod>(
                      initialValue: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Method *',
                      ),
                      items: PaymentMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMethod = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Payment Date & Reference
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _paymentDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _paymentDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Payment Date *',
                          suffixIcon: Icon(Icons.calendar_today, size: 16),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_paymentDate),
                          style: AppTypography.input,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Ref / UTR / Cheque No.',
                        hintText: 'e.g. UTR-9876543210',
                      ),
                    ),
                  ),
                ],
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
                        onPressed: isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () => _submit(agreement, remainingDues),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Record Land Payment'),
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
