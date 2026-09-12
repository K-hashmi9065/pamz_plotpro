import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/land_unit_converter.dart';
import '../../../../core/widgets/land_measurement_input_widget.dart';
import '../../domain/plot_model.dart';
import '../plots_providers.dart';

class PlotEditDialog extends ConsumerStatefulWidget {
  final PlotModel plot;

  const PlotEditDialog({super.key, required this.plot});

  static Future<void> show(BuildContext context, PlotModel plot) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlotEditDialog(plot: plot),
    );
  }

  @override
  ConsumerState<PlotEditDialog> createState() => _PlotEditDialogState();
}

class _PlotEditDialogState extends ConsumerState<PlotEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  late final TextEditingController _ratePerKattaController;
  late final TextEditingController _priceController;

  late final ValueNotifier<double> _plotAreaSqFtNotifier;
  late final ValueNotifier<String> _plotMeasurementUnitNotifier;
  late final ValueNotifier<double?> _plotDisplayAreaNotifier;
  late final ValueNotifier<double?> _plotKattaValueNotifier;
  late final ValueNotifier<double?> _plotDhurValueNotifier;
  late final ValueNotifier<double?> _plotLengthFtNotifier;
  late final ValueNotifier<double?> _plotLengthInNotifier;
  late final ValueNotifier<double?> _plotBreadthFtNotifier;
  late final ValueNotifier<double?> _plotBreadthInNotifier;

  late final ValueNotifier<PlotStatus> _selectedStatusNotifier;
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    final p = widget.plot;
    _numberController = TextEditingController(text: p.plotNumber);

    _plotAreaSqFtNotifier = ValueNotifier<double>(p.areaSqFt);
    _plotMeasurementUnitNotifier = ValueNotifier<String>(p.measurementUnit);
    _plotDisplayAreaNotifier = ValueNotifier<double?>(p.displayArea);
    _plotKattaValueNotifier = ValueNotifier<double?>(p.kattaValue);
    _plotDhurValueNotifier = ValueNotifier<double?>(p.dhurValue);
    _plotLengthFtNotifier = ValueNotifier<double?>(p.lengthFt);
    _plotLengthInNotifier = ValueNotifier<double?>(p.lengthIn);
    _plotBreadthFtNotifier = ValueNotifier<double?>(p.breadthFt);
    _plotBreadthInNotifier = ValueNotifier<double?>(p.breadthIn);

    _selectedStatusNotifier = ValueNotifier<PlotStatus>(p.status);

    _priceController = TextEditingController(
      text: p.expectedPrice > 0
          ? (p.expectedPrice == p.expectedPrice.roundToDouble()
              ? p.expectedPrice.toInt().toString()
              : p.expectedPrice.toString())
          : '',
    );

    // Initial rate per kattha if price & area exist
    String initialRateStr = '';
    if (p.expectedPrice > 0 && p.areaSqFt > 0) {
      final totalKattha = LandUnitConverter.sqFtToKatta(p.areaSqFt);
      if (totalKattha > 0) {
        final rate = p.expectedPrice / totalKattha;
        initialRateStr = rate == rate.roundToDouble()
            ? rate.toInt().toString()
            : rate.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      }
    }
    _ratePerKattaController = TextEditingController(text: initialRateStr);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _ratePerKattaController.dispose();
    _priceController.dispose();
    _plotAreaSqFtNotifier.dispose();
    _plotMeasurementUnitNotifier.dispose();
    _plotDisplayAreaNotifier.dispose();
    _plotKattaValueNotifier.dispose();
    _plotDhurValueNotifier.dispose();
    _plotLengthFtNotifier.dispose();
    _plotLengthInNotifier.dispose();
    _plotBreadthFtNotifier.dispose();
    _plotBreadthInNotifier.dispose();
    _selectedStatusNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  void _onRatePerKattaChanged() {
    final rawRate = _ratePerKattaController.text.trim();
    if (rawRate.isEmpty) return;
    final rate = double.tryParse(rawRate);
    if (rate == null || rate <= 0) return;

    final totalKattha = LandUnitConverter.sqFtToKatta(_plotAreaSqFtNotifier.value);
    if (totalKattha > 0) {
      final totalPrice = totalKattha * rate;
      final formattedPrice = totalPrice == totalPrice.roundToDouble()
          ? totalPrice.toInt().toString()
          : totalPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      _priceController.text = formattedPrice;
    }
  }

  void _onPriceChanged() {
    final rawPrice = _priceController.text.trim();
    if (rawPrice.isEmpty) return;
    final price = double.tryParse(rawPrice);
    if (price == null || price <= 0) return;

    final totalKattha = LandUnitConverter.sqFtToKatta(_plotAreaSqFtNotifier.value);
    if (totalKattha > 0) {
      final computedRate = price / totalKattha;
      final formattedRate = computedRate == computedRate.roundToDouble()
          ? computedRate.toInt().toString()
          : computedRate.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      _ratePerKattaController.text = formattedRate;
    }
  }

  void _recalculatePlotPriceFromRate() {
    final rawRate = _ratePerKattaController.text.trim();
    if (rawRate.isEmpty) return;
    final rate = double.tryParse(rawRate);
    if (rate != null && rate > 0) {
      final totalKattha = LandUnitConverter.sqFtToKatta(_plotAreaSqFtNotifier.value);
      if (totalKattha > 0) {
        final totalPrice = totalKattha * rate;
        final formattedPrice = totalPrice == totalPrice.roundToDouble()
            ? totalPrice.toInt().toString()
            : totalPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
        _priceController.text = formattedPrice;
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_plotAreaSqFtNotifier.value <= 0) {
      _errorMessageNotifier.value = 'Plot Area must be greater than 0 sq.ft.';
      return;
    }

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(plotsRepositoryProvider);
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      final updatedPlot = widget.plot.copyWith(
        plotNumber: _numberController.text.trim(),
        areaSqFt: _plotAreaSqFtNotifier.value,
        measurementUnit: _plotMeasurementUnitNotifier.value,
        displayArea: _plotDisplayAreaNotifier.value,
        kattaValue: _plotKattaValueNotifier.value,
        dhurValue: _plotDhurValueNotifier.value,
        lengthFt: _plotLengthFtNotifier.value,
        lengthIn: _plotLengthInNotifier.value,
        breadthFt: _plotBreadthFtNotifier.value,
        breadthIn: _plotBreadthInNotifier.value,
        expectedPrice: price,
        status: _selectedStatusNotifier.value,
      );

      await repo.updatePlot(updatedPlot, userId: 'admin_user');

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Plot #${updatedPlot.plotNumber} updated successfully!'),
          ),
        );
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
        width: 640,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Edit Plot (${widget.plot.plotNumber})', style: AppTypography.cardTitle),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 14),

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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              errorMessage,
                              style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                            ),
                          ),
                        );
                      },
                    ),

                    // Plot Details Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _numberController,
                            decoration: const InputDecoration(
                              labelText: 'Plot Number / ID *',
                              hintText: 'e.g. AXPN0001',
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Plot Number * is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 3,
                          child: ValueListenableBuilder<PlotStatus>(
                            valueListenable: _selectedStatusNotifier,
                            builder: (context, selectedStatus, _) {
                              return DropdownButtonFormField<PlotStatus>(
                                initialValue: selectedStatus,
                                isExpanded: true,
                                decoration: const InputDecoration(labelText: 'Status *'),
                                items: PlotStatus.values.map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s.name.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) _selectedStatusNotifier.value = val;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Land Measurement Input Widget
                    LandMeasurementInputWidget(
                      labelPrefix: 'Plot Area',
                      initialUnit: _plotMeasurementUnitNotifier.value,
                      initialDisplayArea: _plotDisplayAreaNotifier.value,
                      initialKattaValue: _plotKattaValueNotifier.value,
                      initialDhurValue: _plotDhurValueNotifier.value,
                      initialAreaSqFt: _plotAreaSqFtNotifier.value,
                      initialLengthFt: _plotLengthFtNotifier.value,
                      initialLengthIn: _plotLengthInNotifier.value,
                      initialBreadthFt: _plotBreadthFtNotifier.value,
                      initialBreadthIn: _plotBreadthInNotifier.value,
                      onMeasurementDetailsChanged: ({
                        required String measurementUnit,
                        required double areaSqFt,
                        double? displayArea,
                        double? kattaValue,
                        double? dhurValue,
                        double? lengthFt,
                        double? lengthIn,
                        double? breadthFt,
                        double? breadthIn,
                      }) {
                        _plotMeasurementUnitNotifier.value = measurementUnit;
                        _plotAreaSqFtNotifier.value = areaSqFt;
                        _plotDisplayAreaNotifier.value = displayArea;
                        _plotKattaValueNotifier.value = kattaValue;
                        _plotDhurValueNotifier.value = dhurValue;
                        _plotLengthFtNotifier.value = lengthFt;
                        _plotLengthInNotifier.value = lengthIn;
                        _plotBreadthFtNotifier.value = breadthFt;
                        _plotBreadthInNotifier.value = breadthIn;
                        _recalculatePlotPriceFromRate();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Rate per Kattha & Expected Plot Sale Price Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ratePerKattaController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Rate per Kattha (Optional)',
                              hintText: 'e.g. 500000',
                              prefixText: '₹ ',
                              suffixText: '/ Kattha',
                            ),
                            onChanged: (_) => _onRatePerKattaChanged(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Plot Sell Price (Optional)',
                              hintText: 'e.g. 250000',
                              prefixText: '₹ ',
                            ),
                            onChanged: (_) => _onPriceChanged(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Buttons Row
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
                              : const Text('Save Changes'),
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
    );
  }
}
