import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:field_link/core/presentation/widgets/status_badge.dart';
import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:field_link/features/issues/domain/entities/issue_comment_entity.dart';
import 'package:field_link/features/issues/domain/entities/issue_entity.dart';
import 'package:field_link/features/issues/domain/repositories/issue_repository.dart';
import 'package:field_link/features/issues/presentation/widgets/issue_comment_tile.dart';
import 'package:field_link/features/issues/presentation/widgets/user_search_delegate.dart';
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

  /// Helper to get media IDs from either media array or mediaIds field
  List<String> _getMediaIds(IssueEntity issue) {
    // First try to extract IDs from the media array
    if (issue.media != null && issue.media!.isNotEmpty) {
      return issue.media!
          .map((m) => m['id']?.toString())
          .whereType<String>()
          .toList();
    }
    // Fall back to mediaIds if media array is not available
    return issue.mediaIds ?? [];
  }

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
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Issue Details', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? DesignSystem.surfaceDark 
                    : DesignSystem.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: DesignSystem.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: DesignSystem.textSecondaryLight,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Collaboration'),
                ],
              ),
            ),
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
    final theme = Theme.of(context);
    
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
          
          // Attachments Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
            child: MediaPicker(),
          ),
          
          const SizedBox(height: DesignSystem.spacingM),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<MediaUploaderCubit, MediaUploaderState>(
                  builder: (context, state) {
                    final isUploading = state is MediaUploaderInProcess && state.isUploading;
                    final hasSelected = state is MediaUploaderInProcess && state.selectedFiles.isNotEmpty;

                    if (hasSelected && !isUploading) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<MediaUploaderCubit>().uploadFiles(
                            parentType: 'ISSUE',
                            parentId: issue.id,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: const Text('Upload Selected Files', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                if (_getMediaIds(issue).isNotEmpty) ...[
                  Text(
                    'Gallery',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: DesignSystem.textSecondaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MediaGallery(mediaIds: _getMediaIds(issue)),
                ] else
                  Container(
                    padding: const EdgeInsets.all(DesignSystem.spacingXL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? DesignSystem.surfaceDark 
                          : DesignSystem.surfaceLight,
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                      border: Border.all(
                        color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image_not_supported_rounded,
                          size: 40,
                          color: DesignSystem.textSecondaryLight.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No attachments found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: DesignSystem.textSecondaryLight,
                          ),
                        ),
                      ],
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
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Issue Number
          if (issue.issueNumber != null && issue.issueNumber!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignSystem.spacingS),
              child: Text(
                issue.issueNumber!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: DesignSystem.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          // Upper section: Title and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  issue.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spacingM),
              _buildStatusSelector(context, issue),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spacingS),
          
          // Author
          if (issue.author != null)
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: DesignSystem.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  'Raised by ${issue.author?['fullName'] ?? issue.author?['email'] ?? 'Unknown'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: DesignSystem.textSecondaryLight,
                  ),
                ),
              ],
            ),
            
          const SizedBox(height: DesignSystem.spacingL),

          // Description Section
          if (issue.description != null) ...[
            Text(
              'Description',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? DesignSystem.primaryLight : DesignSystem.primary,
              ),
            ),
            const SizedBox(height: DesignSystem.spacingS),
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacingM),
              decoration: BoxDecoration(
                color: isDark ? DesignSystem.surfaceDark : DesignSystem.surfaceLight,
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                ),
              ),
              child: Text(
                issue.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spacingL),
          ],

          // Info Grid (Tags)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInfoTag(
                context,
                Icons.flag_rounded,
                'Priority',
                issue.priority ?? 'Medium',
                _getPriorityColor(issue.priority),
              ),
              _buildInfoTag(
                context,
                Icons.calendar_today_rounded,
                'Due Date',
                issue.dueDate ?? 'None',
                DesignSystem.textSecondaryLight,
              ),
              if (issue.category != null && issue.category!.isNotEmpty)
                _buildInfoTag(
                  context,
                  Icons.category_rounded,
                  'Category',
                  issue.category!,
                  DesignSystem.primary,
                ),
            ],
          ),
          
          const SizedBox(height: DesignSystem.spacingXL),
          
          // Assignee Card
          Text(
            'Assignment',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? DesignSystem.primaryLight : DesignSystem.primary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          _buildAssigneeCard(context, issue),
        ],
      ),
    );
  }

  Widget _buildInfoTag(BuildContext context, IconData icon, String label, String value, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingS),
      constraints: const BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.surfaceDark : DesignSystem.surfaceLight,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: DesignSystem.textSecondaryLight,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
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

  Widget _buildAssigneeCard(BuildContext context, IssueEntity issue) {
    final theme = Theme.of(context);

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM, vertical: DesignSystem.spacingS),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignSystem.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, size: 20, color: DesignSystem.primary),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned to',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: DesignSystem.textSecondaryLight,
                  ),
                ),
                Text(
                  issue.assignee != null 
                      ? (issue.assignee!['fullName'] ?? issue.assignee!['email'] ?? 'Unknown')
                      : (issue.assigneeId ?? 'Unassigned'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showAssignDialog(context, issue),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Reassign'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssignDialog(
    BuildContext context,
    IssueEntity issue,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    
    // Use the search delegate to find and select a user
    final selectedUser = await showSearch(
      context: context,
      delegate: UserSearchDelegate(),
    );

    if (selectedUser != null && selectedUser.id != issue.assigneeId) {
      try {
        await _repository.assignIssue(issue.id, selectedUser.id);
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Assigned to ${selectedUser.fullName}'),
              backgroundColor: DesignSystem.success,
            ),
          );
          setState(() {}); // Trigger rebuild to show updated assignee
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error assigning issue: $e'),
              backgroundColor: DesignSystem.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildStatusSelector(BuildContext context, IssueEntity issue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: DesignSystem.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: DesignSystem.primary.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: issue.status,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: DesignSystem.primary),
          isDense: true,
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
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.surfaceDark : Colors.white,
        boxShadow: DesignSystem.shadowLg,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : DesignSystem.backgroundLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  style: theme.textTheme.bodyMedium,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: DesignSystem.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isSendingComment ? null : _addComment,
                icon: _isSendingComment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
