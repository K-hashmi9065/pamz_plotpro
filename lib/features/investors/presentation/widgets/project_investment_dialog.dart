import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/searchable_investor_dropdown.dart';
import '../../../../shared/widgets/searchable_project_dropdown.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../investors_providers.dart';

class ProjectInvestmentDialog extends ConsumerStatefulWidget {
  final String? preselectedProjectId;
  final String? preselectedInvestorId;

  const ProjectInvestmentDialog({
    super.key,
    this.preselectedProjectId,
    this.preselectedInvestorId,
  });

  static Future<void> show(
    BuildContext context, {
    String? preselectedProjectId,
    String? preselectedInvestorId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProjectInvestmentDialog(
        preselectedProjectId: preselectedProjectId,
        preselectedInvestorId: preselectedInvestorId,
      ),
    );
  }

  @override
  ConsumerState<ProjectInvestmentDialog> createState() => _ProjectInvestmentDialogState();
}

class _ProjectInvestmentDialogState extends ConsumerState<ProjectInvestmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _docController = TextEditingController();
  final _manualPercentController = TextEditingController();

  final ValueNotifier<String?> _selectedProjectIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedInvestorIdNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<OwnershipMethod> _methodNotifier = ValueNotifier<OwnershipMethod>(OwnershipMethod.capitalBased);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedProjectIdNotifier.value = widget.preselectedProjectId;
    _selectedInvestorIdNotifier.value = widget.preselectedInvestorId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _docController.dispose();
    _manualPercentController.dispose();
    _selectedProjectIdNotifier.dispose();
    _selectedInvestorIdNotifier.dispose();
    _methodNotifier.dispose();
    _isSavingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a Project *';
      return;
    }
    if (_selectedInvestorIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select an Investor *';
      return;
    }

    final docPath = _docController.text.trim();
    if (docPath.isEmpty) {
      _errorMessageNotifier.value = 'Investor Agreement Document * is required to save investment.';
      return;
    }

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(investorsRepositoryProvider);
      final amount = double.parse(_amountController.text.trim());
      final manualPercent = _methodNotifier.value == OwnershipMethod.manual
          ? double.tryParse(_manualPercentController.text.trim())
          : null;

      await repo.addProjectInvestment(
        projectId: _selectedProjectIdNotifier.value!,
        investorId: _selectedInvestorIdNotifier.value!,
        investedAmount: amount,
        agreementDocPath: docPath,
        method: _methodNotifier.value,
        manualOwnershipPercent: manualPercent,
        userId: 'admin_user',
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Capital investment & Ownership % allocated successfully!')),
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
    final investorsAsync = ref.watch(investorsListStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 540,
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
                      Text('Allocate Project Capital & Ownership', style: AppTypography.cardTitle),
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
                                padding: const EdgeInsets.only(bottom: 16),
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

                          // Select Project *
                          projectsAsync.when(
                            data: (projects) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _selectedProjectIdNotifier,
                                builder: (context, selectedProjectId, _) {
                                  final isValidSelected = projects.any((p) => p.id == selectedProjectId);
                                  final dropdownValue = isValidSelected ? selectedProjectId : null;

                                  return SearchableProjectDropdown(
                                    projects: projects,
                                    selectedProjectId: dropdownValue,
                                    labelText: 'Target Project *',
                                    onChanged: (val) => _selectedProjectIdNotifier.value = val,
                                    validator: (val) => val == null ? 'Project * is required' : null,
                                  );
                                },
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (e, s) => Text('Error loading projects: $e'),
                          ),
                          const SizedBox(height: 14),

                          // Select Investor *
                          investorsAsync.when(
                            data: (investors) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _selectedInvestorIdNotifier,
                                builder: (context, selectedInvestorId, _) {
                                  final isValidSelected = investors.any((inv) => inv.id == selectedInvestorId);
                                  final dropdownValue = isValidSelected ? selectedInvestorId : null;

                                  return SearchableInvestorDropdown(
                                    investors: investors,
                                    selectedInvestorId: dropdownValue,
                                    labelText: 'Select Investor *',
                                    onChanged: (val) => _selectedInvestorIdNotifier.value = val,
                                    validator: (val) => val == null ? 'Investor * is required' : null,
                                  );
                                },
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (e, s) => Text('Error loading investors: $e'),
                          ),
                          const SizedBox(height: 14),

                          // Capital Contribution Amount *
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Capital Contribution Amount (₹) *',
                              hintText: 'e.g. 5000000',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Amount * is required';
                              if (double.tryParse(val.trim()) == null) return 'Enter valid amount';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Agreement Document Reference * (AC-03.3 MANDATORY REQUIREMENT)
                          TextFormField(
                            controller: _docController,
                            decoration: const InputDecoration(
                              labelText: 'Investor Agreement Document File/Ref *',
                              hintText: 'e.g. investor_agreement_kamran_prj001.pdf',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Agreement Document * is required per AC-03.3';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Ownership Method Selector
                          ValueListenableBuilder<OwnershipMethod>(
                            valueListenable: _methodNotifier,
                            builder: (context, method, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<OwnershipMethod>(
                                    initialValue: method,
                                    decoration: const InputDecoration(labelText: 'Ownership Method *'),
                                    items: const [
                                      DropdownMenuItem(
                                        value: OwnershipMethod.capitalBased,
                                        child: Text('CAPITAL_BASED (Auto-calculated formula)'),
                                      ),
                                      DropdownMenuItem(
                                        value: OwnershipMethod.manual,
                                        child: Text('MANUAL (Admin Override / Sweat Equity)'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) _methodNotifier.value = val;
                                    },
                                  ),
                                  if (method == OwnershipMethod.manual) ...[
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      controller: _manualPercentController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Manual Ownership % Override',
                                        hintText: 'e.g. 25.5',
                                      ),
                                    ),
                                  ],
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
                            : const Text('Allocate Investment'),
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
