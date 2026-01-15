import 'package:equatable/equatable.dart';

class FormTemplateEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isActive;
  final List<FormFieldEntity> fields;

  const FormTemplateEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isActive,
    required this.fields,
  });

  @override
  List<Object?> get props => [id, name, description, category, isActive, fields];
}

class FormFieldEntity extends Equatable {
  final String id;
  final String label;
  final String fieldType;
  final bool isRequired;
  final List<String> options;
  final int displayOrder;

  const FormFieldEntity({
    required this.id,
    required this.label,
    required this.fieldType,
    required this.isRequired,
    required this.options,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [id, label, fieldType, isRequired, options, displayOrder];
}
