import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class DisableMfaUseCase {
  final AuthRepository repository;

  DisableMfaUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.disableMfa();
  }
}
