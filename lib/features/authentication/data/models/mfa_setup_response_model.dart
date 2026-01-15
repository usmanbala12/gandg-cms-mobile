import 'package:equatable/equatable.dart';

/// Response model for MFA setup initialization.
/// 
/// Returned when calling POST /auth/mfa/setup
/// Contains the secret and QR code URL for authenticator app setup.
class MfaSetupResponse extends Equatable {
  /// The TOTP secret key for manual entry
  final String secret;
  
  /// The otpauth:// URL for QR code generation
  final String qrCodeUrl;
  
  /// The issuer name (typically the app name)
  final String issuer;
  
  /// The account name (typically the user's email)
  final String accountName;

  const MfaSetupResponse({
    required this.secret,
    required this.qrCodeUrl,
    required this.issuer,
    required this.accountName,
  });

  factory MfaSetupResponse.fromJson(Map<String, dynamic> json) {
    return MfaSetupResponse(
      secret: json['secret'] as String? ?? '',
      qrCodeUrl: json['qrCodeUrl'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'secret': secret,
    'qrCodeUrl': qrCodeUrl,
    'issuer': issuer,
    'accountName': accountName,
  };

  @override
  List<Object?> get props => [secret, qrCodeUrl, issuer, accountName];
}
