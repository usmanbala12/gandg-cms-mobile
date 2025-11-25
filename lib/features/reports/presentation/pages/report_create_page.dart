import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/repositories/report_repository.dart';
import '../../domain/entities/report_entity.dart';
import '../widgets/media_picker_widget.dart';
import '../../../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../../../core/db/app_database.dart';

class ReportCreatePage extends StatefulWidget {
  final String? projectId;

  const ReportCreatePage({super.key, this.projectId});

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  late final ReportRepository _repository;
  late final DashboardRepository _dashboardRepository;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _templates = [];
  List<Project> _projects = [];
  String? _selectedTemplateId;
  String? _selectedProjectId;
  bool _isLoading = false;

  // Form fields
  final Map<String, dynamic> _submissionData = {};
  final List<String> _attachedMediaPaths = [];

  @override
  void initState() {
    super.initState();
    _repository = GetIt.instance<ReportRepository>();
    _dashboardRepository = GetIt.instance<DashboardRepository>();
    _selectedProjectId = widget.projectId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final templates = await _repository.getTemplates();
      if (widget.projectId == null) {
        final projects = await _dashboardRepository.getProjects();
        setState(() {
          _projects = projects;
        });
      }
      setState(() {
        _templates = templates;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a project')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reportId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      final report = ReportEntity(
        id: reportId,
        projectId: _selectedProjectId!,
        formTemplateId: _selectedTemplateId,
        reportDate: now,
        submissionData: _submissionData,
        status: 'PENDING',
        createdAt: now,
        updatedAt: now,
      );

      await _repository.createReport(report);

      // Attach media
      for (final path in _attachedMediaPaths) {
        await _repository.attachMedia(path, reportId);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating report: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (widget.projectId == null) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedProjectId,
                      items: _projects.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a project' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Template',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTemplateId,
                    items: _templates.map((t) {
                      return DropdownMenuItem<String>(
                        value: t['id'] as String,
                        child: Text(t['name'] ?? 'Unknown Template'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTemplateId = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a template' : null,
                  ),
                  const SizedBox(height: 16),

                  // Dynamic fields based on template could go here.
                  // For now, we use generic fields.
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _submissionData['title'] = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (value) => _submissionData['description'] = value,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Attachments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  MediaPickerWidget(
                    onMediaSelected: (path) {
                      setState(() {
                        _attachedMediaPaths.add(path);
                      });
                    },
                    currentMediaCount: _attachedMediaPaths.length,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachedMediaPaths.map((path) {
                      return Stack(
                        children: [
                          Image.file(
                            File(path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _attachedMediaPaths.remove(path);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit Report'),
                  ),
                ],
              ),
            ),
    );
  }
}
