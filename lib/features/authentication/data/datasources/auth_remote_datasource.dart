import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/auth_tokens_model.dart';

abstract class AuthRemoteDataSource {
  /// Login with email and password
  /// Returns [AuthResponseModel] with user and tokens
  /// Throws [DioException] on network/server errors
  Future<AuthResponseModel> loginUser(String email, String password);

  /// Verify MFA code
  /// Returns [AuthTokensModel] with updated tokens
  Future<AuthTokensModel> verifyMFA(String code, String mfaToken);

  /// Refresh access token using refresh token
  /// Returns [AuthTokensModel] with new access token
  Future<AuthTokensModel> refreshToken(String refreshToken);

  /// Logout user
  /// Clears session on server
  Future<void> logout(String accessToken);

  /// Request password reset
  Future<void> requestPasswordReset(String email);

  /// Confirm password reset with token and new password
  Future<void> confirmPasswordReset(String token, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> loginUser(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final root = response.data as Map<String, dynamic>;
        final data = root['data'] as Map<String, dynamic>;

        // Map API response (camelCase) to Model expectation (snake_case)
        final mappedData = {
          'user': data['user'],
          'tokens': {
            'access_token': data['accessToken'],
            'refresh_token': data['refreshToken'],
            'mfa_token': data['mfaToken'],
          },
          'mfa_required': data['mfaRequired'] ?? false,
          'mfa_token': data['mfaToken'],
        };

        return AuthResponseModel.fromJson(mappedData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Login failed with status code: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during login: $e',
      );
    }
  }

  @override
  Future<AuthTokensModel> verifyMFA(String code, String mfaToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/mfa/verify',
        data: {'code': code, 'mfa_token': mfaToken},
      );

      if (response.statusCode == 200) {
        final root = response.data as Map<String, dynamic>;
        final data = root['data'] as Map<String, dynamic>;

        final mappedTokens = {
          'access_token': data['accessToken'],
          'refresh_token': data['refreshToken'],
          'mfa_token': data['mfaToken'],
        };

        return AuthTokensModel.fromJson(mappedTokens);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error:
              'MFA verification failed with status code: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/mfa/verify'),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during MFA verification: $e',
      );
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final root = response.data as Map<String, dynamic>;
        final data = root['data'] as Map<String, dynamic>;

        final mappedTokens = {
          'access_token': data['accessToken'],
          'refresh_token': data['refreshToken'],
          'mfa_token': data['mfaToken'],
        };

        return AuthTokensModel.fromJson(mappedTokens);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error:
              'Token refresh failed with status code: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during token refresh: $e',
      );
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      await dio.post(
        '/api/v1/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/logout'),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during logout: $e',
      );
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await dio.post(
        '/api/v1/auth/password-reset/request',
        data: {'email': email},
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/auth/password-reset/request',
        ),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during password reset request: $e',
      );
    }
  }

  @override
  Future<void> confirmPasswordReset(String token, String newPassword) async {
    try {
      await dio.post(
        '/api/v1/auth/password-reset/confirm',
        data: {'token': token, 'new_password': newPassword},
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/auth/password-reset/confirm',
        ),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during password reset confirmation: $e',
      );
    }
  }
}
