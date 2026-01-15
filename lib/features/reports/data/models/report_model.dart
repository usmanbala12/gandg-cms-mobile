import 'dart:convert';

import '../../domain/entities/report_entity.dart';

/// Simplified ReportModel - remote only, no local DB dependencies.
class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.projectId,
    super.projectName,
    super.formTemplateId,
    super.formTemplateName,
    super.reportNumber,
    super.authorId,
    super.authorName,
    required super.reportDate,
    super.submissionData,
    super.location,
    super.mediaIds,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.serverId,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? json['project_id']?.toString() ?? '',
      projectName: json['projectName']?.toString(),
      formTemplateId: json['formTemplateId']?.toString() ?? json['form_template_id']?.toString(),
      formTemplateName: json['formTemplateName']?.toString(),
      reportNumber: json['reportNumber']?.toString() ?? json['report_number']?.toString(),
      authorId: json['authorId']?.toString() ?? json['author_id']?.toString(),
      authorName: json['authorName']?.toString() ?? json['author_name']?.toString(),
      reportDate: json['reportDate']?.toString() ?? json['report_date']?.toString() ?? '',
      submissionData: json['submissionData'] != null
          ? (json['submissionData'] is Map 
              ? json['submissionData'] as Map<String, dynamic>
              : json['submissionData'] is String
                  ? jsonDecode(json['submissionData']) as Map<String, dynamic>
                  : null)
          : (json['submission_data'] is Map 
              ? json['submission_data'] as Map<String, dynamic>
              : json['submission_data'] is String
                  ? jsonDecode(json['submission_data']) as Map<String, dynamic>
                  : null),
      location: json['location'] != null
          ? (json['location'] is Map 
              ? json['location'] as Map<String, dynamic>
              : null)
          : null,
      mediaIds: json['mediaIds'] != null
          ? List<String>.from(json['mediaIds'] as List)
          : (json['media_ids'] != null 
              ? List<String>.from(json['media_ids'] as List)
              : null),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      serverId: json['serverId']?.toString() ?? json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'formTemplateId': formTemplateId,
      'formTemplateName': formTemplateName,
      'reportNumber': reportNumber,
      'authorId': authorId,
      'authorName': authorName,
      'reportDate': reportDate,
      'submissionData': submissionData,
      'location': location,
      'mediaIds': mediaIds,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ReportModel.fromEntity(ReportEntity entity) {
    return ReportModel(
      id: entity.id,
      projectId: entity.projectId,
      projectName: entity.projectName,
      formTemplateId: entity.formTemplateId,
      formTemplateName: entity.formTemplateName,
      reportNumber: entity.reportNumber,
      authorId: entity.authorId,
      authorName: entity.authorName,
      reportDate: entity.reportDate,
      submissionData: entity.submissionData,
      location: entity.location,
      mediaIds: entity.mediaIds,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      serverId: entity.serverId,
    );
  }
}
