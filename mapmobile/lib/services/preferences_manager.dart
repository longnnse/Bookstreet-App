import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();
  static SharedPreferences? _preferences;

  factory PreferencesManager() {
    return _instance;
  }

  PreferencesManager._internal();

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _preferences?.setString('user_data', jsonEncode(userData));
  }

  static Map<String, dynamic>? getUserData() {
    final userDataString = _preferences?.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  static Future<void> removeUserData() async {
    await _preferences?.remove('user_data');
  }

  static Future<void> clearAll() async {
    await _preferences?.clear();
  }
}
