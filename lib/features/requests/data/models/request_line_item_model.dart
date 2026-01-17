import '../../domain/entities/request_line_item_entity.dart';

/// Model for RequestLineItem with JSON serialization.
class RequestLineItemModel extends RequestLineItemEntity {
  const RequestLineItemModel({
    required super.id,
    required super.description,
    required super.quantity,
    super.unitPrice,
    super.unit,
  });

  factory RequestLineItemModel.fromJson(Map<String, dynamic> json) {
    return RequestLineItemModel(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: json['unitPrice'] != null
          ? (json['unitPrice'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (unit != null) 'unit': unit,
    };
  }

  factory RequestLineItemModel.fromEntity(RequestLineItemEntity entity) {
    return RequestLineItemModel(
      id: entity.id,
      description: entity.description,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      unit: entity.unit,
    );
  }
}
