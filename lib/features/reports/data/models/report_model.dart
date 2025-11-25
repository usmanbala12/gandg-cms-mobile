import 'dart:convert';

import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.projectId,
    super.formTemplateId,
    required super.reportDate,
    super.submissionData,
    super.location,
    super.mediaIds,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.serverId,
    super.serverUpdatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      formTemplateId: json['form_template_id'] as String?,
      reportDate: json['report_date'] as int,
      submissionData: json['submission_data'] != null
          ? json['submission_data'] as Map<String, dynamic>
          : null,
      location: json['location'] != null
          ? json['location'] as Map<String, dynamic>
          : null,
      mediaIds: json['media_ids'] != null
          ? List<String>.from(json['media_ids'] as List)
          : null,
      status: json['status'] as String? ?? 'SYNCED',
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
      serverId: json['server_id'] as String?,
      serverUpdatedAt: json['server_updated_at'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'form_template_id': formTemplateId,
      'report_date': reportDate,
      'submission_data': submissionData,
      'location': location,
      'media_ids': mediaIds,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'server_id': serverId,
      'server_updated_at': serverUpdatedAt,
    };
  }

  factory ReportModel.fromEntity(ReportEntity entity) {
    return ReportModel(
      id: entity.id,
      projectId: entity.projectId,
      formTemplateId: entity.formTemplateId,
      reportDate: entity.reportDate,
      submissionData: entity.submissionData,
      location: entity.location,
      mediaIds: entity.mediaIds,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      serverId: entity.serverId,
      serverUpdatedAt: entity.serverUpdatedAt,
    );
  }

  factory ReportModel.fromDb(Report row) {
    return ReportModel(
      id: row.id,
      projectId: row.projectId,
      formTemplateId: row.formTemplateId,
      reportDate: row.reportDate,
      submissionData: row.submissionData != null
          ? jsonDecode(row.submissionData!) as Map<String, dynamic>
          : null,
      location: row.location != null
          ? jsonDecode(row.location!) as Map<String, dynamic>
          : null,
      mediaIds: row.mediaIds != null
          ? List<String>.from(jsonDecode(row.mediaIds!) as List)
          : null,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      serverId: row.serverId,
      serverUpdatedAt: row.serverUpdatedAt,
    );
  }

  ReportsCompanion toCompanion() {
    return ReportsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      formTemplateId: Value(formTemplateId),
      reportDate: Value(reportDate),
      submissionData: Value(
        submissionData != null ? jsonEncode(submissionData) : null,
      ),
      location: Value(location != null ? jsonEncode(location) : null),
      mediaIds: Value(mediaIds != null ? jsonEncode(mediaIds) : null),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: Value(serverId),
      serverUpdatedAt: Value(serverUpdatedAt),
    );
  }
}
