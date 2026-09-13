import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../landowners_providers.dart';
import '../../../../shared/widgets/searchable_landowner_dropdown.dart';
import '../../../../shared/widgets/searchable_project_dropdown.dart';
import 'agreement_pdf_dialog.dart';

class PurchaseAgreementDialog extends ConsumerStatefulWidget {
  final String? initialProjectId;
  final String? initialLandownerId;

  const PurchaseAgreementDialog({
    super.key,
    this.initialProjectId,
    this.initialLandownerId,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialProjectId,
    String? initialLandownerId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PurchaseAgreementDialog(
        initialProjectId: initialProjectId,
        initialLandownerId: initialLandownerId,
      ),
    );
  }

  @override
  ConsumerState<PurchaseAgreementDialog> createState() => _PurchaseAgreementDialogState();
}

class _PurchaseAgreementDialogState extends ConsumerState<PurchaseAgreementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _installmentsController = TextEditingController();

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedLandownerIdNotifier = ValueNotifier<String?>(null);
  final DateTime _agreementDate = DateTime.now();
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedProjectIdNotifier.value = widget.initialProjectId;
    _selectedLandownerIdNotifier.value = widget.initialLandownerId;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _installmentsController.dispose();
    _selectedProjectIdNotifier.dispose();
    _selectedLandownerIdNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  void _onProjectSelected(String? projectId, List<dynamic> projects) {
    _selectedProjectIdNotifier.value = projectId;
    if (projectId == null) return;

    final project = projects.where((p) => p.id == projectId).firstOrNull;
    if (project != null) {
      if (project.purchasePrice != null && project.purchasePrice > 0) {
        final price = project.purchasePrice as double;
        _priceController.text = price == price.roundToDouble()
            ? price.toInt().toString()
            : price.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      }
      if (project.landownerId != null && (project.landownerId as String).isNotEmpty) {
        _selectedLandownerIdNotifier.value = project.landownerId as String;
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a Project *';
      return;
    }
    if (_selectedLandownerIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a Landowner *';
      return;
    }

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(landownersRepositoryProvider);
      final price = double.parse(_priceController.text.trim());
      final rawCount = _installmentsController.text.trim();
      final count = rawCount.isEmpty ? 1 : (int.tryParse(rawCount) ?? 1);

      final projects = ref.read(projectsListStreamProvider).value ?? [];
      final landowners = ref.read(landownersListStreamProvider).value ?? [];

      final project = projects.firstWhere((p) => p.id == _selectedProjectIdNotifier.value);
      final landowner = landowners.firstWhere((l) => l.id == _selectedLandownerIdNotifier.value);

      await repo.createPurchaseAgreement(
        projectId: _selectedProjectIdNotifier.value!,
        landownerId: _selectedLandownerIdNotifier.value!,
        totalPrice: price,
        agreementDate: _agreementDate,
        installmentCount: count,
        userId: 'admin_user',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase Agreement created! Opening PDF...')),
        );

        AgreementPdfDialog.show(
          context,
          landownerName: landowner.name,
          landownerPhone: landowner.phone,
          landownerPan: landowner.pan,
          landownerEmail: landowner.email,
          landownerAddress: landowner.address,
          projectName: project.name,
          projectCode: project.code,
          projectLocation: project.location,
          landAreaSqFt: project.landAreaSqFt,
          totalPrice: price,
          installmentCount: count,
          agreementDate: _agreementDate,
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
    final landownersAsync = ref.watch(landownersListStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 540,
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
                      Text('New Purchase Agreement', style: AppTypography.cardTitle),
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
                        child: Text(
                          errorMessage,
                          style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                        ),
                      );
                    },
                  ),

                  // Select Project *
                  projectsAsync.when(
                    data: (projects) => ValueListenableBuilder<String?>(
                      valueListenable: _selectedProjectIdNotifier,
                      builder: (context, selectedProjectId, _) {
                        return SearchableProjectDropdown(
                          projects: projects,
                          selectedProjectId: selectedProjectId,
                          labelText: 'Target Project *',
                          onChanged: (val) => _onProjectSelected(val, projects),
                          validator: (val) => val == null ? 'Project * is required' : null,
                        );
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, s) => Text('Error loading projects: $e'),
                  ),
                  const SizedBox(height: 14),

                  // Select Landowner *
                  landownersAsync.when(
                    data: (landowners) => ValueListenableBuilder<String?>(
                      valueListenable: _selectedLandownerIdNotifier,
                      builder: (context, selectedLandownerId, _) {
                        return SearchableLandownerDropdown(
                          landowners: landowners,
                          selectedLandownerId: selectedLandownerId,
                          labelText: 'Select Landowner *',
                          onChanged: (val) => _selectedLandownerIdNotifier.value = val,
                          validator: (val) => val == null ? 'Landowner * is required' : null,
                        );
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, s) => Text('Error loading landowners: $e'),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Total Agreement Price *',
                            hintText: 'e.g. 20000000',
                            prefixText: '₹ ',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Total Price * is required';
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed <= 0) return 'Enter valid amount (> 0)';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _installmentsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Installments Count (Optional)',
                            hintText: 'e.g. 5 (Default 1)',
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final count = int.tryParse(val.trim());
                              if (count == null || count <= 0) return 'Enter valid count (>= 1)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
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
                            : const Text('Create Agreement'),
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
