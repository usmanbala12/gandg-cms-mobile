import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/user_dao.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorageService tokenStorageService;
  final UserDao userDao;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorageService,
    required this.userDao,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.loginUser(email, password);

      // If MFA is required, we need to handle this differently
      // For now, we'll save tokens if available and return user
      if (!response.mfaRequired) {
        print('🔐 [AuthRepository] Login successful, saving tokens...');
        await tokenStorageService.saveTokens(
          accessToken: response.tokens.accessToken,
          refreshToken: response.tokens.refreshToken,
        );

        // Verify tokens were saved
        final isAuth = await tokenStorageService.isAuthenticated();
        print('✅ [AuthRepository] Post-login auth check: $isAuth');

        await tokenStorageService.setUserEmail(email);

        // Persist user profile to local DB for Profile screen
        print('👤 [AuthRepository] Saving user profile to DB...');
        await userDao.insertUser(UserTableData(
          id: response.user.id,
          fullName: response.user.fullName,
          email: response.user.email,
          role: response.user.role ?? '',
          status: response.user.status ?? '',
          mfaEnabled: response.user.mfaEnabled,
          lastLoginAt: response.user.lastLoginAt,
        ));
        print('✅ [AuthRepository] User profile saved to DB');
      }

      return Right(response.user);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during login: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  ) async {
    // TODO: Implement registration endpoint
    return Left(ServerFailure('Registration not yet implemented'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken != null) {
        try {
          await remoteDataSource.logout(accessToken);
        } catch (e) {
          // Ignore network errors during logout - we still want to clear local state
          print(
              '⚠️ [AuthRepository] Remote logout failed, continuing with local cleanup: $e');
        }
      }
      await tokenStorageService.clearTokens();
      await tokenStorageService.clearUserEmail();

      // Clear user profile from local DB
      print('👤 [AuthRepository] Clearing user profile from DB...');
      await userDao.deleteUser();
      print('✅ [AuthRepository] User profile cleared from DB');

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Unexpected error during logout: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // TODO: Implement get current user endpoint
    return Left(ServerFailure('Get current user not yet implemented'));
  }

  /// Verify MFA code
  @override
  Future<Either<Failure, AuthTokensModel>> verifyMFA(
    String code,
    String mfaToken,
  ) async {
    try {
      final tokens = await remoteDataSource.verifyMFA(code, mfaToken);
      print('🔐 [AuthRepository] MFA verified, saving tokens...');
      await tokenStorageService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // Verify tokens were saved
      final isAuth = await tokenStorageService.isAuthenticated();
      print('✅ [AuthRepository] Post-MFA auth check: $isAuth');
      return Right(tokens);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error during MFA verification: $e'),
      );
    }
  }

  /// Refresh access token
  @override
  Future<Either<Failure, AuthTokensModel>> refreshAccessToken(
    String refreshToken,
  ) async {
    try {
      final tokens = await remoteDataSource.refreshToken(refreshToken);
      print('🔐 [AuthRepository] Token refreshed, saving new tokens...');
      await tokenStorageService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      // Verify tokens were saved
      final isAuth = await tokenStorageService.isAuthenticated();
      print('✅ [AuthRepository] Post-refresh auth check: $isAuth');
      return Right(tokens);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during token refresh: $e'));
    }
  }

  /// Request password reset
  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await remoteDataSource.requestPasswordReset(email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error during password reset request: $e'),
      );
    }
  }

  /// Confirm password reset
  @override
  Future<Either<Failure, void>> confirmPasswordReset(
    String token,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.confirmPasswordReset(token, newPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(
        ServerFailure(
          'Unexpected error during password reset confirmation: $e',
        ),
      );
    }
  }

  /// Map Dio exceptions to Failure types
  Failure _mapDioExceptionToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 400) {
          final message = data is Map
              ? data['message'] ?? 'Invalid request'
              : 'Invalid request';
          return ValidationFailure(message);
        } else if (statusCode == 401) {
          return ServerFailure('Invalid credentials or session expired');
        } else if (statusCode == 403) {
          return ServerFailure('Access denied');
        } else if (statusCode == 404) {
          return ServerFailure('Resource not found');
        } else if (statusCode == 500) {
          return ServerFailure('Server error. Please try again later.');
        } else {
          return ServerFailure('Error: $statusCode');
        }

      case DioExceptionType.cancel:
        return ServerFailure('Request cancelled');

      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return NetworkFailure('Network error: ${e.message}');
    }
  }
}
