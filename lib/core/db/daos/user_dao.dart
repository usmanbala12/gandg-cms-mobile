import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<void> insertUser(UserTableData user) =>
      into(users).insertOnConflictUpdate(user);

  Future<void> deleteUser() => delete(users).go();

  Future<UserTableData?> getCurrentUser() => select(users).getSingleOrNull();

  Stream<UserTableData?> watchCurrentUser() =>
      select(users).watchSingleOrNull();
}
