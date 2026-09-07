import '../../../core/constants/app_constants.dart';

class UserEntity {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;
}
