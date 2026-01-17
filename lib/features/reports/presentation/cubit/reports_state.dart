import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entity.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ReportEntity> reports;
  final bool isOffline;
  final DateTime? lastSyncedAt;
  final String? message;
  final bool hasReachedMax;
  final bool isFetchingMore;

  const ReportsLoaded({
    required this.reports,
    this.isOffline = false,
    this.lastSyncedAt,
    this.message,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
  });

  ReportsLoaded copyWith({
    List<ReportEntity>? reports,
    bool? isOffline,
    DateTime? lastSyncedAt,
    String? message,
    bool? hasReachedMax,
    bool? isFetchingMore,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      isOffline: isOffline ?? this.isOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message ?? this.message,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [
        reports,
        isOffline,
        lastSyncedAt,
        message,
        hasReachedMax,
        isFetchingMore,
      ];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportsNoProjectSelected extends ReportsState {}
