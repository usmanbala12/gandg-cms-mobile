import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

class VerifyMFAUseCase {
  final AuthRepository repository;

  VerifyMFAUseCase(this.repository);

  Future<Either<Failure, AuthResponseModel>> call(String code, String mfaTempToken) {
    return repository.verifyMFA(code, mfaTempToken);
  }
}
