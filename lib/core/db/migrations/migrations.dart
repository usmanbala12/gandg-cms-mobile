/// Migration scaffolding and examples for database schema changes.
///
/// When modifying the database schema:
/// 1. Update the table definition in lib/core/db/tables/
/// 2. Increment schemaVersion in app_database.dart
/// 3. Add migration logic in MigrationStrategy.onUpgrade()
/// 4. Add a test in test/db/migration_tests.dart
///
/// Example migration (v1 -> v2):
/// Adding thumbnail_path column to media table
///
/// In app_database.dart:
/// ```dart
/// @override
/// int get schemaVersion => 2;
///
/// @override
/// MigrationStrategy get migration => MigrationStrategy(
///   onCreate: (m) async {
///     await m.createAll();
///   },
///   onUpgrade: (m, from, to) async {
///     if (from == 1) {
///       // Add thumbnail_path column to media_files table
///       await m.addColumn(mediaFiles, mediaFiles.thumbnailPath);
///     }
///   },
/// );
/// ```
library;

class MigrationV1ToV2 {
  /// Migration from schema v1 to v2: Add thumbnail_path to media table.
  ///
  /// Changes:
  /// - Adds nullable thumbnail_path column to media_files table
  ///
  /// This allows storing local thumbnail paths for media files,
  /// enabling faster preview loading without re-generating thumbnails.
  static const String description =
      'Add thumbnail_path column to media_files table';

  static const int fromVersion = 1;
  static const int toVersion = 2;
}

/// Future migration template for v2 -> v3
class MigrationV2ToV3 {
  /// Example: Add sync metadata columns
  static const String description = 'Add sync metadata columns';
  static const int fromVersion = 2;
  static const int toVersion = 3;
}

/// Migration utilities and helpers
class MigrationUtils {
  /// Get migration description for a version change
  static String getMigrationDescription(int from, int to) {
    if (from == 1 && to == 2) {
      return MigrationV1ToV2.description;
    } else if (from == 2 && to == 3) {
      return MigrationV2ToV3.description;
    }
    return 'Unknown migration from v$from to v$to';
  }

  /// Check if a migration path is supported
  static bool isMigrationSupported(int from, int to) {
    // Only support sequential migrations
    return (to - from) == 1;
  }
}
