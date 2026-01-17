import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_link/core/services/location_service.dart';
import 'package:field_link/features/reports/domain/entities/form_template_entity.dart';
import 'package:field_link/features/reports/domain/repositories/report_repository.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';

// State
abstract class ReportFormState extends Equatable {
  const ReportFormState();
  @override
  List<Object?> get props => [];
}

class ReportFormInitial extends ReportFormState {}

class ReportFormLoading extends ReportFormState {}

class ReportFormTemplatesLoaded extends ReportFormState {
  final List<FormTemplateEntity> templates;
  final FormTemplateEntity? selectedTemplate;
  final String projectId;

  const ReportFormTemplatesLoaded({
    required this.templates,
    required this.projectId,
    this.selectedTemplate,
  });

  ReportFormTemplatesLoaded copyWith({
    List<FormTemplateEntity>? templates,
    FormTemplateEntity? selectedTemplate,
    String? projectId,
  }) {
    return ReportFormTemplatesLoaded(
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      projectId: projectId ?? this.projectId,
    );
  }

  @override
  List<Object?> get props => [templates, selectedTemplate, projectId];
}

class ReportFormSubmitting extends ReportFormState {}

class ReportFormSuccess extends ReportFormState {
  final String reportId;
  const ReportFormSuccess(this.reportId);
  @override
  List<Object?> get props => [reportId];
}

class ReportFormError extends ReportFormState {
  final String message;
  const ReportFormError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ReportFormCubit extends Cubit<ReportFormState> {
  final ReportRepository _repository;
  final MediaRepository _mediaRepository;
  final LocationService _locationService;

  ReportFormCubit({
    required ReportRepository repository,
    required MediaRepository mediaRepository,
    required LocationService locationService,
  }) : _repository = repository,
       _mediaRepository = mediaRepository,
       _locationService = locationService,
       super(ReportFormInitial());

  Future<void> loadTemplates(String projectId, {bool forceRefresh = false}) async {
    emit(ReportFormLoading());
    try {
      final templates = await _repository.getTemplates(forceRefresh: forceRefresh);
      emit(ReportFormTemplatesLoaded(
        templates: templates,
        projectId: projectId,
      ));
    } catch (e) {
      emit(ReportFormError(e.toString()));
    }
  }

  void selectTemplate(FormTemplateEntity template) {
    if (state is ReportFormTemplatesLoaded) {
      final currentState = state as ReportFormTemplatesLoaded;
      emit(currentState.copyWith(selectedTemplate: template));
    }
  }

  Future<void> submitReport({
    required String projectId,
    required String templateId,
    required Map<String, dynamic> data,
  }) async {
    emit(ReportFormSubmitting());
    try {
      // 1. Extract media file paths from MEDIA fields and upload them
      final List<String> uploadedMediaIds = [];
      final processedData = Map<String, dynamic>.from(data);
      final fields = processedData['fields'] as Map<String, dynamic>? ?? {};
      
      for (final entry in fields.entries) {
        final fieldId = entry.key;
        final fieldData = entry.value as Map<String, dynamic>?;
        if (fieldData != null) {
          final fieldType = fieldData['fieldType']?.toString().toUpperCase();
          // Handle MEDIA_UPLOAD field type
          if (fieldType == 'MEDIA_UPLOAD') {
            final rawValue = fieldData['value'];
            List<dynamic> mediaPaths = [];
            if (rawValue is List) {
              mediaPaths = rawValue;
            } else if (rawValue is String && rawValue.isNotEmpty) {
              mediaPaths = [rawValue];
            }
            
            final List<String> fieldMediaIds = [];
            
            for (final path in mediaPaths) {
              if (path is String && path.isNotEmpty) {
                // Upload to PROJECT first with fieldId as metadata
                final media = await _mediaRepository.uploadMedia(
                  file: File(path),
                  parentType: 'PROJECT',
                  parentId: projectId,
                  metadata: {'fieldId': fieldId},
                );
                fieldMediaIds.add(media.id);
                uploadedMediaIds.add(media.id);
              }
            }
            
            // Replace file paths with media ID(s) in form data
            // Single file: store as string, multiple: store as list, empty: null
            if (fieldMediaIds.isEmpty) {
              fieldData['value'] = null;
            } else if (fieldMediaIds.length == 1) {
              fieldData['value'] = fieldMediaIds.first;
            } else {
              fieldData['value'] = fieldMediaIds;
            }
          }
        }
      }

      // 2. Capture current location
      final location = await _locationService.getCurrentLocation();

      // 3. Create report with inline mediaIds (replaces deprecated associateMedia)
      final reportId = await _repository.createReportWithData(
        projectId: projectId,
        templateId: templateId,
        submissionData: processedData,
        location: location,
        mediaIds: uploadedMediaIds.isNotEmpty ? uploadedMediaIds : null,
      );

      emit(ReportFormSuccess(reportId));
    } catch (e) {
      emit(ReportFormError(e.toString()));
    }
  }
}
