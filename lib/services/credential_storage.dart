import 'package:shared_preferences/shared_preferences.dart';

class CredentialsStorage {
  static const _userKey = 'ufrgs_user';
  static const _passwordKey = 'ufrgs_password';

  static Future<void> save({
    required String user,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user);
    await prefs.setString(_passwordKey, password);
  }

  static Future<(String, String)?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(_userKey);
    final password = prefs.getString(_passwordKey);

    if (user == null || password == null) return null;
    return (user, password);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_passwordKey);
  }
}
