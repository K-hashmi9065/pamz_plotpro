import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/projects/presentation/projects_providers.dart';
import '../../providers/navigation_providers.dart';
import '../global_search_dialog.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentRoleProvider);
    final selectedProject = ref.watch(selectedProjectFilterProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);

    final currentPath = GoRouterState.of(context).uri.path;
    final isDashboard = currentPath == AppRoutes.dashboard || currentPath == '/';

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Group: Project Selector & Quick Stats (Dashboard tab only)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDashboard)
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    projectsAsync.when(
                      data: (projects) {
                        final projectIds = projects.map((p) => p.id).toSet();
                        final validSelectedProject = projectIds.contains(selectedProject) ? selectedProject : null;

                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: validSelectedProject,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                            hint: Text(
                              'All Projects (Portfolio View)',
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Projects (Portfolio View)'),
                              ),
                              ...projects.map((p) {
                                return DropdownMenuItem<String?>(
                                  value: p.id,
                                  child: Text('${p.name} (${p.code})'),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              ref
                                  .read(selectedProjectFilterProvider.notifier)
                                  .state = value;
                            },
                            style: AppTypography.body.copyWith(fontSize: 13),
                          ),
                        );
                      },
                      loading: () => Text(
                        'Loading Projects...',
                        style: AppTypography.secondary.copyWith(fontSize: 13),
                      ),
                      error: (e, s) => Text(
                        'All Projects',
                        style: AppTypography.secondary.copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right Group: Global Search & Role Switcher & User Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Global Search Command Box
              InkWell(
                onTap: () => GlobalSearchDialog.show(context),
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.surfaceVariant,
                child: Container(
                  width: 240,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quick search anything...',
                          style: AppTypography.input.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          'Ctrl K',
                          style: AppTypography.secondary.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // User Role Switcher Badge (Admin vs Member toggle)
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: currentRole.isAdmin
                      ? AppColors.adminRoleBg
                      : AppColors.memberRoleBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentRole.isAdmin
                        ? AppColors.adminRoleBorder
                        : AppColors.memberRoleBorder,
                  ),
                ),
                child: PopupMenuButton<UserRole>(
                  tooltip: 'Switch Active Role (Testing/Session)',
                  constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
                  onSelected: (role) {
                    ref.read(currentRoleProvider.notifier).setRole(role);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: UserRole.admin,
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings_outlined,
                              color: AppColors.adminRoleText, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Admin Role (Full CRUD & Investors)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: UserRole.member,
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              color: AppColors.memberRoleText, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Member Role (Sales/Purchases only)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentRole.isAdmin
                              ? AppColors.adminRoleText
                              : AppColors.memberRoleText,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        currentRole.displayName,
                        style: AppTypography.secondary.copyWith(
                          color: currentRole.isAdmin
                              ? AppColors.adminRoleText
                              : AppColors.memberRoleText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: currentRole.isAdmin
                            ? AppColors.adminRoleText
                            : AppColors.memberRoleText,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // User Avatar & Name Container
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        currentRole.isAdmin ? 'A' : 'M',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentRole.isAdmin ? 'Admin User' : 'Member User',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

