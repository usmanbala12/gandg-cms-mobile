import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class EnableMfaUseCase {
  final AuthRepository repository;

  EnableMfaUseCase(this.repository);

  Future<Either<Failure, void>> call(String code) {
    return repository.enableMfa(code);
  }
}
