/// Domain entity representing an Issue Comment.
class IssueCommentEntity {
  final String id;
  final String issueLocalId;
  final String authorId;
  final String content;
  final String? type; // COMMENT/STATUS_CHANGE/ASSIGNMENT/ESCALATION
  final Map<String, dynamic>? author;
  final int createdAt;
  final String? serverId;
  final int? serverCreatedAt;
  final String status; // PENDING/SYNCED/ERROR

  const IssueCommentEntity({
    required this.id,
    required this.issueLocalId,
    required this.authorId,
    required this.content,
    this.type,
    this.author,
    required this.createdAt,
    this.serverId,
    this.serverCreatedAt,
    required this.status,
  });

  /// Check if comment is pending sync.
  bool get isPending => status == 'PENDING';

  /// Check if comment is synced.
  bool get isSynced => status == 'SYNCED';

  /// Check if comment has error.
  bool get hasError => status == 'ERROR';

  /// Copy with method for immutability.
  IssueCommentEntity copyWith({
    String? id,
    String? issueLocalId,
    String? authorId,
    String? content,
    String? type,
    Map<String, dynamic>? author,
    int? createdAt,
    String? serverId,
    int? serverCreatedAt,
    String? status,
  }) {
    return IssueCommentEntity(
      id: id ?? this.id,
      issueLocalId: issueLocalId ?? this.issueLocalId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      type: type ?? this.type,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      serverId: serverId ?? this.serverId,
      serverCreatedAt: serverCreatedAt ?? this.serverCreatedAt,
      status: status ?? this.status,
    );
  }
}
