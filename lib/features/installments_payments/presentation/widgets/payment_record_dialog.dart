import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';

import '../../domain/installment_model.dart';
import '../installments_providers.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../../buyers_sales/presentation/sales_providers.dart';
import '../../../buyers_sales/domain/sale_model.dart';
import '../../../../shared/widgets/searchable_project_dropdown.dart';

class PaymentRecordDialog extends ConsumerStatefulWidget {
  final InstallmentModel? initialInstallment;
  final String? initialProjectId;

  const PaymentRecordDialog({
    super.key,
    this.initialInstallment,
    this.initialProjectId,
  });

  static Future<void> show(
    BuildContext context, {
    InstallmentModel? installment,
    String? projectId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentRecordDialog(
        initialInstallment: installment,
        initialProjectId: projectId,
      ),
    );
  }

  @override
  ConsumerState<PaymentRecordDialog> createState() => _PaymentRecordDialogState();
}

class _PaymentRecordDialogState extends ConsumerState<PaymentRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _receiptPathController = TextEditingController();

  final ValueNotifier<DateTime> _paymentDateNotifier = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<PaymentMethod> _paymentMethodNotifier = ValueNotifier<PaymentMethod>(PaymentMethod.bankTransfer);
  final ValueNotifier<InstallmentModel?> _selectedInstallmentNotifier = ValueNotifier<InstallmentModel?>(null);
  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedSaleIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedInstallmentNotifier.value = widget.initialInstallment;
    _selectedProjectIdNotifier.value = widget.initialProjectId;
    if (_selectedInstallmentNotifier.value != null) {
      _amountController.text = _selectedInstallmentNotifier.value!.remainingAmount.toStringAsFixed(2);
      _selectedSaleIdNotifier.value = _selectedInstallmentNotifier.value!.saleId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _receiptPathController.dispose();
    _paymentDateNotifier.dispose();
    _paymentMethodNotifier.dispose();
    _selectedInstallmentNotifier.dispose();
    _selectedProjectIdNotifier.dispose();
    _selectedSaleIdNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDateNotifier.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _paymentDateNotifier.value = picked;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectIdNotifier.value == null && widget.initialProjectId == null && _selectedInstallmentNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a target project.';
      return;
    }

    final parsedAmount = double.tryParse(_amountController.text) ?? 0.0;
    final projId = _selectedProjectIdNotifier.value ?? widget.initialProjectId ?? 'GLOBAL_PROJECT';

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(installmentsRepositoryProvider);
      await repo.recordPayment(
        projectId: projId,
        installmentId: _selectedInstallmentNotifier.value?.id,
        amount: parsedAmount,
        paymentDate: _paymentDateNotifier.value,
        paymentMethod: _paymentMethodNotifier.value,
        referenceNumber: _referenceController.text,
        receiptPath: _receiptPathController.text,
        userId: 'active_user',
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully!')),
        );
      }
    } catch (e) {
      _errorMessageNotifier.value = e.toString().replaceAll('ArgumentError: ', '');
      _isSavingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListStreamProvider);
    final salesAsync = ref.watch(salesListStreamProvider);
    final installmentsAsync = ref.watch(installmentsListStreamProvider);

    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: maxHeight,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSavingNotifier,
              builder: (context, isSaving, _) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Record Payment Entry', style: AppTypography.cardTitle),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      ValueListenableBuilder<String?>(
                        valueListenable: _errorMessageNotifier,
                        builder: (context, errorMessage, _) {
                          if (errorMessage == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.dangerBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.dangerBorder),
                              ),
                              child: Text(
                                errorMessage,
                                style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                              ),
                            ),
                          );
                        },
                      ),

                      // Cash Limit Warning Banner (Section 269ST)
                      ValueListenableBuilder<PaymentMethod>(
                        valueListenable: _paymentMethodNotifier,
                        builder: (context, paymentMethod, _) {
                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _amountController,
                            builder: (context, amountVal, _) {
                              final parsedAmount = double.tryParse(amountVal.text) ?? 0.0;
                              final isCashLimitTriggered =
                                  paymentMethod == PaymentMethod.cash && parsedAmount >= AppConstants.cashTransactionLimit;

                              if (!isCashLimitTriggered) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade900.withAlpha(50),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.warningText),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: AppColors.warningText, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '⚠️ SECTION 269ST COMPLIANCE WARNING: Receiving cash equal to or exceeding ₹2,00,000 in a single day/transaction triggers statutory scrutiny under Section 269ST with up to 100% penalty under Section 271DA.',
                                          style: AppTypography.secondary.copyWith(
                                            color: AppColors.warningText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Project & Buyer Filtering Dropdowns if not pre-selected installment
                      if (widget.initialInstallment == null) ...[
                        Row(
                          children: [
                            // Step 1: Target Project Dropdown
                            Expanded(
                              child: projectsAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (err, s) => Text('Error loading projects: $err'),
                                data: (projects) {
                                  return ValueListenableBuilder<String?>(
                                    valueListenable: _selectedProjectIdNotifier,
                                    builder: (context, selectedProjectId, _) {
                                      final currentProjectValid = selectedProjectId != null &&
                                          projects.any((p) => p.id == selectedProjectId);
                                      final projectValue = currentProjectValid ? selectedProjectId : null;

                                      return SearchableProjectDropdown(
                                        projects: projects,
                                        selectedProjectId: projectValue,
                                        labelText: 'Select Project *',
                                        onChanged: (val) {
                                          _selectedProjectIdNotifier.value = val;
                                          _selectedSaleIdNotifier.value = null;
                                          _selectedInstallmentNotifier.value = null;
                                          _amountController.clear();
                                        },
                                        validator: (val) => val == null ? 'Please select a project' : null,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Step 2: Target Buyer / Sale Dropdown (Disabled until Project selected)
                            Expanded(
                              child: salesAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (err, s) => Text('Error loading sales: $err'),
                                data: (sales) {
                                  return ValueListenableBuilder<String?>(
                                    valueListenable: _selectedProjectIdNotifier,
                                    builder: (context, selectedProjectId, _) {
                                      return ValueListenableBuilder<String?>(
                                        valueListenable: _selectedSaleIdNotifier,
                                        builder: (context, selectedSaleId, _) {
                                          final filteredSales = selectedProjectId != null
                                              ? sales.where((s) => s.projectId == selectedProjectId).toList()
                                              : <SaleModel>[];

                                          final currentSaleValid = selectedSaleId != null &&
                                              filteredSales.any((s) => s.id == selectedSaleId);
                                          final saleValue = currentSaleValid ? selectedSaleId : null;

                                          final isBuyerEnabled = selectedProjectId != null;

                                          return DropdownButtonFormField<String?>(
                                            initialValue: saleValue,
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              labelText: 'Select Buyer / Sale *',
                                              hintText: !isBuyerEnabled ? 'Select Project First' : 'Choose Buyer',
                                            ),
                                            items: isBuyerEnabled
                                                ? filteredSales.map((sale) {
                                                    final displayId =
                                                        sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id;
                                                    return DropdownMenuItem<String?>(
                                                      value: sale.id,
                                                      child: Text(
                                                        '${sale.buyerName} (#$displayId)',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: AppTypography.input.copyWith(fontSize: 13),
                                                      ),
                                                    );
                                                  }).toList()
                                                : null,
                                            onChanged: !isBuyerEnabled
                                                ? null
                                                : (val) {
                                                    _selectedSaleIdNotifier.value = val;
                                                    _selectedInstallmentNotifier.value = null;
                                                    _amountController.clear();
                                                  },
                                            validator: (val) {
                                              if (selectedProjectId != null && val == null) {
                                                return 'Please select a buyer';
                                              }
                                              return null;
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Step 3: Installment Selection Dropdown (Disabled until Buyer selected)
                        installmentsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (err, s) => Text('Error loading installments: $err'),
                          data: (installments) {
                            return ValueListenableBuilder<String?>(
                              valueListenable: _selectedSaleIdNotifier,
                              builder: (context, selectedSaleId, _) {
                                return ValueListenableBuilder<InstallmentModel?>(
                                  valueListenable: _selectedInstallmentNotifier,
                                  builder: (context, selectedInstallment, _) {
                                    var available = installments
                                        .where((inst) => inst.status != InstallmentStatus.paid)
                                        .toList();

                                    if (selectedSaleId != null) {
                                      available = available
                                          .where((inst) => inst.saleId == selectedSaleId)
                                          .toList();
                                    } else {
                                      available = [];
                                    }

                                    final isSelectedValid = selectedInstallment != null &&
                                        available.any((inst) => inst.id == selectedInstallment.id);
                                    final dropdownValue = isSelectedValid ? selectedInstallment : null;

                                    final isInstallmentEnabled = selectedSaleId != null;

                                    return DropdownButtonFormField<InstallmentModel?>(
                                      initialValue: dropdownValue,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: 'Select Installment',
                                        hintText: !isInstallmentEnabled
                                            ? 'Select Project & Buyer First'
                                            : 'Select Installment or Direct Payment',
                                      ),
                                      items: isInstallmentEnabled
                                          ? [
                                              DropdownMenuItem<InstallmentModel?>(
                                                value: null,
                                                child: Text(
                                                  '➕ Direct Payment (Without Installment)',
                                                  style: AppTypography.input.copyWith(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.accent,
                                                  ),
                                                ),
                                              ),
                                              ...available.map((inst) {
                                                return DropdownMenuItem<InstallmentModel?>(
                                                  value: inst,
                                                  child: Text(
                                                    'Inst #${inst.installmentNumber} - Due: ${CalculationEngine.formatCurrency(inst.dueAmount)} (Remaining: ${CalculationEngine.formatCurrency(inst.remainingAmount)})',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTypography.input.copyWith(fontSize: 13),
                                                  ),
                                                );
                                              }),
                                            ]
                                          : null,
                                      onChanged: !isInstallmentEnabled
                                          ? null
                                          : (val) {
                                              _selectedInstallmentNotifier.value = val;
                                              if (val != null) {
                                                _amountController.text = val.remainingAmount.toStringAsFixed(2);
                                              } else {
                                                _amountController.clear();
                                              }
                                            },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ] else
                        ValueListenableBuilder<InstallmentModel?>(
                          valueListenable: _selectedInstallmentNotifier,
                          builder: (context, selectedInstallment, _) {
                            if (selectedInstallment == null) return const SizedBox.shrink();
                            return Container(
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
                                    'Installment #${selectedInstallment.installmentNumber}',
                                    style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Due Date: ${DateFormat('dd MMM yyyy').format(selectedInstallment.dueDate)} | Total Due: ${CalculationEngine.formatCurrency(selectedInstallment.dueAmount)}',
                                    style: AppTypography.secondary,
                                  ),
                                  const SizedBox(height: 2),
                                  if (selectedInstallment.remainingAmount <= 0)
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: AppColors.successText, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Status: Fully Paid & Cleared (Balance: ₹0)',
                                          style: AppTypography.secondary.copyWith(
                                            color: AppColors.successText,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      'Remaining Balance: ${CalculationEngine.formatCurrency(selectedInstallment.remainingAmount)}',
                                      style: AppTypography.secondary.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Payment Amount (₹) *',
                                hintText: 'e.g. 50000',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Amount * is required';
                                }
                                final num = double.tryParse(val);
                                if (num == null || num <= 0) {
                                  return 'Enter a valid positive amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ValueListenableBuilder<PaymentMethod>(
                              valueListenable: _paymentMethodNotifier,
                              builder: (context, paymentMethod, _) {
                                return DropdownButtonFormField<PaymentMethod>(
                                  initialValue: paymentMethod,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Method *',
                                  ),
                                  items: PaymentMethod.values.map((method) {
                                    return DropdownMenuItem<PaymentMethod>(
                                      value: method,
                                      child: Text(
                                        method.name.toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.input.copyWith(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) _paymentMethodNotifier.value = val;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Payment Date *',
                                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                                ),
                                child: ValueListenableBuilder<DateTime>(
                                  valueListenable: _paymentDateNotifier,
                                  builder: (context, paymentDate, _) {
                                    return Text(
                                      DateFormat('dd MMM yyyy').format(paymentDate),
                                      style: AppTypography.input,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _referenceController,
                              decoration: const InputDecoration(
                                labelText: 'Ref / UTR / Cheque No.',
                                hintText: 'e.g. UTR987654321',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _receiptPathController,
                        decoration: const InputDecoration(
                          labelText: 'Receipt File Path / Ref',
                          hintText: 'e.g. C:\\Receipts\\rcpt_101.pdf',
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
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
                                : const Text('Record Payment'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
