import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? role;
  final String? status;
  final bool mfaEnabled;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role,
    this.status,
    this.mfaEnabled = false,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props =>
      [id, email, fullName, role, status, mfaEnabled, lastLoginAt];
}
