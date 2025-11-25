import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String id;
  final String projectId;
  final String? formTemplateId;
  final int reportDate;
  final Map<String, dynamic>? submissionData;
  final Map<String, dynamic>? location;
  final List<String>? mediaIds;
  final String status;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;

  const ReportEntity({
    required this.id,
    required this.projectId,
    this.formTemplateId,
    required this.reportDate,
    this.submissionData,
    this.location,
    this.mediaIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.serverUpdatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    formTemplateId,
    reportDate,
    submissionData,
    location,
    mediaIds,
    status,
    createdAt,
    updatedAt,
    serverId,
    serverUpdatedAt,
  ];

  ReportEntity copyWith({
    String? id,
    String? projectId,
    String? formTemplateId,
    int? reportDate,
    Map<String, dynamic>? submissionData,
    Map<String, dynamic>? location,
    List<String>? mediaIds,
    String? status,
    int? createdAt,
    int? updatedAt,
    String? serverId,
    int? serverUpdatedAt,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      formTemplateId: formTemplateId ?? this.formTemplateId,
      reportDate: reportDate ?? this.reportDate,
      submissionData: submissionData ?? this.submissionData,
      location: location ?? this.location,
      mediaIds: mediaIds ?? this.mediaIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    );
  }
}
