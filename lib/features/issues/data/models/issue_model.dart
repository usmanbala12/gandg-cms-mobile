import '../../domain/entities/issue_entity.dart';

/// Data model for Issue with converters between JSON and Entity.
/// Simplified to remove database dependencies (remote-only mode).
class IssueModel {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String? priority;
  final String? assigneeId;
  final String? status;
  final String? category;
  final String? location;
  final int? dueDate;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;
  final String? meta;

  const IssueModel({
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
  });

  /// Convert from JSON (server response).
  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? json['projectId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'],
      assigneeId: json['assignee_id']?.toString() ?? json['assigneeId']?.toString(),
      status: json['status'],
      category: json['category'],
      location: json['location'],
      dueDate: json['due_date'] ?? json['dueDate'],
      createdAt:
          json['created_at'] ??
          json['createdAt'] ??
          DateTime.now().millisecondsSinceEpoch,
      updatedAt:
          json['updated_at'] ??
          json['updatedAt'] ??
          DateTime.now().millisecondsSinceEpoch,
      serverId: json['server_id']?.toString() ?? json['serverId']?.toString() ?? json['id']?.toString(),
      serverUpdatedAt: json['server_updated_at'] ?? json['serverUpdatedAt'],
      meta: json['meta'],
    );
  }

  /// Convert to JSON (for API requests).
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (dueDate != null) 'due_date': dueDate,
      if (meta != null) 'meta': meta,
    };
  }

  /// Convert from domain entity.
  factory IssueModel.fromEntity(IssueEntity entity) {
    return IssueModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      priority: entity.priority,
      assigneeId: entity.assigneeId,
      status: entity.status,
      category: entity.category,
      location: entity.location,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      serverId: entity.serverId,
      serverUpdatedAt: entity.serverUpdatedAt,
      meta: entity.meta,
    );
  }

  /// Convert to domain entity.
  IssueEntity toEntity() {
    return IssueEntity(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      priority: priority,
      assigneeId: assigneeId,
      status: status,
      category: category,
      location: location,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      serverId: serverId,
      serverUpdatedAt: serverUpdatedAt,
      meta: meta,
    );
  }
}
