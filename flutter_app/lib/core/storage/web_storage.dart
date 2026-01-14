import 'package:shared_preferences/shared_preferences.dart';
import 'storage_interface.dart';

class WebStorage implements StorageInterface {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> write({required String key, required String? value}) async {
    final prefs = await _preferences;
    if (value != null) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  @override
  Future<String?> read({required String key}) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  @override
  Future<void> delete({required String key}) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }
}
