import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../requests/domain/entities/request_entity.dart';

class RequestListItem extends StatelessWidget {
  final RequestEntity request;
  final VoidCallback? onTap;

  const RequestListItem({super.key, required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.fromMillisecondsSinceEpoch(request.createdAt);
    final formattedDate = DateFormat('MMM d, yyyy').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Icon(
            _getIconForType(request.type),
            color: theme.colorScheme.onPrimary,
            size: 20,
          ),
        ),
        title: Text(
          request.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${request.type ?? 'Request'} • $formattedDate',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            if (request.amount != null) ...[
              const SizedBox(height: 4),
              Text(
                '${request.currency ?? 'USD'} ${request.amount!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
        trailing: _buildStatusBadge(context, request.status),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'FUNDS':
        return Icons.attach_money;
      case 'MATERIALS':
        return Icons.inventory_2;
      case 'EQUIPMENT':
        return Icons.construction;
      case 'LEAVE':
        return Icons.flight_takeoff;
      default:
        return Icons.description;
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'APPROVED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      case 'PENDING':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
