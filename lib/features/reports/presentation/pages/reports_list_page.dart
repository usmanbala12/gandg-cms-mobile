import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/repositories/report_repository.dart';
import '../../domain/entities/report_entity.dart';
import 'report_create_page.dart';
import 'report_detail_page.dart';

class ReportsListPage extends StatefulWidget {
  final String? projectId;

  const ReportsListPage({super.key, this.projectId});

  @override
  State<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends State<ReportsListPage> {
  late final ReportRepository _repository;
  late Stream<List<ReportEntity>> _reportsStream;
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _repository = GetIt.instance<ReportRepository>();
    _reportsStream = _repository.watchReports(projectId: widget.projectId);
  }

  Future<void> _refresh() async {
    await _repository.getReports(
      projectId: widget.projectId,
      forceRemote: widget.projectId != null,
    );
  }

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
            child: StreamBuilder<List<ReportEntity>>(
              stream: _reportsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports = _filterReports(snapshot.data!);

                if (reports.isEmpty) {
                  return const Center(child: Text('No reports found'));
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
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
              builder: (context) =>
                  ReportCreatePage(projectId: widget.projectId),
            ),
          );
        },
        child: const Icon(Icons.add),
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
