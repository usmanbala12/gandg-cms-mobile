import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:field_link/core/services/location_service.dart';
import 'package:field_link/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:field_link/features/reports/presentation/widgets/template_selector.dart';
import 'package:field_link/features/reports/presentation/widgets/dynamic_form.dart';
import 'package:field_link/features/reports/domain/repositories/report_repository.dart';
import 'package:field_link/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';

class ReportCreatePage extends StatelessWidget {
  const ReportCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: GetIt.instance<DashboardRepository>().getActiveProjectId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final projectId = snapshot.data ?? '';

        return BlocProvider(
          create: (context) => ReportFormCubit(
            repository: GetIt.instance<ReportRepository>(),
            mediaRepository: GetIt.instance<MediaRepository>(),
            locationService: GetIt.instance<LocationService>(),
          )..loadTemplates(projectId),
          child: const _ReportCreateView(),
        );
      },
    );
  }
}

class _ReportCreateView extends StatelessWidget {
  const _ReportCreateView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Report')),
      body: BlocConsumer<ReportFormCubit, ReportFormState>(
        listener: (context, state) {
          if (state is ReportFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report created successfully: ${state.reportId}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ReportFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportFormTemplatesLoaded) {
            if (state.selectedTemplate == null) {
              return TemplateSelector(
                templates: state.templates,
                selectedTemplate: state.selectedTemplate,
                onSelected: (template) {
                  context.read<ReportFormCubit>().selectTemplate(template);
                },
              );
            } else {
              return DynamicForm(
                template: state.selectedTemplate!,
                onSubmit: (formData) {
                  // Submit report - media paths are already in formData from MEDIA fields
                  context.read<ReportFormCubit>().submitReport(
                    projectId: state.projectId,
                    templateId: state.selectedTemplate!.id,
                    data: formData,
                  );
                },
                onCancel: () {
                  // Reload specific project templates or jus deselect
                  // Since we don't have deselect in cubit easily without reload or explicit method
                  // For now, simpler to reload
                  context.read<ReportFormCubit>().loadTemplates(state.projectId);
                },
              );
            }
          }

          if (state is ReportFormSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('Initialize...'));
        },
      ),
    );
  }
}
