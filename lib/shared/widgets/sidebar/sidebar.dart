import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/nav_item.dart';
import '../../../core/navigation/nav_items_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/navigation_providers.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final currentRole = ref.watch(currentRoleProvider);
    final currentRoute = GoRouterState.of(context).uri.path;
    final navItems = NavItemsData.getNavItemsForRole(currentRole);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 240 : 72,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header / Logo Row
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.sidebarBorder),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showDetails = isExpanded && constraints.maxWidth > 100;
                return Row(
                  children: [
                    const Icon(
                      Icons.landscape_rounded,
                      color: AppColors.accent,
                      size: 28,
                    ),
                    if (showDetails) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppConstants.appName,
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = currentRoute == item.routePath ||
                    (item.routePath == '/dashboard' && currentRoute == '/') ||
                    (item.routePath != '/dashboard' &&
                        item.routePath != '/' &&
                        currentRoute.startsWith(item.routePath));

                return _NavTile(
                  item: item,
                  isExpanded: isExpanded,
                  isSelected: isSelected,
                );
              },
            ),
          ),
          // Collapse / Expand Toggle Button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.sidebarBorder),
              ),
            ),
            child: InkWell(
              onTap: () => ref.read(sidebarExpandedProvider.notifier).toggle(),
              borderRadius: BorderRadius.circular(8),
              hoverColor: AppColors.sidebarHover,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showDetails = isExpanded && constraints.maxWidth > 100;
                    return Row(
                      mainAxisAlignment: showDetails
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_open_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        if (showDetails) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Collapse Sidebar',
                              style: AppTypography.secondary.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends ConsumerWidget {
  final NavItem item;
  final bool isExpanded;
  final bool isSelected;

  const _NavTile({
    required this.item,
    required this.isExpanded,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoveredPath = ref.watch(hoveredNavTileProvider);
    final isHovered = hoveredPath == item.routePath;

    // Colors & Hover styling
    final textColor = isSelected
        ? AppColors.sidebarActiveText
        : (isHovered ? AppColors.textPrimary : AppColors.sidebarText);

    final iconColor = isSelected
        ? AppColors.sidebarActiveText
        : (isHovered ? AppColors.accent : AppColors.textSecondary);

    final tileBackground = isSelected
        ? (isHovered
            ? AppColors.sidebarActive.withValues(alpha: 0.85)
            : AppColors.sidebarActive)
        : (isHovered ? AppColors.sidebarHover : Colors.transparent);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => ref.read(hoveredNavTileProvider.notifier).state = item.routePath,
        onExit: (_) => ref.read(hoveredNavTileProvider.notifier).state = null,
        child: InkWell(
          onTap: () => context.go(item.routePath),
          borderRadius: BorderRadius.circular(8),
          focusColor: AppColors.accent.withValues(alpha: 0.15),
          hoverColor: Colors.transparent, // Handled by state
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: tileBackground,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1)
                  : (isHovered
                      ? Border.all(color: AppColors.accent.withValues(alpha: 0.15), width: 1)
                      : null),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showDetails = isExpanded && constraints.maxWidth > 100;
                return Tooltip(
                  message: showDetails ? '' : item.title,
                  child: Row(
                    mainAxisAlignment: showDetails
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      // Subtle vertical active indicator line
                      if (isSelected && showDetails) ...[
                        Container(
                          width: 3.5,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      Icon(
                        item.icon,
                        size: 20,
                        color: iconColor,
                      ),
                      if (showDetails) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTypography.body.copyWith(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: (isSelected || isHovered)
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

