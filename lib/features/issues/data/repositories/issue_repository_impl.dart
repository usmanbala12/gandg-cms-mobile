import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/network/dio_exception_extension.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/issue_comment_entity.dart';
import '../../domain/entities/issue_entity.dart';
import '../../domain/entities/data_source.dart';
import '../../domain/repositories/issue_repository.dart';
import '../datasources/issue_remote_datasource.dart';
import '../models/issue_model.dart';

/// Simplified IssueRepository - remote only, no local caching.
/// Issues are always fetched from the server when online.
class IssueRepositoryImpl implements IssueRepository {
  final IssueRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  IssueRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Stream<List<IssueEntity>> watchIssues({
    String? projectId,
    Map<String, dynamic>? filters,
  }) {
    // Remote-only: no local stream, return empty.
    // UI should use getIssues and refresh periodically.
    logger.w('watchIssues is deprecated in remote-only mode');
    return Stream.value([]);
  }

  @override
  Future<IssueListResult> getIssues({
    String? projectId,
    bool forceRemote = false,
    Map<String, dynamic>? filters,
    int limit = 50,
    int offset = 0,
  }) async {
    if (projectId == null) {
      return IssueListResult.error(
        'No project selected. Please select a project from the dashboard.',
      );
    }

    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      return IssueListResult.offline(
        'You are offline. Issues cannot be loaded.',
      );
    }

    try {
      logger.i('Fetching issues from remote API...');
      final remoteData = await remoteDataSource.fetchProjectIssues(
        projectId,
        limit: limit,
        offset: offset,
        filters: filters,
      );

      final entities = remoteData
          .map((data) => IssueModel.fromJson(data, projectId: projectId).toEntity())
          .toList();

      logger.i('✅ Fetched ${entities.length} issues from remote');
      return IssueListResult.remote(
        entities,
        lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
      );
    } on DioException catch (e) {
      final message = e.errorMessage;
      logger.e('Dio error fetching issues: $message');
      return IssueListResult.error(message);
    } catch (e) {
      logger.e('Error fetching issues: $e');
      return IssueListResult.error('Failed to load issues: $e');
    }
  }

  @override
  Future<IssueEntity?> getIssue(String localId) async {
    // In remote-only mode, localId is actually serverId
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) return null;

    try {
      final data = await remoteDataSource.fetchIssue(localId);
      final projectId = data['project_id'] ?? data['project']?['id'];
      return IssueModel.fromJson(data, projectId: projectId?.toString()).toEntity();
    } catch (e) {
      logger.e('Error fetching issue $localId: $e');
      return null;
    }
  }

  @override
  Stream<IssueEntity?> watchIssue(String localId) async* {
    yield await getIssue(localId);
  }

  @override
  Future<String> createIssue({
    required String projectId,
    required String title,
    String? description,
    String? priority,
    String? assigneeId,
    String? category,
    String? location,
    String? dueDate,
    String? meta,
    List<String>? mediaIds,
  }) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot create issue while offline.');
    }

    try {
      final response = await remoteDataSource.createIssue(projectId, {
        'title': title,
        if (description != null) 'description': description,
        if (priority != null) 'priority': priority,
        if (assigneeId != null) 'assigneeId': assigneeId,
        if (category != null) 'category': category,
        if (location != null) 'location': location,
        if (dueDate != null) 'dueDate': dueDate,
        if (meta != null) 'meta': meta,
        if (mediaIds != null && mediaIds.isNotEmpty) 'mediaIds': mediaIds,
      });

      final serverId = response['id'] ?? response['data']?['id'];
      logger.i('✅ Issue created: $serverId');
      return serverId.toString();
    } catch (e) {
      logger.e('Error creating issue: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateIssue({
    required String localId,
    String? title,
    String? description,
    String? priority,
    String? assigneeId,
    String? category,
    String? location,
    String? dueDate,
    String? meta,
  }) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot update issue while offline.');
    }

    try {
      // In remote-only mode, localId is the serverId
      final current = await remoteDataSource.fetchIssue(localId);
      final projectId = current['project_id'] ?? current['project']?['id'];

      await remoteDataSource.updateIssue(projectId, localId, {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (priority != null) 'priority': priority,
        if (assigneeId != null) 'assigneeId': assigneeId,
        if (category != null) 'category': category,
        if (location != null) 'location': location,
        if (dueDate != null) 'dueDate': dueDate,
        if (meta != null) 'meta': meta,
      });
      logger.i('✅ Issue updated: $localId');
    } catch (e) {
      logger.e('Error updating issue: $e');
      rethrow;
    }
  }

  @override
  Future<void> changeIssueStatus(
    String localId,
    String newStatus, {
    String? comment,
    String? authorId,
  }) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot change status while offline.');
    }

    try {
      await remoteDataSource.patchIssueStatus(localId, {
        'status': newStatus,
        if (comment != null) 'comment': comment,
      });
      logger.i('✅ Issue status changed: $localId -> $newStatus');
    } catch (e) {
      logger.e('Error changing issue status: $e');
      rethrow;
    }
  }

  @override
  Future<void> addComment(
    String localIssueId,
    String text,
    String authorId, {
    String? type,
  }) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot add comment while offline.');
    }

    try {
      await remoteDataSource.createComment(localIssueId, {
        'content': text,
        if (type != null) 'type': type,
      });
      logger.i('✅ Comment added to issue: $localIssueId');
    } catch (e) {
      logger.e('Error adding comment: $e');
      rethrow;
    }
  }

  @override
  Future<List<IssueCommentEntity>> getComments(String issueLocalId) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) return [];

    try {
      final items = await remoteDataSource.fetchIssueComments(issueLocalId);

      return items.map((item) {
        final rawDate = item['created_at'] ?? item['createdAt'];
        int parsedDate;
        if (rawDate is int) {
          parsedDate = rawDate;
        } else if (rawDate is String) {
          parsedDate = DateTime.tryParse(rawDate)?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch;
        } else {
          parsedDate = DateTime.now().millisecondsSinceEpoch;
        }

        final authorMap = item['author'] as Map<String, dynamic>?;

        return IssueCommentEntity(
          id: item['id']?.toString() ?? '',
          issueLocalId: issueLocalId,
          authorId: item['author_id']?.toString() ??
              item['authorId']?.toString() ??
              authorMap?['id']?.toString() ??
              '',
          content: item['content'] ?? item['body'] ?? '',
          type: item['type']?.toString(),
          author: authorMap,
          createdAt: parsedDate,
          status: 'SYNCED',
        );
      }).cast<IssueCommentEntity>().toList();
    } catch (e) {
      logger.e('Error fetching comments: $e');
      return [];
    }
  }

  @override
  Stream<List<IssueCommentEntity>> watchComments(String issueLocalId) async* {
    yield await getComments(issueLocalId);
  }

  @override
  Future<void> deleteIssue(String localId) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot delete issue while offline.');
    }

    try {
      // Need project ID for the API call
      final issue = await remoteDataSource.fetchIssue(localId);
      final projectId = issue['project_id'] ?? issue['project']?['id'];
      await remoteDataSource.deleteIssue(projectId, localId);
      logger.i('✅ Issue deleted: $localId');
    } catch (e) {
      logger.e('Error deleting issue: $e');
      rethrow;
    }
  }

  @override
  Future<void> assignIssue(String localId, String assigneeId) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot assign issue while offline.');
    }

    try {
      await remoteDataSource.assignIssue(localId, {
        'assigneeId': assigneeId,
        'comment': null,
      });
      logger.i('✅ Issue assigned: $localId -> $assigneeId');
    } catch (e) {
      logger.e('Error assigning issue: $e');
      rethrow;
    }
  }

  @override
  Future<void> attachMedia(String localIssueId, String filePath) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot attach media while offline.');
    }

    try {
      await remoteDataSource.uploadIssueMedia(localIssueId, filePath);
      logger.i('✅ Media attached to issue: $localIssueId');
    } catch (e) {
      logger.e('Error attaching media: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadHistory(String localIssueId) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) return [];

    try {
      return await remoteDataSource.fetchIssueHistory(localIssueId);
    } catch (e) {
      logger.e('Error loading history: $e');
      return [];
    }
  }

  @override
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  ) async {
    // Not used in remote-only mode
    logger.w('processSyncQueueItem called but issues are remote-only');
  }
}
