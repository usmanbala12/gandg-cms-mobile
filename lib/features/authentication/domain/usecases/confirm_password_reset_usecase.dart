import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ConfirmPasswordResetUseCase {
  final AuthRepository repository;

  ConfirmPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) {
    return repository.confirmPasswordReset(token, newPassword, confirmPassword);
  }
}
