import '../../domain/entities/form_template_entity.dart';

class FormTemplateModel extends FormTemplateEntity {
  const FormTemplateModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.isActive,
    required super.fields,
  });

  factory FormTemplateModel.fromJson(Map<String, dynamic> json) {
    return FormTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'GENERAL',
      isActive: json['isActive'] as bool? ?? true,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => FormFieldModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FormFieldModel extends FormFieldEntity {
  const FormFieldModel({
    required super.id,
    required super.label,
    required super.fieldType,
    required super.isRequired,
    required super.options,
    required super.displayOrder,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'] as String,
      label: json['label'] as String,
      fieldType: json['fieldType'] as String,
      isRequired: json['isRequired'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }
}
