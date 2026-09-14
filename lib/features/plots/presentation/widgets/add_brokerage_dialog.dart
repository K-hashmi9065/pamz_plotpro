import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../domain/plot_model.dart';
import '../plots_providers.dart';
import 'brokerage_pdf_dialog.dart';

class AddBrokerageDialog extends ConsumerStatefulWidget {
  final PlotModel plot;

  const AddBrokerageDialog({super.key, required this.plot});

  static Future<bool?> show(BuildContext context, PlotModel plot) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddBrokerageDialog(plot: plot),
    );
  }

  @override
  ConsumerState<AddBrokerageDialog> createState() => _AddBrokerageDialogState();
}

class _AddBrokerageDialogState extends ConsumerState<AddBrokerageDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _brokerNameController;
  late final TextEditingController _brokerPhoneController;
  late final TextEditingController _brokerageChargeController;

  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _brokerNameController = TextEditingController(text: widget.plot.brokerName ?? '');
    _brokerPhoneController = TextEditingController(text: widget.plot.brokerPhone ?? '');
    _brokerageChargeController = TextEditingController(
      text: widget.plot.brokerageCharge > 0
          ? (widget.plot.brokerageCharge == widget.plot.brokerageCharge.roundToDouble()
              ? widget.plot.brokerageCharge.toInt().toString()
              : widget.plot.brokerageCharge.toString())
          : '',
    );
  }

  @override
  void dispose() {
    _brokerNameController.dispose();
    _brokerPhoneController.dispose();
    _brokerageChargeController.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final charge = double.tryParse(_brokerageChargeController.text.trim()) ?? 0.0;
    if (charge <= 0) {
      _errorMessageNotifier.value = 'Brokerage charge must be greater than ₹0.';
      return;
    }

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(plotsRepositoryProvider);
      await repo.recordPlotBrokerage(
        plotId: widget.plot.id,
        brokerName: _brokerNameController.text.trim(),
        brokerPhone: _brokerPhoneController.text.trim(),
        brokerageCharge: charge,
        userId: 'admin_user',
      );

      final updatedPlot = widget.plot.copyWith(
        brokerName: _brokerNameController.text.trim(),
        brokerPhone: _brokerPhoneController.text.trim(),
        brokerageCharge: charge,
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        final db = ref.read(appDatabaseProvider);
        final prj = await (db.select(db.projects)
              ..where((p) => p.id.equals(widget.plot.projectId)))
            .getSingleOrNull();

        navigator.pop(true);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Brokerage charge of ${CalculationEngine.formatCurrency(charge)} recorded for Plot #${widget.plot.plotNumber}! Opening PDF voucher...',
            ),
          ),
        );

        if (mounted) {
          BrokeragePdfDialog.show(
            context,
            plot: updatedPlot,
            projectName: prj?.name ?? 'Project',
            projectCode: prj?.code ?? 'PRJ',
            projectLocation: prj?.location ?? '—',
          );
        }
      }
    } catch (e) {
      _errorMessageNotifier.value = e.toString().replaceAll('ArgumentError: ', '');
      _isSavingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 520,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.handshake_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Brokerage Charge',
                                      style: AppTypography.cardTitle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${widget.plot.plotNumber} • Area: ${widget.plot.formattedArea}',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Info banner explaining project expense linkage
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This brokerage charge will be attached to ${widget.plot.plotNumber} and automatically recorded as a capitalized project expense under this project.',
                              style: AppTypography.secondary.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error Message Container
                    ValueListenableBuilder<String?>(
                      valueListenable: _errorMessageNotifier,
                      builder: (context, errorMessage, _) {
                        if (errorMessage == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.dangerText.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.dangerBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.dangerText, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(color: AppColors.dangerText, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Broker Name
                    TextFormField(
                      controller: _brokerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Broker Name *',
                        hintText: 'Enter broker full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Broker Name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Broker Mobile Number
                    TextFormField(
                      controller: _brokerPhoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Broker Mobile Number',
                        hintText: 'e.g. +91 9876543210',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Brokerage Charge Amount
                    TextFormField(
                      controller: _brokerageChargeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Brokerage Charge (₹) *',
                        hintText: 'e.g. 25000',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Brokerage Charge amount is required.';
                        }
                        final amount = double.tryParse(val.trim());
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount greater than ₹0.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: isSaving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Brokerage Charge'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
