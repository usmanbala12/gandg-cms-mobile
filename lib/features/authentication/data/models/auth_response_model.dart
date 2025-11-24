import 'package:equatable/equatable.dart';
import 'auth_tokens_model.dart';
import 'user_model.dart';

class AuthResponseModel extends Equatable {
  final UserModel user;
  final AuthTokensModel tokens;
  final bool mfaRequired;
  final String? mfaToken;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
    this.mfaRequired = false,
    this.mfaToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      tokens: AuthTokensModel.fromJson(json['tokens'] as Map<String, dynamic>? ?? {}),
      mfaRequired: json['mfa_required'] as bool? ?? false,
      mfaToken: json['mfa_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'tokens': tokens.toJson(),
    'mfa_required': mfaRequired,
    if (mfaToken != null) 'mfa_token': mfaToken,
  };

  @override
  List<Object?> get props => [user, tokens, mfaRequired, mfaToken];
}
