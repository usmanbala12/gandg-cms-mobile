import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'media_picker_widget.dart';
import 'template_selector.dart';

/// Widget that dynamically builds a form based on a template
class DynamicForm extends StatefulWidget {
  final FormTemplate template;
  final Map<String, dynamic>? initialValues;
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback? onCancel;

  const DynamicForm({
    super.key,
    required this.template,
    this.initialValues,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final field in widget.template.fields) {
      // Initialize with provided initial value, default value, or null
      final initialValue =
          widget.initialValues?[field.key] ?? field.defaultValue;

      _formData[field.key] = initialValue;

      // Create text controllers for fields that need them
      if (_needsController(field.type)) {
        _controllers[field.key] = TextEditingController(
          text: initialValue?.toString() ?? '',
        );
      }

      // Special handling for location which might have sub-fields
      if (field.type == 'location') {
        final locMap = initialValue as Map<String, dynamic>?;
        _controllers['${field.key}_lat'] = TextEditingController(
          text: locMap?['lat']?.toString() ?? '',
        );
        _controllers['${field.key}_lng'] = TextEditingController(
          text: locMap?['lng']?.toString() ?? '',
        );
      }
    }
  }

  bool _needsController(String type) {
    return ['text', 'longtext', 'number'].contains(type);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateField(TemplateFormField field, dynamic value) {
    if (field.required) {
      if (value == null ||
          (value is String && value.isEmpty) ||
          (value is List && value.isEmpty) ||
          (value is Map && value.isEmpty)) {
        return '${field.label} is required';
      }
    }

    // Type-specific validation
    if (value != null && value.toString().isNotEmpty) {
      switch (field.type) {
        case 'number':
          if (double.tryParse(value.toString()) == null) {
            return 'Please enter a valid number';
          }
          break;
        // Add more type-specific validations as needed
      }
    }

    return null;
  }

  Widget _buildField(TemplateFormField field) {
    // print('🔨 Building field: ${field.label} (${field.type})');

    switch (field.type) {
      case 'text':
        return _buildTextField(field, maxLines: 1);

      case 'longtext':
        return _buildTextField(field, maxLines: 5);

      case 'number':
        return _buildNumberField(field);

      case 'date':
        return _buildDateField(field);

      case 'select':
        return _buildSelectField(field);

      case 'multi_select':
        return _buildMultiSelectField(field);

      case 'checkbox':
        return _buildCheckboxField(field);

      case 'location':
        return _buildLocationField(field);

      case 'media':
        return _buildMediaField(field);

      default:
        // Fallback for unknown types
        print(
          '⚠️ Unsupported field type: "${field.type}", falling back to text',
        );
        return _buildTextField(field, maxLines: 1);
    }
  }

  Widget _buildTextField(TemplateFormField field, {required int maxLines}) {
    // Ensure controller exists, fallback if missing (defensive)
    final controller = _controllers[field.key];
    if (controller == null) {
      print('❌ Missing controller for field ${field.key} (${field.type})');
      // Create a temporary one to prevent crash, but this shouldn't happen if init is correct
      return TextFormField(
        initialValue: _formData[field.key]?.toString(),
        decoration: InputDecoration(
          labelText: field.label + (field.required ? ' *' : ''),
          hintText: field.placeholder,
          border: const OutlineInputBorder(),
          errorText: 'Internal Error: Missing Controller',
        ),
        maxLines: maxLines,
        onSaved: (value) => _formData[field.key] = value,
      );
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      onSaved: (value) => _formData[field.key] = value,
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildNumberField(TemplateFormField field) {
    final controller = _controllers[field.key];

    return TextFormField(
      controller:
          controller, // Might be null if type mismatch, handled by defensive check in init?
      // If controller is null here, it means _needsController returned false but we are here.
      // _needsController includes 'number', so it should be fine.
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _formData[field.key] = double.tryParse(value) ?? value;
        } else {
          _formData[field.key] = null;
        }
      },
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildDateField(TemplateFormField field) {
    final currentValue = _formData[field.key] as DateTime?;

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: currentValue ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() {
            _formData[field.key] = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: field.label + (field.required ? ' *' : ''),
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
          errorText: _validateField(field, currentValue),
        ),
        child: Text(
          currentValue != null
              ? DateFormat('yyyy-MM-dd').format(currentValue)
              : field.placeholder ?? 'Select date',
          style: TextStyle(
            color: currentValue != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectField(TemplateFormField field) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        border: const OutlineInputBorder(),
      ),
      value: _formData[field.key] as String?,
      items: (field.options ?? []).map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _formData[field.key] = value;
        });
      },
      onSaved: (value) => _formData[field.key] = value,
      validator: (value) => _validateField(field, value),
    );
  }

  Widget _buildMultiSelectField(TemplateFormField field) {
    final selectedValues =
        (_formData[field.key] as List<dynamic>?)?.cast<String>() ?? [];

    return FormField<List<String>>(
      initialValue: selectedValues,
      validator: (value) => _validateField(field, value),
      onSaved: (value) => _formData[field.key] = value,
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label + (field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (field.options ?? []).map((option) {
                final isSelected = selectedValues.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedValues.add(option);
                      } else {
                        selectedValues.remove(option);
                      }
                      _formData[field.key] = selectedValues;
                      state.didChange(selectedValues);
                    });
                  },
                );
              }).toList(),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCheckboxField(TemplateFormField field) {
    final value = _formData[field.key] as bool? ?? false;

    return CheckboxListTile(
      title: Text(field.label + (field.required ? ' *' : '')),
      subtitle: field.placeholder != null ? Text(field.placeholder!) : null,
      value: value,
      onChanged: (newValue) {
        setState(() {
          _formData[field.key] = newValue ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildLocationField(TemplateFormField field) {
    // We use separate controllers for lat/lng to ensure they persist and can be validated
    final latController = _controllers['${field.key}_lat'];
    final lngController = _controllers['${field.key}_lng'];

    if (latController == null || lngController == null) {
      return const Text('Error: Location controllers not initialized');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label + (field.required ? ' *' : ''),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                onChanged: (value) {
                  _updateLocationData(field.key, lat: value);
                },
                validator: (value) {
                  if (field.required && (value == null || value.isEmpty)) {
                    return 'Required';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                onChanged: (value) {
                  _updateLocationData(field.key, lng: value);
                },
                validator: (value) {
                  if (field.required && (value == null || value.isEmpty)) {
                    return 'Required';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateLocationData(String fieldKey, {String? lat, String? lng}) {
    final currentMap = _formData[fieldKey] as Map<String, dynamic>? ?? {};
    if (lat != null) currentMap['lat'] = double.tryParse(lat);
    if (lng != null) currentMap['lng'] = double.tryParse(lng);
    _formData[fieldKey] = currentMap;
  }

  Widget _buildMediaField(TemplateFormField field) {
    final mediaPaths =
        (_formData[field.key] as List<dynamic>?)?.cast<String>() ?? [];

    return FormField<List<String>>(
      initialValue: mediaPaths,
      validator: (value) => _validateField(field, value),
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label + (field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            MediaPickerWidget(
              currentMediaCount: mediaPaths.length,
              onMediaSelected: (path) {
                setState(() {
                  mediaPaths.add(path);
                  _formData[field.key] = mediaPaths;
                  state.didChange(mediaPaths);
                });
              },
            ),
            if (mediaPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mediaPaths.asMap().entries.map((entry) {
                  final index = entry.key;
                  final path = entry.value;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              mediaPaths.removeAt(index);
                              _formData[field.key] = mediaPaths;
                              state.didChange(mediaPaths);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print('📤 Form submitted with data: $_formData');
      widget.onSubmit(_formData);
    } else {
      print('⚠️ Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Template header
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (widget.template.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.template.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Form fields
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.template.fields.length,
              itemBuilder: (context, index) {
                final field = widget.template.fields[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildField(field),
                );
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (widget.onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                if (widget.onCancel != null) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
