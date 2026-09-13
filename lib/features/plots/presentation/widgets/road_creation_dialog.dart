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

class RoadCreationDialog extends ConsumerStatefulWidget {
  final String? preselectedProjectId;

  const RoadCreationDialog({
    super.key,
    this.preselectedProjectId,
  });

  static Future<void> show(BuildContext context, {String? preselectedProjectId}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoadCreationDialog(preselectedProjectId: preselectedProjectId),
    );
  }

  @override
  ConsumerState<RoadCreationDialog> createState() => _RoadCreationDialogState();
}

class _RoadCreationDialogState extends ConsumerState<RoadCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Road Area & Measurement Notifiers
  final ValueNotifier<double> _roadAreaSqFtNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> _roadMeasurementUnitNotifier =
      ValueNotifier<String>(LandMeasurementInputWidget.dimensionsUnit);
  final ValueNotifier<double?> _roadDisplayAreaNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _roadKattaValueNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _roadDhurValueNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _roadLengthFtNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _roadLengthInNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _roadBreadthFtNotifier = ValueNotifier<double?>(null);
  final ValueNotifier<double?> _roadBreadthInNotifier = ValueNotifier<double?>(null);

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedProjectIdNotifier.value = widget.preselectedProjectId;
    _autoGenerateRoadNumber();
  }

  Future<void> _autoGenerateRoadNumber() async {
    final repo = ref.read(plotsRepositoryProvider);
    final autoNumber = await repo.generateNextRoadNumber();
    if (mounted) {
      _nameController.text = autoNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roadAreaSqFtNotifier.dispose();
    _roadMeasurementUnitNotifier.dispose();
    _roadDisplayAreaNotifier.dispose();
    _roadKattaValueNotifier.dispose();
    _roadDhurValueNotifier.dispose();
    _roadLengthFtNotifier.dispose();
    _roadLengthInNotifier.dispose();
    _roadBreadthFtNotifier.dispose();
    _roadBreadthInNotifier.dispose();
    _selectedProjectIdNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a Target Project *';
      return;
    }
    if (_roadAreaSqFtNotifier.value <= 0) {
      _errorMessageNotifier.value = 'Road Area must be greater than 0';
      return;
    }

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(plotsRepositoryProvider);
      final roadName = _nameController.text.trim();

      await repo.createPlot(
        projectId: _selectedProjectIdNotifier.value!,
        plotNumber: roadName,
        areaSqFt: _roadAreaSqFtNotifier.value,
        measurementUnit: _roadMeasurementUnitNotifier.value,
        displayArea: _roadDisplayAreaNotifier.value,
        kattaValue: _roadKattaValueNotifier.value,
        dhurValue: _roadDhurValueNotifier.value,
        lengthFt: _roadLengthFtNotifier.value,
        lengthIn: _roadLengthInNotifier.value,
        breadthFt: _roadBreadthFtNotifier.value,
        breadthIn: _roadBreadthInNotifier.value,
        expectedPrice: 0.0,
        status: PlotStatus.reserved, // Road infrastructure is non-sellable corridor
        userId: 'admin_user',
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Road "$roadName" created successfully!'),
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
                        Row(
                          children: [
                            const Icon(Icons.add_road, color: AppColors.accent, size: 24),
                            const SizedBox(width: 8),
                            Text('Add Road / Access Pathway', style: AppTypography.cardTitle),
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

                    // Road Identifier / Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Road Identifier / ID *',
                        hintText: 'e.g. ROAD-01 or Access Road',
                        prefixIcon: const Icon(Icons.alt_route_outlined, size: 18),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
                          tooltip: 'Auto-generate Road ID (ROAD-01)',
                          onPressed: _autoGenerateRoadNumber,
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Road Identifier / ID * is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Land Measurement Input Widget
                    LandMeasurementInputWidget(
                      labelPrefix: 'Road Dimensions & Area',
                      initialUnit: _roadMeasurementUnitNotifier.value,
                      initialDisplayArea: _roadDisplayAreaNotifier.value,
                      initialKattaValue: _roadKattaValueNotifier.value,
                      initialDhurValue: _roadDhurValueNotifier.value,
                      initialAreaSqFt: _roadAreaSqFtNotifier.value,
                      initialLengthFt: _roadLengthFtNotifier.value,
                      initialLengthIn: _roadLengthInNotifier.value,
                      initialBreadthFt: _roadBreadthFtNotifier.value,
                      initialBreadthIn: _roadBreadthInNotifier.value,
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
                        _roadMeasurementUnitNotifier.value = measurementUnit;
                        _roadAreaSqFtNotifier.value = areaSqFt;
                        _roadDisplayAreaNotifier.value = displayArea;
                        _roadKattaValueNotifier.value = kattaValue;
                        _roadDhurValueNotifier.value = dhurValue;
                        _roadLengthFtNotifier.value = lengthFt;
                        _roadLengthInNotifier.value = lengthIn;
                        _roadBreadthFtNotifier.value = breadthFt;
                        _roadBreadthInNotifier.value = breadthIn;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Road Summary Box
                    ValueListenableBuilder<double>(
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
                              Text('Road Corridor Summary', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Road Corridor Area:', style: AppTypography.secondary.copyWith(color: AppColors.warningText)),
                                  Text(
                                    LandUnitConverter.formatAllUnits(roadAreaSqFt),
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.warningText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Roads are non-saleable infrastructure (RESERVED) and do not count as sellable inventory plots.',
                                      style: AppTypography.secondary.copyWith(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isSaving ? null : _submit,
                          icon: const Icon(Icons.add_road, size: 18),
                          label: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Create Road'),
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
