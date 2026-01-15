part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  static const Object _sentinel = Object();

  const DashboardState({
    this.projects = const [],
    this.selectedProjectId,
    this.analytics,
    this.loading = false,
    this.error,
    this.lastSynced,
    this.offline = false,
    this.analyticsStale = false,
    this.requiresReauthentication = false,
    this.isInitialized = false,
  });

  final List<Project> projects;
  final String? selectedProjectId;
  final AnalyticsEntity? analytics;
  final bool loading;
  final String? error;
  final DateTime? lastSynced;
  final bool offline;
  final bool analyticsStale;
  final bool requiresReauthentication;
  final bool isInitialized;

  DashboardState copyWith({
    List<Project>? projects,
    String? selectedProjectId,
    AnalyticsEntity? analytics,
    bool? loading,
    Object? error = _sentinel,
    DateTime? lastSynced,
    bool? offline,
    bool? analyticsStale,
    bool? requiresReauthentication,
    bool? isInitialized,
  }) {
    return DashboardState(
      projects: projects ?? this.projects,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      analytics: analytics ?? this.analytics,
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
      lastSynced: lastSynced ?? this.lastSynced,
      offline: offline ?? this.offline,
      analyticsStale: analyticsStale ?? this.analyticsStale,
      requiresReauthentication:
          requiresReauthentication ?? this.requiresReauthentication,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [
    projects,
    selectedProjectId,
    analytics,
    loading,
    error,
    lastSynced?.millisecondsSinceEpoch,
    offline,
    analyticsStale,
    requiresReauthentication,
    isInitialized,
  ];
}
