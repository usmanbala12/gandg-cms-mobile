import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/repositories/report_repository.dart';
import '../../../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../../features/dashboard/presentation/widgets/sync_status_widget.dart';
import '../../domain/entities/report_entity.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import 'report_create_page.dart';
import 'report_detail_page.dart';

class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsCubit(
        repository: GetIt.instance<ReportRepository>(),
        dashboardCubit: context.read<DashboardCubit>(),
      ),
      child: const _ReportsListView(),
    );
  }
}

class _ReportsListView extends StatefulWidget {
  const _ReportsListView();

  @override
  State<_ReportsListView> createState() => _ReportsListViewState();
}

class _ReportsListViewState extends State<_ReportsListView> {
  String _searchQuery = '';
  String? _statusFilter;

  List<ReportEntity> _filterReports(List<ReportEntity> reports) {
    return reports.where((report) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          report.id.contains(_searchQuery) ||
          (report.submissionData?.toString().contains(_searchQuery) ?? false);
      final matchesStatus =
          _statusFilter == null || report.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          const SyncStatusWidget(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportsCubit>().refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) {
                if (state is ReportsError) {
                  return Center(child: Text('Error: ${state.message}'));
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
                  final reports = _filterReports(state.reports);

                  if (reports.isEmpty) {
                    return const Center(child: Text('No reports found'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<ReportsCubit>().refresh(),
                    child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return ListTile(
                          title: Text(
                            'Report ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(report.reportDate))}',
                          ),
                          subtitle: Text(
                            'Status: ${report.status}\nID: ${report.id.substring(0, 8)}...',
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
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                onTap: () {
                  setState(() => _statusFilter = null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Draft'),
                onTap: () {
                  setState(() => _statusFilter = 'DRAFT');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Pending'),
                onTap: () {
                  setState(() => _statusFilter = 'PENDING');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Synced'),
                onTap: () {
                  setState(() => _statusFilter = 'SYNCED');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Error'),
                onTap: () {
                  setState(() => _statusFilter = 'ERROR');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
