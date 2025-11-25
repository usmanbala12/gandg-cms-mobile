//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/repositories/report_repository.dart';
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
  late Stream<ReportEntity?> _reportStream;

  @override
  void initState() {
    super.initState();
    _repository = GetIt.instance<ReportRepository>();
    _reportStream = _repository.watchReports(projectId: widget.projectId).map((
      reports,
    ) {
      try {
        return reports.firstWhere((r) => r.id == widget.reportId);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: StreamBuilder<ReportEntity?>(
        stream: _reportStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final report = snapshot.data;
          if (report == null) {
            return const Center(child: Text('Report not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
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
                        'Date: ${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(report.reportDate))}',
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
                // We need to fetch media details to show them.
                // But ReportEntity only has mediaIds (JSON string).
                // We'd need to fetch media from MediaRepository.
                // For now, just list the IDs.
                Text('Media IDs: ${report.mediaIds}'),
              ],
            ],
          );
        },
      ),
    );
  }
}
