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

  static Future setLoginMobile(String mobile) async {
    await _prefs.setString("login_mobile", mobile);
    await _prefs.remove("login_email");
  }

  static String? getLoginMobile() {
    return _prefs.getString("login_mobile");
  }

  static Future setLoginEmail(String email) async {
    await _prefs.setString("login_email", email);
    await _prefs.remove("login_mobile");
  }

  static String? getLoginEmail() {
    return _prefs.getString("login_email");
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

  static bool hasSavedLanguage() {
    return _prefs.containsKey("language");
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

  static Future setPublicSettings(String value) async {
    await _prefs.setString("public_settings", value);
  }

  static String? getPublicSettings() {
    return _prefs.getString("public_settings");
  }

  static Future clear() async {
    await _prefs.clear();
  }

  static Future clearSession() async {
    final savedLanguage = _prefs.getString("language");
    final savedPublicSettings = _prefs.getString("public_settings");

    await _prefs.clear();

    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      await _prefs.setString("language", savedLanguage);
    }
    if (savedPublicSettings != null && savedPublicSettings.isNotEmpty) {
      await _prefs.setString("public_settings", savedPublicSettings);
    }
  }
}
