import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyMFAUseCase {
  final AuthRepository repository;

  VerifyMFAUseCase(this.repository);

  Future<Either<Failure, void>> call(String code, String mfaToken) {
    return repository.verifyMFA(code, mfaToken);
  }
}
