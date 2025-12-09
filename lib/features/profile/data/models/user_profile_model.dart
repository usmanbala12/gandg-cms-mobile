import '../../domain/entities/user_profile_entity.dart';

/// Data model for user profile with JSON serialization.
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.role,
    super.status,
    super.mfaEnabled,
    super.lastLoginAt,
  });

  /// Create from JSON (matches auth login response structure).
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    try {
      DateTime? lastLogin;
      final lastLoginStr = json['lastLoginAt'] as String?;
      if (lastLoginStr != null && lastLoginStr.isNotEmpty) {
        lastLogin = DateTime.tryParse(lastLoginStr);
      }

      return UserProfileModel(
        id: json['id'] as String? ?? '',
        fullName: json['fullName'] as String? ?? 'Unknown',
        email: json['email'] as String? ?? '',
        role: json['role'] as String?,
        status: json['status'] as String?,
        mfaEnabled: json['mfaEnabled'] as bool? ?? false,
        lastLoginAt: lastLogin,
      );
    } catch (e, stack) {
      print('❌ Error parsing UserProfileModel: $e');
      print('Dump JSON: $json');
      print(stack);
      rethrow;
    }
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      'mfaEnabled': mfaEnabled,
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
    };
  }

  /// Convert to entity.
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      status: status,
      mfaEnabled: mfaEnabled,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Create from entity.
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      role: entity.role,
      status: entity.status,
      mfaEnabled: entity.mfaEnabled,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  /// Create from Drift UserTableData.
  factory UserProfileModel.fromDrift(dynamic userTableData) {
    return UserProfileModel(
      id: userTableData.id as String,
      fullName: userTableData.fullName as String,
      email: userTableData.email as String,
      role: userTableData.role as String?,
      status: userTableData.status as String?,
      mfaEnabled: userTableData.mfaEnabled as bool? ?? false,
      lastLoginAt: userTableData.lastLoginAt as DateTime?,
    );
  }
}
