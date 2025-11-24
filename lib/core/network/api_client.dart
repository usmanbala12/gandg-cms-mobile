import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Typed API client wrapping Dio for sync operations.
/// Handles all backend communication for the offline-first sync layer.
class ApiClient {
  final Dio dio;
  final Logger logger;

  ApiClient({required this.dio, Logger? logger}) : logger = logger ?? Logger();

  /// Fetch all projects for the current user.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<List<Map<String, dynamic>>> fetchProjects() async {
    try {
      final response = await dio.get('/api/v1/projects');
      logger.d('📥 [ApiClient] Raw Projects Response: ${response.data}');
      logger.i('✅ Fetched projects: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        // Handle paginated response: data -> data -> content
        if (data is Map &&
            data['data'] is Map &&
            data['data']['content'] is List) {
          return List<Map<String, dynamic>>.from(data['data']['content']);
        }
        // Handle direct list response: data -> data
        if (data is Map && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final responseData = error.response?.data;
      logger.e(
        '❌ Error fetching projects (status: $status): ${error.message}',
        error: error,
        stackTrace: error.stackTrace,
      );

      // Log actual request headers to debug auth issues
      final requestHeaders = error.requestOptions.headers;
      final authHeader = requestHeaders['Authorization'];
      if (authHeader != null) {
        final token = authHeader.toString().replaceFirst('Bearer ', '');
        final preview = token.length > 10
            ? '${token.substring(0, 10)}...'
            : token;
        logger.i('🔑 Request sent with Token: Bearer $preview');
      } else {
        logger.w('⚠️ Request sent WITHOUT Authorization header');
      }

      if (status == 401 || status == 403) {
        logger.e(
          '🚫 Authentication/Authorization failed. Token may be invalid or expired.',
        );
        if (responseData != null) {
          logger.e('Server response: $responseData');
        }
      }
      rethrow;
    } catch (error, stackTrace) {
      logger.e(
        'Unexpected error fetching projects',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Fetch analytics for a specific project.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<Map<String, dynamic>> fetchProjectAnalytics(String projectId) async {
    try {
      final response = await dio.get(
        '/api/v1/projects/$projectId/requests/analytics',
      );
      logger.i(
        'Fetched analytics for project $projectId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error fetching analytics for project $projectId: $e');
      rethrow;
    }
  }

  /// Create a new report on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> createReport(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/projects/$projectId/reports',
        data: payload,
      );
      logger.i('Created report in project $projectId: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error creating report in project $projectId: $e');
      rethrow;
    }
  }

  /// Update an existing report on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> updateReport(
    String projectId,
    String reportId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.put(
        '/api/v1/projects/$projectId/reports/$reportId',
        data: payload,
      );
      logger.i(
        'Updated report $reportId in project $projectId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error updating report $reportId in project $projectId: $e');
      rethrow;
    }
  }

  /// Delete a report on the server.
  Future<void> deleteReport(String projectId, String reportId) async {
    try {
      final response = await dio.delete(
        '/api/v1/projects/$projectId/reports/$reportId',
      );
      logger.i(
        'Deleted report $reportId in project $projectId: ${response.statusCode}',
      );
    } catch (e) {
      logger.e('Error deleting report $reportId in project $projectId: $e');
      rethrow;
    }
  }

  /// Upload media file with multipart form data.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<Map<String, dynamic>> uploadMedia(
    String projectId,
    String filePath,
    String parentType,
    String parentId, {
    String? mimeType,
  }) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
        contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
      );

      final formData = FormData.fromMap({
        'file': file,
        'parent_type': parentType,
        'parent_id': parentId,
      });

      final response = await dio.post(
        '/api/v1/projects/$projectId/media',
        data: formData,
      );
      logger.i('Uploaded media to project $projectId: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error uploading media to project $projectId: $e');
      rethrow;
    }
  }

  /// Sync batch: upload pending changes to server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> syncBatch(
    String projectId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final payload = {'project_id': projectId, 'items': items};

      final response = await dio.post('/api/v1/sync/batch', data: payload);
      logger.i('Synced batch for project $projectId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error syncing batch for project $projectId: $e');
      rethrow;
    }
  }

  /// Download changes from server since a given timestamp.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<Map<String, dynamic>> syncDownload(String projectId, int since) async {
    try {
      final response = await dio.get(
        '/api/v1/sync/download',
        queryParameters: {'project_id': projectId, 'since': since},
      );
      logger.i(
        'Downloaded sync data for project $projectId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error downloading sync data for project $projectId: $e');
      rethrow;
    }
  }

  /// Fetch unresolved sync conflicts for a project.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<List<Map<String, dynamic>>> fetchSyncConflicts(
    String projectId,
  ) async {
    try {
      final response = await dio.get(
        '/api/v1/sync/conflicts',
        queryParameters: {'project_id': projectId},
      );
      logger.i(
        'Fetched sync conflicts for project $projectId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['conflicts'] is List) {
          return List<Map<String, dynamic>>.from(data['conflicts']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (e) {
      logger.e('Error fetching sync conflicts for project $projectId: $e');
      rethrow;
    }
  }

  /// Resolve a sync conflict.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> resolveConflict(
    String conflictId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/sync/conflicts/$conflictId/resolve',
        data: payload,
      );
      logger.i('Resolved conflict $conflictId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error resolving conflict $conflictId: $e');
      rethrow;
    }
  }

  /// Create an issue on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> createIssue(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/projects/$projectId/issues',
        data: payload,
      );
      logger.i('Created issue in project $projectId: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error creating issue in project $projectId: $e');
      rethrow;
    }
  }

  /// Update an existing issue on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> updateIssue(
    String projectId,
    String issueId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.put(
        '/api/v1/projects/$projectId/issues/$issueId',
        data: payload,
      );
      logger.i(
        'Updated issue $issueId in project $projectId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return response.data is Map ? response.data : {};
      }
      return {};
    } catch (e) {
      logger.e('Error updating issue $issueId in project $projectId: $e');
      rethrow;
    }
  }

  /// Delete an issue on the server.
  Future<void> deleteIssue(String projectId, String issueId) async {
    try {
      final response = await dio.delete(
        '/api/v1/projects/$projectId/issues/$issueId',
      );
      logger.i(
        'Deleted issue $issueId in project $projectId: ${response.statusCode}',
      );
    } catch (e) {
      logger.e('Error deleting issue $issueId in project $projectId: $e');
      rethrow;
    }
  }
}
