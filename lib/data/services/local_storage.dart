import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyToken = 'token';
  static const _keyUserId = 'user_id';
  static const _keyIsAdmin = 'is_admin';

  static Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _prefs();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs();
    return prefs.getString(_keyToken);
  }

  static Future<void> clearToken() async {
    final prefs = await _prefs();
    await prefs.remove(_keyToken);
  }

  static Future<void> saveUserId(int id) async {
    final prefs = await _prefs();
    await prefs.setInt(_keyUserId, id);
  }

  static Future<int?> getUserId() async {
    final prefs = await _prefs();
    return prefs.getInt(_keyUserId);
  }

  static Future<void> saveIsAdmin(bool isAdmin) async {
    final prefs = await _prefs();
    await prefs.setBool(_keyIsAdmin, isAdmin);
  }

  static Future<bool> getIsAdmin() async {
    final prefs = await _prefs();
    return prefs.getBool(_keyIsAdmin) ?? false;
  }
}
