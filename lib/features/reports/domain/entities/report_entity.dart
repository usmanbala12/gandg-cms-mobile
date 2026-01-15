import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String id;
  final String projectId;
  final String? projectName;
  final String? formTemplateId;
  final String? formTemplateName;
  final String? reportNumber;
  final String? authorId;
  final String? authorName;
  final String reportDate; // Changed to String YYYY-MM-DD
  final Map<String, dynamic>? submissionData;
  final Map<String, dynamic>? location;
  final List<String>? mediaIds;
  final String status;
  final String createdAt; // Changed to String ISO8601
  final String updatedAt; // Changed to String ISO8601
  final String? serverId;

  const ReportEntity({
    required this.id,
    required this.projectId,
    this.projectName,
    this.formTemplateId,
    this.formTemplateName,
    this.reportNumber,
    this.authorId,
    this.authorName,
    required this.reportDate,
    this.submissionData,
    this.location,
    this.mediaIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    projectName,
    formTemplateId,
    formTemplateName,
    reportNumber,
    authorId,
    authorName,
    reportDate,
    submissionData,
    location,
    mediaIds,
    status,
    createdAt,
    updatedAt,
    serverId,
  ];

  ReportEntity copyWith({
    String? id,
    String? projectId,
    String? projectName,
    String? formTemplateId,
    String? formTemplateName,
    String? reportNumber,
    String? authorId,
    String? authorName,
    String? reportDate,
    Map<String, dynamic>? submissionData,
    Map<String, dynamic>? location,
    List<String>? mediaIds,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? serverId,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      formTemplateId: formTemplateId ?? this.formTemplateId,
      formTemplateName: formTemplateName ?? this.formTemplateName,
      reportNumber: reportNumber ?? this.reportNumber,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      reportDate: reportDate ?? this.reportDate,
      submissionData: submissionData ?? this.submissionData,
      location: location ?? this.location,
      mediaIds: mediaIds ?? this.mediaIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
    );
  }
}
