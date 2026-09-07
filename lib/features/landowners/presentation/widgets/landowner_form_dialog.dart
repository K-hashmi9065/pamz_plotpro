import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../../projects/presentation/widgets/project_form_dialog.dart';
import '../../domain/landowner_model.dart';
import '../landowners_providers.dart';

class LandownerFormDialog extends ConsumerStatefulWidget {
  final LandownerModel? landowner;
  const LandownerFormDialog({super.key, this.landowner});

  static Future<LandownerModel?> show(BuildContext context, {LandownerModel? landowner}) {
    return showDialog<LandownerModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LandownerFormDialog(landowner: landowner),
    );
  }

  @override
  ConsumerState<LandownerFormDialog> createState() => _LandownerFormDialogState();
}

class _LandownerFormDialogState extends ConsumerState<LandownerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _panController;

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    final l = widget.landowner;
    _nameController = TextEditingController(text: l?.name ?? '');
    _phoneController = TextEditingController(
        text: l != null ? l.phone : '+91 ');
    _emailController = TextEditingController(text: l?.email ?? '');
    _addressController = TextEditingController(text: l?.address ?? '');
    _panController = TextEditingController(text: l?.pan ?? '');
  }

  Future<void> _createNewProject() async {
    final newProject = await ProjectFormDialog.show(context);
    if (newProject != null && mounted) {
      _selectedProjectIdNotifier.value = newProject.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _panController.dispose();
    _selectedProjectIdNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(landownersRepositoryProvider);
      final LandownerModel result;
      if (widget.landowner != null) {
        result = await repo.updateLandowner(
          id: widget.landowner!.id,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
          pan: _panController.text,
          userId: 'admin_user',
        );
      } else {
        result = await repo.createLandowner(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
          pan: _panController.text,
          userId: 'admin_user',
        );
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop(result);
        messenger.showSnackBar(
          SnackBar(
            content: Text(widget.landowner != null
                ? 'Landowner updated successfully!'
                : 'Landowner registered successfully!'),
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
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                      Text(widget.landowner != null ? 'Edit Landowner Profile' : 'Register Landowner', style: AppTypography.cardTitle),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Landowner Full Name *',
                              hintText: 'e.g. Ramesh Kumar Patel',
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? 'Landowner Name * is required'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number *',
                                    hintText: 'e.g. +91 9876543210',
                                  ),
                                  validator: (val) {
                                    if (val == null) return 'Phone Number * is required';
                                    final digits = val.replaceAll(RegExp(r'\D'), '');
                                    if (digits.isEmpty || digits == '91') {
                                      return 'Phone Number * is required';
                                    }
                                    if (digits.length < 10) {
                                      return 'Enter valid 10-digit Phone Number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextFormField(
                                  controller: _panController,
                                  decoration: const InputDecoration(
                                    labelText: 'PAN Card No. (Optional)',
                                    hintText: 'e.g. ABCDE1234F',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address (Optional)',
                              hintText: 'e.g. ramesh@example.com',
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _addressController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Residential Address (Optional)',
                              hintText: 'e.g. Plot 42, Civil Lines, Nagpur',
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Attach to Project (Optional) with Inline Project Creation
                          Builder(
                            builder: (context) {
                              final projectsAsync = ref.watch(projectsListStreamProvider);
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: projectsAsync.when(
                                      data: (projects) => ValueListenableBuilder<String?>(
                                        valueListenable: _selectedProjectIdNotifier,
                                        builder: (context, selectedProjectId, _) {
                                          return DropdownButtonFormField<String>(
                                            initialValue: selectedProjectId,
                                            isExpanded: true,
                                            decoration: const InputDecoration(
                                              labelText: 'Associated Project (Optional)',
                                              hintText: 'Select associated project...',
                                            ),
                                            items: [
                                              const DropdownMenuItem<String>(
                                                value: null,
                                                child: Text('None / General Landowner'),
                                              ),
                                              ...projects.map((p) => DropdownMenuItem<String>(
                                                    value: p.id,
                                                    child: Text(
                                                      '${p.name} (${p.code})',
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  )),
                                            ],
                                            onChanged: (val) => _selectedProjectIdNotifier.value = val,
                                          );
                                        },
                                      ),
                                      loading: () => const LinearProgressIndicator(),
                                      error: (err, s) => Text('Error loading projects: $err'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                    onPressed: _createNewProject,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('New Project', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                            : Text(widget.landowner != null ? 'Save Changes' : 'Register Landowner'),
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
