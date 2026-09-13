import '../../../core/constants/app_constants.dart';
import 'member_type.dart';

/// Immutable domain entity representing an authenticated user.
class UserEntity {
  final String id;

  /// Display name of the user.
  final String name;

  /// Mobile number used as login credential.
  final String mobileNo;

  /// Legacy username field (kept for backwards compatibility; equals mobileNo for new users).
  final String username;

  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  /// Sub-type for Member role. Null for Admin.
  final MemberType? memberType;

  /// Links member to their corresponding entity row (Buyers/Investors/Landowners).
  final String? linkedEntityId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.memberType,
    this.linkedEntityId,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;

  bool get isBuyer => memberType == MemberType.customerBuyer;
  bool get isInvestor => memberType == MemberType.investor;
  bool get isLandowner => memberType == MemberType.landowner;

  UserEntity copyWith({
    String? id,
    String? name,
    String? mobileNo,
    String? username,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    MemberType? memberType,
    String? linkedEntityId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      memberType: memberType ?? this.memberType,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
