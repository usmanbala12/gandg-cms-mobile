import 'package:flutter/material.dart';
import '../../domain/entities/form_template_entity.dart';

/// Widget for selecting a form template
class TemplateSelector extends StatefulWidget {
  final List<FormTemplateEntity> templates;
  final FormTemplateEntity? selectedTemplate;
  final ValueChanged<FormTemplateEntity> onSelected;
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
  List<FormTemplateEntity> _filteredTemplates = [];

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
            (template.description.toLowerCase().contains(query));
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
                          subtitle: Text(
                            template.description.isNotEmpty
                                ? template.description
                                : '${template.fields.length} fields',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
