import 'package:flutter/material.dart';

/// Model representing a form template
class FormTemplate {
  final String id;
  final String name;
  final String? description;
  final List<TemplateFormField> fields;
  final DateTime? lastSynced;

  const FormTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.fields,
    this.lastSynced,
  });

  factory FormTemplate.fromJson(Map<String, dynamic> json) {
    final fieldsJson = json['fields'] as List<dynamic>? ?? [];
    return FormTemplate(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unnamed Template',
      description: json['description'] as String?,
      fields: fieldsJson
          .map((f) => TemplateFormField.fromJson(f as Map<String, dynamic>))
          .toList(),
      lastSynced: json['last_synced'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_synced'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fields': fields.map((f) => f.toJson()).toList(),
      'last_synced': lastSynced?.millisecondsSinceEpoch,
    };
  }
}

/// Model representing a form field in a template
class TemplateFormField {
  final String key;
  final String label;
  final String
  type; // text, longtext, number, date, select, multi_select, checkbox, location, media
  final bool required;
  final List<String>? options; // For select/multi_select
  final String? placeholder;
  final dynamic defaultValue;

  const TemplateFormField({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.options,
    this.placeholder,
    this.defaultValue,
  });

  factory TemplateFormField.fromJson(Map<String, dynamic> json) {
    // Map backend fields to model fields
    // Backend: id, label, fieldType, isRequired, displayOrder
    // Model: key, label, type, required, options, placeholder, defaultValue

    String rawType =
        (json['fieldType'] as String? ?? json['type'] as String? ?? 'text')
            .toUpperCase();
    String normalizedType = rawType.toLowerCase();

    // Map specific backend types to frontend types if needed
    if (rawType == 'MEDIA_UPLOAD') {
      normalizedType = 'media';
    } else if (rawType == 'MULTI_SELECT') {
      normalizedType = 'multi_select';
    }

    return TemplateFormField(
      key: json['id'] as String? ?? json['key'] as String? ?? '',
      label: json['label'] as String? ?? 'Unnamed Field',
      type: normalizedType,
      required:
          json['isRequired'] as bool? ?? json['required'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      placeholder: json['placeholder'] as String?,
      defaultValue: json['default_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'required': required,
      if (options != null) 'options': options,
      if (placeholder != null) 'placeholder': placeholder,
      if (defaultValue != null) 'default_value': defaultValue,
    };
  }
}

/// Widget for selecting a form template
class TemplateSelector extends StatefulWidget {
  final List<FormTemplate> templates;
  final FormTemplate? selectedTemplate;
  final ValueChanged<FormTemplate> onSelected;
  final bool isLoading;

  const TemplateSelector({
    super.key,
    required this.templates,
    this.selectedTemplate,
    required this.onSelected,
    this.isLoading = false,
  });

  @override
  State<TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends State<TemplateSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<FormTemplate> _filteredTemplates = [];

  @override
  void initState() {
    super.initState();
    _filteredTemplates = widget.templates;
    _searchController.addListener(_filterTemplates);
  }

  @override
  void didUpdateWidget(TemplateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templates != widget.templates) {
      _filterTemplates();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTemplates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTemplates = widget.templates.where((template) {
        return template.name.toLowerCase().contains(query) ||
            (template.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading templates'),
      );
    }

    if (widget.templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No templates available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search templates',
              hintText: 'Type to search...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                      tooltip: 'Clear search',
                    )
                  : null,
            ),
          ),
        ),

        // Template list
        Expanded(
          child: _filteredTemplates.isEmpty
              ? const Center(child: Text('No templates match your search'))
              : ListView.builder(
                  itemCount: _filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _filteredTemplates[index];
                    final isSelected =
                        widget.selectedTemplate?.id == template.id;

                    return Semantics(
                      label: 'Template: ${template.name}',
                      selected: isSelected,
                      button: true,
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: isSelected ? 4 : 1,
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        child: ListTile(
                          leading: Icon(
                            Icons.description,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                          title: Text(
                            template.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: template.description != null
                              ? Text(
                                  template.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text('${template.fields.length} fields'),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () {
                            print(
                              '📋 Template selected: ${template.name} (${template.id})',
                            );
                            widget.onSelected(template);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
