import 'package:logger/logger.dart';

import '../../../../core/network/api_client.dart';

/// Remote datasource for issue-related API operations.
/// Wraps ApiClient methods and handles error responses.
class IssueRemoteDataSource {
  final ApiClient apiClient;
  final Logger logger;

  IssueRemoteDataSource({required this.apiClient, Logger? logger})
    : logger = logger ?? Logger();

  /// Fetch all issues for a project with optional filters.
  Future<List<Map<String, dynamic>>> fetchProjectIssues(
    String projectId, {
    int limit = 50,
    int offset = 0,
    Map<String, dynamic>? filters,
  }) async {
    try {
      return await apiClient.fetchProjectIssues(
        projectId,
        limit: limit,
        offset: offset,
        filters: filters,
      );
    } catch (e) {
      logger.e('Error fetching project issues: $e');
      rethrow;
    }
  }

  /// Create a new issue on the server.
  Future<Map<String, dynamic>> createIssue(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await apiClient.createIssue(projectId, payload);
      logger.i('Issue created successfully');
      return response;
    } catch (e) {
      logger.e('Error creating issue: $e');
      rethrow;
    }
  }

  /// Update an existing issue on the server.
  Future<Map<String, dynamic>> updateIssue(
    String projectId,
    String issueServerId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await apiClient.updateIssue(
        projectId,
        issueServerId,
        payload,
      );
      logger.i('Issue updated successfully');
      return response;
    } catch (e) {
      logger.e('Error updating issue: $e');
      rethrow;
    }
  }

  /// Patch issue status on the server.
  Future<Map<String, dynamic>> patchIssueStatus(
    String issueServerId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await apiClient.patchIssueStatus(issueServerId, payload);
      logger.i('Issue status patched successfully');
      return response;
    } catch (e) {
      logger.e('Error patching issue status: $e');
      rethrow;
    }
  }

  /// Create a comment on an issue.
  Future<Map<String, dynamic>> createComment(
    String issueServerId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await apiClient.createIssueComment(
        issueServerId,
        payload,
      );
      logger.i('Comment created successfully');
      return response;
    } catch (e) {
      logger.e('Error creating comment: $e');
      rethrow;
    }
  }

  /// Delete an issue on the server.
  Future<void> deleteIssue(String projectId, String issueServerId) async {
    try {
      await apiClient.deleteIssue(projectId, issueServerId);
      logger.i('Issue deleted successfully');
    } catch (e) {
      logger.e('Error deleting issue: $e');
      rethrow;
    }
  }

  /// Assign an issue to a user.
  Future<Map<String, dynamic>> assignIssue(
    String issueServerId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await apiClient.assignIssue(issueServerId, payload);
      logger.i('Issue assigned successfully');
      return response;
    } catch (e) {
      logger.e('Error assigning issue: $e');
      rethrow;
    }
  }

  /// Upload media for an issue.
  Future<Map<String, dynamic>> uploadMedia(
    String projectId,
    String issueServerId,
    String filePath, {
    String? mimeType,
  }) async {
    try {
      final response = await apiClient.uploadMedia(
        projectId,
        filePath,
        'issue',
        issueServerId,
        mimeType: mimeType,
      );
      logger.i('Media uploaded successfully');
      return response;
    } catch (e) {
      logger.e('Error uploading media: $e');
      rethrow;
    }
  }

  /// Fetch history for an issue.
  Future<List<Map<String, dynamic>>> fetchIssueHistory(
    String issueServerId,
  ) async {
    try {
      final response = await apiClient.fetchIssueHistory(issueServerId);
      return response;
    } catch (e) {
      logger.e('Error fetching issue history: $e');
      rethrow;
    }
  }
}
