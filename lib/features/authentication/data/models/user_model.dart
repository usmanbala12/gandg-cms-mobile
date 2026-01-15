import 'package:field_link/features/authentication/domain/entities/user.dart';

/// Data layer model for User, handles JSON serialization.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.roleId,
    super.roleName,
    super.roleDisplayName,
    super.admin,
    super.status,
    super.mfaEnabled,
    super.lastLoginAt,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roleId: json['roleId'] as String?,
      roleName: json['roleName'] as String?,
      roleDisplayName: json['roleDisplayName'] as String?,
      admin: json['admin'] as bool? ?? false,
      status: UserStatus.fromString(json['status'] as String?),
      mfaEnabled: json['mfaEnabled'] as bool? ?? false,
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    if (roleId != null) 'roleId': roleId,
    if (roleName != null) 'roleName': roleName,
    if (roleDisplayName != null) 'roleDisplayName': roleDisplayName,
    'admin': admin,
    'status': status.name,
    'mfaEnabled': mfaEnabled,
    if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  /// Create a copy with updated fields.
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? roleId,
    String? roleName,
    String? roleDisplayName,
    bool? admin,
    UserStatus? status,
    bool? mfaEnabled,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      roleDisplayName: roleDisplayName ?? this.roleDisplayName,
      admin: admin ?? this.admin,
      status: status ?? this.status,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
