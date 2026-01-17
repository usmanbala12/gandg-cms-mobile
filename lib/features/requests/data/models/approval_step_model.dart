import '../../domain/entities/approval_step_entity.dart';

/// Model for ApprovalStep with JSON serialization.
class ApprovalStepModel extends ApprovalStepEntity {
  const ApprovalStepModel({
    required super.order,
    required super.approverId,
    super.approverFirstName,
    super.approverLastName,
    super.approverFullName,
    super.approverEmail,
    required super.status,
    super.maxApprovalAmount,
    super.timestamp,
    super.comments,
    super.delegatedFromId,
    super.delegatedToId,
    super.delegationReason,
  });

  factory ApprovalStepModel.fromJson(Map<String, dynamic> json) {
    final approverJson = (json['approver'] as Map<String, dynamic>?) ?? json;
    final delegatedFrom = json['delegatedFrom'] as Map<String, dynamic>?;
    final delegatedTo = json['delegatedTo'] as Map<String, dynamic>?;

    String? firstName = approverJson['firstName']?.toString() ?? 
                       approverJson['first_name']?.toString() ?? 
                       json['approver_first_name']?.toString();
                       
    String? lastName = approverJson['lastName']?.toString() ?? 
                      approverJson['last_name']?.toString() ?? 
                      json['approver_last_name']?.toString();
                      
    String? fullName = approverJson['fullName']?.toString() ?? 
                       approverJson['full_name']?.toString() ?? 
                       json['approver_full_name']?.toString();
                      
    String? email = approverJson['email']?.toString() ?? 
                    json['approver_email']?.toString();

    return ApprovalStepModel(
      order: json['order'] as int? ?? 0,
      approverId: approverJson['id']?.toString() ?? json['approverId']?.toString() ?? '',
      approverFirstName: firstName,
      approverLastName: lastName,
      approverFullName: fullName,
      approverEmail: email,
      status: json['status'] as String? ?? 'PENDING',
      maxApprovalAmount: json['maxApprovalAmount'] != null
          ? (json['maxApprovalAmount'] as num).toDouble()
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
      comments: json['comments'] as String?,
      delegatedFromId: delegatedFrom?['id'] as String?,
      delegatedToId: delegatedTo?['id'] as String?,
      delegationReason: json['delegationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'approverId': approverId,
      'status': status,
      if (maxApprovalAmount != null) 'maxApprovalAmount': maxApprovalAmount,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      if (comments != null) 'comments': comments,
      if (delegatedFromId != null) 'delegatedFromId': delegatedFromId,
      if (delegatedToId != null) 'delegatedToId': delegatedToId,
      if (delegationReason != null) 'delegationReason': delegationReason,
    };
  }

  factory ApprovalStepModel.fromEntity(ApprovalStepEntity entity) {
    return ApprovalStepModel(
      order: entity.order,
      approverId: entity.approverId,
      approverFirstName: entity.approverFirstName,
      approverLastName: entity.approverLastName,
      approverFullName: entity.approverFullName,
      approverEmail: entity.approverEmail,
      status: entity.status,
      maxApprovalAmount: entity.maxApprovalAmount,
      timestamp: entity.timestamp,
      comments: entity.comments,
      delegatedFromId: entity.delegatedFromId,
      delegatedToId: entity.delegatedToId,
      delegationReason: entity.delegationReason,
    );
  }
}
