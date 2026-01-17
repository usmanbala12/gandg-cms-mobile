/// Domain entity representing an Issue.
class IssueEntity {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String? priority; // LOW/MEDIUM/HIGH/CRITICAL
  final String? assigneeId;
  final String? status; // OPEN/IN_PROGRESS/RESOLVED/CLOSED
  final String? category;
  final String? location; // JSON string
  final String? dueDate;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;
  final String? meta; // Additional JSON metadata
  final String? issueNumber;
  final Map<String, dynamic>? author;
  final Map<String, dynamic>? assignee;
  final List<Map<String, dynamic>>? media;
  final List<String>? mediaIds;

  const IssueEntity({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.priority,
    this.assigneeId,
    this.status,
    this.category,
    this.location,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.serverUpdatedAt,
    this.meta,
    this.issueNumber,
    this.author,
    this.assignee,
    this.media,
    this.mediaIds,
  });

  /// Check if issue is pending sync.
  bool get isPending => serverId == null;

  /// Check if issue is synced.
  bool get isSynced => serverId != null;

  /// Check if issue has conflict (would need to check sync_conflicts table).
  /// This is a placeholder - actual implementation would query conflicts.
  bool get hasConflict => false;

  /// Copy with method for immutability.
  IssueEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? priority,
    String? assigneeId,
    String? status,
    String? category,
    String? location,
    String? dueDate,
    int? createdAt,
    int? updatedAt,
    String? serverId,
    int? serverUpdatedAt,
    String? meta,
    String? issueNumber,
    Map<String, dynamic>? author,
    Map<String, dynamic>? assignee,
    List<Map<String, dynamic>>? media,
    List<String>? mediaIds,
  }) {
    return IssueEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      status: status ?? this.status,
      category: category ?? this.category,
      location: location ?? this.location,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      meta: meta ?? this.meta,
      issueNumber: issueNumber ?? this.issueNumber,
      author: author ?? this.author,
      assignee: assignee ?? this.assignee,
      media: media ?? this.media,
      mediaIds: mediaIds ?? this.mediaIds,
    );
  }
}
