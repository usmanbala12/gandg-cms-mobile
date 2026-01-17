import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../requests/presentation/cubit/request_create_cubit.dart';

class RequestCreatePage extends StatelessWidget {
  const RequestCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RequestCreateView();
  }
}

class _RequestCreateView extends StatefulWidget {
  const _RequestCreateView();

  @override
  State<_RequestCreateView> createState() => _RequestCreateViewState();
}

class _RequestCreateViewState extends State<_RequestCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'FUNDS';
  String _selectedPriority = 'MEDIUM';
  String _selectedCurrency = 'USD';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dashboardState = context.read<DashboardCubit>().state;
      if (dashboardState.selectedProjectId != null) {
        context.read<RequestCreateCubit>().submit(
              projectId: dashboardState.selectedProjectId!,
              type: _selectedType,
              title: _titleController.text,
              description: _descriptionController.text,
              priority: _selectedPriority,
              createdBy: 'current_user_id', // TODO: Get from AuthBloc
              amount: _selectedType == 'FUNDS'
                  ? double.tryParse(_amountController.text)
                  : null,
              currency: _selectedType == 'FUNDS' ? _selectedCurrency : null,
            );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active project selected')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Request',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: BlocListener<RequestCreateCubit, RequestCreateState>(
        listener: (context, state) {
          if (state is RequestCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Request created successfully')),
            );
            Navigator.pop(context);
          } else if (state is RequestCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Request Type',
                  border: OutlineInputBorder(),
                ),
                items: ['FUNDS', 'MATERIALS', 'EQUIPMENT', 'OTHER', 'LEAVE']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              if (_selectedType == 'FUNDS') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        items: ['USD', 'EUR', 'GBP']
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['LOW', 'MEDIUM', 'HIGH', 'URGENT', 'CRITICAL']
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<RequestCreateCubit, RequestCreateState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed:
                        state is RequestCreateSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is RequestCreateSubmitting
                        ? CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                          )
                        : const Text('Submit Request'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
