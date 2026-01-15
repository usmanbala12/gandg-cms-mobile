import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/mfa_setup_response_model.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Login user
  Future<Either<Failure, AuthResponseModel>> login(String email, String password);
  
  /// Verify MFA code during login
  Future<Either<Failure, AuthResponseModel>> verifyMFA(String code, String mfaTempToken);
  
  /// Refresh authentication tokens
  Future<Either<Failure, AuthResponseModel>> refreshAccessToken(String refreshToken);
  
  /// Logout user
  Future<Either<Failure, void>> logout();
  
  /// Get current user data
  Future<Either<Failure, User>> getCurrentUser();
  
  /// Initialize MFA setup
  Future<Either<Failure, MfaSetupResponse>> setupMfa();
  
  /// Complete MFA setup
  Future<Either<Failure, void>> enableMfa(String code);
  
  /// Disable MFA
  Future<Either<Failure, void>> disableMfa();
  
  /// Request password reset email
  Future<Either<Failure, void>> requestPasswordReset(String email);
  
  /// Confirm password reset with token
  Future<Either<Failure, void>> confirmPasswordReset(
    String token, 
    String newPassword,
    String confirmPassword,
  );
}
