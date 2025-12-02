import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/data_source.dart';
import '../../domain/entities/issue_entity.dart';
import '../../domain/repositories/issue_repository.dart';

part 'issues_event.dart';
part 'issues_state.dart';

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  final IssueRepository repository;
  StreamSubscription? _issuesSubscription;

  List<IssueEntity> _allIssues = [];
  Map<String, dynamic> _currentFilters = {};

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
      }
    } catch (e) {
      emit(IssuesError(e.toString()));
    }
  }

  void _onFilterIssues(FilterIssues event, Emitter<IssuesState> emit) {
    _currentFilters = event.filters;
    _emitFilteredIssues(emit);
  }

  void _onIssuesUpdated(IssuesUpdated event, Emitter<IssuesState> emit) {
    _allIssues = event.issues;
    _emitFilteredIssues(emit);
  }

  void _emitFilteredIssues(Emitter<IssuesState> emit) {
    List<IssueEntity> filtered = _allIssues;

    // Apply filters
    if (_currentFilters.isNotEmpty) {
      filtered = filtered.where((issue) {
        // Status Filter
        if (_currentFilters.containsKey('status')) {
          final statusFilter = _currentFilters['status'] as String;
          if (statusFilter != 'All') {
            final status = issue.status?.toUpperCase() ?? 'OPEN';
            final filter = statusFilter.toUpperCase().replaceAll(' ', '_');
            if (status != filter) return false;
          }
        }

        // Priority Filter
        if (_currentFilters.containsKey('priority')) {
          final priorityFilter = _currentFilters['priority'] as String;
          if (priorityFilter != 'All') {
            final priority = issue.priority?.toUpperCase() ?? 'MEDIUM';
            final filter = priorityFilter.toUpperCase();
            if (priority != filter) return false;
          }
        }

        // Search Query
        if (_currentFilters.containsKey('search')) {
          final query = (_currentFilters['search'] as String).toLowerCase();
          if (query.isNotEmpty) {
            final title = issue.title.toLowerCase();
            final desc = issue.description?.toLowerCase() ?? '';
            if (!title.contains(query) && !desc.contains(query)) return false;
          }
        }

        return true;
      }).toList();
    }

    emit(
      IssuesLoaded(
        filtered,
        dataSource: DataSource.local, // Stream data is always from local DB
      ),
    );
  }

  @override
  Future<void> close() {
    _issuesSubscription?.cancel();
    return super.close();
  }
}
