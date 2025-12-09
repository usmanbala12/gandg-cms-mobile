import 'package:equatable/equatable.dart';

/// Entity representing a user's profile information.
class UserProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? role;
  final String? status;
  final bool mfaEnabled;
  final DateTime? lastLoginAt;

  const UserProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.status,
    this.mfaEnabled = false,
    this.lastLoginAt,
  });

  /// Compute avatar initials from the user's name (first two letters).
  String get avatarInitials {
    if (fullName.isEmpty) return '??';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  List<Object?> get props =>
      [id, fullName, email, role, status, mfaEnabled, lastLoginAt];
}
