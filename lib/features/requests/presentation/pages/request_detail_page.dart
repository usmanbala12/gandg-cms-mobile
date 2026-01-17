import 'package:flutter/material.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/presentation/widgets/status_badge.dart';

import '../../domain/entities/request_entity.dart';
import '../widgets/approval_timeline.dart';

class RequestDetailPage extends StatelessWidget {
  final RequestEntity request;

  const RequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App bar with status
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignSystem.primary,
                      DesignSystem.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(DesignSystem.spacingXL, DesignSystem.spacingM, DesignSystem.spacingM, DesignSystem.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        StatusBadge(
                          status: request.status,
                          color: Colors.white,
                        ),
                        const SizedBox(height: DesignSystem.spacingS),
                        Text(
                          request.requestNumber ?? 'Request',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount card for FUNDS requests
                if (request.amount != null) _buildAmountCard(theme),

                // Type & Priority chips
                _buildTypePrioritySection(theme),

                // Description
                if (request.description != null)
                  _buildDescriptionSection(theme),

                // Requester info
                _buildRequesterCard(theme),

                // Approval workflow
                if (request.approvalSteps?.isNotEmpty ?? false)
                  _buildApprovalSection(theme),

                // Line items
                if (request.lineItems?.isNotEmpty ?? false)
                  _buildLineItemsSection(theme),

                // Metadata
                _buildMetadataSection(theme),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade600,
            Colors.green.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount Requested',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request.currency ?? 'NGN'} ${_formatAmount(request.amount!)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePrioritySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
      child: Wrap(
        spacing: DesignSystem.spacingS,
        runSpacing: DesignSystem.spacingS,
        children: [
          if (request.type != null)
            _buildChip(
              icon: Icons.category_outlined,
              label: request.type!,
              color: DesignSystem.primary,
            ),
          if (request.priority != null)
            _buildChip(
              icon: Icons.flag_outlined,
              label: request.priority!,
              color: _getPriorityColor(request.priority!),
            ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          CustomCard(
            child: Text(
              request.description ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequesterCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requester',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          CustomCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: DesignSystem.primary.withValues(alpha: 0.1),
                  child: Text(
                    _getInitials(request.requesterDisplayName),
                    style: const TextStyle(
                      color: DesignSystem.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: DesignSystem.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterDisplayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (request.requesterEmail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          request.requesterEmail!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: DesignSystem.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Approval Workflow',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'v1.0', // Fallback version
                  style: TextStyle(
                    color: DesignSystem.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingM),
          CustomCard(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            child: ApprovalTimeline(
              steps: request.approvalSteps!,
              currentStep: request.currentStepOrder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Line Items',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${request.lineItems!.length} item(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...request.lineItems!.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Qty: ${item.quantity} ${item.unit ?? 'units'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.unitPrice != null)
                      Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          CustomCard(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            child: Column(
              children: [
                _buildMetadataRow(
                  theme,
                  icon: Icons.calendar_today_outlined,
                  label: 'Created',
                  value: _formatDateTime(request.createdAt),
                ),
                const Divider(height: DesignSystem.spacingXL),
                _buildMetadataRow(
                  theme,
                  icon: Icons.update_outlined,
                  label: 'Updated',
                  value: _formatDateTime(request.updatedAt),
                ),
                if (request.completedAt != null) ...[
                  const Divider(height: DesignSystem.spacingXL),
                  _buildMetadataRow(
                    theme,
                    icon: Icons.check_circle_outline,
                    label: 'Completed',
                    value: _formatDateTime(
                      request.completedAt!.millisecondsSinceEpoch,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: DesignSystem.textSecondaryLight,
        ),
        const SizedBox(width: DesignSystem.spacingM),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: DesignSystem.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }

  String _formatDateTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }


  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return DesignSystem.success;
      case 'MEDIUM':
        return DesignSystem.warning;
      case 'HIGH':
      case 'URGENT':
      case 'CRITICAL':
        return DesignSystem.error;
      default:
        return DesignSystem.primary;
    }
  }
}
