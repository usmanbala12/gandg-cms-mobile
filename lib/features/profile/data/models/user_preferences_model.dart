import '../../domain/entities/user_preferences_entity.dart';

/// Data model for user preferences with JSON serialization.
class UserPreferencesModel extends UserPreferencesEntity {
  const UserPreferencesModel({
    super.appNotificationsEnabled,
    super.emailNotificationsEnabled,
    super.issuesNotifications,
    super.requestsNotifications,
    super.reportsNotifications,
  });

  /// Create from JSON.
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      appNotificationsEnabled:
          json['app_notifications_enabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['email_notifications_enabled'] as bool? ?? true,
      issuesNotifications: json['issues_notifications'] as bool? ?? true,
      requestsNotifications: json['requests_notifications'] as bool? ?? true,
      reportsNotifications: json['reports_notifications'] as bool? ?? true,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'app_notifications_enabled': appNotificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'issues_notifications': issuesNotifications,
      'requests_notifications': requestsNotifications,
      'reports_notifications': reportsNotifications,
    };
  }

  /// Convert to entity.
  UserPreferencesEntity toEntity() {
    return UserPreferencesEntity(
      appNotificationsEnabled: appNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      issuesNotifications: issuesNotifications,
      requestsNotifications: requestsNotifications,
      reportsNotifications: reportsNotifications,
    );
  }

  /// Create from entity.
  factory UserPreferencesModel.fromEntity(UserPreferencesEntity entity) {
    return UserPreferencesModel(
      appNotificationsEnabled: entity.appNotificationsEnabled,
      emailNotificationsEnabled: entity.emailNotificationsEnabled,
      issuesNotifications: entity.issuesNotifications,
      requestsNotifications: entity.requestsNotifications,
      reportsNotifications: entity.reportsNotifications,
    );
  }
}
