import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/land_unit_converter.dart';
import '../../../../core/widgets/land_measurement_input_widget.dart';
import '../../../../shared/widgets/searchable_project_dropdown.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../plots_providers.dart';

class PlotSubdivisionDialog extends ConsumerStatefulWidget {
  final String? preselectedProjectId;

  const PlotSubdivisionDialog({
    super.key,
    this.preselectedProjectId,
  });

  static Future<void> show(BuildContext context, {String? preselectedProjectId}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlotSubdivisionDialog(preselectedProjectId: preselectedProjectId),
    );
  }

  @override
  ConsumerState<PlotSubdivisionDialog> createState() => _PlotSubdivisionDialogState();
}

class _PlotSubdivisionDialogState extends ConsumerState<PlotSubdivisionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _numberOfPlotsController = TextEditingController(text: '1');
  final _ratePerKattaController = TextEditingController();
  final _priceController = TextEditingController();

  final ValueNotifier<int> _numberOfPlotsNotifier = ValueNotifier<int>(1);

  // Plot Area & Measurement Notifiers
  final ValueNotifier<double> _plotAreaSqFtNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> _plotMeasurementUnitNotifier =
      ValueNotifier<String>(LandMeasurementInputWidget.dimensionsUnit);
  final ValueNotifier<double?> _plotDisplayAreaNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _plotKattaValueNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _plotDhurValueNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _plotLengthFtNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _plotLengthInNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _plotBreadthFtNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _plotBreadthInNotifier = ValueNotifier<double?>(null);

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<PlotStatus> _selectedStatusNotifier = ValueNotifier<PlotStatus>(PlotStatus.available);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedProjectIdNotifier.value = widget.preselectedProjectId;

    _numberOfPlotsController.addListener(() {
      final raw = _numberOfPlotsController.text.trim();
      final val = raw.isEmpty ? 1 : (int.tryParse(raw) ?? 1);
      _numberOfPlotsNotifier.value = val.clamp(1, 500);
    });

    _autoGeneratePlotNumber();
  }

  Future<void> _autoGeneratePlotNumber() async {
    final repo = ref.read(plotsRepositoryProvider);
    final autoNumber = await repo.generateNextPlotNumber();
    if (mounted) {
      _numberController.text = autoNumber;
    }
  }

  List<String> _getGeneratedPlotNumbers() {
    final startingNumber = _numberController.text.trim().isEmpty
        ? 'AXPN0001'
        : _numberController.text.trim();
    final count = _numberOfPlotsNotifier.value;
    if (count <= 1) return [startingNumber];

    final regExp = RegExp(r'^(.*?)(\d+)$');
    final match = regExp.firstMatch(startingNumber);
    if (match != null) {
      final prefix = match.group(1) ?? '';
      final digitsStr = match.group(2) ?? '';
      final startNum = int.tryParse(digitsStr) ?? 1;
      final padLength = digitsStr.length;
      final list = <String>[];
      for (int i = 0; i < count; i++) {
        final currentNum = startNum + i;
        list.add('$prefix${currentNum.toString().padLeft(padLength, '0')}');
      }
      return list;
    } else {
      final base = startingNumber;
      final list = <String>[];
      for (int i = 1; i <= count; i++) {
        list.add('$base-$i');
      }
      return list;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _numberOfPlotsController.dispose();
    _numberOfPlotsNotifier.dispose();
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
    _selectedProjectIdNotifier.dispose();
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
    if (_selectedProjectIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a Project *';
      return;
    }
    if (_plotAreaSqFtNotifier.value <= 0) {
      _errorMessageNotifier.value = 'Plot Area must be greater than 0';
      return;
    }

    final count = _numberOfPlotsNotifier.value;
    if (count < 1) {
      _errorMessageNotifier.value = 'Number of plots must be at least 1';
      return;
    }

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(plotsRepositoryProvider);
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final plotNumbers = _getGeneratedPlotNumbers();

      // Create Plots in batch with identical measurements
      await repo.createPlotsBatch(
        projectId: _selectedProjectIdNotifier.value!,
        plotNumbers: plotNumbers,
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
        userId: 'admin_user',
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        final successMsg = count > 1
            ? '$count Plots (${plotNumbers.first} - ${plotNumbers.last}) created successfully!'
            : 'Plot ${plotNumbers.first} created successfully!';
        messenger.showSnackBar(
          SnackBar(content: Text(successMsg)),
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 680,
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
                        Row(
                          children: [
                            const Icon(Icons.grid_view_outlined, color: AppColors.accent, size: 24),
                            const SizedBox(width: 8),
                            Text('Subdivide Land into Plot', style: AppTypography.cardTitle),
                          ],
                        ),
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

                    // Target Project *
                    projectsAsync.when(
                      data: (projects) => ValueListenableBuilder<String?>(
                        valueListenable: _selectedProjectIdNotifier,
                        builder: (context, selectedProjectId, _) {
                          return SearchableProjectDropdown(
                            projects: projects,
                            selectedProjectId: selectedProjectId,
                            labelText: 'Target Project *',
                            onChanged: (val) => _selectedProjectIdNotifier.value = val,
                            validator: (val) => val == null ? 'Project * is required' : null,
                          );
                        },
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text('Error loading projects: $e'),
                    ),
                    const SizedBox(height: 16),

                    // Plot Details Row: Plot Number / Starting ID, Number of Plots (Optional), Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _numberController,
                            onChanged: (_) {
                              _numberOfPlotsNotifier.value = _numberOfPlotsNotifier.value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Plot Number / Starting ID *',
                              hintText: 'e.g. AXPN0001',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
                                tooltip: 'Auto-generate Plot ID (AXPN0001)',
                                onPressed: _autoGeneratePlotNumber,
                              ),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Plot Number * is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _numberOfPlotsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Total Plots (Optional)',
                              hintText: '1',
                              prefixIcon: Icon(Icons.copy_outlined, size: 18),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return null;
                              final count = int.tryParse(val.trim());
                              if (count == null || count < 1) {
                                return 'Min 1';
                              }
                              if (count > 500) {
                                return 'Max 500';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: ValueListenableBuilder<PlotStatus>(
                            valueListenable: _selectedStatusNotifier,
                            builder: (context, selectedStatus, _) {
                              return DropdownButtonFormField<PlotStatus>(
                                initialValue: selectedStatus,
                                isExpanded: true,
                                decoration: const InputDecoration(labelText: 'Initial Status *'),
                                items: const [
                                  DropdownMenuItem(
                                    value: PlotStatus.available,
                                    child: Text('AVAILABLE', overflow: TextOverflow.ellipsis),
                                  ),
                                  DropdownMenuItem(
                                    value: PlotStatus.reserved,
                                    child: Text('RESERVED', overflow: TextOverflow.ellipsis),
                                  ),
                                  DropdownMenuItem(
                                    value: PlotStatus.booked,
                                    child: Text('BOOKED', overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) _selectedStatusNotifier.value = val;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Multi-Plot Preview Banner
                    ValueListenableBuilder<int>(
                      valueListenable: _numberOfPlotsNotifier,
                      builder: (context, count, _) {
                        if (count <= 1) return const SizedBox.shrink();
                        final plotNumbers = _getGeneratedPlotNumbers();
                        final firstId = plotNumbers.first;
                        final lastId = plotNumbers.last;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.layers_outlined, size: 16, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Will create $count identical plots ($firstId to $lastId) with same length & breadth.',
                                    style: AppTypography.secondary.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                    const SizedBox(height: 20),

                    // Plot Cutting Summary Box
                    ValueListenableBuilder<double>(
                      valueListenable: _plotAreaSqFtNotifier,
                      builder: (context, plotAreaSqFt, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: _numberOfPlotsNotifier,
                          builder: (context, count, _) {
                            final totalPlotsArea = plotAreaSqFt * count;
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Subdivision Cutting Summary', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                                  const SizedBox(height: 8),
                                  if (count > 1) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Single Plot Area:', style: AppTypography.secondary),
                                        Text(LandUnitConverter.formatAllUnits(plotAreaSqFt), style: AppTypography.body),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Number of Plots to Cut:', style: AppTypography.secondary),
                                        Text('$count Plots', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Plots Area ($count × ${plotAreaSqFt.toStringAsFixed(0)}):', style: AppTypography.secondary.copyWith(fontWeight: FontWeight.w600)),
                                        Text(LandUnitConverter.formatAllUnits(totalPlotsArea), style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Land Cut ($count Plots):', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                                        Text(
                                          LandUnitConverter.formatAllUnits(totalPlotsArea),
                                          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Land Cut (1 Plot):', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                                        Text(LandUnitConverter.formatAllUnits(plotAreaSqFt), style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
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
                        ValueListenableBuilder<int>(
                          valueListenable: _numberOfPlotsNotifier,
                          builder: (context, count, _) {
                            return ElevatedButton(
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
                                  : Text(count > 1 ? 'Create $count Plots' : 'Create Plot'),
                            );
                          },
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
