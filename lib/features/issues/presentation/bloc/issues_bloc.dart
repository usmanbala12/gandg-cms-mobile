import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
  String? _lastErrorMessage;
  String? _currentProjectId;
  bool _hasReachedMax = false;
  static const _pageSize = 20;

  IssuesBloc({required this.repository}) : super(IssuesInitial()) {
    on<LoadIssues>(_onLoadIssues);
    on<RefreshIssues>(_onRefreshIssues);
    on<FilterIssues>(_onFilterIssues);
    on<LoadMoreIssues>(_onLoadMoreIssues);
    on<IssuesUpdated>(_onIssuesUpdated);
  }

  Future<void> _onLoadIssues(
    LoadIssues event,
    Emitter<IssuesState> emit,
  ) async {
    emit(IssuesLoading());
    _currentProjectId = event.projectId;
    _currentFilters = event.filters ?? {};
    _hasReachedMax = false;
    _allIssues = [];

    try {
      final result = await repository.getIssues(
        projectId: event.projectId,
        filters: _currentFilters,
        limit: _pageSize,
        offset: 0,
      );

      if (result.hasError) {
        emit(IssuesError(result.errorMessage ?? 'Failed to load issues'));
      } else {
        _allIssues = result.issues;
        _lastErrorMessage = result.errorMessage;
        _hasReachedMax = result.issues.length < _pageSize;

        emit(IssuesLoaded(
          _allIssues,
          dataSource: DataSource.remote,
          errorMessage: _lastErrorMessage,
          hasReachedMax: _hasReachedMax,
        ));
      }
    } catch (e) {
      emit(IssuesError(e.toString()));
    }
  }

  Future<void> _onRefreshIssues(
    RefreshIssues event,
    Emitter<IssuesState> emit,
  ) async {
    // Refresh keeps current filters but resets pagination
    _currentProjectId = event.projectId;
    _hasReachedMax = false;
    // Don't clear _allIssues immediately to avoid UI flicker, 
    // but the getIssues call will replace it.
    
    try {
      final result = await repository.getIssues(
        projectId: event.projectId,
        forceRemote: true,
        filters: _currentFilters,
        limit: _pageSize,
        offset: 0,
      );

      if (result.hasError) {
        // If refresh fails, keep showing old data but with error
        if (state is IssuesLoaded) {
           emit((state as IssuesLoaded).copyWith(
             errorMessage: result.errorMessage ?? 'Failed to refresh'
           ));
        } else {
           emit(IssuesError(result.errorMessage ?? 'Failed to refresh'));
        }
      } else {
        _allIssues = result.issues;
        _lastErrorMessage = result.errorMessage;
        _hasReachedMax = result.issues.length < _pageSize;
        
        emit(IssuesLoaded(
          _allIssues,
          dataSource: DataSource.remote,
          errorMessage: _lastErrorMessage,
          hasReachedMax: _hasReachedMax,
        ));
      }
    } catch (e) {
      if (state is IssuesLoaded) {
         emit((state as IssuesLoaded).copyWith(errorMessage: e.toString()));
      } else {
         emit(IssuesError(e.toString()));
      }
    }
  }

  Future<void> _onFilterIssues(
    FilterIssues event,
    Emitter<IssuesState> emit,
  ) async {
    // Filtering now requires a reload from server
    add(LoadIssues(projectId: event.projectId, filters: event.filters));
  }

  Future<void> _onLoadMoreIssues(
    LoadMoreIssues event,
    Emitter<IssuesState> emit,
  ) async {
    if (_hasReachedMax || _currentProjectId == null) return;
    if (state is! IssuesLoaded) return;
    
    final currentState = state as IssuesLoaded;
    if (currentState.isFetchingMore) return;

    // Set fetching more flag
    emit(currentState.copyWith(isFetchingMore: true));

    try {
      final result = await repository.getIssues(
        projectId: _currentProjectId!,
        filters: _currentFilters,
        limit: _pageSize,
        offset: _allIssues.length,
      );

      if (result.hasError) {
        emit(currentState.copyWith(
          isFetchingMore: false,
          errorMessage: result.errorMessage ?? 'Failed to load more issues',
        ));
      } else {
        final newIssues = result.issues;
        _hasReachedMax = newIssues.length < _pageSize;
        _allIssues = [..._allIssues, ...newIssues];

        emit(currentState.copyWith(
          issues: _allIssues,
          isFetchingMore: false,
          hasReachedMax: _hasReachedMax,
          errorMessage: result.errorMessage,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(
        isFetchingMore: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onIssuesUpdated(
    IssuesUpdated event,
    Emitter<IssuesState> emit,
  ) async {
    // This event seems to come from a stream that we are no longer using for the main list
    // But if we did receive updates, we should probably merge them carefully or just replace.
    // tailored for the "watch" behavior which we disabled.
    // For now, let's just update the local list if it matches.
    
    // In a remote-only pagination world, real-time updates are tricky.
    // We'll assume this event might be manually triggered after an edit.
    // Ideally we should reload the current page or just update the specific item in the list.
    // But since the event gives a List<IssueEntity>, it implies a full replace.
    
    _allIssues = event.issues;
    emit(IssuesLoaded(
      _allIssues,
      dataSource: DataSource.remote,
      hasReachedMax: _hasReachedMax,
    ));
  }

  @override
  Future<void> close() {
    _issuesSubscription?.cancel();
    return super.close();
  }
}
