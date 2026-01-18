import 'package:field_link/core/utils/theme/design_system.dart';
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
  String _categoryFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<IssuesBloc>();
    _loadActiveProject();
  }

  @override
  void dispose() {
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
          'category': _categoryFilter,
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

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search issues...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: DesignSystem.textSecondaryLight,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _updateFilters();
                  },
                )
              : Text(
                  'Issues',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: _isSearching ? DesignSystem.error : null,
              ),
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
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            IssueFilterBar(
              selectedStatus: _statusFilter,
              selectedPriority: _priorityFilter,
              selectedCategory: _categoryFilter,
              onStatusChanged: (value) {
                setState(() => _statusFilter = value);
                _updateFilters();
              },
              onPriorityChanged: (value) {
                setState(() => _priorityFilter = value);
                _updateFilters();
              },
              onCategoryChanged: (value) {
                setState(() => _categoryFilter = value);
                _updateFilters();
              },
            ),
            Expanded(
              child: BlocBuilder<IssuesBloc, IssuesState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType ||
                    (previous is IssuesLoaded &&
                        current is IssuesLoaded &&
                        (previous.issues != current.issues ||
                            previous.errorMessage != current.errorMessage)),
                builder: (context, state) {
                  if (state is IssuesError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignSystem.spacingL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: DesignSystem.error.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: 64,
                                color: DesignSystem.error,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Something went wrong',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: DesignSystem.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                _bloc.add(LoadIssues(projectId: _projectId!));
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
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
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: DesignSystem.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: DesignSystem.error.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 20,
                                  color: DesignSystem.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: DesignSystem.error,
                                      fontWeight: FontWeight.w500,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: DesignSystem.primary.withValues(alpha: 0.05),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.assignment_rounded,
                                            size: 80,
                                            color: DesignSystem.primary.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'No issues found',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _projectId == null
                                              ? 'Please select a project from the dashboard'
                                              : 'Try adjusting your search or filters to find what you\'re looking for.',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                color: DesignSystem.textSecondaryLight,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : NotificationListener<ScrollNotification>(
                                    onNotification: _onScroll,
                                    child: RefreshIndicator(
                                      onRefresh: () async {
                                        if (_projectId != null) {
                                          _bloc.add(RefreshIssues(projectId: _projectId!));
                                        }
                                      },
                                      color: DesignSystem.primary,
                                      edgeOffset: 20,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                                        itemCount: state.hasReachedMax
                                            ? state.issues.length
                                            : state.issues.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index >= state.issues.length) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 32.0),
                                              child: Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          }
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
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: DesignSystem.primary,
          foregroundColor: DesignSystem.onPrimary,
          elevation: 4,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IssueCreatePage(projectId: _projectId!),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Issue', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
  }

  bool _onScroll(ScrollNotification scrollInfo) {
    final state = _bloc.state;
    if (state is! IssuesLoaded) return false;

    if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 200 &&
        !state.hasReachedMax &&
        !state.isFetchingMore) {
      _bloc.add(const LoadMoreIssues());
    }
    return false;
  }
}
