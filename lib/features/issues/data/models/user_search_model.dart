import 'package:equatable/equatable.dart';

/// Model representing a user from the search API.
/// Matches the UserResponse structure from the backend.
class UserSearchModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? roleId;
  final String? roleName;
  final String? roleDisplayName;
  final bool? admin;
  final String status;
  final bool? mfaEnabled;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserSearchModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.roleId,
    this.roleName,
    this.roleDisplayName,
    this.admin,
    required this.status,
    this.mfaEnabled,
    this.lastLoginAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON response.
  factory UserSearchModel.fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      roleId: json['roleId'] as String?,
      roleName: json['roleName'] as String?,
      roleDisplayName: json['roleDisplayName'] as String?,
      admin: json['admin'] as bool?,
      status: json['status'] as String? ?? 'ACTIVE',
      mfaEnabled: json['mfaEnabled'] as bool?,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      if (roleId != null) 'roleId': roleId,
      if (roleName != null) 'roleName': roleName,
      if (roleDisplayName != null) 'roleDisplayName': roleDisplayName,
      if (admin != null) 'admin': admin,
      'status': status,
      if (mfaEnabled != null) 'mfaEnabled': mfaEnabled,
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Get display name for UI (role display name or role name fallback).
  String get displayRole => roleDisplayName ?? roleName ?? 'No Role';

  /// Get avatar initials from the user's name.
  String get avatarInitials {
    if (fullName.isEmpty) return '??';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase();
  }

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

/// Paginated response for user search.
class UserSearchPageResponse {
  final List<UserSearchModel> content;
  final int totalElements;
  final int totalPages;
  final int pageSize;
  final int pageNumber;
  final bool last;
  final bool first;
  final bool empty;

  const UserSearchPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageSize,
    required this.pageNumber,
    required this.last,
    required this.first,
    required this.empty,
  });

  /// Create from JSON response (handles nested data wrapper).
  factory UserSearchPageResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data wrapper: { data: { content: [...] } }
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    
    final contentList = (data['content'] as List<dynamic>?) ?? [];
    
    return UserSearchPageResponse(
      content: contentList
          .map((item) => UserSearchModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalElements: data['totalElements'] as int? ?? 0,
      totalPages: data['totalPages'] as int? ?? 0,
      pageSize: data['pageSize'] as int? ?? 10,
      pageNumber: data['pageNumber'] as int? ?? 0,
      last: data['last'] as bool? ?? true,
      first: data['first'] as bool? ?? true,
      empty: data['empty'] as bool? ?? true,
    );
  }
}
