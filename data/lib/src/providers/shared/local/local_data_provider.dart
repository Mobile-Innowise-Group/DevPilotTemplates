import 'package:shared_preferences/shared_preferences.dart';

class LocalDataProvider {
  final SharedPreferences _prefs;

  const LocalDataProvider({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  Future<bool> contains(String key) async {
    return _prefs.containsKey(key);
  }

  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  Future<String?> readString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> writeString({
    required String key,
    required String value,
  }) async {
    await _prefs.setString(key, value);
  }

  Future<int?> readInt(String key) async {
    return _prefs.getInt(key);
  }

  Future<void> writeInt({
    required String key,
    required int value,
  }) async {
    await _prefs.setInt(key, value);
  }

  Future<double?> readDouble(String key) async {
    return _prefs.getDouble(key);
  }

  Future<void> writeDouble({
    required String key,
    required double value,
  }) async {
    await _prefs.setDouble(key, value);
  }

  Future<bool?> readBool(String key) async {
    return _prefs.getBool(key);
  }

  Future<void> writeBool({
    required String key,
    required bool value,
  }) async {
    await _prefs.setBool(key, value);
  }
}
