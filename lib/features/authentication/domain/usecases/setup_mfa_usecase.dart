import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/mfa_setup_response_model.dart';
import '../repositories/auth_repository.dart';

class SetupMfaUseCase {
  final AuthRepository repository;

  SetupMfaUseCase(this.repository);

  Future<Either<Failure, MfaSetupResponse>> call() {
    return repository.setupMfa();
  }
}
