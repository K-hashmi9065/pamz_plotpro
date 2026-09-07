import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final segments = location
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: AppColors.background,
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/dashboard'),
            child: Text(
              'Home',
              style: AppTypography.secondary.copyWith(fontSize: 13),
            ),
          ),
          ...segments.map((segment) {
            final formatted = segment
                .replaceAll('-', ' ')
                .replaceAll('_', ' ');
            final capitalized = formatted.isEmpty
                ? ''
                : '${formatted[0].toUpperCase()}${formatted.substring(1)}';

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.textDisabled,
                  ),
                ),
                Text(
                  capitalized,
                  style: AppTypography.secondary.copyWith(
                    color: segment == segments.last
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: segment == segments.last
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
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
