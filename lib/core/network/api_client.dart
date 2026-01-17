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
        final preview =
            token.length > 10 ? '${token.substring(0, 10)}...' : token;
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
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/reports',
        data: payload,
      );
      logger.i('Created report: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error creating report: $e');
      rethrow;
    }
  }

  /// Update an existing report on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> updateReport(
    String reportId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.put(
        '/api/v1/reports/$reportId',
        data: payload,
      );
      logger.i(
        'Updated report $reportId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error updating report $reportId: $e');
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
        return _unwrapMap(response.data);
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
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error syncing batch for project $projectId: $e');
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
        return _unwrapList(response.data);
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
        return _unwrapMap(response.data);
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
        return _unwrapMap(response.data);
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
        return _unwrapMap(response.data);
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

  /// Patch issue status on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> patchIssueStatus(
    String issueId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.patch(
        '/api/v1/issues/$issueId/status',
        data: payload,
      );
      logger.i('Patched issue status for $issueId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error patching issue status for $issueId: $e');
      rethrow;
    }
  }

  /// Create a comment on an issue.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> createIssueComment(
    String issueId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/issues/$issueId/comments',
        data: payload,
      );
      logger.i('Created comment on issue $issueId: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error creating comment on issue $issueId: $e');
      rethrow;
    }
  }

  /// Assign an issue to a user.
  Future<Map<String, dynamic>> assignIssue(
    String issueId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.patch(
        '/api/v1/issues/$issueId/assign',
        data: payload,
      );
      logger.i('Assigned issue $issueId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error assigning issue $issueId: $e');
      rethrow;
    }
  }

  /// Fetch history for an issue.
  Future<List<Map<String, dynamic>>> fetchIssueHistory(String issueId) async {
    try {
      final response = await dio.get('/api/v1/issues/$issueId/history');
      logger.i('Fetched history for issue $issueId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapList(response.data);
      }
      return [];
    } catch (e) {
      logger.e('Error fetching history for issue $issueId: $e');
      rethrow;
    }
  }

  /// Fetch a single issue by ID.
  Future<Map<String, dynamic>> fetchIssue(String issueId) async {
    try {
      final response = await dio.get('/api/v1/issues/$issueId');
      logger.i('Fetched issue $issueId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error fetching issue $issueId: $e');
      rethrow;
    }
  }

  /// Fetch comments for an issue.
  Future<List<Map<String, dynamic>>> fetchIssueComments(String issueId) async {
    try {
      final response = await dio.get('/api/v1/issues/$issueId/comments');
      logger.i('Fetched comments for issue $issueId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapList(response.data);
      }
      return [];
    } catch (e) {
      logger.e('Error fetching comments for issue $issueId: $e');
      rethrow;
    }
  }

  /// Upload media for an issue.
  Future<Map<String, dynamic>> uploadIssueMedia(
    String issueId,
    String filePath, {
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
        'parent_type': 'issue',
        'parent_id': issueId,
      });

      final response = await dio.post(
        '/api/v1/issues/$issueId/media',
        data: formData,
      );
      logger.i('Uploaded media for issue $issueId: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error uploading media for issue $issueId: $e');
      rethrow;
    }
  }

  /// Fetch issues for a project.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<List<Map<String, dynamic>>> fetchProjectIssues(
    String projectId, {
    int limit = 50,
    int offset = 0,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (filters != null) ...filters,
      };

      final response = await dio.get(
        '/api/v1/projects/$projectId/issues',
        queryParameters: queryParams,
      );
      logger.i('Fetched issues for project $projectId: ${response.statusCode}');

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
    } catch (e) {
      logger.e('Error fetching issues for project $projectId: $e');
      rethrow;
    }
  }

  /// Fetch form templates.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<List<Map<String, dynamic>>> fetchTemplates() async {
    try {
      final response = await dio.get('/api/v1/form-templates');
      logger.d('📥 [ApiClient] Raw Templates Response: ${response.data}');
      logger.i('💡 Fetched form templates: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapList(response.data);
      }
      return [];
    } catch (e) {
      logger.e('Error fetching form templates: $e');
      rethrow;
    }
  }

  /// Fetch a single form template.
  Future<Map<String, dynamic>> fetchTemplate(String templateId) async {
    try {
      final response = await dio.get('/api/v1/form-templates/$templateId');
      logger.i('Fetched template $templateId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error fetching template $templateId: $e');
      rethrow;
    }
  }

  /// Fetch reports for a project.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<List<Map<String, dynamic>>> fetchProjectReports(
    String projectId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/projects/$projectId/reports',
        queryParameters: {'page': page, 'size': size},
      );
      logger.i(
        'Fetched reports for project $projectId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return _unwrapList(response.data);
      }
      return [];
    } catch (e) {
      logger.e('Error fetching reports for project $projectId: $e');
      rethrow;
    }
  }

  /// Fetch a single report.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<Map<String, dynamic>> fetchReport(
    String reportId,
  ) async {
    try {
      final response = await dio.get(
        '/api/v1/reports/$reportId',
      );
      logger.i(
        'Fetched report $reportId: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error fetching report $reportId: $e');
      rethrow;
    }
  }

  // ========== REQUEST ENDPOINTS ==========

  /// Fetch requests for a project.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<List<Map<String, dynamic>>> fetchProjectRequests(
    String projectId, {
    int limit = 50,
    int offset = 0,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (filters != null) ...filters,
      };

      final response = await dio.get(
        '/api/v1/projects/$projectId/requests',
        queryParameters: queryParams,
      );
      logger.i(
        'Fetched requests for project $projectId: ${response.statusCode}',
      );

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
    } catch (e) {
      logger.e('Error fetching requests for project $projectId: $e');
      rethrow;
    }
  }

  /// Create a new request on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> createRequest(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/projects/$projectId/requests',
        data: payload,
      );
      logger.i('Created request in project $projectId: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error creating request in project $projectId: $e');
      rethrow;
    }
  }

  /// Fetch a single request details.
  /// TODO: Adjust response shape based on actual backend contract.
  Future<Map<String, dynamic>> fetchRequestDetails(String requestId) async {
    try {
      final response = await dio.get('/api/v1/requests/$requestId');
      logger.i('Fetched request $requestId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error fetching request $requestId: $e');
      rethrow;
    }
  }

  /// Update an existing request on the server.
  /// TODO: Adjust payload and response shape based on actual backend contract.
  Future<Map<String, dynamic>> updateRequest(
    String requestId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.patch(
        '/api/v1/requests/$requestId',
        data: payload,
      );
      logger.i('Updated request $requestId: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapMap(response.data);
      }
      return {};
    } catch (e) {
      logger.e('Error updating request $requestId: $e');
      rethrow;
    }
  }

  // ========== NOTIFICATION ENDPOINTS ==========

  /// Fetch paginated notifications for the current user.
  /// Endpoint: GET /api/v1/notifications
  Future<List<Map<String, dynamic>>> fetchNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/notifications',
        queryParameters: {
          'page': page,
          'size': size,
          'unreadOnly': unreadOnly,
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
      );
      logger.i('Fetched notifications: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _unwrapList(response.data);
      }
      return [];
    } catch (e) {
      logger.e('Error fetching notifications: $e');
      rethrow;
    }
  }

  /// Get the count of unread notifications.
  /// Endpoint: GET /api/v1/notifications/count
  Future<int> fetchNotificationUnreadCount() async {
    try {
      final response = await dio.get('/api/v1/notifications/count');
      logger.i('Fetched notification count: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = _unwrapMap(response.data);
        return (data['unreadCount'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      logger.e('Error fetching notification count: $e');
      rethrow;
    }
  }

  /// Mark a specific notification as read.
  /// Endpoint: POST /api/v1/notifications/{id}/read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final response = await dio.post(
        '/api/v1/notifications/$notificationId/read',
      );
      logger.i(
        'Marked notification $notificationId as read: ${response.statusCode}',
      );
    } catch (e) {
      logger.e('Error marking notification $notificationId as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read for the current user.
  /// Endpoint: POST /api/v1/notifications/mark-all-read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await dio.post('/api/v1/notifications/mark-all-read');
      logger.i('Marked all notifications as read: ${response.statusCode}');
    } catch (e) {
      logger.e('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete a notification.
  /// Endpoint: DELETE /api/v1/notifications/{id}
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await dio.delete(
        '/api/v1/notifications/$notificationId',
      );
      logger.i(
        'Deleted notification $notificationId: ${response.statusCode}',
      );
    } catch (e) {
      logger.e('Error deleting notification $notificationId: $e');
      rethrow;
    }
  }

  // ========== UTILS ==========

  Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  List<Map<String, dynamic>> _unwrapList(dynamic data) {
    if (data is Map && data['data'] is Map && data['data']['content'] is List) {
      return List<Map<String, dynamic>>.from(data['data']['content']);
    }
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}
