import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/form_template_entity.dart';
import '../../domain/repositories/report_repository.dart';

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
  final LocationService _locationService;

  ReportFormCubit({
    required ReportRepository repository,
    required LocationService locationService,
  }) : _repository = repository,
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
      // Capture current location
      final location = await _locationService.getCurrentLocation();

      final reportId = await _repository.createReportWithData(
        projectId: projectId,
        templateId: templateId,
        submissionData: data,
        location: location,
      );
      emit(ReportFormSuccess(reportId));
    } catch (e) {
      emit(ReportFormError(e.toString()));
    }
  }
}
