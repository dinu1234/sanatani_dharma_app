import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future setToken(String token) async {
    await _prefs.setString("token", token);
  }

  static String? getToken() {
    return _prefs.getString("token");
  }

  static Future setProfileCompleted(bool value) async {
    await _prefs.setBool("profile_completed", value);
  }

  static bool isProfileCompleted() {
    return _prefs.getBool("profile_completed") ?? false;
  }

  static Future setLastSyncedFirebaseToken(String token) async {
    await _prefs.setString("last_synced_firebase_token", token);
  }

  static String? getLastSyncedFirebaseToken() {
    return _prefs.getString("last_synced_firebase_token");
  }

  static Future setLanguage(String code) async {
    await _prefs.setString("language", code);
  }

  static String getLanguage() {
    return _prefs.getString("language") ?? "en";
  }

  static Future setJapaProgress(String value) async {
    await _prefs.setString("japa_progress", value);
  }

  static String? getJapaProgress() {
    return _prefs.getString("japa_progress");
  }

  static Future setJapaPendingIncrement(int value) async {
    await _prefs.setInt("japa_pending_increment", value);
  }

  static int getJapaPendingIncrement() {
    return _prefs.getInt("japa_pending_increment") ?? 0;
  }

  static Future clear() async {
    await _prefs.clear();
  }
}
