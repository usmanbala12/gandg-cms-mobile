import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/user_dao.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/mfa_setup_response_model.dart';

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
  Future<Either<Failure, AuthResponseModel>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.loginUser(email, password);

      if (!response.mfaRequired && response.user != null) {
        await _persistAuthData(response, email);
      }

      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during login: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken != null) {
        try {
          await remoteDataSource.logout(accessToken);
        } catch (e) {
          // Ignore network errors during logout
        }
      }
      await tokenStorageService.clearTokens();
      await tokenStorageService.clearUserEmail();
      await userDao.deleteUser();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Unexpected error during logout: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final cachedUser = await tokenStorageService.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      
      final dbUser = await userDao.getCurrentUser();
      if (dbUser != null) {
        return Right(User(
          id: dbUser.id,
          fullName: dbUser.fullName,
          email: dbUser.email,
          roleName: dbUser.role,
          roleId: dbUser.roleId,
          roleDisplayName: dbUser.roleDisplayName,
          admin: dbUser.admin,
          status: UserStatus.fromString(dbUser.status),
          mfaEnabled: dbUser.mfaEnabled,
          lastLoginAt: dbUser.lastLoginAt,
          createdAt: dbUser.createdAt,
          updatedAt: dbUser.updatedAt,
        ));
      }
      
      return Left(ServerFailure('No authenticated user found'));
    } catch (e) {
      return Left(ServerFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> verifyMFA(
    String code,
    String mfaTempToken,
  ) async {
    try {
      final response = await remoteDataSource.verifyMfa(code, mfaTempToken);
      
      if (response.user != null) {
        await _persistAuthData(response, response.user!.email);
      }
      
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during MFA verification: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> refreshAccessToken(
    String refreshToken,
  ) async {
    try {
      final response = await remoteDataSource.refreshToken(refreshToken);
      await tokenStorageService.saveAuthResponse(response);
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during token refresh: $e'));
    }
  }

  @override
  Future<Either<Failure, MfaSetupResponse>> setupMfa() async {
    try {
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken == null) return Left(ServerFailure('Unauthorized'));
      
      final response = await remoteDataSource.setupMfa(accessToken);
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during MFA setup: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enableMfa(String code) async {
    try {
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken == null) return Left(ServerFailure('Unauthorized'));
      
      await remoteDataSource.enableMfa(accessToken, code);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during MFA enable: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> disableMfa() async {
    try {
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken == null) return Left(ServerFailure('Unauthorized'));
      
      await remoteDataSource.disableMfa(accessToken);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during MFA disable: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await remoteDataSource.requestPasswordReset(email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during password reset: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPasswordReset(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await remoteDataSource.confirmPasswordReset(token, newPassword, confirmPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error during password confirmation: $e'));
    }
  }

  /// Helper to save tokens and user data
  Future<void> _persistAuthData(AuthResponseModel response, String email) async {
    await tokenStorageService.saveAuthResponse(response);
    
    if (response.user != null) {
      await userDao.insertUser(UserTableData(
        id: response.user!.id,
        fullName: response.user!.fullName,
        email: response.user!.email,
        role: response.user!.roleName ?? '',
        roleId: response.user!.roleId,
        roleDisplayName: response.user!.roleDisplayName,
        admin: response.user!.admin,
        status: response.user!.status.name,
        mfaEnabled: response.user!.mfaEnabled,
        lastLoginAt: response.user!.lastLoginAt,
        createdAt: response.user!.createdAt,
        updatedAt: response.user!.updatedAt,
      ));
    }
  }

  Failure _mapDioExceptionToFailure(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      final message = data is Map ? data['message'] ?? data['error'] : null;
      
      switch (e.response!.statusCode) {
        case 400: return ValidationFailure(message ?? 'Invalid request');
        case 401: return ServerFailure(message ?? 'Unauthorized');
        case 403: return ServerFailure(message ?? 'Access denied');
        case 404: return ServerFailure(message ?? 'Not found');
        case 500: return ServerFailure('Server error. Please try again later.');
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('Connection timed out');
      case DioExceptionType.connectionError:
        return NetworkFailure('No internet connection');
      default:
        return ServerFailure('Network error occurred');
    }
  }
}
