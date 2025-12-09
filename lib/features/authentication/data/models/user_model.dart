import 'package:field_link/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.role,
    super.status,
    super.mfaEnabled,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? lastLogin;
    final lastLoginStr = json['lastLoginAt'] as String?;
    if (lastLoginStr != null && lastLoginStr.isNotEmpty) {
      lastLogin = DateTime.tryParse(lastLoginStr);
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String?,
      status: json['status'] as String?,
      mfaEnabled: json['mfaEnabled'] as bool? ?? false,
      lastLoginAt: lastLogin,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        'mfaEnabled': mfaEnabled,
        if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      };
}
