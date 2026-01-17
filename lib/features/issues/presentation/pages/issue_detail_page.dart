import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:field_link/features/issues/domain/entities/issue_comment_entity.dart';
import 'package:field_link/features/issues/domain/entities/issue_entity.dart';
import 'package:field_link/features/issues/domain/repositories/issue_repository.dart';
import 'package:field_link/features/issues/presentation/widgets/issue_comment_tile.dart';
import 'package:field_link/features/media/presentation/widgets/media_gallery.dart';
import 'package:field_link/features/media/presentation/widgets/media_picker.dart';
import 'package:field_link/features/media/presentation/cubit/media_uploader_cubit.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IssueDetailPage extends StatefulWidget {
  final String issueId;

  const IssueDetailPage({super.key, required this.issueId});

  @override
  State<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  final _repository = GetIt.I<IssueRepository>();
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSendingComment = false;

  // TODO: Get actual current user ID
  final String _currentUserId = 'current_user_id';

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _repository.changeIssueStatus(
        widget.issueId,
        newStatus,
        // Optional: Prompt for comment when changing status
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingComment = true);

    try {
      await _repository.addComment(widget.issueId, text, _currentUserId, type: 'COMMENT');
      _commentController.clear();
      // Refetch comments manually since we are in remote-only mode
      setState(() {}); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding comment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Issue Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Collaboration'),
            ],
          ),
        ),
        body: BlocProvider(
          create: (context) => MediaUploaderCubit(
            repository: GetIt.I<MediaRepository>(),
          ),
          child: FutureBuilder<IssueEntity?>(
            future: _repository.getIssue(widget.issueId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final issue = snapshot.data;
              if (issue == null) {
                return const Center(child: Text('Issue not found'));
              }

              return TabBarView(
                children: [
                   _buildDetailsTab(context, issue),
                  _buildCollaborationTab(context, issue),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, IssueEntity issue) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIssueHeader(context, issue),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Media',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MediaPicker(),
                const SizedBox(height: 16),
                BlocBuilder<MediaUploaderCubit, MediaUploaderState>(
                  builder: (context, state) {
                    final isUploading = state is MediaUploaderInProcess && state.isUploading;
                    final hasSelected = state is MediaUploaderInProcess && state.selectedFiles.isNotEmpty;

                    if (hasSelected && !isUploading) {
                      return ElevatedButton.icon(
                        onPressed: () => context.read<MediaUploaderCubit>().uploadFiles(
                          parentType: 'ISSUE',
                          parentId: issue.id,
                        ),
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Selected'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                if (issue.mediaIds != null && issue.mediaIds!.isNotEmpty)
                  MediaGallery(mediaIds: issue.mediaIds!)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No media attached to this issue'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationTab(BuildContext context, IssueEntity issue) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<IssueCommentEntity>>(
            future: _repository.getComments(widget.issueId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final comments = (snapshot.data ?? []).reversed.toList();
              if (comments.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No comments yet'),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return IssueCommentTile(
                    comment: comment,
                    isCurrentUser: comment.authorId == _currentUserId,
                  );
                },
              );
            },
          ),
        ),
        _buildCommentInput(context),
      ],
    );
  }


  Widget _buildIssueHeader(BuildContext context, IssueEntity issue) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                _buildStatusDropdown(context, issue),
              ],
            ),
            const SizedBox(height: 4),
            if (issue.author != null)
              Text(
                'By: ${issue.author?['firstName']} ${issue.author?['lastName'] ?? ''}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            const SizedBox(height: 8),
            if (issue.description != null) ...[
              Text(issue.description!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(Icons.flag, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text('Priority: ${issue.priority ?? 'Medium'}'),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  issue.dueDate ?? 'No due date',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAssigneeRow(context, issue),
          ],
        ),
      ),
    );
  }

  Widget _buildAssigneeRow(BuildContext context, IssueEntity issue) {
    return Row(
      children: [
        const Icon(Icons.person, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          'Assignee: ${issue.assignee != null ? "${issue.assignee!['firstName']} ${issue.assignee!['lastName'] ?? ''}" : (issue.assigneeId ?? 'Unassigned')}',
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            _showAssignDialog(context, issue);
          },
          child: const Text('Change'),
        ),
      ],
    );
  }

  Future<void> _showAssignDialog(
    BuildContext context,
    IssueEntity issue,
  ) async {
    final controller = TextEditingController(text: issue.assigneeId);
    final assignee = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Issue'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Assignee ID',
            hintText: 'Enter user ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (assignee != null && assignee != issue.assigneeId) {
      try {
        await _repository.assignIssue(issue.id, assignee);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Assigned to $assignee')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error assigning issue: $e')));
        }
      }
    }
  }

  Widget _buildStatusDropdown(BuildContext context, IssueEntity issue) {
    return DropdownButton<String>(
      value: issue.status,
      underline: const SizedBox(),
      items: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(
                status.replaceAll('_', ' '),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null && value != issue.status) {
          _updateStatus(value);
        }
      },
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSendingComment ? null : _addComment,
              icon: _isSendingComment
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
