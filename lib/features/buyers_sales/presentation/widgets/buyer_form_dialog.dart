import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../../projects/presentation/widgets/project_form_dialog.dart';
import '../../domain/buyer_model.dart';
import '../sales_providers.dart';

class BuyerFormDialog extends ConsumerStatefulWidget {
  final BuyerModel? buyer;
  const BuyerFormDialog({super.key, this.buyer});

  static Future<void> show(BuildContext context, {BuyerModel? buyer}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BuyerFormDialog(buyer: buyer),
    );
  }

  @override
  ConsumerState<BuyerFormDialog> createState() => _BuyerFormDialogState();
}

class _BuyerFormDialogState extends ConsumerState<BuyerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _panController;
  late final TextEditingController _aadharController;

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    final b = widget.buyer;
    _nameController = TextEditingController(text: b?.name ?? '');
    _phoneController = TextEditingController(text: b != null ? b.phone : '+91 ');
    _emailController = TextEditingController(text: b?.email ?? '');
    _panController = TextEditingController(text: b?.pan ?? '');
    _aadharController = TextEditingController(text: b?.aadhar ?? '');
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
    _panController.dispose();
    _aadharController.dispose();
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
      final repo = ref.read(salesRepositoryProvider);
      if (widget.buyer != null) {
        await repo.updateBuyer(
          id: widget.buyer!.id,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          pan: _panController.text,
          aadhar: _aadharController.text,
          userId: 'active_user',
        );
      } else {
        await repo.createBuyer(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          pan: _panController.text,
          aadhar: _aadharController.text,
          userId: 'active_user',
        );
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(widget.buyer != null
                ? 'Buyer profile updated successfully!'
                : 'Buyer registered successfully!'),
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
                      Text(widget.buyer != null ? 'Edit Buyer Profile' : 'Register Buyer Profile', style: AppTypography.cardTitle),
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

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Buyer Full Name *',
                      hintText: 'e.g. Vikram Sharma',
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Buyer Name * is required'
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
                            hintText: 'e.g. +91 9876500000',
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Address (Optional)',
                            hintText: 'e.g. vikram@example.com',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _panController,
                          decoration: const InputDecoration(
                            labelText: 'PAN Card No. (Optional)',
                            hintText: 'e.g. ABCDE1234F',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _aadharController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Aadhar No. (Optional)',
                            hintText: 'e.g. 1234 5678 9012',
                          ),
                        ),
                      ),
                    ],
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
                                        child: Text('None / All Projects'),
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
                            label: const Text(' New Project', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      );
                    },
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
                            : Text(widget.buyer != null ? 'Save Changes' : 'Register Buyer'),
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
