//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/domain/repository_result.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/entities/report_entity.dart';

class ReportDetailPage extends StatefulWidget {
  final String projectId;
  final String reportId;

  const ReportDetailPage({
    super.key,
    required this.projectId,
    required this.reportId,
  });

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  late final ReportRepository _repository;
  late Future<RepositoryResult<ReportEntity>> _reportFuture;

  @override
  void initState() {
    super.initState();
    _repository = GetIt.instance<ReportRepository>();
    _reportFuture = _repository.getReport(widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: FutureBuilder<RepositoryResult<ReportEntity>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final result = snapshot.data;
          if (result == null) {
            return const Center(child: Text('Report not found'));
          }

          if (result.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      result.message ?? 'Error loading report',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _reportFuture = _repository.getReport(widget.reportId);
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final report = result.data;
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (result.isLocal && result.message != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.orange.shade100,
                  child: Text(
                    result.message!,
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${report.status}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${report.reportDate}',
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${report.id}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Submission Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        report.submissionData?.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${e.key}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(child: Text(e.value.toString())),
                              ],
                            ),
                          );
                        }).toList() ??
                        [const Text('No data')],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (report.mediaIds != null) ...[
                const Text(
                  'Media',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Media IDs: ${report.mediaIds}'),
              ],
            ],
          );
        },
      ),
    );
  }
}
