import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/report_entity.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import 'report_create_page.dart';
import 'report_detail_page.dart';

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
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Submitted'),
              Tab(text: 'Pending'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
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
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
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
              return const Center(
                child: Text('Please select a project to view reports'),
              );
            }
            if (state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ReportsLoaded) {
              final submittedReports = state.reports
                  .where((r) => r.status?.toUpperCase() == 'SUBMITTED' || r.status?.toUpperCase() == 'REVIEWED')
                  .toList();
              final pendingReports = state.reports
                  .where((r) => r.status?.toUpperCase() != 'SUBMITTED' && r.status?.toUpperCase() != 'REVIEWED')
                  .toList();

              return TabBarView(
                children: [
                  _ReportsList(
                    reports: submittedReports,
                    emptyMessage: 'No submitted reports',
                  ),
                  _ReportsList(
                    reports: pendingReports,
                    emptyMessage: 'No pending reports',
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

  const _ReportsList({
    required this.reports,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReportsCubit>().refresh(),
      child: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return ListTile(
            title: Text(
              'Report ${report.reportNumber ?? report.reportDate}',
            ),
            subtitle: Text(
              'Status: ${report.status ?? 'Unknown'}\nDate: ${report.reportDate}',
            ),
            trailing: const Icon(Icons.chevron_right),
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
          );
        },
      ),
    );
  }
}
