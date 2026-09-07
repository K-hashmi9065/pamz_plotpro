import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
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

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Project Filter Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  projectsAsync.when(
                    data: (projects) {
                      final projectIds = projects.map((p) => p.id).toSet();
                      final validSelectedProject = projectIds.contains(selectedProject) ? selectedProject : null;

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: validSelectedProject,
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
            const SizedBox(width: 16),
            // Quick Search Box
            InkWell(
              onTap: () => GlobalSearchDialog.show(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 220,
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
                      Icons.search_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search land, plot...',
                        style: AppTypography.input.copyWith(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Ctrl K',
                        style: AppTypography.secondary.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // User Role Switcher Badge (Admin vs Member toggle)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: currentRole.isAdmin
                    ? AppColors.adminRoleBg
                    : AppColors.memberRoleBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (currentRole.isAdmin
                          ? AppColors.adminRoleText
                          : AppColors.memberRoleText)
                      .withValues(alpha: 0.2),
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
                    Icon(
                      currentRole.isAdmin
                          ? Icons.admin_panel_settings_outlined
                          : Icons.person_outline,
                      size: 15,
                      color: currentRole.isAdmin
                          ? AppColors.adminRoleText
                          : AppColors.memberRoleText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Role: ${currentRole.displayName}',
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
            const SizedBox(width: 20),
            // User Avatar & Name
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    currentRole.isAdmin ? 'A' : 'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currentRole.isAdmin ? 'Admin User' : 'Member User',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

