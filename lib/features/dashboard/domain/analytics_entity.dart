import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/db_utils.dart';

/// Domain representation of the cached dashboard analytics payload.
/// Provides typed collections for charts and recent activity along with
/// freshness metadata used by the UI layer.
class AnalyticsEntity extends Equatable {
  final String projectId;
  final int reportsCount;
  final int pendingRequests;
  final int openIssues;
  final List<TimeSeriesPoint> reportTrend;
  final List<StatusSegment> statusBreakdown;
  final List<RecentActivityEntry> recentActivity;
  final DateTime? lastSyncedAt;
  final bool isStale;
  final bool isExpired;

  const AnalyticsEntity({
    required this.projectId,
    required this.reportsCount,
    required this.pendingRequests,
    required this.openIssues,
    required this.reportTrend,
    required this.statusBreakdown,
    required this.recentActivity,
    required this.lastSyncedAt,
    required this.isStale,
    required this.isExpired,
  });

  bool get hasData =>
      reportsCount > 0 ||
      pendingRequests > 0 ||
      openIssues > 0 ||
      reportTrend.isNotEmpty ||
      statusBreakdown.isNotEmpty ||
      recentActivity.isNotEmpty;

  AnalyticsEntity copyWith({
    int? reportsCount,
    int? pendingRequests,
    int? openIssues,
    List<TimeSeriesPoint>? reportTrend,
    List<StatusSegment>? statusBreakdown,
    List<RecentActivityEntry>? recentActivity,
    DateTime? lastSyncedAt,
    bool? isStale,
    bool? isExpired,
  }) {
    return AnalyticsEntity(
      projectId: projectId,
      reportsCount: reportsCount ?? this.reportsCount,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      openIssues: openIssues ?? this.openIssues,
      reportTrend: reportTrend ?? this.reportTrend,
      statusBreakdown: statusBreakdown ?? this.statusBreakdown,
      recentActivity: recentActivity ?? this.recentActivity,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isStale: isStale ?? this.isStale,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  /// Build an [AnalyticsEntity] from a cached [ProjectAnalytic] row.
  factory AnalyticsEntity.fromRow(
    ProjectAnalytic row, {
    required DateTime now,
    bool isStale = false,
  }) {
    final lastSynced = row.lastSynced != null
        ? DateTime.fromMillisecondsSinceEpoch(row.lastSynced!, isUtc: true)
        : null;

    final expired = lastSynced == null
        ? true
        : now.difference(lastSynced).inMilliseconds > CacheTTL.analyticsTTL;

    return AnalyticsEntity(
      projectId: row.projectId,
      reportsCount: row.reportsCount,
      pendingRequests: row.requestsPending,
      openIssues: row.openIssues,
      reportTrend: _parseTimeSeries(row.reportsTimeseries),
      statusBreakdown: _parseStatusDistribution(row.requestsByStatus),
      recentActivity: _parseRecentActivity(row.recentActivity),
      lastSyncedAt: lastSynced,
      isStale: isStale,
      isExpired: expired,
    );
  }

  /// Empty placeholder used when no analytics are available locally or remotely.
  factory AnalyticsEntity.empty(String projectId) => AnalyticsEntity(
    projectId: projectId,
    reportsCount: 0,
    pendingRequests: 0,
    openIssues: 0,
    reportTrend: const [],
    statusBreakdown: const [],
    recentActivity: const [],
    lastSyncedAt: null,
    isStale: false,
    isExpired: true,
  );

  static List<TimeSeriesPoint> _parseTimeSeries(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) {
              if (item is Map) {
                final count = _parseInt(item['count']);
                final tsRaw = item['timestamp'] ?? item['date'];
                final timestamp = _parseDate(tsRaw);
                if (timestamp != null) {
                  return TimeSeriesPoint(timestamp, count);
                }
              }
              return null;
            })
            .whereType<TimeSeriesPoint>()
            .toList();
      }
      if (decoded is Map) {
        return decoded.entries
            .map((entry) {
              final timestamp = _parseDate(entry.key);
              final count = _parseInt(entry.value);
              if (timestamp != null) {
                return TimeSeriesPoint(timestamp, count);
              }
              return null;
            })
            .whereType<TimeSeriesPoint>()
            .toList();
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }

  static List<StatusSegment> _parseStatusDistribution(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        return decoded.entries
            .map(
              (entry) =>
                  StatusSegment(entry.key.toString(), _parseInt(entry.value)),
            )
            .where((segment) => segment.count > 0)
            .toList();
      }
      if (decoded is List) {
        return decoded
            .map((item) {
              if (item is Map) {
                final label = item['status'] ?? item['label'] ?? item['key'];
                if (label == null) return null;
                final count = _parseInt(item['count']);
                return StatusSegment(label.toString(), count);
              }
              return null;
            })
            .whereType<StatusSegment>()
            .toList();
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }

  static List<RecentActivityEntry> _parseRecentActivity(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) {
              if (item is Map) {
                final type = item['type']?.toString() ?? 'activity';
                final title = (item['title'] ?? item['summary'] ?? '')
                    .toString();
                final description =
                    (item['description'] ?? item['detail'] ?? '').toString();
                final timestamp = _parseDate(item['timestamp'] ?? item['time']);
                return RecentActivityEntry(
                  type: type,
                  title: title.isNotEmpty ? title : type,
                  description: description,
                  timestamp: timestamp,
                );
              }
              return null;
            })
            .whereType<RecentActivityEntry>()
            .toList();
      }
    } catch (_) {
      return const [];
    }
    return const [];
  }

  static int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      final millis = value > 9999999999 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
    if (value is num) {
      final millis = value > 9999999999
          ? value.toInt()
          : (value * 1000).toInt();
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toUtc();
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    projectId,
    reportsCount,
    pendingRequests,
    openIssues,
    reportTrend,
    statusBreakdown,
    recentActivity,
    lastSyncedAt?.millisecondsSinceEpoch,
    isStale,
    isExpired,
  ];
}

class TimeSeriesPoint extends Equatable {
  final DateTime timestamp;
  final int count;

  const TimeSeriesPoint(this.timestamp, this.count);

  @override
  List<Object?> get props => [timestamp.millisecondsSinceEpoch, count];
}

class StatusSegment extends Equatable {
  final String label;
  final int count;

  const StatusSegment(this.label, this.count);

  StatusSegment copyWith({String? label, int? count}) =>
      StatusSegment(label ?? this.label, count ?? this.count);

  @override
  List<Object?> get props => [label, count];
}

class RecentActivityEntry extends Equatable {
  final String type;
  final String title;
  final String description;
  final DateTime? timestamp;

  const RecentActivityEntry({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    type,
    title,
    description,
    timestamp?.millisecondsSinceEpoch,
  ];
}
