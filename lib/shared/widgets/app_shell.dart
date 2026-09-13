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
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            GlobalSearchDialog.show(context),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            GlobalSearchDialog.show(context),
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
                    // Main Route Content Container with Smooth Animation & RepaintBoundary
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: AppColors.background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: _AnimatedBranchShell(
                          navigationShell: navigationShell,
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

class _AnimatedBranchShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const _AnimatedBranchShell({required this.navigationShell});

  @override
  State<_AnimatedBranchShell> createState() => _AnimatedBranchShellState();
}

class _AnimatedBranchShellState extends State<_AnimatedBranchShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.008),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _AnimatedBranchShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _animController.forward(from: 0.1);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.navigationShell,
        ),
      ),
    );
  }
}
