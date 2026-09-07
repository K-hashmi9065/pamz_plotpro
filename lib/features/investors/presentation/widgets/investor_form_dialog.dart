import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/searchable_project_dropdown.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../../projects/presentation/widgets/project_form_dialog.dart';
import '../../domain/investor_model.dart';
import '../investors_providers.dart';

class InvestorFormDialog extends ConsumerStatefulWidget {
  final InvestorModel? investor;
  const InvestorFormDialog({super.key, this.investor});

  static Future<InvestorModel?> show(BuildContext context, {InvestorModel? investor}) {
    return showDialog<InvestorModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InvestorFormDialog(investor: investor),
    );
  }

  @override
  ConsumerState<InvestorFormDialog> createState() => _InvestorFormDialogState();
}

class _InvestorFormDialogState extends ConsumerState<InvestorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _panController;

  final _amountController = TextEditingController();
  final _docController = TextEditingController();

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    final inv = widget.investor;
    _nameController = TextEditingController(text: inv?.name ?? '');
    _phoneController = TextEditingController(text: inv != null ? inv.phone : '+91 ');
    _emailController = TextEditingController(text: inv?.email ?? '');
    _panController = TextEditingController(text: inv?.pan ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _panController.dispose();
    _amountController.dispose();
    _docController.dispose();
    _selectedProjectIdNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _createNewProject() async {
    final newProject = await ProjectFormDialog.show(context);
    if (newProject != null && mounted) {
      _selectedProjectIdNotifier.value = newProject.id;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(investorsRepositoryProvider);
      final InvestorModel resultInvestor;

      if (widget.investor != null) {
        resultInvestor = await repo.updateInvestor(
          id: widget.investor!.id,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          pan: _panController.text,
          userId: 'admin_user',
        );
      } else {
        resultInvestor = await repo.createInvestor(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          pan: _panController.text,
          userId: 'admin_user',
        );
      }

      if (_selectedProjectIdNotifier.value != null && widget.investor == null) {
        final amountText = _amountController.text.trim();
        final amount = double.tryParse(amountText) ?? 0.0;
        final docText = _docController.text.trim();
        final docPath = docText.isNotEmpty
            ? docText
            : 'Initial Investor Registration (${resultInvestor.name})';

        await repo.addProjectInvestment(
          projectId: _selectedProjectIdNotifier.value!,
          investorId: resultInvestor.id,
          investedAmount: amount,
          agreementDocPath: docPath,
          method: OwnershipMethod.capitalBased,
          userId: 'admin_user',
        );
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop(resultInvestor);
        messenger.showSnackBar(
          SnackBar(
            content: Text(widget.investor != null
                ? 'Investor updated successfully!'
                : _selectedProjectIdNotifier.value != null
                    ? 'Investor registered & attached to project successfully!'
                    : 'Investor registered successfully!'),
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
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.investor != null ? 'Edit Investor Profile' : 'Register New Investor', style: AppTypography.cardTitle),
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
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.dangerBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.dangerText, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: AppTypography.secondary.copyWith(
                                      color: AppColors.dangerText,
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

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Investor Full Name *',
                        hintText: 'e.g. Kamran Hashmi',
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Investor Name * is required'
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
                        hintText: 'e.g. kamran@example.com',
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Project Attachment (Optional)',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can attach this investor to a project now or add it next time later.',
                      style: AppTypography.secondary.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    // Project Dropdown & Create New Project Button
                    projectsAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (err, stack) => Text(
                        'Error loading projects',
                        style: AppTypography.secondary.copyWith(color: AppColors.dangerText),
                      ),
                      data: (projects) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: _selectedProjectIdNotifier,
                          builder: (context, selectedProjectId, _) {
                            final isValidSelected = projects.any((p) => p.id == selectedProjectId);
                            final dropdownValue = isValidSelected ? selectedProjectId : null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: SearchableProjectDropdown(
                                       projects: projects,
                                       selectedProjectId: dropdownValue,
                                       labelText: 'Attach to Project (Optional)',
                                       hintText: '-- Select Project (Optional) --',
                                       onChanged: (val) {
                                         _selectedProjectIdNotifier.value = val;
                                       },
                                     ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: _createNewProject,
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text(' Create New Project'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                if (selectedProjectId != null) ...[
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Initial Capital (₹) (Optional)',
                                            hintText: 'e.g. 500000',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _docController,
                                          decoration: const InputDecoration(
                                            labelText: 'Agreement Doc / Ref (Optional)',
                                            hintText: 'e.g. investor_agreement.pdf',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
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
                              : Text(widget.investor != null ? 'Save Changes' : 'Register Investor'),
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
