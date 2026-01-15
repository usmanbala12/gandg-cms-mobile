import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/data_source.dart';
import '../../domain/entities/issue_entity.dart';
import '../../domain/repositories/issue_repository.dart';

part 'issues_event.dart';
part 'issues_state.dart';

/// Top-level function for compute isolate - must be top-level or static
List<IssueEntity> _filterIssuesInIsolate(_FilterParams params) {
  final issues = params.issues;
  final filters = params.filters;

  if (filters.isEmpty) {
    return issues;
  }

  return issues.where((issue) {
    // Status Filter
    if (filters.containsKey('status')) {
      final statusFilter = filters['status'] as String;
      if (statusFilter != 'All') {
        final status = issue.status?.toUpperCase() ?? 'OPEN';
        final filter = statusFilter.toUpperCase().replaceAll(' ', '_');
        if (status != filter) return false;
      }
    }

    // Priority Filter
    if (filters.containsKey('priority')) {
      final priorityFilter = filters['priority'] as String;
      if (priorityFilter != 'All') {
        final priority = issue.priority?.toUpperCase() ?? 'MEDIUM';
        final filter = priorityFilter.toUpperCase();
        if (priority != filter) return false;
      }
    }

    // Search Query
    if (filters.containsKey('search')) {
      final query = (filters['search'] as String).toLowerCase();
      if (query.isNotEmpty) {
        final title = issue.title.toLowerCase();
        final desc = issue.description?.toLowerCase() ?? '';
        if (!title.contains(query) && !desc.contains(query)) return false;
      }
    }

    return true;
  }).toList();
}

/// Parameters for the isolate filter function
class _FilterParams {
  final List<IssueEntity> issues;
  final Map<String, dynamic> filters;

  const _FilterParams({required this.issues, required this.filters});
}

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  final IssueRepository repository;
  StreamSubscription? _issuesSubscription;

  List<IssueEntity> _allIssues = [];
  Map<String, dynamic> _currentFilters = {};
  String? _lastErrorMessage;

  IssuesBloc({required this.repository}) : super(IssuesInitial()) {
    on<LoadIssues>(_onLoadIssues);
    on<RefreshIssues>(_onRefreshIssues);
    on<FilterIssues>(_onFilterIssues);
    on<IssuesUpdated>(_onIssuesUpdated);
  }

  Future<void> _onLoadIssues(
    LoadIssues event,
    Emitter<IssuesState> emit,
  ) async {
    emit(IssuesLoading());
    _currentFilters = event.filters ?? {};
    try {
      // Subscribe to stream
      _issuesSubscription?.cancel();
      _issuesSubscription = repository
          .watchIssues(projectId: event.projectId)
          .listen((issues) {
            add(IssuesUpdated(issues));
          });
    } catch (e) {
      emit(IssuesError(e.toString()));
    }
  }

  Future<void> _onRefreshIssues(
    RefreshIssues event,
    Emitter<IssuesState> emit,
  ) async {
    try {
      // Trigger remote fetch and update state with result
      final result = await repository.getIssues(
        projectId: event.projectId,
        forceRemote: true,
      );

      // The watchIssues stream will automatically emit updated data
      // But we can also emit loading state with data source info
      if (result.hasError) {
        emit(IssuesError(result.errorMessage ?? 'Failed to refresh'));
      } else if (result.errorMessage != null) {
        _lastErrorMessage = result.errorMessage;
        await _emitFilteredIssues(emit);
      } else {
        _lastErrorMessage = null;
      }
    } catch (e) {
      emit(IssuesError(e.toString()));
    }
  }

  Future<void> _onFilterIssues(
    FilterIssues event,
    Emitter<IssuesState> emit,
  ) async {
    _currentFilters = event.filters;
    await _emitFilteredIssues(emit);
  }

  Future<void> _onIssuesUpdated(
    IssuesUpdated event,
    Emitter<IssuesState> emit,
  ) async {
    _allIssues = event.issues;
    await _emitFilteredIssues(emit);
  }

  Future<void> _emitFilteredIssues(Emitter<IssuesState> emit) async {
    // Use compute to offload filtering to a background isolate
    // This prevents jank when filtering large lists
    final filtered = await compute(
      _filterIssuesInIsolate,
      _FilterParams(issues: _allIssues, filters: _currentFilters),
    );

    emit(
      IssuesLoaded(
        filtered,
        dataSource: DataSource.local, // Stream data is always from local DB
        errorMessage: _lastErrorMessage,
      ),
    );
  }

  @override
  Future<void> close() {
    _issuesSubscription?.cancel();
    return super.close();
  }
}
