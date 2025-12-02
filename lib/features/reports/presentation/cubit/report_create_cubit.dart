import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../widgets/template_selector.dart';
import '../../../../core/db/repositories/report_repository.dart';
import '../../../../features/dashboard/data/repositories/dashboard_repository_impl.dart';

// States
abstract class ReportCreateState extends Equatable {
  const ReportCreateState();

  @override
  List<Object?> get props => [];
}

class ReportCreateInitial extends ReportCreateState {}

class ReportCreateLoading extends ReportCreateState {}

class ReportCreateNoProject extends ReportCreateState {}

class ReportCreateTemplatesLoaded extends ReportCreateState {
  final List<FormTemplate> templates;
  final FormTemplate? selectedTemplate;
  final String projectId;

  const ReportCreateTemplatesLoaded({
    required this.templates,
    this.selectedTemplate,
    required this.projectId,
  });

  @override
  List<Object?> get props => [templates, selectedTemplate, projectId];

  ReportCreateTemplatesLoaded copyWith({
    List<FormTemplate>? templates,
    FormTemplate? selectedTemplate,
    String? projectId,
  }) {
    return ReportCreateTemplatesLoaded(
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      projectId: projectId ?? this.projectId,
    );
  }
}

class ReportCreateSubmitting extends ReportCreateState {
  final String projectId;
  final FormTemplate template;

  const ReportCreateSubmitting({
    required this.projectId,
    required this.template,
  });

  @override
  List<Object?> get props => [projectId, template];
}

class ReportCreateSuccess extends ReportCreateState {
  final String reportId;

  const ReportCreateSuccess(this.reportId);

  @override
  List<Object?> get props => [reportId];
}

class ReportCreateError extends ReportCreateState {
  final String message;
  final List<FormTemplate>? templates;
  final FormTemplate? selectedTemplate;
  final String? projectId;

  const ReportCreateError({
    required this.message,
    this.templates,
    this.selectedTemplate,
    this.projectId,
  });

  @override
  List<Object?> get props => [message, templates, selectedTemplate, projectId];
}

// Cubit
class ReportCreateCubit extends Cubit<ReportCreateState> {
  final ReportRepository _reportRepository;
  final DashboardRepository _dashboardRepository;

  ReportCreateCubit({
    required ReportRepository reportRepository,
    required DashboardRepository dashboardRepository,
  }) : _reportRepository = reportRepository,
       _dashboardRepository = dashboardRepository,
       super(ReportCreateInitial());

  Future<void> init({bool forceRefresh = false}) async {
    emit(ReportCreateLoading());

    try {
      print('🔍 Initializing report create page...');

      // Get active project ID from dashboard
      final projectId = await _dashboardRepository.getActiveProjectId();
      print('📍 Active project ID: $projectId');

      if (projectId == null) {
        print('⚠️ No active project selected');
        emit(ReportCreateNoProject());
        return;
      }

      // Fetch templates
      print('📋 Fetching templates (forceRefresh: $forceRefresh)...');
      final templatesJson = await _reportRepository.getTemplates(
        forceRefresh: forceRefresh,
      );

      final templates = templatesJson
          .map((json) => FormTemplate.fromJson(json))
          .toList();

      print('✅ Loaded ${templates.length} templates');

      emit(
        ReportCreateTemplatesLoaded(templates: templates, projectId: projectId),
      );
    } catch (e, stackTrace) {
      print('❌ Error initializing: $e');
      print('Stack trace: $stackTrace');
      emit(ReportCreateError(message: 'Failed to load templates: $e'));
    }
  }

  void selectTemplate(FormTemplate template) {
    final currentState = state;
    if (currentState is ReportCreateTemplatesLoaded) {
      print('📝 Template selected: ${template.name}');
      emit(currentState.copyWith(selectedTemplate: template));
    }
  }

  Future<void> submit(Map<String, dynamic> formData) async {
    final currentState = state;
    if (currentState is! ReportCreateTemplatesLoaded ||
        currentState.selectedTemplate == null) {
      emit(const ReportCreateError(message: 'No template selected'));
      return;
    }

    emit(
      ReportCreateSubmitting(
        projectId: currentState.projectId,
        template: currentState.selectedTemplate!,
      ),
    );

    try {
      print('📤 Submitting report...');
      print('Project ID: ${currentState.projectId}');
      print('Template ID: ${currentState.selectedTemplate!.id}');
      print('Form data: $formData');

      final reportId = await _reportRepository.createReportWithData(
        projectId: currentState.projectId,
        templateId: currentState.selectedTemplate!.id,
        submissionData: formData,
      );

      print('✅ Report created successfully: $reportId');
      emit(ReportCreateSuccess(reportId));
    } catch (e, stackTrace) {
      print('❌ Error submitting report: $e');
      print('Stack trace: $stackTrace');

      // Return to loaded state with error
      emit(
        ReportCreateError(
          message: 'Failed to create report: $e',
          templates: currentState.templates,
          selectedTemplate: currentState.selectedTemplate,
          projectId: currentState.projectId,
        ),
      );
    }
  }

  void retry() {
    init();
  }
}
