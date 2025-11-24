import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> verifyMFA(String code, String mfaToken);
  Future<Either<Failure, void>> refreshAccessToken(String refreshToken);
  Future<Either<Failure, void>> requestPasswordReset(String email);
  Future<Either<Failure, void>> confirmPasswordReset(String token, String newPassword);
}
