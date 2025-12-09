import 'package:equatable/equatable.dart';

/// Entity representing user notification preferences.
class UserPreferencesEntity extends Equatable {
  final bool appNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool issuesNotifications;
  final bool requestsNotifications;
  final bool reportsNotifications;

  const UserPreferencesEntity({
    this.appNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.issuesNotifications = true,
    this.requestsNotifications = true,
    this.reportsNotifications = true,
  });

  UserPreferencesEntity copyWith({
    bool? appNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? issuesNotifications,
    bool? requestsNotifications,
    bool? reportsNotifications,
  }) {
    return UserPreferencesEntity(
      appNotificationsEnabled:
          appNotificationsEnabled ?? this.appNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      issuesNotifications: issuesNotifications ?? this.issuesNotifications,
      requestsNotifications:
          requestsNotifications ?? this.requestsNotifications,
      reportsNotifications: reportsNotifications ?? this.reportsNotifications,
    );
  }

  @override
  List<Object?> get props => [
        appNotificationsEnabled,
        emailNotificationsEnabled,
        issuesNotifications,
        requestsNotifications,
        reportsNotifications,
      ];
}
