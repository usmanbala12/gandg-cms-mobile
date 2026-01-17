import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:field_link/features/issues/domain/repositories/issue_repository.dart';
import 'package:field_link/features/media/presentation/widgets/media_picker.dart';
import 'package:field_link/features/media/presentation/cubit/media_uploader_cubit.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IssueCreatePage extends StatefulWidget {
  final String projectId;

  const IssueCreatePage({super.key, required this.projectId});

  @override
  State<IssueCreatePage> createState() => _IssueCreatePageState();
}

class _IssueCreatePageState extends State<IssueCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  String _priority = 'MEDIUM';
  DateTime? _dueDate;
  bool _isSubmitting = false;

  final _repository = GetIt.I<IssueRepository>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final mediaCubit = context.read<MediaUploaderCubit>();
      
      // 1. Upload media to project
      await mediaCubit.uploadFiles(
        parentType: 'PROJECT',
        parentId: widget.projectId,
      );

      final mediaState = mediaCubit.state;
      List<String> mediaIds = [];
      if (mediaState is MediaUploaderInProcess) {
        mediaIds = mediaState.uploadedMedia.map((m) => m.id).toList();
      }

      // 2. Create issue with inline mediaIds (replaces deprecated associateMedia)
      await _repository.createIssue(
        projectId: widget.projectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        dueDate: _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : null,
        mediaIds: mediaIds.isNotEmpty ? mediaIds : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Issue created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating issue: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MediaUploaderCubit(
        repository: GetIt.I<MediaRepository>(),
      ),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Issue'),
        actions: [
          Builder(
            builder: (context) => TextButton(
              onPressed: _isSubmitting ? null : () => _submit(context),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter issue title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter issue description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'LOW', child: Text('Low')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                DropdownMenuItem(value: 'HIGH', child: Text('High')),
                DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (Optional)',
                hintText: 'e.g., Electrical, Plumbing',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(
                _dueDate == null
                    ? 'No date selected'
                    : DateFormat.yMMMd().format(_dueDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _dueDate = date);
                }
              },
            ),
            const Divider(height: 32),
            const MediaPicker(),
          ],
        ),
      ),
    );
  }
}
