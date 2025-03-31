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

  Future<String?> read(String key) async {
    return _prefs.getString(key);
  }

  Future<void> write({
    required String key,
    required String value,
  }) async {
    await _prefs.setString(key, value);
  }
}
