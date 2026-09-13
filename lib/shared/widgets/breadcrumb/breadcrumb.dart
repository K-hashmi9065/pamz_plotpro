import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/presentation/auth_provider.dart';

class Breadcrumb extends ConsumerWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentUser = ref.watch(currentUserProvider);
    final isMember = currentUser?.isMember ?? false;

    // For member dashboard routes, don't show the admin breadcrumb navigation
    if (isMember || location.startsWith('/my')) {
      return const SizedBox.shrink();
    }

    final segments = location
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: AppColors.background,
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () => context.go('/dashboard'),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Home',
                      style: AppTypography.secondary.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...segments.map((segment) {
            final formatted = segment
                .replaceAll('-', ' ')
                .replaceAll('_', ' ');
            final capitalized = formatted.isEmpty
                ? ''
                : '${formatted[0].toUpperCase()}${formatted.substring(1)}';
            final isLast = segment == segments.last;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppColors.textDisabled,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    capitalized,
                    style: AppTypography.secondary.copyWith(
                      color: isLast
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight: isLast
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
