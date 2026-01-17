part of 'issues_bloc.dart';

@immutable
abstract class IssuesEvent extends Equatable {
  const IssuesEvent();

  @override
  List<Object?> get props => [];
}

class LoadIssues extends IssuesEvent {
  final String projectId;
  final Map<String, dynamic>? filters;

  const LoadIssues({required this.projectId, this.filters});

  @override
  List<Object?> get props => [projectId, filters];
}

class RefreshIssues extends IssuesEvent {
  final String projectId;

  const RefreshIssues({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class FilterIssues extends IssuesEvent {
  final String projectId;
  final Map<String, dynamic> filters;

  const FilterIssues({required this.projectId, required this.filters});

  @override
  List<Object?> get props => [projectId, filters];
}

class IssuesUpdated extends IssuesEvent {
  final List<IssueEntity> issues;

  const IssuesUpdated(this.issues);

  @override
  List<Object?> get props => [issues];
}

class LoadMoreIssues extends IssuesEvent {
  const LoadMoreIssues();
}
