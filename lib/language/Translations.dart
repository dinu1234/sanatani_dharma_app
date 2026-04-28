import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  AppTranslations(this._translationKeys);

  final Map<String, Map<String, String>> _translationKeys;

  static const List<String> _supportedCodes = [
    'en',
    'hi',
    'mr',
    'bn',
    'kn',
    'te',
    'ta',
    'gu',
  ];

  static Future<AppTranslations> loadFromAssets() async {
    final keys = <String, Map<String, String>>{};

    for (final code in _supportedCodes) {
      final rawJson = await rootBundle.loadString('assets/lang/$code.json');
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      keys[code] = decoded.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }

    return AppTranslations(keys);
  }

  @override
  Map<String, Map<String, String>> get keys => _translationKeys;
}
