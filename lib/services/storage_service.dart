import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  /// ✅ INIT
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // =========================
  // 🔐 TOKEN SAVE
  // =========================
  static Future setToken(String token) async {
    await _prefs.setString("token", token);
  }

  // =========================
  // 🔐 TOKEN GET
  // =========================
  static String? getToken() {
    return _prefs.getString("token");
  }

  // =========================
  // 🌐 LANGUAGE SAVE
  // =========================
  static Future setLanguage(String code) async {
    await _prefs.setString("language", code);
  }

  // =========================
  // 🌐 LANGUAGE GET
  // =========================
  static String getLanguage() {
    return _prefs.getString("language") ?? "en"; // default English
  }

  // =========================
  // ❌ CLEAR ALL (Logout)
  // =========================
  static Future clear() async {
    await _prefs.clear();
  }
}