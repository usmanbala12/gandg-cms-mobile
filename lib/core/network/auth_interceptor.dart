import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../services/token_storage_service.dart';
import '../../features/authentication/data/models/auth_response_model.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService tokenStorageService;
  final Dio dio;
  final Logger _logger = Logger();

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;
  
  // Queue for requests waiting for token refresh
  final List<_QueuedRequest> _queue = [];

  AuthInterceptor({required this.tokenStorageService, required this.dio});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip adding token for auth endpoints
      final publicEndpoints = [
        '/auth/login',
        '/auth/refresh',
        '/auth/password-reset/',
        '/auth/mfa/verify', // MFA verification uses temp token, handled explicitly in datasource
      ];

      if (publicEndpoints.any((e) => options.path.contains(e))) {
        _logger.d('🔓 [AuthInterceptor] Skipping token for public endpoint: ${options.path}');
        return handler.next(options);
      }

      // Get access token and add to headers
      final accessToken = await tokenStorageService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        final tokenPreview = accessToken.length > 8 ? '${accessToken.substring(0, 8)}...' : 'short';
        _logger.d('🔑 [AuthInterceptor] Added token ($tokenPreview) to ${options.path}');
      } else {
        _logger.w('⚠️ [AuthInterceptor] NO TOKEN for ${options.path}');
      }

      return handler.next(options);
    } catch (e) {
      _logger.e('❌ [AuthInterceptor] ERROR in onRequest: $e');
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    _logger.e('❌ [AuthInterceptor] onError: ${err.requestOptions.path} (status: $statusCode)');

    // Handle 401 Unauthorized
    if (statusCode == 401) {
      // Don't retry refresh or login endpoints
      if (err.requestOptions.path.contains('/auth/login') ||
          err.requestOptions.path.contains('/auth/refresh')) {
        await tokenStorageService.triggerLogout();
        return handler.next(err);
      }

      // If this request was already retried, don't try again
      final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;
      if (retryCount >= 1) {
        _logger.e('🛑 [AuthInterceptor] Max retries reached for ${err.requestOptions.path}. Clearing tokens and logging out.');
        await tokenStorageService.triggerLogout();
        return handler.next(err);
      }

      // If already refreshing, queue the request
      if (_isRefreshing) {
        _logger.i('⏳ [AuthInterceptor] Already refreshing, queuing: ${err.requestOptions.path}');
        final completer = Completer<Response>();
        _queue.add(_QueuedRequest(err.requestOptions, completer));
        
        try {
          final response = await completer.future;
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }

      _isRefreshing = true;
      _logger.i('🔄 [AuthInterceptor] Starting token refresh flow...');

      try {
        final refreshToken = await tokenStorageService.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _logger.w('⚠️ [AuthInterceptor] No refresh token available');
          _isRefreshing = false;
          _clearQueue(err);
          return handler.next(err);
        }

        // Attempt to refresh token
        final response = await dio.post(
          '/api/v1/auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200) {
          _logger.i('✅ [AuthInterceptor] Token refresh successful');
          final root = response.data as Map<String, dynamic>;
          final data = root.containsKey('data') ? root['data'] : root;
          
          final authResponse = AuthResponseModel.fromJson(data);
          
          if (authResponse.accessToken != null) {
            await tokenStorageService.saveAuthResponse(authResponse);
            
            _isRefreshing = false;
            
            // Retry the original request
            final retryResponse = await _retryRequest(err.requestOptions);
            
            // Process the queue
            _processQueue();
            
            return handler.resolve(retryResponse);
          }
        }
        
        _logger.e('❌ [AuthInterceptor] Refresh failed (status: ${response.statusCode})');
        _isRefreshing = false;
        _clearQueue(err);
        return handler.next(err);
      } catch (e) {
        _logger.e('❌ [AuthInterceptor] Exception during refresh: $e');
        _isRefreshing = false;
        _clearQueue(err);
        await tokenStorageService.triggerLogout();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Retry a single request with the latest token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await tokenStorageService.getAccessToken();
    
    // Increment retry count
    final retryCount = (requestOptions.extra['retry_count'] as int? ?? 0) + 1;
    final extra = Map<String, dynamic>.from(requestOptions.extra)
      ..['retry_count'] = retryCount;

    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers)
        ..['Authorization'] = 'Bearer $accessToken',
      extra: extra,
    );

    _logger.i('🔁 [AuthInterceptor] Retrying ${requestOptions.path} (attempt $retryCount)');

    return dio.request(
      requestOptions.path,
      options: options,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  /// Process all queued requests after successful token refresh
  void _processQueue() async {
    for (final request in _queue) {
      try {
        final response = await _retryRequest(request.options);
        request.completer.complete(response);
      } catch (e) {
        request.completer.completeError(e);
      }
    }
    _queue.clear();
  }

  /// Reject all queued requests if refresh fails
  void _clearQueue(DioException originalError) {
    for (final request in _queue) {
      request.completer.completeError(originalError);
    }
    _queue.clear();
  }
}

class _QueuedRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  _QueuedRequest(this.options, this.completer);
}
