import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'breadcrumb/breadcrumb.dart';
import 'global_search_dialog.dart';
import 'sidebar/sidebar.dart';
import 'top_bar/top_bar.dart';

/// Persistent application layout shell containing Sidebar, TopBar, Breadcrumb, and Content area.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () => GlobalSearchDialog.show(context),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () => GlobalSearchDialog.show(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Persistent Sidebar Navigation
          const Sidebar(),
          // Main Body Column
          Expanded(
            child: Column(
              children: [
                // Persistent Top Bar Header
                const TopBar(),
                // Dynamic Breadcrumb Bar
                const Breadcrumb(),
                // Main Route Content Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.015, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(GoRouterState.of(context).uri.path),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
