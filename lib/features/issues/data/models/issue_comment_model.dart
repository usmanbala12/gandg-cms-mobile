import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/issue_comment_entity.dart';

/// Data model for Issue Comment with converters between DB, JSON, and Entity.
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

  /// Convert from Drift database row to model.
  factory IssueCommentModel.fromDb(IssueComment dbRow) {
    return IssueCommentModel(
      id: dbRow.id,
      issueLocalId: dbRow.issueLocalId,
      authorId: dbRow.authorId,
      body: dbRow.body,
      createdAt: dbRow.createdAt,
      serverId: dbRow.serverId,
      serverCreatedAt: dbRow.serverCreatedAt,
      status: dbRow.status,
    );
  }

  /// Convert to Drift companion for insert/update.
  IssueCommentsCompanion toCompanion() {
    return IssueCommentsCompanion(
      id: Value(id),
      issueLocalId: Value(issueLocalId),
      authorId: Value(authorId),
      body: Value(body),
      createdAt: Value(createdAt),
      serverId: Value(serverId),
      serverCreatedAt: Value(serverCreatedAt),
      status: Value(status),
    );
  }

  /// Convert from JSON (server response).
  factory IssueCommentModel.fromJson(Map<String, dynamic> json) {
    return IssueCommentModel(
      id: json['id'] ?? '',
      issueLocalId: json['issue_local_id'] ?? json['issueLocalId'] ?? '',
      authorId: json['author_id'] ?? json['authorId'] ?? '',
      body: json['body'] ?? '',
      createdAt:
          json['created_at'] ??
          json['createdAt'] ??
          DateTime.now().millisecondsSinceEpoch,
      serverId: json['server_id'] ?? json['serverId'] ?? json['id'],
      serverCreatedAt: json['server_created_at'] ?? json['serverCreatedAt'],
      status: json['status'] ?? 'PENDING',
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
