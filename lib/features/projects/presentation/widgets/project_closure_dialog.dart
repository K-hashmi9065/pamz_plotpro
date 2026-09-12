import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/navigation_providers.dart';
import '../../domain/project_model.dart';
import '../projects_providers.dart';

class ProjectClosureDialog extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ProjectClosureDialog({
    super.key,
    required this.project,
  });

  static Future<void> show(BuildContext context, {required ProjectModel project}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProjectClosureDialog(project: project),
    );
  }

  @override
  ConsumerState<ProjectClosureDialog> createState() => _ProjectClosureDialogState();
}

class _ProjectClosureDialogState extends ConsumerState<ProjectClosureDialog> {
  late final ValueNotifier<Map<String, bool>> _checklistNotifier;
  final ValueNotifier<bool> _isClosingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _checklistNotifier = ValueNotifier<Map<String, bool>>({
      'Land purchase agreement & title recorded': true,
      'All project expenses reviewed & capitalized': true,
      'All plot sales reviewed & executed': false,
      'Installments & customer payments reconciled': false,
      'Investor capital contributions & ownership % finalized': true,
      'Final Net Project Profit / Loss calculated': false,
      'Outstanding payables & receivables reviewed': false,
      'Required legal documents archived': true,
      'Investor profit distributions approved by Admin': false,
    });
  }

  @override
  void dispose() {
    _checklistNotifier.dispose();
    _isClosingNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  bool _isAllChecked(Map<String, bool> map) => map.values.every((v) => v == true);

  Future<void> _closeProject() async {
    final currentRole = ref.read(currentRoleProvider);
    if (!currentRole.isAdmin) {
      _errorMessageNotifier.value = 'Security Violation: Only Admin can close projects.';
      return;
    }

    if (!_isAllChecked(_checklistNotifier.value)) {
      _errorMessageNotifier.value = 'All checklist items must be verified prior to project closure.';
      return;
    }

    _isClosingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(projectsRepositoryProvider);
      final closedProject = widget.project.copyWith(status: ProjectStatus.closed);
      await repo.updateProject(closedProject, userId: 'admin_user');

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Project ${widget.project.name} (${widget.project.code}) closed successfully! Financial records locked.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _errorMessageNotifier.value = e.toString().replaceAll('StateError: ', '');
        _isClosingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = ref.watch(currentRoleProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.dangerText, size: 24),
                      const SizedBox(width: 8),
                      Text('Final Project Closure Checklist', style: AppTypography.cardTitle),
                    ],
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isClosingNotifier,
                    builder: (context, isClosing, _) {
                      return IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: isClosing ? null : () => Navigator.of(context).pop(),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warningText.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warningText, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Closing project "${widget.project.name}" will lock all financial records, expenses, and sales from further editing.',
                        style: AppTypography.secondary.copyWith(color: AppColors.warningText, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ValueListenableBuilder<String?>(
                valueListenable: _errorMessageNotifier,
                builder: (context, errorMessage, _) {
                  if (errorMessage == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
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

              Text(
                'Pre-Closure Operational Requirements (* Required)',
                style: AppTypography.secondary.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              ValueListenableBuilder<Map<String, bool>>(
                valueListenable: _checklistNotifier,
                builder: (context, checklist, _) {
                  return Column(
                    children: checklist.keys.map((item) {
                      final isChecked = checklist[item]!;
                      return CheckboxListTile(
                        dense: true,
                        value: isChecked,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.accent,
                        title: Text(item, style: AppTypography.body.copyWith(fontSize: 13)),
                        onChanged: (val) {
                          final updated = Map<String, bool>.from(checklist);
                          updated[item] = val ?? false;
                          _checklistNotifier.value = updated;
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              ValueListenableBuilder<Map<String, bool>>(
                valueListenable: _checklistNotifier,
                builder: (context, checklist, _) {
                  final allChecked = _isAllChecked(checklist);

                  return ValueListenableBuilder<bool>(
                    valueListenable: _isClosingNotifier,
                    builder: (context, isClosing, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.dangerText,
                              side: const BorderSide(color: AppColors.dangerBorder),
                            ),
                            onPressed: isClosing ? null : () => Navigator.of(context).pop(),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: allChecked && currentRole.isAdmin ? AppColors.dangerText : Colors.grey,
                            ),
                            onPressed: (isClosing || !allChecked || !currentRole.isAdmin) ? null : _closeProject,
                            icon: isClosing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Confirm & Close Project'),
                          ),
                        ],
                      );
                    },
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
