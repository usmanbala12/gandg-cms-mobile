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

  const ReportsLoaded({
    required this.reports,
    this.isOffline = false,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [reports, isOffline, lastSyncedAt];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportsNoProjectSelected extends ReportsState {}
