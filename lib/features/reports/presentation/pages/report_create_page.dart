import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../cubit/report_create_cubit.dart';
import '../widgets/template_selector.dart';
import '../widgets/dynamic_form.dart';
import '../../../../core/db/repositories/report_repository.dart';
import '../../../../features/dashboard/data/repositories/dashboard_repository_impl.dart';

class ReportCreatePage extends StatelessWidget {
  const ReportCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportCreateCubit(
        reportRepository: GetIt.instance<ReportRepository>(),
        dashboardRepository: GetIt.instance<DashboardRepository>(),
      )..init(),
      child: const _ReportCreateView(),
    );
  }
}

class _ReportCreateView extends StatelessWidget {
  const _ReportCreateView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Report')),
      body: BlocConsumer<ReportCreateCubit, ReportCreateState>(
        listener: (context, state) {
          if (state is ReportCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report created successfully: ${state.reportId}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ReportCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ReportCreateCubit>().retry();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportCreateInitial || state is ReportCreateLoading) {
            return const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading'),
            );
          }

          if (state is ReportCreateNoProject) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'No Project Selected',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please select a project from the Dashboard before creating a report.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.dashboard),
                      label: const Text('Go to Dashboard'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ReportCreateTemplatesLoaded) {
            if (state.selectedTemplate == null) {
              // Show template selector
              return TemplateSelector(
                templates: state.templates,
                selectedTemplate: state.selectedTemplate,
                onSelected: (template) {
                  context.read<ReportCreateCubit>().selectTemplate(template);
                },
              );
            } else {
              // Show dynamic form
              return DynamicForm(
                template: state.selectedTemplate!,
                onSubmit: (formData) {
                  context.read<ReportCreateCubit>().submit(formData);
                },
                onCancel: () {
                  // Deselect template to go back to selector
                  context.read<ReportCreateCubit>().init();
                },
              );
            }
          }

          if (state is ReportCreateSubmitting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Submitting ${state.template.name}...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (state is ReportCreateError) {
            // Show error with option to retry
            if (state.templates != null && state.selectedTemplate == null) {
              // Error during template loading, show selector with error
              return Column(
                children: [
                  Container(
                    color: Colors.red.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TemplateSelector(
                      templates: state.templates!,
                      selectedTemplate: state.selectedTemplate,
                      onSelected: (template) {
                        context.read<ReportCreateCubit>().selectTemplate(
                          template,
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state.selectedTemplate != null) {
              // Error during submission, show form with error
              return Column(
                children: [
                  Container(
                    color: Colors.red.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: DynamicForm(
                      template: state.selectedTemplate!,
                      onSubmit: (formData) {
                        context.read<ReportCreateCubit>().submit(formData);
                      },
                      onCancel: () {
                        context.read<ReportCreateCubit>().init();
                      },
                    ),
                  ),
                ],
              );
            }
          }

          // Fallback
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReportCreateCubit>().retry();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
