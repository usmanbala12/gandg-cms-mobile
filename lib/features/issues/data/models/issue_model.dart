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
  final String? dueDate;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;
  final String? meta;
  final String? issueNumber;
  final Map<String, dynamic>? author;
  final Map<String, dynamic>? assignee;
  final List<Map<String, dynamic>>? media;

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
    this.issueNumber,
    this.author,
    this.assignee,
    this.media,
  });

  /// Convert from JSON (server response).
  factory IssueModel.fromJson(Map<String, dynamic> json, {String? projectId}) {
    // Parse dates which could be ISO8601 strings or milliseconds
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

    // Helper to parse Map
    Map<String, dynamic>? parseMap(dynamic source) {
      if (source is Map) return Map<String, dynamic>.from(source);
      return null;
    }

    // Helper to parse List of Maps
    List<Map<String, dynamic>>? parseMedia(dynamic source) {
      if (source is List) {
        return source
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return null;
    }

    return IssueModel(
      id: json['id']?.toString() ?? '',
      projectId:
          projectId ??
          json['project_id']?.toString() ??
          json['projectId']?.toString() ??
          '',
      title: json['title'] ?? '',
      description: json['description'],
      priority: json['priority'],
      assigneeId:
          json['assignee_id']?.toString() ?? json['assigneeId']?.toString(),
      status: json['status'],
      category: json['category'],
      location: json['location'],
      dueDate: json['due_date']?.toString() ?? json['dueDate']?.toString(),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
      serverId:
          json['server_id']?.toString() ??
          json['serverId']?.toString() ??
          json['id']?.toString(),
      serverUpdatedAt: json['server_updated_at'] ?? json['serverUpdatedAt'],
      meta: json['meta']?.toString(),
      issueNumber: json['issueNumber']?.toString() ?? json['issue_number']?.toString(),
      author: parseMap(json['author']),
      assignee: parseMap(json['assignee']),
      media: parseMedia(json['media']),
    );
  }

  /// Convert to JSON (for API requests).
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (dueDate != null) 'dueDate': dueDate,
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
      issueNumber: entity.issueNumber,
      author: entity.author,
      assignee: entity.assignee,
      media: entity.media,
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
      issueNumber: issueNumber,
      author: author,
      assignee: assignee,
      media: media,
    );
  }
}
