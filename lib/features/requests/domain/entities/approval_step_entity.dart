import 'package:equatable/equatable.dart';

/// Represents an approval step in the request workflow.
class ApprovalStepEntity extends Equatable {
  final int order;
  final String approverId;
  final String? approverFirstName;
  final String? approverLastName;
  final String? approverEmail;
  final String status; // PENDING, APPROVED, REJECTED
  final double? maxApprovalAmount;
  final DateTime? timestamp;
  final String? comments;

  // Delegation fields
  final String? delegatedFromId;
  final String? delegatedToId;
  final String? delegationReason;

  const ApprovalStepEntity({
    required this.order,
    required this.approverId,
    this.approverFirstName,
    this.approverLastName,
    this.approverEmail,
    required this.status,
    this.maxApprovalAmount,
    this.timestamp,
    this.comments,
    this.delegatedFromId,
    this.delegatedToId,
    this.delegationReason,
  });

  String get approverDisplayName {
    if (approverFirstName != null && approverLastName != null) {
      return '$approverFirstName $approverLastName';
    }
    if (approverFirstName != null) return approverFirstName!;
    if (approverEmail != null) return approverEmail!;
    return approverId;
  }

  String get approverInitials {
    if (approverFirstName != null && approverLastName != null) {
      return '${approverFirstName![0]}${approverLastName![0]}'.toUpperCase();
    }
    if (approverFirstName != null && approverFirstName!.isNotEmpty) {
      return approverFirstName![0].toUpperCase();
    }
    return '?';
  }

  @override
  List<Object?> get props => [
        order,
        approverId,
        approverFirstName,
        approverLastName,
        approverEmail,
        status,
        maxApprovalAmount,
        timestamp,
        comments,
        delegatedFromId,
        delegatedToId,
        delegationReason,
      ];
}
