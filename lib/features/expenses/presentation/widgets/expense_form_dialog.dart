import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../../projects/presentation/widgets/project_form_dialog.dart';
import '../../../../shared/widgets/searchable_project_dropdown.dart';
import '../expenses_providers.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  final String? preselectedProjectId;
  final String? preselectedPlotNumber;
  final String? initialNotes;

  const ExpenseFormDialog({
    super.key,
    this.preselectedProjectId,
    this.preselectedPlotNumber,
    this.initialNotes,
  });

  static Future<void> show(
    BuildContext context, {
    String? preselectedProjectId,
    String? preselectedPlotNumber,
    String? initialNotes,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExpenseFormDialog(
        preselectedProjectId: preselectedProjectId,
        preselectedPlotNumber: preselectedPlotNumber,
        initialNotes: initialNotes,
      ),
    );
  }

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _notesController = TextEditingController();

  late final ValueNotifier<String?> _selectedProjectIdNotifier;
  final ValueNotifier<ExpenseCategory> _selectedCategoryNotifier = ValueNotifier<ExpenseCategory>(ExpenseCategory.development);
  final ValueNotifier<bool> _isCapitalizedNotifier = ValueNotifier<bool>(true);
  final DateTime _expenseDate = DateTime.now();
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedProjectIdNotifier = ValueNotifier<String?>(widget.preselectedProjectId);
    if (widget.initialNotes != null && widget.initialNotes!.isNotEmpty) {
      _notesController.text = widget.initialNotes!;
    } else if (widget.preselectedPlotNumber != null && widget.preselectedPlotNumber!.isNotEmpty) {
      _notesController.text = 'Plot ${widget.preselectedPlotNumber} - ';
    }
  }

  Future<void> _createNewProject() async {
    final newProject = await ProjectFormDialog.show(context);
    if (newProject != null && mounted) {
      _selectedProjectIdNotifier.value = newProject.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vendorController.dispose();
    _notesController.dispose();
    _selectedProjectIdNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    _isCapitalizedNotifier.dispose();
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

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(expensesRepositoryProvider);
      final amount = double.parse(_amountController.text.trim());

      await repo.addExpense(
        projectId: _selectedProjectIdNotifier.value!,
        category: _selectedCategoryNotifier.value,
        amount: amount,
        expenseDate: _expenseDate,
        vendor: _vendorController.text,
        isCapitalized: _isCapitalizedNotifier.value,
        notes: _notesController.text,
        userId: 'active_user',
      );

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(_isCapitalizedNotifier.value
                ? 'Expense logged & Actual Project Cost updated!'
                : 'Expense logged as period expense.'),
          ),
        );
      }
    } catch (e) {
      _errorMessageNotifier.value = e.toString().replaceAll('StateError: ', '').replaceAll('ArgumentError: ', '');
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
        width: 520,
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
                      Text('Log Project Expense', style: AppTypography.cardTitle),
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
                          child: Text(
                            errorMessage,
                            style: AppTypography.secondary.copyWith(
                              color: AppColors.dangerText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Target Project *
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: projectsAsync.when(
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
                  ),
                  const SizedBox(height: 14),

                  // Category * & Amount * Row
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<ExpenseCategory>(
                          valueListenable: _selectedCategoryNotifier,
                          builder: (context, selectedCategory, _) {
                            return DropdownButtonFormField<ExpenseCategory>(
                              initialValue: selectedCategory,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Category *'),
                              items: ExpenseCategory.values.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat.name.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  _selectedCategoryNotifier.value = val;
                                  // Default capitalization by category (AC-04.1 vs AC-04.2)
                                  _isCapitalizedNotifier.value = val != ExpenseCategory.marketing &&
                                      val != ExpenseCategory.administration;
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Expense Amount (₹) *',
                            hintText: 'e.g. 800000',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Amount * is required';
                            if (double.tryParse(val.trim()) == null) return 'Enter valid number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Vendor / Payee (Optional)
                  TextFormField(
                    controller: _vendorController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor / Payee Name (Optional)',
                      hintText: 'e.g. ABC Earthmovers Pvt Ltd',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Capitalization Flag Switch (AC-04.1 & AC-04.2)
                  ValueListenableBuilder<bool>(
                    valueListenable: _isCapitalizedNotifier,
                    builder: (context, isCapitalized, _) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Switch(
                              value: isCapitalized,
                              onChanged: (val) => _isCapitalizedNotifier.value = val,
                              activeThumbColor: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCapitalized
                                        ? 'Capitalized Cost (Rolls into Actual Project Cost)'
                                        : 'Period Expense (Tracked as P&L Expense)',
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isCapitalized
                                          ? AppColors.textPrimary
                                          : AppColors.warningText,
                                    ),
                                  ),
                                  Text(
                                    isCapitalized
                                        ? 'Included in plot cost allocation and project asset value.'
                                        : 'Does NOT increase Actual Project Cost (AC-04.2).',
                                    style: AppTypography.secondary.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Notes (Optional)
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Invoice Reference (Optional)',
                      hintText: 'e.g. Inv #8492 for land levelling and fencing',
                    ),
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
                            : const Text('Log Expense'),
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
