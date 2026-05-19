import 'dart:convert';

import 'package:dharma_app/services/storage_service.dart';
import 'package:dharma_app/settings/app_settings_model.dart';
import 'package:dharma_app/settings/app_settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AppSettingsService extends GetxService {
  AppSettingsService({AppSettingsRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<AppSettingsRepository>()
              ? Get.find<AppSettingsRepository>()
              : Get.put(AppSettingsRepository(), permanent: true)) {
    _hydrateFromStorage();
  }

  final AppSettingsRepository _repository;
  final Map<String, PublicSettingItem> _settings =
      <String, PublicSettingItem>{};

  Map<String, PublicSettingItem> get settings =>
      Map<String, PublicSettingItem>.unmodifiable(_settings);

  double? get srcUnitPrice => _settings['src_unit_price']?.decimalValue;

  String get srcUnitPriceLabel {
    final price = srcUnitPrice;
    if (price == null) {
      return 'Rate will be applied as per current setting.';
    }
    final hasDecimals = price % 1 != 0;
    final amount = hasDecimals
        ? price.toStringAsFixed(2)
        : price.toStringAsFixed(0);
    return 'Current rate: Rs $amount per SRC';
  }

  Future<void> preloadPublicSettings() async {
    final response = await _repository.getPublicSettings();
    if (!response.success) {
      debugPrint('PUBLIC SETTINGS LOAD FAILED: ${response.message}');
      return;
    }

    final fetchedSettings =
        response.data?.settings ?? const <PublicSettingItem>[];
    if (fetchedSettings.isEmpty) {
      final singleSetting = response.data?.setting;
      if (singleSetting != null && singleSetting.settingKey.isNotEmpty) {
        _settings[singleSetting.settingKey] = singleSetting;
        await _persistSettings();
      }
      return;
    }

    _settings
      ..clear()
      ..addEntries(
        fetchedSettings
            .where((item) => item.settingKey.trim().isNotEmpty)
            .map((item) => MapEntry(item.settingKey, item)),
      );
    await _persistSettings();
  }

  void _hydrateFromStorage() {
    final raw = StorageService.getPublicSettings();
    if (raw == null || raw.trim().isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }
      _settings
        ..clear()
        ..addEntries(
          decoded.whereType<Map>().map((item) {
            final setting = PublicSettingItem.fromJson(
              Map<String, dynamic>.from(item),
            );
            return MapEntry(setting.settingKey, setting);
          }),
        );
    } catch (error) {
      debugPrint('PUBLIC SETTINGS CACHE PARSE FAILED: $error');
    }
  }

  Future<void> _persistSettings() async {
    final payload = _settings.values.map((item) => item.toJson()).toList();
    await StorageService.setPublicSettings(jsonEncode(payload));
  }
}
