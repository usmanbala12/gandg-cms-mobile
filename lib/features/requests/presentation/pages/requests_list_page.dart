import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/domain/repository_result.dart';
import '../../../authentication/presentation/bloc/auth/auth_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../cubit/requests_cubit.dart';
import '../widgets/request_tile.dart';
import 'request_create_page.dart';
import 'request_detail_page.dart';

/// Main Requests tab page displaying list of requests with filtering.
class RequestsListPage extends StatelessWidget {
  const RequestsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RequestsCubit>(),
      child: const _RequestsListView(),
    );
  }
}

class _RequestsListView extends StatefulWidget {
  const _RequestsListView();

  @override
  State<_RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<_RequestsListView> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    final dashboardState = context.read<DashboardCubit>().state;
    if (dashboardState.selectedProjectId != null) {
      context.read<RequestsCubit>().loadRequests(
            projectId: dashboardState.selectedProjectId!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Requests',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('My Requests', 'mine'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending Approval', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Approved', 'approved'),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<RequestsCubit, RequestsState>(
              builder: (context, state) {
                if (state is RequestsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is RequestsError) {
                  return _buildErrorState(state.message);
                } else if (state is RequestsLoaded) {
                  return _buildLoadedState(state, theme);
                }
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateRequest(context),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        // TODO: Apply filter to cubit
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildLoadedState(RequestsLoaded state, ThemeData theme) {
    if (state.requests.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (state.source == DataSource.local)
          Container(
            width: double.infinity,
            color: theme.colorScheme.primary.withOpacity(0.1),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Offline Mode: Showing cached requests',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final dashboardState = context.read<DashboardCubit>().state;
              if (dashboardState.selectedProjectId != null) {
                await context.read<RequestsCubit>().refresh(
                      projectId: dashboardState.selectedProjectId!,
                    );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RequestTile(
                    request: request,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RequestDetailPage(request: request),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.request_page_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Requests Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first request to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateRequest(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Requests',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Requests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Status'),
              subtitle: const Text('Filter by request status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show status filter
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Type'),
              subtitle: const Text('Filter by request type'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show type filter
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Priority'),
              subtitle: const Text('Filter by priority level'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show priority filter
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateRequest(BuildContext context) {
    final dashboardState = context.read<DashboardCubit>().state;
    final authState = context.read<AuthBloc>().state;

    if (dashboardState.selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active project selected')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestCreatePage(
          projectId: dashboardState.selectedProjectId!,
          userId: authState.user?.id ?? 'unknown',
        ),
      ),
    );
  }
}
