import '../../domain/entities/issue_comment_entity.dart';

/// Data model for Issue Comment with converters between JSON and Entity.
/// Simplified to remove database dependencies (remote-only mode).
class IssueCommentModel {
  final String id;
  final String issueLocalId;
  final String authorId;
  final String content;
  final String? type;
  final Map<String, dynamic>? author;
  final int createdAt;
  final String? serverId;
  final int? serverCreatedAt;
  final String status;

  const IssueCommentModel({
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

  /// Convert from JSON (server response).
  factory IssueCommentModel.fromJson(Map<String, dynamic> json) {
    // Parse date
    int parseDate(dynamic date) {
      if (date == null) return DateTime.now().millisecondsSinceEpoch;
      if (date is int) return date;
      if (date is String) {
        try {
          return DateTime.parse(date).millisecondsSinceEpoch;
        } catch (_) {
          return DateTime.now().millisecondsSinceEpoch;
        }
      }
      return DateTime.now().millisecondsSinceEpoch;
    }

    return IssueCommentModel(
      id: json['id']?.toString() ?? '',
      issueLocalId: json['issue_local_id']?.toString() ??
          json['issueLocalId']?.toString() ??
          json['issue_id']?.toString() ??
          '',
      authorId:
          json['author_id']?.toString() ?? json['authorId']?.toString() ?? '',
      content: json['content'] ?? json['body'] ?? '',
      type: json['type']?.toString(),
      author: json['author'] is Map ? Map<String, dynamic>.from(json['author']) : null,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      serverId: json['server_id']?.toString() ??
          json['serverId']?.toString() ??
          json['id']?.toString(),
      serverUpdatedAt: json['server_updated_at'] ?? json['serverUpdatedAt'],
      status: json['status'] ?? 'SYNCED',
    );
  }

  /// Convert to JSON (for API requests).
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (type != null) 'type': type,
    };
  }

  /// Convert from domain entity.
  factory IssueCommentModel.fromEntity(IssueCommentEntity entity) {
    return IssueCommentModel(
      id: entity.id,
      issueLocalId: entity.issueLocalId,
      authorId: entity.authorId,
      content: entity.content,
      type: entity.type,
      author: entity.author,
      createdAt: entity.createdAt,
      serverId: entity.serverId,
      serverUpdatedAt: entity.serverUpdatedAt,
      status: entity.status,
    );
  }

  /// Convert to domain entity.
  IssueCommentEntity toEntity() {
    return IssueCommentEntity(
      id: id,
      issueLocalId: issueLocalId,
      authorId: authorId,
      content: content,
      type: type,
      author: author,
      createdAt: createdAt,
      serverId: serverId,
      serverUpdatedAt: serverUpdatedAt,
      status: status,
    );
  }
}
