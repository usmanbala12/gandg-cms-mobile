import 'package:dio/dio.dart';

extension DioExceptionExtension on DioException {
  /// Extracts a user-friendly error message from the API response.
  /// 
  /// The G&G API typically returns errors in the format:
  /// { "success": false, "message": "Actual error message", ... }
  String get errorMessage {
    try {
      if (response != null && response!.data is Map) {
        final data = response!.data as Map<String, dynamic>;
        if (data.containsKey('message') && data['message'] != null) {
          return data['message'].toString();
        }
      }
    } catch (_) {
      // Fallback to default Dio message if parsing fails
    }

    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.badResponse:
        final code = response?.statusCode;
        if (code == 401) return 'Session expired. Please sign in again.';
        if (code == 403) return 'You do not have permission to perform this action.';
        if (code == 404) return 'Requested resource not found.';
        if (code != null && code >= 500) return 'Server error. Please try again later.';
        return 'Server returned an error ($code).';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'An unexpected network error occurred.';
    }
  }
}
