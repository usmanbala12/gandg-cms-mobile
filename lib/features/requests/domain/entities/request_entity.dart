import 'package:equatable/equatable.dart';

class RequestEntity extends Equatable {
  final String id;
  final String projectId;
  final String? requestNumber;
  final String? type; // FUNDS, MATERIALS, EQUIPMENT, OTHER, LEAVE
  final String title;
  final String? shortSummary;
  final String? description;
  final double? amount;
  final String? currency;
  final String? priority; // LOW, MEDIUM, HIGH, URGENT, CRITICAL
  final String status; // PENDING, APPROVED, REJECTED, CANCELLED
  final String? rejectionReason;
  final String createdBy;
  final String? assigneeId;
  final String? location;
  final int? dueDate;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;
  final Map<String, dynamic>? meta;

  const RequestEntity({
    required this.id,
    required this.projectId,
    this.requestNumber,
    this.type,
    required this.title,
    this.shortSummary,
    this.description,
    this.amount,
    this.currency,
    this.priority,
    required this.status,
    this.rejectionReason,
    required this.createdBy,
    this.assigneeId,
    this.location,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.serverUpdatedAt,
    this.meta,
  });

  RequestEntity copyWith({
    String? id,
    String? projectId,
    String? requestNumber,
    String? type,
    String? title,
    String? shortSummary,
    String? description,
    double? amount,
    String? currency,
    String? priority,
    String? status,
    String? rejectionReason,
    String? createdBy,
    String? assigneeId,
    String? location,
    int? dueDate,
    int? createdAt,
    int? updatedAt,
    String? serverId,
    int? serverUpdatedAt,
    Map<String, dynamic>? meta,
  }) {
    return RequestEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      requestNumber: requestNumber ?? this.requestNumber,
      type: type ?? this.type,
      title: title ?? this.title,
      shortSummary: shortSummary ?? this.shortSummary,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdBy: createdBy ?? this.createdBy,
      assigneeId: assigneeId ?? this.assigneeId,
      location: location ?? this.location,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        requestNumber,
        type,
        title,
        shortSummary,
        description,
        amount,
        currency,
        priority,
        status,
        rejectionReason,
        createdBy,
        assigneeId,
        location,
        dueDate,
        createdAt,
        updatedAt,
        serverId,
        serverUpdatedAt,
        meta,
      ];
}
