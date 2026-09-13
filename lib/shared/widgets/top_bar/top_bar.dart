import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/domain/user_entity.dart';
import '../../../features/auth/presentation/auth_provider.dart';
import '../../../features/projects/presentation/projects_providers.dart';
import '../../providers/navigation_providers.dart';
import '../global_search_dialog.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentRole = currentUser?.role ?? UserRole.admin;
    final selectedProject = ref.watch(selectedProjectFilterProvider);
    final projectsAsync = ref.watch(projectsListStreamProvider);

    final currentPath = GoRouterState.of(context).uri.path;
    final isDashboard =
        currentPath == AppRoutes.dashboard || currentPath == '/';

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
          // Left Group: Project Selector (Dashboard tab only)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDashboard && currentRole.isAdmin)
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
                          final projectIds =
                              projects.map((p) => p.id).toSet();
                          final validSelectedProject =
                              projectIds.contains(selectedProject)
                                  ? selectedProject
                                  : null;

                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: validSelectedProject,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary),
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
                                  child: Text(
                                      'All Projects (Portfolio View)'),
                                ),
                                ...projects.map((p) {
                                  return DropdownMenuItem<String?>(
                                    value: p.id,
                                    child: Text(
                                        '${p.name} (${p.code})'),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                ref
                                    .read(selectedProjectFilterProvider
                                        .notifier)
                                    .state = value;
                              },
                              style: AppTypography.body
                                  .copyWith(fontSize: 13),
                            ),
                          );
                        },
                        loading: () => Text(
                          'Loading Projects...',
                          style: AppTypography.secondary
                              .copyWith(fontSize: 13),
                        ),
                        error: (e, s) => Text(
                          'All Projects',
                          style: AppTypography.secondary
                              .copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Right Group: Search + Role Badge + User Avatar + Logout
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Global Search Command Box
              InkWell(
                onTap: () => GlobalSearchDialog.show(context),
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.surfaceVariant,
                child: Container(
                  width: 220,
                  height: 36,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quick search...',
                          style: AppTypography.input.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: AppColors.border),
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
              const SizedBox(width: 12),

              // Role Badge (read-only, shows actual role + member type)
              _RoleBadge(user: currentUser),
              const SizedBox(width: 12),

              // User Avatar + Popup menu (Reset Password)
              _UserAvatar(
                user: currentUser,
                onResetPassword: () =>
                    context.push(AppRoutes.resetPassword),
              ),
              const SizedBox(width: 8),

              // Logout icon button
              _LogoutButton(),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Role Badge ────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final UserEntity? user;

  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    final isAdmin = user!.role == UserRole.admin;
    final memberTypeStr = user!.memberType != null
        ? user!.memberType!.displayName
        : 'Member';
    final label = isAdmin ? 'Admin' : 'Member · $memberTypeStr';

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:
            isAdmin ? AppColors.adminRoleBg : AppColors.memberRoleBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAdmin
              ? AppColors.adminRoleBorder
              : AppColors.memberRoleBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAdmin
                  ? AppColors.adminRoleText
                  : AppColors.memberRoleText,
            ),
          ),
          const SizedBox(width: 7),
          Icon(
            isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline,
            size: 14,
            color: isAdmin
                ? AppColors.adminRoleText
                : AppColors.memberRoleText,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.secondary.copyWith(
              color: isAdmin
                  ? AppColors.adminRoleText
                  : AppColors.memberRoleText,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Avatar ───────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback onResetPassword;

  const _UserAvatar({required this.user, required this.onResetPassword});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'User';
    final initials = _initials(name);
    final isAdmin = (user?.role == UserRole.admin);

    return PopupMenuButton<String>(
      tooltip: 'Account options',
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
      onSelected: (val) {
        if (val == 'reset_password') onResetPassword();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 13.5)),
              if (user?.mobileNo != null && user!.mobileNo.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 12, color: AppColors.accent),
                    const SizedBox(width: 5),
                    Text(
                      user!.mobileNo,
                      style: AppTypography.secondary.copyWith(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 3),
              Text(
                isAdmin ? 'Administrator' : (user?.memberType?.displayName ?? 'Member'),
                style: AppTypography.secondary.copyWith(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'reset_password',
          child: Row(
            children: [
              Icon(Icons.key_rounded, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Text('Change Password'),
            ],
          ),
        ),
      ],
      child: Container(
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
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Sign Out',
      child: InkWell(
        onTap: () => _confirmLogout(context, ref),
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.dangerBg,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.logout_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.logout_rounded,
                  size: 18, color: AppColors.danger),
            ),
            const SizedBox(width: 12),
            const Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      // Router will auto-redirect to login via authProvider listener
    }
  }
}
