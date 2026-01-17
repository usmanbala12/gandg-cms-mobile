import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:field_link/core/presentation/widgets/status_badge.dart';
import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
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
      padding: const EdgeInsets.only(bottom: DesignSystem.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIssueHeader(context, issue),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
            child: Divider(height: DesignSystem.spacingXL),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
            child: Text(
              'Media',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MediaPicker(),
                const SizedBox(height: DesignSystem.spacingM),
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
                const SizedBox(height: DesignSystem.spacingM),
                if (issue.mediaIds != null && issue.mediaIds!.isNotEmpty)
                  MediaGallery(mediaIds: issue.mediaIds!)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: DesignSystem.spacingXL),
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
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: CustomCard(
        padding: const EdgeInsets.all(DesignSystem.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacingXS),
                      if (issue.author != null)
                        Text(
                          'By: ${issue.author?['firstName']} ${issue.author?['lastName'] ?? ''}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: DesignSystem.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusDropdown(context, issue),
              ],
            ),
            const SizedBox(height: DesignSystem.spacingM),
            if (issue.description != null) ...[
              Text(
                issue.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: DesignSystem.textPrimaryLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: DesignSystem.spacingM),
            ],
            Row(
              children: [
                _buildInfoTag(
                  context,
                  Icons.flag_outlined,
                  'Priority: ${issue.priority ?? 'Medium'}',
                  _getPriorityColor(issue.priority),
                ),
                const SizedBox(width: DesignSystem.spacingS),
                _buildInfoTag(
                  context,
                  Icons.calendar_today_outlined,
                  issue.dueDate ?? 'No due date',
                  DesignSystem.textSecondaryLight,
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacingM),
            const Divider(),
            const SizedBox(height: DesignSystem.spacingS),
            _buildAssigneeRow(context, issue),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingS,
        vertical: DesignSystem.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
      case 'URGENT':
      case 'CRITICAL':
        return DesignSystem.error;
      case 'MEDIUM':
        return DesignSystem.warning;
      case 'LOW':
        return DesignSystem.success;
      default:
        return DesignSystem.textSecondaryLight;
    }
  }

  Widget _buildAssigneeRow(BuildContext context, IssueEntity issue) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: const Icon(Icons.person, size: 14, color: DesignSystem.primary),
        ),
        const SizedBox(width: DesignSystem.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assignee',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: DesignSystem.textSecondaryLight,
                ),
              ),
              Text(
                issue.assignee != null 
                    ? "${issue.assignee!['firstName']} ${issue.assignee!['lastName'] ?? ''}" 
                    : (issue.assigneeId ?? 'Unassigned'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            _showAssignDialog(context, issue);
          },
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingS),
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingS),
      decoration: BoxDecoration(
        color: DesignSystem.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      ),
      child: DropdownButton<String>(
        value: issue.status,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: DesignSystem.primary),
        items: ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']
            .map(
              (status) => DropdownMenuItem(
                value: status,
                child: StatusBadge(status: status),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null && value != issue.status) {
            _updateStatus(value);
          }
        },
      ),
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
