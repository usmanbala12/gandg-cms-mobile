import 'package:dio/dio.dart';
import '../models/user_profile_model.dart';
import '../models/user_preferences_model.dart';

/// Remote data source for profile-related API calls.
class ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSource({required this.dio});

  /// Fetch user profile from server.
  /// Calls GET /api/v1/users/me
  Future<UserProfileModel> fetchUserProfile() async {
    try {
      print('🌐 [DataSource] Calling GET /api/v1/users/me');
      final response = await dio.get('/api/v1/users/me');
      print(
          '✅ [DataSource] GET /api/v1/users/me success. Status: ${response.statusCode}');
      print('   Data type: ${response.data.runtimeType}');
      // print('   Data value: ${response.data}'); // Careful with sensitive data

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      final Map<String, dynamic> dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        // Try parsing if it's a string (sometimes needed depending on Dio config)
        print('⚠️ Response data is String, attempting to decode...');
        try {
          // import 'dart:convert'; needed? No, dio usually handles it.
          // Assuming dynamic here, we can't easily import jsonDecode without modifying imports.
          // but normally Dio handles this.
          dataMap = {}; // Fallback or throw?
          throw Exception('Expected Map but got String: ${response.data}');
        } catch (e) {
          throw e;
        }
      } else {
        // Check for 'data' wrapper common in some APIs
        if (response.data is Map &&
            (response.data as Map).containsKey('data')) {
          final inner = (response.data as Map)['data'];
          if (inner is Map<String, dynamic>) {
            dataMap = inner;
          } else {
            dataMap = response.data as Map<String, dynamic>;
          }
        } else {
          dataMap = response.data as Map<String, dynamic>;
        }
      }

      return UserProfileModel.fromJson(dataMap);
    } on DioException catch (e) {
      print('❌ [DataSource] DioException in fetchUserProfile: ${e.message}');
      throw Exception('Failed to fetch user profile: ${e.message}');
    } catch (e) {
      print('❌ [DataSource] Unexpected error in fetchUserProfile: $e');
      rethrow;
    }
  }

  /// Update notification preferences on server.
  /// Calls PATCH /api/v1/users/me/preferences
  Future<void> updateNotificationPreferences(
    UserPreferencesModel preferences,
  ) async {
    try {
      await dio.patch(
        '/api/v1/users/me/preferences',
        data: preferences.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to update notification preferences: ${e.message}',
      );
    }
  }
}
