import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/issue_comment_entity.dart';
import '../../domain/entities/issue_entity.dart';
import '../../domain/repositories/issue_repository.dart';
import '../widgets/issue_comment_tile.dart';

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
      await _repository.addComment(widget.issueId, text, _currentUserId);
      _commentController.clear();
      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Reverse list
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Issue Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'History'),
              Tab(text: 'Media'),
            ],
          ),
        ),
        body: StreamBuilder<IssueEntity?>(
          stream: _repository.watchIssue(widget.issueId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final issue = snapshot.data;
            if (issue == null) {
              return const Center(child: Text('Issue not found'));
            }

            return TabBarView(
              children: [
                _buildDetailsTab(context, issue),
                _buildHistoryTab(context, issue),
                _buildMediaTab(context, issue),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, IssueEntity issue) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            reverse: true,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: StreamBuilder<List<IssueCommentEntity>>(
                    stream: _repository.watchComments(widget.issueId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
              ),
              SliverToBoxAdapter(child: _buildIssueHeader(context, issue)),
            ],
          ),
        ),
        _buildCommentInput(context),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context, IssueEntity issue) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _repository.loadHistory(issue.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading history: ${snapshot.error}'),
          );
        }
        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return const Center(child: Text('No history found'));
        }
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            final date = DateTime.fromMillisecondsSinceEpoch(
              (item['created_at'] as num).toInt(),
            );
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text('${item['action']} ${item['field'] ?? ''}'),
              subtitle: Text(
                '${item['old_value'] ?? '-'} -> ${item['new_value'] ?? '-'}\n${DateFormat.yMMMd().add_jm().format(date)}',
              ),
              trailing: Text(item['author_id'] ?? 'Unknown'),
            );
          },
        );
      },
    );
  }

  Widget _buildMediaTab(BuildContext context, IssueEntity issue) {
    // Placeholder for media tab
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No media attached'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement media upload
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Media upload not implemented yet'),
                ),
              );
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Photo'),
          ),
        ],
      ),
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
                  issue.dueDate != null
                      ? DateFormat.yMMMd().format(
                          DateTime.fromMillisecondsSinceEpoch(issue.dueDate!),
                        )
                      : 'No due date',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAssigneeRow(context, issue),
            const Divider(height: 32),
            Text('Comments', style: theme.textTheme.titleMedium),
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
        Text('Assignee: ${issue.assigneeId ?? 'Unassigned'}'),
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
            color: Colors.black.withOpacity(0.05),
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
