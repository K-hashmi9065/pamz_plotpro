import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/land_measurement_input_widget.dart';
import '../../../../shared/widgets/searchable_landowner_dropdown.dart';
import '../../domain/project_model.dart';
import '../projects_providers.dart';

import '../../../landowners/presentation/landowners_providers.dart';
import '../../../landowners/presentation/widgets/landowner_form_dialog.dart';

class ProjectFormDialog extends ConsumerStatefulWidget {
  final ProjectModel? projectToEdit;

  const ProjectFormDialog({
    super.key,
    this.projectToEdit,
  });

  static Future<ProjectModel?> show(BuildContext context, {ProjectModel? projectToEdit}) {
    return showDialog<ProjectModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProjectFormDialog(projectToEdit: projectToEdit),
    );
  }

  @override
  ConsumerState<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  late ValueNotifier<String?> _selectedLandownerIdNotifier;
  late ValueNotifier<ProjectStatus> _selectedStatusNotifier;
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  String _measurementUnit = LandMeasurementInputWidget.dimensionsUnit;
  double? _displayArea;
  double? _kattaValue;
  double? _dhurValue;
  double? _lengthFt;
  double? _lengthIn;
  double? _breadthFt;
  double? _breadthIn;
  double _areaSqFt = 0.0;

  @override
  void initState() {
    super.initState();
    final p = widget.projectToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _locationController = TextEditingController(text: p?.location ?? '');
    _priceController = TextEditingController(text: p?.purchasePrice.toString() ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');

    _selectedLandownerIdNotifier = ValueNotifier<String?>(p?.landownerId);
    _selectedStatusNotifier = ValueNotifier<ProjectStatus>(p?.status ?? ProjectStatus.draft);

    if (p != null) {
      _measurementUnit = p.measurementUnit;
      _displayArea = p.displayArea;
      _kattaValue = p.kattaValue;
      _dhurValue = p.dhurValue;
      _lengthFt = p.lengthFt;
      _lengthIn = p.lengthIn ?? (p.lengthFt != null ? 0.0 : null);
      _breadthFt = p.breadthFt;
      _breadthIn = p.breadthIn ?? (p.breadthFt != null ? 0.0 : null);
      _areaSqFt = p.landAreaSqFt;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _selectedLandownerIdNotifier.dispose();
    _selectedStatusNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _createNewLandowner() async {
    final newLandowner = await LandownerFormDialog.show(context);
    if (newLandowner != null && mounted) {
      _selectedLandownerIdNotifier.value = newLandowner.id;
    }
  }

  Future<void> _submit() async {
    _errorMessageNotifier.value = null;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (_areaSqFt <= 0) {
      _errorMessageNotifier.value = 'Project Land Area * must be greater than zero.';
      return;
    }

    _isSavingNotifier.value = true;

    try {
      final repo = ref.read(projectsRepositoryProvider);
      if (widget.projectToEdit == null) {
        final newProject = await repo.createProject(
          name: name,
          location: location,
          landownerId: _selectedLandownerIdNotifier.value,
          landAreaSqFt: _areaSqFt,
          measurementUnit: _measurementUnit,
          displayArea: _displayArea,
          kattaValue: _kattaValue,
          dhurValue: _dhurValue,
          lengthFt: _lengthFt,
          lengthIn: _lengthIn,
          breadthFt: _breadthFt,
          breadthIn: _breadthIn,
          purchasePrice: price,
          description: _descriptionController.text.trim(),
          status: _selectedStatusNotifier.value,
          userId: 'admin_user',
        );

        if (mounted) {
          Navigator.of(context).pop(newProject);
        }
      } else {
        final updatedProject = widget.projectToEdit!.copyWith(
          name: name,
          location: location,
          landownerId: _selectedLandownerIdNotifier.value,
          landAreaSqFt: _areaSqFt,
          measurementUnit: _measurementUnit,
          displayArea: _displayArea,
          kattaValue: _kattaValue,
          dhurValue: _dhurValue,
          lengthFt: _lengthFt,
          lengthIn: _lengthIn,
          breadthFt: _breadthFt,
          breadthIn: _breadthIn,
          purchasePrice: price,
          description: _descriptionController.text.trim(),
          status: _selectedStatusNotifier.value,
        );
        await repo.updateProject(updatedProject, userId: 'admin_user');

        if (mounted) {
          Navigator.of(context).pop(updatedProject);
        }
      }
    } catch (e) {
      if (mounted) {
        _errorMessageNotifier.value = e.toString().replaceAll('Exception: ', '');
        _isSavingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.projectToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Land Project' : 'Create New Land Project',
                    style: AppTypography.pageTitle.copyWith(fontSize: 20),
                  ),
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
              const SizedBox(height: 16),

              // Error Message Banner
              ValueListenableBuilder<String?>(
                valueListenable: _errorMessageNotifier,
                builder: (context, errorMessage, _) {
                  if (errorMessage == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.dangerText.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.dangerText, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Form Scrollable Area
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Name Input
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Project Name *',
                          hintText: 'e.g. PAMZ Green Valley Enclave',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Project Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Location Input
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location / Survey Site *',
                          hintText: 'e.g. Plot 42, Sitamarhi Highway, Ward 12',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Landowner Selection & Create New Button
                      Consumer(
                        builder: (context, ref, child) {
                          final landownersAsync = ref.watch(landownersListStreamProvider);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: landownersAsync.when(
                                  loading: () => const LinearProgressIndicator(),
                                  error: (err, stack) => Text(
                                    'Error loading landowners',
                                    style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                                  ),
                                  data: (landowners) {
                                    return ValueListenableBuilder<String?>(
                                      valueListenable: _selectedLandownerIdNotifier,
                                      builder: (context, selectedLandownerId, _) {
                                        final isValidSelected = landowners.any((l) => l.id == selectedLandownerId);
                                        final dropdownValue = isValidSelected ? selectedLandownerId : null;

                                        return SearchableLandownerDropdown(
                                          landowners: landowners,
                                          selectedLandownerId: dropdownValue,
                                          labelText: 'Landowner',
                                          hintText: '-- Select Landowner --',
                                          onChanged: (val) {
                                            _selectedLandownerIdNotifier.value = val;
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _createNewLandowner,
                                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                label: const Text('Create New Landowner'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Total Project Land Area Input Widget
                      LandMeasurementInputWidget(
                        labelPrefix: 'Project Total Land',
                        initialUnit: _measurementUnit,
                        initialDisplayArea: _displayArea,
                        initialKattaValue: _kattaValue,
                        initialDhurValue: _dhurValue,
                        initialAreaSqFt: _areaSqFt,
                        initialLengthFt: _lengthFt,
                        initialLengthIn: _lengthIn,
                        initialBreadthFt: _breadthFt,
                        initialBreadthIn: _breadthIn,
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
                          _measurementUnit = measurementUnit;
                          _areaSqFt = areaSqFt;
                          _displayArea = displayArea;
                          _kattaValue = kattaValue;
                          _dhurValue = dhurValue;
                          _lengthFt = lengthFt;
                          _lengthIn = lengthIn;
                          _breadthFt = breadthFt;
                          _breadthIn = breadthIn;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Purchase Price & Status Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Land Purchase Price (Optional)',
                                hintText: 'e.g. 20000000',
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ValueListenableBuilder<ProjectStatus>(
                              valueListenable: _selectedStatusNotifier,
                              builder: (context, selectedStatus, _) {
                                return DropdownButtonFormField<ProjectStatus>(
                                  initialValue: selectedStatus,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Status *',
                                  ),
                                  items: ProjectStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status.name.toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.body.copyWith(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _selectedStatusNotifier.value = val;
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description (Optional)
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Brief notes on acquisition terms, location access...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
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
                            : Text(isEditing ? 'Save Changes' : 'Create Project'),
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
