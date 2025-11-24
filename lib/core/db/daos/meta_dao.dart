import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/meta.dart';

part 'meta_dao.g.dart';

@DriftAccessor(tables: [Meta])
class MetaDao extends DatabaseAccessor<AppDatabase> with _$MetaDaoMixin {
  MetaDao(super.db);

  Future<String?> getValue(String key) async {
    final result = (select(
      meta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return (await result)?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(
      meta,
    ).insertOnConflictUpdate(MetaCompanion.insert(key: key, value: value));
  }

  Future<int> deleteKey(String key) async {
    return (delete(meta)..where((t) => t.key.equals(key))).go();
  }

  Future<Map<String, String>> getAllMeta() async {
    final rows = await select(meta).get();
    return {for (final row in rows) row.key: row.value};
  }
}
