import 'package:equatable/equatable.dart';

class AuthTokensModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String? mfaToken;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.mfaToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      mfaToken: json['mfa_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    if (mfaToken != null) 'mfa_token': mfaToken,
  };

  @override
  List<Object?> get props => [accessToken, refreshToken, mfaToken];
}
