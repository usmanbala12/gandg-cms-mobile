import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_response_model.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, AuthResponseModel>> call(String refreshToken) {
    return repository.refreshAccessToken(refreshToken);
  }
}
