import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/presentation/widgets/status_badge.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:field_link/features/reports/domain/entities/report_entity.dart';
import 'package:field_link/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:field_link/features/reports/presentation/cubit/reports_state.dart';
import 'package:field_link/features/reports/presentation/pages/report_create_page.dart';
import 'package:field_link/features/reports/presentation/pages/report_detail_page.dart';

class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportsListView();
  }
}

class _ReportsListView extends StatelessWidget {
  const _ReportsListView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Reports',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: DesignSystem.primary,
            labelColor: DesignSystem.primary,
            unselectedLabelColor: DesignSystem.textSecondaryLight,
            tabs: const [
              Tab(text: 'Submitted'),
              Tab(text: 'Pending'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
               color: DesignSystem.primary,
              onPressed: () => context.read<ReportsCubit>().refresh(),
            ),
          ],
        ),
        body: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            if (state is ReportsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: DesignSystem.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: DesignSystem.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ReportsCubit>().refresh(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is ReportsNoProjectSelected) {
              return Center(
                child: Text(
                  'Please select a project to view reports',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: DesignSystem.textSecondaryLight,
                  ),
                ),
              );
            }
            if (state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ReportsLoaded) {
              final submittedReports = state.reports
                  .where((r) => r.status.toUpperCase() == 'SUBMITTED' || r.status.toUpperCase() == 'REVIEWED')
                  .toList();
              final pendingReports = state.reports
                  .where((r) => r.status.toUpperCase() != 'SUBMITTED' && r.status.toUpperCase() != 'REVIEWED')
                  .toList();

              return TabBarView(
                children: [
                  _ReportsList(
                    reports: submittedReports,
                    emptyMessage: 'No submitted reports',
                    hasReachedMax: state.hasReachedMax,
                    isFetchingMore: state.isFetchingMore,
                  ),
                  _ReportsList(
                    reports: pendingReports,
                    emptyMessage: 'No pending reports',
                    hasReachedMax: state.hasReachedMax,
                    isFetchingMore: state.isFetchingMore,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            if (state is ReportsNoProjectSelected) return const SizedBox.shrink();
            return FloatingActionButton(
              backgroundColor: DesignSystem.primary,
              foregroundColor: DesignSystem.onPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportCreatePage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class _ReportsList extends StatelessWidget {
  final List<ReportEntity> reports;
  final String emptyMessage;
  final bool hasReachedMax;
  final bool isFetchingMore;

  const _ReportsList({
    required this.reports,
    required this.emptyMessage,
    required this.hasReachedMax,
    required this.isFetchingMore,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty && !isFetchingMore) {
      return Center(
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignSystem.textSecondaryLight,
              ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !hasReachedMax &&
            !isFetchingMore) {
          context.read<ReportsCubit>().loadMoreReports();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => context.read<ReportsCubit>().refresh(),
        color: DesignSystem.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          // Add 1 for the loader if there are more pages
          itemCount: hasReachedMax ? reports.length : reports.length + 1,
          itemBuilder: (context, index) {
            if (index >= reports.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final report = reports[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailPage(
                        projectId: report.projectId,
                        reportId: report.id,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            report.reportNumber ?? 'New Report',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: DesignSystem.textPrimaryLight,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: report.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: DesignSystem.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          report.reportDate,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: DesignSystem.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                    // Additional details can go here
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
