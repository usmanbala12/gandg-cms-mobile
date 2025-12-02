import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/db/daos/meta_dao.dart';
import '../bloc/issues_bloc.dart';
import '../widgets/issue_filter_bar.dart';
import '../widgets/issue_tile.dart';
import 'issue_create_page.dart';
import 'issue_detail_page.dart';

class IssuesListPage extends StatefulWidget {
  const IssuesListPage({super.key});

  @override
  State<IssuesListPage> createState() => _IssuesListPageState();
}

class _IssuesListPageState extends State<IssuesListPage> {
  final _metaDao = GetIt.I<MetaDao>();
  late IssuesBloc _bloc;

  String? _projectId;
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<IssuesBloc>();
    _loadActiveProject();
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveProject() async {
    final projectId = await _metaDao.getValue('active_project_id');
    if (mounted) {
      setState(() {
        _projectId = projectId;
      });
      if (projectId != null) {
        _bloc.add(LoadIssues(projectId: projectId));
      }
    }
  }

  void _updateFilters() {
    if (_projectId == null) return;
    _bloc.add(
      FilterIssues(
        projectId: _projectId!,
        filters: {
          'status': _statusFilter,
          'priority': _priorityFilter,
          'search': _searchQuery,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_projectId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search issues...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _updateFilters();
                  },
                )
              : const Text('Issues'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchController.clear();
                    _updateFilters();
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            IssueFilterBar(
              selectedStatus: _statusFilter,
              selectedPriority: _priorityFilter,
              onStatusChanged: (value) {
                setState(() => _statusFilter = value);
                _updateFilters();
              },
              onPriorityChanged: (value) {
                setState(() => _priorityFilter = value);
                _updateFilters();
              },
            ),
            Expanded(
              child: BlocBuilder<IssuesBloc, IssuesState>(
                builder: (context, state) {
                  if (state is IssuesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text('Error', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _bloc.add(LoadIssues(projectId: _projectId!));
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is IssuesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is IssuesLoaded) {
                    return Column(
                      children: [
                        // Data source indicator banner
                        if (state.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            color: theme.colorScheme.errorContainer,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: 20,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Issue list
                        Expanded(
                          child: state.issues.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 64,
                                        color: theme.colorScheme.outline,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No issues found',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.outline,
                                            ),
                                      ),
                                      if (_projectId == null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Please select a project from the dashboard',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    _bloc.add(
                                      RefreshIssues(projectId: _projectId!),
                                    );
                                  },
                                  child: ListView.builder(
                                    itemCount: state.issues.length,
                                    itemBuilder: (context, index) {
                                      final issue = state.issues[index];
                                      return IssueTile(
                                        issue: issue,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  IssueDetailPage(
                                                    issueId: issue.id,
                                                  ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IssueCreatePage(projectId: _projectId!),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
