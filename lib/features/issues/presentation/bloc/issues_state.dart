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
  final bool hasReachedMax;
  final bool isFetchingMore;

  const IssuesLoaded(
    this.issues, {
    this.dataSource = DataSource.local,
    this.errorMessage,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  IssuesLoaded copyWith({
    List<IssueEntity>? issues,
    DataSource? dataSource,
    String? errorMessage,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return IssuesLoaded(
      issues ?? this.issues,
      dataSource: dataSource ?? this.dataSource,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [
        issues,
        dataSource,
        errorMessage,
        hasReachedMax,
        isFetchingMore,
      ];
}

class IssuesError extends IssuesState {
  final String message;

  const IssuesError(this.message);

  @override
  List<Object?> get props => [message];
}
