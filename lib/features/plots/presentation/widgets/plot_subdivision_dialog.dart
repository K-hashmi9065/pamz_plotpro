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
  final _priceController = TextEditingController();

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

  // Road Access state Notifiers
  final ValueNotifier<bool> _includeRoadNotifier = ValueNotifier<bool>(false);
  final _roadNameController = TextEditingController(text: 'Access Road');
  final _roadLengthFtController = TextEditingController();
  final _roadLengthInController = TextEditingController();
  final _roadBreadthFtController = TextEditingController();
  final _roadBreadthInController = TextEditingController();
  final ValueNotifier<double> _roadAreaSqFtNotifier = ValueNotifier<double>(0.0);

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<PlotStatus> _selectedStatusNotifier = ValueNotifier<PlotStatus>(PlotStatus.available);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedProjectIdNotifier.value = widget.preselectedProjectId;
    _autoGeneratePlotNumber();
  }

  Future<void> _autoGeneratePlotNumber() async {
    final repo = ref.read(plotsRepositoryProvider);
    final autoNumber = await repo.generateNextPlotNumber();
    if (mounted) {
      _numberController.text = autoNumber;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _priceController.dispose();
    _roadNameController.dispose();
    _roadLengthFtController.dispose();
    _roadLengthInController.dispose();
    _roadBreadthFtController.dispose();
    _roadBreadthInController.dispose();
    _plotAreaSqFtNotifier.dispose();
    _plotMeasurementUnitNotifier.dispose();
    _plotDisplayAreaNotifier.dispose();
    _plotKattaValueNotifier.dispose();
    _plotDhurValueNotifier.dispose();
    _plotLengthFtNotifier.dispose();
    _plotLengthInNotifier.dispose();
    _plotBreadthFtNotifier.dispose();
    _plotBreadthInNotifier.dispose();
    _includeRoadNotifier.dispose();
    _roadAreaSqFtNotifier.dispose();
    _selectedProjectIdNotifier.dispose();
    _selectedStatusNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  void _calculateRoadArea() {
    final lFt = double.tryParse(_roadLengthFtController.text.trim()) ?? 0.0;
    final lIn = double.tryParse(_roadLengthInController.text.trim()) ?? 0.0;
    final bFt = double.tryParse(_roadBreadthFtController.text.trim()) ?? 0.0;
    final bIn = double.tryParse(_roadBreadthInController.text.trim()) ?? 0.0;

    _roadAreaSqFtNotifier.value = LandUnitConverter.calculateRoadAreaSqFt(
      lengthFt: lFt,
      lengthIn: lIn,
      breadthFt: bFt,
      breadthIn: bIn,
    );
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

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(plotsRepositoryProvider);
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final mainPlotNumber = _numberController.text.trim();

      // Create Main Plot with independent measurement
      await repo.createPlot(
        projectId: _selectedProjectIdNotifier.value!,
        plotNumber: mainPlotNumber,
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

      // If Road Access is included and road area > 0, create dedicated Road Plot record
      if (_includeRoadNotifier.value && _roadAreaSqFtNotifier.value > 0) {
        final roadName = _roadNameController.text.trim().isEmpty
            ? '$mainPlotNumber Road'
            : '${_roadNameController.text.trim()} ($mainPlotNumber)';

        await repo.createPlot(
          projectId: _selectedProjectIdNotifier.value!,
          plotNumber: roadName,
          areaSqFt: _roadAreaSqFtNotifier.value,
          measurementUnit: 'Square Feet',
          displayArea: _roadAreaSqFtNotifier.value,
          expectedPrice: 0.0,
          status: PlotStatus.reserved, // Road corridor reserved
          userId: 'admin_user',
        );
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              _includeRoadNotifier.value && _roadAreaSqFtNotifier.value > 0
                  ? 'Plot $mainPlotNumber & Road Parcel created successfully!'
                  : 'Plot $mainPlotNumber created successfully!',
            ),
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
    final projectsAsync = ref.watch(projectsListStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 660,
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
                        Text('Subdivide Land into Plot', style: AppTypography.cardTitle),
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

                    // Plot Details Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _numberController,
                            decoration: InputDecoration(
                              labelText: 'Plot Number / ID *',
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
                        const SizedBox(width: 14),
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
                                    child: Text(
                                      'AVAILABLE',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: PlotStatus.reserved,
                                    child: Text(
                                      'RESERVED',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: PlotStatus.booked,
                                    child: Text(
                                      'BOOKED',
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                    const SizedBox(height: 16),

                    // Price Field
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Expected Plot Sale Price (Optional)',
                        hintText: 'e.g. 250000',
                        prefixText: '₹ ',
                      ),
                    ),
                    const SizedBox(height: 20),

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
                      },
                    ),
                    const SizedBox(height: 20),

                    // Road Option Switch Section
                    ValueListenableBuilder<bool>(
                      valueListenable: _includeRoadNotifier,
                      builder: (context, includeRoad, _) {
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: includeRoad ? AppColors.accent : AppColors.border,
                              width: includeRoad ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.add_road,
                                        color: includeRoad ? AppColors.accent : AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add Road / Access Pathway',
                                        style: AppTypography.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: includeRoad ? AppColors.accent : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: includeRoad,
                                    onChanged: (val) {
                                      _includeRoadNotifier.value = val;
                                    },
                                  ),
                                ],
                              ),

                              if (includeRoad) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _roadNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Road Identifier / Name',
                                    hintText: 'e.g. Frontage Access Road',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _roadLengthFtController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Road Length (Ft)',
                                          hintText: 'e.g. 100',
                                          suffixText: 'ft',
                                        ),
                                        onChanged: (_) => _calculateRoadArea(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _roadLengthInController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Length (Inches)',
                                          hintText: '0 - 11',
                                          suffixText: 'in',
                                        ),
                                        onChanged: (_) => _calculateRoadArea(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _roadBreadthFtController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Road Breadth / Width (Ft)',
                                          hintText: 'e.g. 15',
                                          suffixText: 'ft',
                                        ),
                                        onChanged: (_) => _calculateRoadArea(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _roadBreadthInController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Breadth (Inches)',
                                          hintText: '0 - 11',
                                          suffixText: 'in',
                                        ),
                                        onChanged: (_) => _calculateRoadArea(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Plot & Road Cutting Summary Box
                    ValueListenableBuilder<double>(
                      valueListenable: _plotAreaSqFtNotifier,
                      builder: (context, plotAreaSqFt, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _includeRoadNotifier,
                          builder: (context, includeRoad, _) {
                            return ValueListenableBuilder<double>(
                              valueListenable: _roadAreaSqFtNotifier,
                              builder: (context, roadAreaSqFt, _) {
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Net Plot Area:', style: AppTypography.secondary),
                                          Text(LandUnitConverter.formatAllUnits(plotAreaSqFt), style: AppTypography.body),
                                        ],
                                      ),
                                      if (includeRoad) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Road Corridor Area:', style: AppTypography.secondary.copyWith(color: AppColors.warningText)),
                                            Text(
                                              LandUnitConverter.formatAllUnits(roadAreaSqFt),
                                              style: AppTypography.body.copyWith(color: AppColors.warningText, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Total Land Cut (Plot + Road):', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                                            Text(
                                              LandUnitConverter.formatAllUnits(plotAreaSqFt + roadAreaSqFt),
                                              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
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
                              : const Text('Create Plot'),
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
