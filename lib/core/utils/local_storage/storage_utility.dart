import 'package:get_storage/get_storage.dart';

class TLocalStorage {
  static final TLocalStorage _instance = TLocalStorage._internal();
  final GetStorage _storage = GetStorage();

  factory TLocalStorage() => _instance;

  TLocalStorage._internal();

  /// Save data to local storage
  Future<void> saveData<T>(String key, T value) async =>
      await _storage.write(key, value);

  /// Read data from local storage
  T? readData<T>(String key) => _storage.read<T>(key);

  /// Remove specific data from local storage
  Future<void> removeData(String key) async => await _storage.remove(key);

  /// Clear all stored data
  Future<void> clearAll() async => await _storage.erase();
}
