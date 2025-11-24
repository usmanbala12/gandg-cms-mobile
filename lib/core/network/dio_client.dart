import 'package:dio/dio.dart';
import '../services/token_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio? _dio;
  static TokenStorageService? _tokenStorageService;
  static String _baseUrl = 'http://72.61.19.130:8080/';

  /// Configure the base URL for all API calls.
  static void configure({required String baseUrl}) {
    final normalized = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    _baseUrl = normalized;
    if (_dio != null) {
      _dio!.options.baseUrl = _baseUrl;
    }
  }

  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      _setupInterceptors();
    }
    return _dio!;
  }

  /// Initialize Dio with token storage service
  static void initialize(TokenStorageService tokenStorageService) {
    _tokenStorageService = tokenStorageService;
    if (_dio != null) {
      _setupInterceptors();
    }
  }

  static void _setupInterceptors() {
    // Remove existing interceptors
    _dio!.interceptors.clear();

    // Add auth interceptor if token storage is available
    if (_tokenStorageService != null) {
      _dio!.interceptors.add(
        AuthInterceptor(tokenStorageService: _tokenStorageService!, dio: _dio!),
      );
    }

    // Add logging interceptor for debugging
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }
}
