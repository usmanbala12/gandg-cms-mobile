import '../../domain/entities/issue_comment_entity.dart';

/// Data model for Issue Comment with converters between JSON and Entity.
/// Simplified to remove database dependencies (remote-only mode).
class IssueCommentModel {
  final String id;
  final String issueLocalId;
  final String authorId;
  final String body;
  final int createdAt;
  final String? serverId;
  final int? serverCreatedAt;
  final String status;

  const IssueCommentModel({
    required this.id,
    required this.issueLocalId,
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.serverId,
    this.serverCreatedAt,
    required this.status,
  });

  /// Convert from JSON (server response).
  factory IssueCommentModel.fromJson(Map<String, dynamic> json) {
    return IssueCommentModel(
      id: json['id']?.toString() ?? '',
      issueLocalId: json['issue_local_id']?.toString() ?? json['issueLocalId']?.toString() ?? json['issue_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? json['authorId']?.toString() ?? '',
      body: json['body'] ?? json['content'] ?? '',
      createdAt:
          json['created_at'] ??
          json['createdAt'] ??
          DateTime.now().millisecondsSinceEpoch,
      serverId: json['server_id']?.toString() ?? json['serverId']?.toString() ?? json['id']?.toString(),
      serverCreatedAt: json['server_created_at'] ?? json['serverCreatedAt'],
      status: json['status'] ?? 'SYNCED',
    );
  }

  /// Convert to JSON (for API requests).
  Map<String, dynamic> toJson() {
    return {'body': body, 'author_id': authorId};
  }

  /// Convert from domain entity.
  factory IssueCommentModel.fromEntity(IssueCommentEntity entity) {
    return IssueCommentModel(
      id: entity.id,
      issueLocalId: entity.issueLocalId,
      authorId: entity.authorId,
      body: entity.body,
      createdAt: entity.createdAt,
      serverId: entity.serverId,
      serverCreatedAt: entity.serverCreatedAt,
      status: entity.status,
    );
  }

  /// Convert to domain entity.
  IssueCommentEntity toEntity() {
    return IssueCommentEntity(
      id: id,
      issueLocalId: issueLocalId,
      authorId: authorId,
      body: body,
      createdAt: createdAt,
      serverId: serverId,
      serverCreatedAt: serverCreatedAt,
      status: status,
    );
  }
}
