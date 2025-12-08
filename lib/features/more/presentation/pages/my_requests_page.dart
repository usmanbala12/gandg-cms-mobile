import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/domain/repository_result.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../requests/presentation/cubit/requests_cubit.dart';
import '../widgets/request_list_item.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RequestsCubit>(),
      child: const _MyRequestsView(),
    );
  }
}

class _MyRequestsView extends StatefulWidget {
  const _MyRequestsView();

  @override
  State<_MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<_MyRequestsView> {
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
            // userId: 'current_user_id', // TODO: Get from AuthBloc
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
          'My Requests',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter dialog
            },
          ),
        ],
      ),
      body: BlocBuilder<RequestsCubit, RequestsState>(
        builder: (context, state) {
          if (state is RequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RequestsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is RequestsLoaded) {
            if (state.requests.isEmpty) {
              return const Center(child: Text('No requests found.'));
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
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final dashboardState =
                          context.read<DashboardCubit>().state;
                      if (dashboardState.selectedProjectId != null) {
                        await context.read<RequestsCubit>().refresh(
                              projectId: dashboardState.selectedProjectId!,
                            );
                      }
                    },
                    child: ListView.builder(
                      itemCount: state.requests.length,
                      itemBuilder: (context, index) {
                        final request = state.requests[index];
                        return RequestListItem(
                          request: request,
                          onTap: () {
                            // TODO: Navigate to details
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
    );
  }
}
