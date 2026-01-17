import 'package:equatable/equatable.dart';

/// Represents a line item in a request (for MATERIALS/EQUIPMENT types).
class RequestLineItemEntity extends Equatable {
  final String id;
  final String description;
  final int quantity;
  final double? unitPrice;
  final String? unit;

  const RequestLineItemEntity({
    required this.id,
    required this.description,
    required this.quantity,
    this.unitPrice,
    this.unit,
  });

  double get total => (unitPrice ?? 0) * quantity;

  @override
  List<Object?> get props => [id, description, quantity, unitPrice, unit];
}
