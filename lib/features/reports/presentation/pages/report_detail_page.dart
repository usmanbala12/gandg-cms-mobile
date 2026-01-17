import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:field_link/core/presentation/widgets/status_badge.dart';
import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:field_link/core/domain/repository_result.dart';
import 'package:field_link/features/reports/domain/repositories/report_repository.dart';
import 'package:field_link/features/reports/domain/entities/report_entity.dart';
import 'package:field_link/features/reports/domain/entities/form_template_entity.dart';
import 'package:field_link/features/media/presentation/widgets/media_gallery.dart';

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
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            children: [
              if (reportResult.isLocal && reportResult.message != null)
                _buildSyncNotice(reportResult.message!),
              _buildReportInfoCard(report),
              const SizedBox(height: DesignSystem.spacingL),
              Text(
                'Submission Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: DesignSystem.spacingM),
              _buildSubmissionDataCard(report, template),
              if (report.mediaIds != null && report.mediaIds!.isNotEmpty) ...[
                const SizedBox(height: DesignSystem.spacingL),
                Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: DesignSystem.spacingM),
                MediaGallery(mediaIds: report.mediaIds!),
              ],
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
    return CustomCard(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Details',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              StatusBadge(status: report.status),
            ],
          ),
          const Divider(height: DesignSystem.spacingXL),
          _buildInfoRow('Project', report.projectName ?? 'N/A'),
          const SizedBox(height: DesignSystem.spacingS),
          _buildInfoRow('Template', report.formTemplateName ?? 'N/A'),
          const SizedBox(height: DesignSystem.spacingS),
          _buildInfoRow('Report #', report.reportNumber ?? 'N/A'),
          const SizedBox(height: DesignSystem.spacingS),
          _buildInfoRow('Date', report.reportDate),
          const SizedBox(height: DesignSystem.spacingS),
          _buildInfoRow('Author', report.authorName ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: DesignSystem.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
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

    if (template == null || template.fields.isEmpty) {
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
            children: fieldsData.entries.map((e) {
              return ListTile(
                title: Text(e.key),
                subtitle: Text(e.value.toString()),
              );
            }).toList(),
          ),
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            template.fields.map((field) {
              final fieldResponse = fieldsData[field.id];
              final value = fieldResponse is Map ? fieldResponse['value'] : fieldResponse;

              return Padding(
                padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: DesignSystem.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    _renderFieldValue(field, value),
                  ],
                ),
              );
            }).toList(),
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
          if (value.isEmpty) return const Text('None selected', style: TextStyle(color: Colors.grey));
          return Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                value
                    .map(
                      (v) => Chip(
                        label: Text(v.toString(), style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.blue.shade50,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
          );
        }
        return Text(value.toString());

      case 'LOCATION':
        if (value is Map) {
          final address = value['address']?.toString();
          final lat = value['latitude']?.toString();
          final lng = value['longitude']?.toString();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (address != null && address.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(child: Text(address)),
                  ],
                ),
              if (lat != null && lng != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Coords: $lat, $lng',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              if ((address == null || address.isEmpty) && (lat == null || lng == null))
                const Text('No location details', style: TextStyle(color: Colors.grey)),
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

      case 'NUMBER':
        return Text(
          value.toString(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        );

      default:
        return Text(
          value.toString(),
          style: const TextStyle(fontSize: 15),
        );
    }
  }

}

extension on String {
  String get overflow {
    if (length > 15) return '${substring(0, 12)}...';
    return this;
  }
}
