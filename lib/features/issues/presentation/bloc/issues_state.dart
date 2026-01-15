part of 'issues_bloc.dart';

@immutable
abstract class IssuesState extends Equatable {
  const IssuesState();

  @override
  List<Object?> get props => [];
}

class IssuesInitial extends IssuesState {}

class IssuesLoading extends IssuesState {}

class IssuesLoaded extends IssuesState {
  final List<IssueEntity> issues;
  final DataSource dataSource;
  final String? errorMessage;

  const IssuesLoaded(
    this.issues, {
    this.dataSource = DataSource.local,
    this.errorMessage,
  });

  IssuesLoaded copyWith({
    List<IssueEntity>? issues,
    DataSource? dataSource,
    String? errorMessage,
  }) {
    return IssuesLoaded(
      issues ?? this.issues,
      dataSource: dataSource ?? this.dataSource,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [issues, dataSource, errorMessage];
}

class IssuesError extends IssuesState {
  final String message;

  const IssuesError(this.message);

  @override
  List<Object?> get props => [message];
}
