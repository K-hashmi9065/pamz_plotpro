import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/auth_provider.dart';

/// Provider for sidebar collapse/expand state.
class SidebarNotifier extends StateNotifier<bool> {
  SidebarNotifier() : super(true); // default expanded

  void toggle() => state = !state;
  void setExpanded(bool value) => state = value;
}

final sidebarExpandedProvider =
    StateNotifierProvider<SidebarNotifier, bool>((ref) {
  return SidebarNotifier();
});

/// Selected project filter (null means All Projects)
final selectedProjectFilterProvider = StateProvider<String?>((ref) => null);

/// Active hovered nav tile path
final hoveredNavTileProvider = StateProvider<String?>((ref) => null);

/// The current user's role, derived from the real auth session.
/// All existing widgets that watch this will now get the real role.
final currentRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(currentUserProvider)?.role ?? UserRole.admin;
});
