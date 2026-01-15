import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/mfa_setup_response_model.dart';

/// Remote data source for authentication API operations.
/// 
/// Handles all authentication-related API calls to the G&G CMS backend.
abstract class AuthRemoteDataSource {
  /// Login with email and password.
  /// Returns [AuthResponseModel] with tokens and user, or MFA temp token.
  Future<AuthResponseModel> loginUser(String email, String password);

  /// Verify MFA code during login.
  /// Requires the MFA temp token from login response in Authorization header.
  Future<AuthResponseModel> verifyMfa(String code, String mfaTempToken);

  /// Refresh access token using refresh token.
  Future<AuthResponseModel> refreshToken(String refreshToken);

  /// Logout user (blacklist current token).
  Future<void> logout(String accessToken);

  /// Initialize MFA setup for current user.
  /// Returns QR code URL and secret for authenticator app.
  Future<MfaSetupResponse> setupMfa(String accessToken);

  /// Complete MFA setup by verifying a code.
  Future<void> enableMfa(String accessToken, String code);

  /// Disable MFA for current user.
  Future<void> disableMfa(String accessToken);

  /// Request password reset email.
  Future<void> requestPasswordReset(String email);

  /// Confirm password reset with token and new password.
  Future<void> confirmPasswordReset(
    String token,
    String newPassword,
    String confirmPassword,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> loginUser(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return AuthResponseModel.fromJson(data);
      } else {
        throw _createException(response, 'Login failed');
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
  Future<AuthResponseModel> verifyMfa(String code, String mfaTempToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/mfa/verify',
        data: {'code': code},
        options: Options(
          headers: {
            'Authorization': 'Bearer $mfaTempToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return AuthResponseModel.fromJson(data);
      } else {
        throw _createException(response, 'MFA verification failed');
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
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return AuthResponseModel.fromJson(data);
      } else {
        throw _createException(response, 'Token refresh failed');
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
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
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
  Future<MfaSetupResponse> setupMfa(String accessToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/mfa/setup',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return MfaSetupResponse.fromJson(data);
      } else {
        throw _createException(response, 'MFA setup failed');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/mfa/setup'),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during MFA setup: $e',
      );
    }
  }

  @override
  Future<void> enableMfa(String accessToken, String code) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/mfa/enable',
        data: {'code': code},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw _createException(response, 'MFA enable failed');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/mfa/enable'),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during MFA enable: $e',
      );
    }
  }

  @override
  Future<void> disableMfa(String accessToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/mfa/disable',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw _createException(response, 'MFA disable failed');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/mfa/disable'),
        type: DioExceptionType.unknown,
        error: 'Unexpected error during MFA disable: $e',
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
      // Always returns success for security (doesn't reveal if email exists)
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
  Future<void> confirmPasswordReset(
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/password-reset/confirm',
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode != 200) {
        throw _createException(response, 'Password reset confirmation failed');
      }
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

  /// Extract data from API response wrapper.
  /// Handles both wrapped and unwrapped responses.
  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Check if response is wrapped in ApiResponse format
      if (responseData.containsKey('data') && responseData.containsKey('success')) {
        return responseData['data'] as Map<String, dynamic>? ?? responseData;
      }
      return responseData;
    }
    return {};
  }

  /// Create a DioException from a response.
  DioException _createException(Response response, String defaultMessage) {
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: '$defaultMessage with status code: ${response.statusCode}',
    );
  }
}
