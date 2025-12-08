import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/request_entity.dart';

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
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['local_id'] ?? json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      requestNumber: json['requestNumber'],
      type: json['type'],
      title: json['title'] ?? 'Request',
      shortSummary: json['shortSummary'],
      description: json['description'],
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'],
      priority: json['priority'],
      status: json['status'] ?? 'PENDING',
      rejectionReason: json['rejectionReason'],
      createdBy: json['created_by'] ?? json['requester']?['id'] ?? '',
      assigneeId: json['assignee_id'],
      location: json['location'],
      dueDate: json['dueDate'] is int
          ? json['dueDate']
          : DateTime.tryParse(json['dueDate'] ?? '')?.millisecondsSinceEpoch,
      createdAt: json['created_at'] is int
          ? json['created_at']
          : DateTime.tryParse(json['created_at'] ?? '')
                  ?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updated_at'] is int
          ? json['updated_at']
          : DateTime.tryParse(json['updated_at'] ?? '')
                  ?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
      serverId: json['id'], // Assuming 'id' from API is server ID
      serverUpdatedAt: json['updated_at'] is int
          ? json['updated_at']
          : DateTime.tryParse(json['updated_at'] ?? '')?.millisecondsSinceEpoch,
      meta: json['metadata'] != null && json['metadata'] is String
          ? jsonDecode(json['metadata'])
          : (json['metadata'] is Map ? json['metadata'] : null),
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
      // Amount/Currency/RequestNumber not in DB table yet?
      // Checking table definition:
      // TextColumn get requestType => text().nullable()();
      // TextColumn get title => text()();
      // TextColumn get shortSummary => text().nullable()();
      // TextColumn get location => text().nullable()();
      // IntColumn get dueDate => integer().nullable()();
      amount: null, // TODO: Extract from meta if stored there
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
