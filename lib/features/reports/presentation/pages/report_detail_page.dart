//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/domain/repository_result.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/entities/report_entity.dart';

import '../../domain/entities/form_template_entity.dart';

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
  late Future<
    (RepositoryResult<ReportEntity>, RepositoryResult<FormTemplateEntity>?)
  >
  _detailFuture;

  @override
  void initState() {
    super.initState();
    _repository = GetIt.instance<ReportRepository>();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _detailFuture = _repository.getReport(widget.reportId).then((
        reportResult,
      ) async {
        if (!reportResult.hasError && reportResult.data.formTemplateId != null) {
          final templateResult = await _repository.getTemplate(
            reportResult.data.formTemplateId!,
          );
          return (reportResult, templateResult);
        }
        return (reportResult, null as RepositoryResult<FormTemplateEntity>?);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: FutureBuilder<
        (RepositoryResult<ReportEntity>, RepositoryResult<FormTemplateEntity>?)
      >(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final (reportResult, templateResult) = snapshot.data!;

          if (reportResult.hasError) {
            return _buildErrorState(reportResult.message);
          }

          final report = reportResult.data;
          final template = templateResult?.data;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (reportResult.isLocal && reportResult.message != null)
                _buildSyncNotice(reportResult.message!),
              _buildReportInfoCard(report),
              const SizedBox(height: 24),
              const Text(
                'Submission Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSubmissionDataCard(report, template),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message ?? 'Error loading report', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncNotice(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportInfoCard(ReportEntity report) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'Status',
              report.status,
              color: _getStatusColor(report.status),
            ),
            const Divider(height: 24),
            _buildInfoRow('Project', report.projectName ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('Template', report.formTemplateName ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('Report #', report.reportNumber ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow('Date', report.reportDate),
            const SizedBox(height: 8),
            _buildInfoRow('Author', report.authorName ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionDataCard(
    ReportEntity report,
    FormTemplateEntity? template,
  ) {
    final submissionData = report.submissionData;
    if (submissionData == null) return const Card(child: ListTile(title: Text('No data')));

    // The data is actually in submissionData['fields'] based on user sample
    final fieldsData = submissionData['fields'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              template?.fields.map((field) {
                final fieldResponse = fieldsData[field.id];
                final value = fieldResponse is Map ? fieldResponse['value'] : fieldResponse;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.label,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _renderFieldValue(field, value),
                    ],
                  ),
                );
              }).toList() ??
              fieldsData.entries.map((e) {
                return ListTile(
                  title: Text(e.key),
                  subtitle: Text(e.value.toString()),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _renderFieldValue(FormFieldEntity field, dynamic value) {
    if (value == null) {
      return const Text('N/A', style: TextStyle(color: Colors.grey));
    }

    switch (field.fieldType.toUpperCase()) {
      case 'MULTISELECT':
        if (value is List) {
          return Wrap(
            spacing: 8,
            children:
                value
                    .map(
                      (v) => Chip(
                        label: Text(v.toString(), style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.blue.shade50,
                      ),
                    )
                    .toList(),
          );
        }
        return Text(value.toString());

      case 'LOCATION':
        if (value is Map) {
          return Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Expanded(child: Text(value['address'] ?? 'Coordinate only')),
            ],
          );
        }
        return Text(value.toString());

      case 'MEDIA_UPLOAD':
        return Row(
          children: [
            const Icon(Icons.image, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text('Media ID: ${value.toString().overflow}'),
          ],
        );

      case 'DATE':
        return Text(value.toString());

      default:
        return Text(
          value.toString(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'REVIEWED':
        return Colors.green;
      case 'DRAFT':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

extension on String {
  String get overflow {
    if (length > 15) return '${substring(0, 12)}...';
    return this;
  }
}
