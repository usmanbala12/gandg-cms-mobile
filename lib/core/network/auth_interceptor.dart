import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../services/token_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService tokenStorageService;
  final Dio dio;
  final Logger _logger = Logger();

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  AuthInterceptor({required this.tokenStorageService, required this.dio});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip adding token for auth endpoints
      if (options.path.contains('/auth/')) {
        _logger.d(
          '🔓 [AuthInterceptor] Skipping token for auth endpoint: ${options.path}',
        );
        return handler.next(options);
      }

      _logger.d('🔐 [AuthInterceptor] Processing request to: ${options.path}');

      // Get access token and add to headers
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        final tokenPreview = accessToken.length > 10
            ? '${accessToken.substring(0, 10)}...'
            : accessToken;
        _logger.d(
          '✅ [AuthInterceptor] Added Authorization header: Bearer $tokenPreview',
        );
      } else {
        // Log warning if no token is available for protected endpoint
        _logger.w(
          '⚠️ [AuthInterceptor] WARNING: No access token available for ${options.path}',
        );
        _logger.w('   This request will likely fail with 401 Unauthorized');
      }

      return handler.next(options);
    } catch (e) {
      _logger.e('❌ [AuthInterceptor] ERROR in onRequest: $e');
      return handler.next(options);
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    // Handle both 401 Unauthorized and 403 Forbidden
    if (statusCode == 401 || statusCode == 403) {
      _logger.w(
        '🛑 [AuthInterceptor] Caught $statusCode for ${err.requestOptions.path}',
      );

      // Don't retry refresh endpoint itself
      if (err.requestOptions.path.contains('/auth/refresh')) {
        _logger.e('❌ [AuthInterceptor] Refresh endpoint failed. Cannot retry.');
        return handler.next(err);
      }

      // If already refreshing, queue the request (simple retry for now)
      if (_isRefreshing) {
        _logger.i(
          '⏳ [AuthInterceptor] Refresh already in progress. Retrying request...',
        );
        try {
          // Wait a bit and retry (basic handling, ideally use a queue)
          await Future.delayed(const Duration(milliseconds: 1000));
          await _retryRequest(err.requestOptions, handler);
        } catch (e) {
          return handler.next(err);
        }
        return;
      }

      _isRefreshing = true;
      _logger.i('🔄 [AuthInterceptor] Starting token refresh flow...');

      try {
        final refreshToken = await tokenStorageService.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _logger.w(
            '⚠️ [AuthInterceptor] No refresh token available. Aborting refresh.',
          );
          _isRefreshing = false;
          return handler.next(err);
        }

        // Attempt to refresh token
        final response = await dio.post(
          '/api/v1/auth/refresh',
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        _logger.i(
          '✅ [AuthInterceptor] Refresh response: ${response.statusCode}',
        );

        if (response.statusCode == 200) {
          final root = response.data as Map<String, dynamic>;
          // Handle potential data wrapper
          final data = root.containsKey('data')
              ? (root['data'] as Map<String, dynamic>? ?? root)
              : root;

          // Check for both snake_case (standard) and camelCase (potential legacy)
          final newAccessToken =
              data['access_token'] as String? ?? data['accessToken'] as String?;
          final newRefreshToken = data['refresh_token'] as String? ??
              data['refreshToken'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            _logger.i(
              '✅ [AuthInterceptor] Tokens refreshed successfully. Saving...',
            );
            // Save new tokens
            await tokenStorageService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Update original request with new token
            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            _isRefreshing = false;

            _logger.i(
              '🔄 [AuthInterceptor] Retrying original request: ${err.requestOptions.path}',
            );
            // Retry original request
            return handler.resolve(
              await dio.request(
                err.requestOptions.path,
                options: Options(
                  method: err.requestOptions.method,
                  headers: err.requestOptions.headers,
                ),
                data: err.requestOptions.data,
                queryParameters: err.requestOptions.queryParameters,
              ),
            );
          } else {
            _logger.e('❌ [AuthInterceptor] Refresh response missing tokens.');
            _logger.e('   Response keys: ${data.keys.toList()}');
          }
        } else {
          _logger.e(
            '❌ [AuthInterceptor] Refresh failed with status: ${response.statusCode}',
          );
        }

        _isRefreshing = false;
        return handler.next(err);
      } catch (e) {
        _logger.e('❌ [AuthInterceptor] Exception during refresh: $e');
        _isRefreshing = false;
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Retry queued request with new token
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken != null) {
        requestOptions.headers['Authorization'] = 'Bearer $accessToken';

        final response = await dio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );
        return handler.resolve(response);
      } else {
        // If still no token, just pass the error? Or try original request?
        // For now, we can't really do much without a token.
      }
    } catch (e) {
      // If retry fails, we can't do much
    }
  }
}
