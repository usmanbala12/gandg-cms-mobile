import 'package:equatable/equatable.dart';

/// User account status enum matching API specification.
enum UserStatus { 
  active, 
  inactive, 
  pending, 
  suspended;

  /// Parse status from string, defaulting to active if unknown.
  static UserStatus fromString(String? value) {
    if (value == null) return UserStatus.active;
    return UserStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserStatus.active,
    );
  }
}

/// User entity representing an authenticated user.
class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  
  /// Role ID (UUID)
  final String? roleId;
  
  /// Role name (e.g., 'admin', 'user')
  final String? roleName;
  
  /// Human-readable role name (e.g., 'Administrator', 'Regular User')
  final String? roleDisplayName;
  
  /// Whether user has admin privileges
  final bool admin;
  
  /// Account status
  final UserStatus status;
  
  /// Whether MFA is enabled for this user
  final bool mfaEnabled;
  
  /// Last login timestamp
  final DateTime? lastLoginAt;
  
  /// Account creation timestamp
  final DateTime? createdAt;
  
  /// Last update timestamp
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.roleId,
    this.roleName,
    this.roleDisplayName,
    this.admin = false,
    this.status = UserStatus.active,
    this.mfaEnabled = false,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Get the display role name, falling back to roleName if not available.
  String? get displayRole => roleDisplayName ?? roleName;

  /// Check if user is active.
  bool get isActive => status == UserStatus.active;

  @override
  List<Object?> get props => [
    id, 
    fullName, 
    email, 
    roleId, 
    roleName, 
    roleDisplayName,
    admin,
    status, 
    mfaEnabled, 
    lastLoginAt,
    createdAt,
    updatedAt,
  ];
}
