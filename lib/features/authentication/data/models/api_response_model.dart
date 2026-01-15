import 'package:equatable/equatable.dart';

/// Generic wrapper for all API responses from the G&G CMS backend.
/// 
/// All API responses follow this format:
/// ```json
/// {
///   "success": true,
///   "message": "Optional message",
///   "data": { ... },
///   "error": "Optional error message",
///   "timestamp": "2026-01-15T15:00:00Z"
/// }
/// ```
class ApiResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final DateTime timestamp;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    required this.timestamp,
  });

  /// Create an ApiResponse from JSON with a custom data parser.
  /// 
  /// [json] - The raw JSON response from the API
  /// [fromJsonT] - Optional function to parse the 'data' field into type T
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : (json['data'] as T?),
      error: json['error'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Create an ApiResponse for list data.
  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic>) fromJsonList,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? fromJsonList(json['data'] as List<dynamic>)
          : null,
      error: json['error'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Check if the response indicates a failure.
  bool get isFailure => !success;

  /// Get the error message or a default message.
  String get errorMessage => error ?? message ?? 'Unknown error occurred';

  @override
  List<Object?> get props => [success, message, data, error, timestamp];
}
