import 'package:dio/dio.dart';
import '../models/user_profile_model.dart';

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

  /// Update current user's profile.
  /// Calls PATCH /api/v1/users/me
  Future<UserProfileModel> updateProfile({
    required String fullName,
    required String email,
  }) async {
    try {
      print('🌐 [DataSource] Calling PATCH /api/v1/users/me');
      final response = await dio.patch(
        '/api/v1/users/me',
        data: {
          'fullName': fullName,
          'email': email,
        },
      );
      print(
          '✅ [DataSource] PATCH /api/v1/users/me success. Status: ${response.statusCode}');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      final Map<String, dynamic> dataMap;
      if (response.data is Map && (response.data as Map).containsKey('data')) {
        final inner = (response.data as Map)['data'];
        dataMap = inner is Map<String, dynamic>
            ? inner
            : response.data as Map<String, dynamic>;
      } else {
        dataMap = response.data as Map<String, dynamic>;
      }

      return UserProfileModel.fromJson(dataMap);
    } on DioException catch (e) {
      print('❌ [DataSource] DioException in updateProfile: ${e.message}');
      // Handle specific error codes
      if (e.response?.statusCode == 409) {
        throw Exception('Email is already in use');
      }
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      print('❌ [DataSource] Unexpected error in updateProfile: $e');
      rethrow;
    }
  }

  /// Change current user's password.
  /// Calls PUT /api/v1/users/me/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      print('🌐 [DataSource] Calling PUT /api/v1/users/me/password');
      final response = await dio.put(
        '/api/v1/users/me/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      print(
          '✅ [DataSource] PUT /api/v1/users/me/password success. Status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ [DataSource] DioException in changePassword: ${e.message}');
      // Handle specific error codes
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      
      if (statusCode == 400) {
        final message = errorData is Map ? errorData['message'] ?? errorData['error'] : null;
        if (message != null && message.toString().toLowerCase().contains('current password')) {
          throw Exception('Current password is incorrect');
        }
        if (message != null && message.toString().toLowerCase().contains('match')) {
          throw Exception('New password and confirmation do not match');
        }
        throw Exception(message ?? 'Invalid password data');
      }
      throw Exception('Failed to change password: ${e.message}');
    } catch (e) {
      print('❌ [DataSource] Unexpected error in changePassword: $e');
      rethrow;
    }
  }
}

