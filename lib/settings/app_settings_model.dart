class PublicSettingsResponseModel {
  PublicSettingsResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final PublicSettingsData? data;

  factory PublicSettingsResponseModel.fromJson(Map<String, dynamic> json) {
    return PublicSettingsResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? PublicSettingsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PublicSettingsData {
  PublicSettingsData({required this.settings, this.setting});

  final List<PublicSettingItem> settings;
  final PublicSettingItem? setting;

  factory PublicSettingsData.fromJson(Map<String, dynamic> json) {
    final settingsJson = json['settings'];
    return PublicSettingsData(
      settings: settingsJson is List
          ? settingsJson
                .whereType<Map>()
                .map(
                  (item) => PublicSettingItem.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      setting: json['setting'] is Map<String, dynamic>
          ? PublicSettingItem.fromJson(json['setting'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PublicSettingItem {
  PublicSettingItem({
    required this.settingKey,
    this.label,
    this.description,
    this.type,
    this.settingValue,
    this.defaultValue,
    this.currency,
    this.isPublic,
  });

  final String settingKey;
  final String? label;
  final String? description;
  final String? type;
  final String? settingValue;
  final String? defaultValue;
  final String? currency;
  final bool? isPublic;

  factory PublicSettingItem.fromJson(Map<String, dynamic> json) {
    return PublicSettingItem(
      settingKey: json['setting_key']?.toString() ?? '',
      label: _readString(json['label']),
      description: _readString(json['description']),
      type: _readString(json['type']),
      settingValue: _readString(json['setting_value']),
      defaultValue: _readString(json['default_value']),
      currency: _readString(json['currency']),
      isPublic: json['is_public'] is bool ? json['is_public'] as bool : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setting_key': settingKey,
      'label': label,
      'description': description,
      'type': type,
      'setting_value': settingValue,
      'default_value': defaultValue,
      'currency': currency,
      'is_public': isPublic,
    };
  }

  double? get decimalValue =>
      double.tryParse(settingValue ?? defaultValue ?? '');
}

String? _readString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}
