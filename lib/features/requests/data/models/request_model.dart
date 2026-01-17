import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/approval_step_entity.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/entities/request_line_item_entity.dart';
import 'approval_step_model.dart';
import 'request_line_item_model.dart';

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.projectId,
    super.requestNumber,
    super.type,
    required super.title,
    super.shortSummary,
    super.description,
    super.amount,
    super.currency,
    super.priority,
    required super.status,
    super.rejectionReason,
    required super.createdBy,
    super.assigneeId,
    super.location,
    super.dueDate,
    required super.createdAt,
    required super.updatedAt,
    super.serverId,
    super.serverUpdatedAt,
    super.meta,
    // Workflow
    super.workflowVersion,
    super.approvalDeadline,
    super.completedAt,
    super.approvalSteps,
    super.currentStepOrder,
    // Requester
    super.requesterFirstName,
    super.requesterLastName,
    super.requesterEmail,
    // Line items
    super.lineItems,
  });

  /// Safely truncate description to 50 chars for title
  static String _truncateDescription(dynamic description) {
    if (description == null) return 'Request';
    final str = description.toString();
    if (str.length <= 50) return str;
    return '${str.substring(0, 47)}...';
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    // Parse requester info
    final requester = json['requester'] as Map<String, dynamic>?;

    // Parse approval steps
    List<ApprovalStepEntity>? approvalSteps;
    if (json['approvalSteps'] is List) {
      approvalSteps = (json['approvalSteps'] as List)
          .map((step) => ApprovalStepModel.fromJson(step as Map<String, dynamic>))
          .toList();
    }

    // Parse line items
    List<RequestLineItemEntity>? lineItems;
    if (json['lineItems'] is List) {
      lineItems = (json['lineItems'] as List)
          .map((item) => RequestLineItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return RequestModel(
      id: json['local_id'] ?? json['id'] ?? '',
      projectId: json['project_id'] ?? json['projectId'] ?? '',
      requestNumber: json['requestNumber'] as String?,
      type: json['type'] as String?,
      title: json['title'] ?? _truncateDescription(json['description']),
      shortSummary: json['shortSummary'] as String?,
      description: json['description'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      createdBy: json['created_by'] ?? requester?['id'] ?? '',
      assigneeId: json['assignee_id'] as String?,
      location: json['location'] as String?,
      dueDate: json['dueDate'] is int
          ? json['dueDate']
          : DateTime.tryParse(json['dueDate'] ?? '')?.millisecondsSinceEpoch,
      createdAt: json['created_at'] is int
          ? json['created_at']
          : DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '')
                  ?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updated_at'] is int
          ? json['updated_at']
          : DateTime.tryParse(json['updatedAt'] ?? json['updated_at'] ?? '')
                  ?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
      serverId: json['id'] as String?,
      serverUpdatedAt: json['updated_at'] is int
          ? json['updated_at']
          : DateTime.tryParse(json['updated_at'] ?? '')?.millisecondsSinceEpoch,
      meta: json['metadata'] != null && json['metadata'] is String
          ? jsonDecode(json['metadata'])
          : (json['metadata'] is Map ? json['metadata'] : null),
      // Workflow
      workflowVersion: json['workflowVersion'] as int?,
      approvalDeadline: json['approvalDeadline'] != null
          ? DateTime.tryParse(json['approvalDeadline'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      approvalSteps: approvalSteps,
      currentStepOrder: json['currentStepOrder'] as int?,
      // Requester
      requesterFirstName: requester?['firstName'] as String?,
      requesterLastName: requester?['lastName'] as String?,
      requesterEmail: requester?['email'] as String?,
      // Line items
      lineItems: lineItems,
    );
  }

  factory RequestModel.fromDb(Request row) {
    return RequestModel(
      id: row.id,
      projectId: row.projectId,
      type: row.requestType,
      title: row.title,
      shortSummary: row.shortSummary,
      description: row.description,
      amount: null, // Not in DB table
      currency: null,
      priority: row.priority,
      status: row.status,
      createdBy: row.createdBy,
      assigneeId: row.assigneeId,
      location: row.location,
      dueDate: row.dueDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      serverId: row.serverId,
      serverUpdatedAt: row.serverUpdatedAt,
      meta: row.meta != null ? jsonDecode(row.meta!) : null,
    );
  }

  factory RequestModel.fromEntity(RequestEntity entity) {
    return RequestModel(
      id: entity.id,
      projectId: entity.projectId,
      requestNumber: entity.requestNumber,
      type: entity.type,
      title: entity.title,
      shortSummary: entity.shortSummary,
      description: entity.description,
      amount: entity.amount,
      currency: entity.currency,
      priority: entity.priority,
      status: entity.status,
      rejectionReason: entity.rejectionReason,
      createdBy: entity.createdBy,
      assigneeId: entity.assigneeId,
      location: entity.location,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      serverId: entity.serverId,
      serverUpdatedAt: entity.serverUpdatedAt,
      meta: entity.meta,
      approvalDeadline: entity.approvalDeadline,
      completedAt: entity.completedAt,
      approvalSteps: entity.approvalSteps,
      currentStepOrder: entity.currentStepOrder,
      requesterFirstName: entity.requesterFirstName,
      requesterLastName: entity.requesterLastName,
      requesterEmail: entity.requesterEmail,
      lineItems: entity.lineItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'local_id': id,
      'project_id': projectId,
      'requestNumber': requestNumber,
      'type': type,
      'title': title,
      'shortSummary': shortSummary,
      'description': description,
      'amount': amount,
      'currency': currency,
      'priority': priority,
      'status': status,
      'rejectionReason': rejectionReason,
      'created_by': createdBy,
      'assignee_id': assigneeId,
      'location': location,
      'dueDate': dueDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'metadata': meta,
    };
  }

  /// Create payload for API request
  Map<String, dynamic> toCreatePayload({bool isDraft = false}) {
    return {
      'type': type,
      'description': description,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (priority != null) 'priority': priority,
      'isDraft': isDraft,
    };
  }

  RequestsCompanion toCompanion() {
    return RequestsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      requestType: Value(type),
      title: Value(title),
      shortSummary: Value(shortSummary),
      description: Value(description),
      status: Value(status),
      createdBy: Value(createdBy),
      assigneeId: Value(assigneeId),
      priority: Value(priority),
      location: Value(location),
      dueDate: Value(dueDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: Value(serverId),
      serverUpdatedAt: Value(serverUpdatedAt),
      meta: Value(meta != null ? jsonEncode(meta) : null),
    );
  }
}
