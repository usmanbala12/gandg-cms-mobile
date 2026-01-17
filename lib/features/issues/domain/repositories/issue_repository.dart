import '../entities/data_source.dart';
import '../entities/issue_comment_entity.dart';
import '../entities/issue_entity.dart';

/// Abstract repository interface for Issue operations.
/// Defines the contract for offline-first issue management.
abstract class IssueRepository {
  /// Watch issues for a project with optional filters.
  /// Returns a stream that emits whenever the local DB changes.
  Stream<List<IssueEntity>> watchIssues({
    String? projectId,
    Map<String, dynamic>? filters,
  });

  /// Get issues for a project with optional filters.
  /// When online, fetches from server and updates local DB.
  /// When offline, returns from local DB.
  /// Returns IssueListResult with data source indicator.
  Future<IssueListResult> getIssues({
    String? projectId,
    bool forceRemote = false,
    Map<String, dynamic>? filters,
    int limit = 50,
    int offset = 0,
  });

  /// Get a single issue by local ID.
  Future<IssueEntity?> getIssue(String localId);

  /// Watch a single issue by local ID.
  Stream<IssueEntity?> watchIssue(String localId);

  /// Create a new issue.
  /// Inserts to local DB and enqueues sync item.
  /// Returns the local ID.
  /// If [mediaIds] is provided, the media will be associated with the issue.
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
  });

  /// Update an existing issue.
  /// Updates local DB and enqueues sync item.
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
  });

  /// Change issue status.
  /// Updates local status and enqueues PATCH sync item.
  /// Optionally adds a comment with the status change.
  Future<void> changeIssueStatus(
    String localId,
    String newStatus, {
    String? comment,
    String? authorId,
  });

  /// Add a comment to an issue.
  /// Inserts comment row and enqueues sync item.
  Future<void> addComment(String localIssueId, String text, String authorId, {String? type});

  /// Get comments for an issue.
  Future<List<IssueCommentEntity>> getComments(String issueLocalId);

  Stream<List<IssueCommentEntity>> watchComments(String issueLocalId);

  /// Delete an issue.
  /// Marks as deleted locally and enqueues sync item.
  Future<void> deleteIssue(String localId);

  /// Assign an issue to a user.
  /// Updates local DB and enqueues sync item.
  Future<void> assignIssue(String localId, String assigneeId);

  /// Attach media to an issue.
  /// Saves locally and enqueues sync item.
  Future<void> attachMedia(String localIssueId, String filePath);

  /// Load issue history.
  /// Merges remote history with local history.
  Future<List<Map<String, dynamic>>> loadHistory(String localIssueId);

  /// Process a sync queue item (called by SyncManager).
  /// Handles create/update/status/comment/delete/assign/media actions.
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  );
}
