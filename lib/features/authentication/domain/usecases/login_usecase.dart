import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponseModel>> call(String email, String password) {
    return repository.login(email, password);
  }
}
