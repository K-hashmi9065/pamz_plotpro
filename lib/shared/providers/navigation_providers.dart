import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

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

/// Provider for active logged-in user role (Admin vs Member).
class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier() : super(UserRole.admin); // default Admin

  void setRole(UserRole role) => state = role;
  void toggleRole() => state = state.isAdmin ? UserRole.member : UserRole.admin;
}

final currentRoleProvider =
    StateNotifierProvider<UserRoleNotifier, UserRole>((ref) {
  return UserRoleNotifier();
});

/// Selected project filter (null means All Projects)
final selectedProjectFilterProvider = StateProvider<String?>((ref) => null);

/// Active hovered nav tile path
final hoveredNavTileProvider = StateProvider<String?>((ref) => null);

