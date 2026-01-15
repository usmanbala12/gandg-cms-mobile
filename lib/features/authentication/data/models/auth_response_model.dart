import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Authentication response model matching the G&G CMS API specification.
/// 
/// This response can represent:
/// - Successful login (with tokens and user)
/// - MFA required state (with mfaTempToken)
/// - Token refresh response
class AuthResponseModel extends Equatable {
  /// JWT access token for API authorization
  final String? accessToken;
  
  /// Refresh token for obtaining new access tokens
  final String? refreshToken;
  
  /// Token type, always "Bearer"
  final String tokenType;
  
  /// Access token expiration time in milliseconds
  final int? expiresIn;
  
  /// Authenticated user data (null if MFA required)
  final UserModel? user;
  
  /// Whether MFA verification is required to complete login
  final bool mfaRequired;
  
  /// Temporary token for MFA verification (valid for 5 minutes)
  final String? mfaTempToken;

  const AuthResponseModel({
    this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.user,
    this.mfaRequired = false,
    this.mfaTempToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      mfaRequired: json['mfaRequired'] as bool? ?? false,
      mfaTempToken: json['mfaTempToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (accessToken != null) 'accessToken': accessToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    'tokenType': tokenType,
    if (expiresIn != null) 'expiresIn': expiresIn,
    if (user != null) 'user': (user as UserModel).toJson(),
    'mfaRequired': mfaRequired,
    if (mfaTempToken != null) 'mfaTempToken': mfaTempToken,
  };

  /// Check if this response requires MFA verification.
  bool get requiresMfa => mfaRequired && mfaTempToken != null;

  /// Check if this is a successful login response with all required data.
  bool get isSuccess => 
      accessToken != null && 
      refreshToken != null && 
      user != null && 
      !mfaRequired;

  /// Calculate the token expiry datetime (if expiresIn is provided).
  DateTime? get tokenExpiry => expiresIn != null
      ? DateTime.now().add(Duration(milliseconds: expiresIn!))
      : null;

  @override
  List<Object?> get props => [
    accessToken, 
    refreshToken, 
    tokenType,
    expiresIn,
    user, 
    mfaRequired, 
    mfaTempToken,
  ];
}
