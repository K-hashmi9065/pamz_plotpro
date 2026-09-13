import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import 'project_detail_screen.dart';
import 'projects_providers.dart';
import 'widgets/project_closure_dialog.dart';
import 'widgets/project_form_dialog.dart';

final projectsSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final projectsStatusFilterProvider = StateProvider.autoDispose<ProjectStatus?>((ref) => null);
final projectsDateRangeFilterProvider = StateProvider.autoDispose<DashboardDateRange>((ref) => DashboardDateRange.allTime);

class ProjectsListScreen extends ConsumerWidget {
  const ProjectsListScreen({super.key});

  Future<void> _handleDeleteProject(BuildContext context, WidgetRef ref, dynamic project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever_outlined, color: AppColors.dangerText, size: 24),
            const SizedBox(width: 8),
            Text('Confirm Delete Project', style: AppTypography.cardTitle),
          ],
        ),
        content: Text(
          'Are you sure you want to delete project "${project.name}" (${project.code})?\n\n'
          'WARNING: This will delete the project and cleanly clean up all mapped plots, expenses, and agreements for this project.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerText),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Project', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(projectsRepositoryProvider);
        await repo.deleteProject(project.id, userId: 'admin_user', cascade: true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Project "${project.name}" deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting project: $e')),
          );
        }
      }
    }
  }

  BadgeType _getBadgeType(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
      case ProjectStatus.purchased:
      case ProjectStatus.closed:
        return BadgeType.success;
      case ProjectStatus.draft:
      case ProjectStatus.negotiation:
      case ProjectStatus.purchasePending:
      case ProjectStatus.funding:
        return BadgeType.warning;
      case ProjectStatus.cancelled:
        return BadgeType.danger;
      default:
        return BadgeType.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(projectsSearchQueryProvider);
    final statusFilter = ref.watch(projectsStatusFilterProvider);
    final dateRangeFilter = ref.watch(projectsDateRangeFilterProvider);

    final currentRole = ref.watch(currentRoleProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Projects Directory',
          subtitle:
              'Manage independent land projects, financial boundaries, and lifecycle statuses.',
          icon: Icons.business_outlined,
          actions: [
            // Admin only "+ New Project" button
            if (currentRole.isAdmin)
              ElevatedButton.icon(
                onPressed: () => ProjectFormDialog.show(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Project'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 300,
                height: 38,
                child: TextField(
                  onChanged: (val) => ref.read(projectsSearchQueryProvider.notifier).state = val,
                  decoration: const InputDecoration(
                    hintText: 'Search by project name, code, location...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: AppTypography.input.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ProjectStatus?>(
                    value: statusFilter,
                    hint: Text('All Statuses', style: AppTypography.secondary),
                    items: [
                      const DropdownMenuItem<ProjectStatus?>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...ProjectStatus.values.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.name.toUpperCase()),
                          )),
                    ],
                    onChanged: (val) => ref.read(projectsStatusFilterProvider.notifier).state = val,
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DashboardDateRange>(
                    value: dateRangeFilter,
                    items: DashboardDateRange.values.map((range) {
                      return DropdownMenuItem<DashboardDateRange>(
                        value: range,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(range.label, style: AppTypography.input.copyWith(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(projectsDateRangeFilterProvider.notifier).state = val;
                      }
                    },
                    style: AppTypography.body.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Projects Data Table
        Expanded(
          child: projectsAsync.when(
            loading: () => const CustomDataTable(
              columns: [],
              rows: [],
              isLoading: true,
            ),
            error: (err, stack) => Center(
              child: Text(
                'Error loading projects: $err',
                style: AppTypography.body.copyWith(color: AppColors.dangerText),
              ),
            ),
            data: (projectsList) {
              final filtered = projectsList.where((p) {
                if (statusFilter != null && p.status != statusFilter) {
                  return false;
                }
                if (!isDateInFilterRange(p.createdAt, dateRangeFilter)) {
                  return false;
                }
                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  return p.name.toLowerCase().contains(q) ||
                      p.code.toLowerCase().contains(q) ||
                      p.location.toLowerCase().contains(q);
                }
                return true;
              }).toList();

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Code', width: 90),
                  DataTableColumn(label: 'Project Name', width: 220),
                  DataTableColumn(label: 'Landowner', width: 140),
                  DataTableColumn(label: 'Location', width: 160),
                  DataTableColumn(label: 'Land Area', width: 130),
                  DataTableColumn(label: 'Purchase Price', width: 140),
                  DataTableColumn(label: 'Actual Cost', width: 140),
                  DataTableColumn(label: 'Status', width: 110),
                  DataTableColumn(label: 'Actions', width: 145, alignment: Alignment.center),
                ],
                rows: filtered.map((project) {
                  return [
                    Text(
                      project.code,
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      project.name,
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      project.landownerName ?? '—',
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: project.landownerName != null ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    Text(
                      project.location,
                      style: AppTypography.tableCell,
                    ),
                    Text(
                      project.formattedArea,
                      style: AppTypography.tableCell,
                    ),
                    Text(
                      CalculationEngine.formatCurrency(project.purchasePrice),
                      style: AppTypography.amountMedium.copyWith(fontSize: 14),
                    ),
                    Text(
                      CalculationEngine.formatCurrency(project.actualCost),
                      style: AppTypography.amountMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.successText,
                      ),
                    ),
                    StatusBadge(
                      label: project.status.name.toUpperCase(),
                      type: _getBadgeType(project.status),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          tooltip: 'View Details',
                          onPressed: () => ProjectDetailScreen.showAsDialog(context, project.id),
                        ),
                        if (currentRole.isAdmin && !project.isClosed) ...[
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit Project',
                            onPressed: () => ProjectFormDialog.show(
                              context,
                              projectToEdit: project,
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.lock_clock, size: 18, color: AppColors.warning),
                            tooltip: 'Close Project (Finalization)',
                            onPressed: () => ProjectClosureDialog.show(
                              context,
                              project: project,
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.dangerText),
                            tooltip: 'Delete Project',
                            onPressed: () => _handleDeleteProject(context, ref, project),
                          ),
                        ],
                      ],
                    ),
                  ];
                }).toList(),
                emptyMessage: 'No projects match the search filter.',
              );
            },
          ),
        ),
      ],
    );
  }
}
