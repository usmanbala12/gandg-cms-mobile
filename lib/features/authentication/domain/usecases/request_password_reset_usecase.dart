import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  final AuthRepository repository;

  RequestPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) {
    return repository.requestPasswordReset(email);
  }
}
