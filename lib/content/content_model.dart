class SponsorsResponseModel {
  SponsorsResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SponsorsData? data;

  factory SponsorsResponseModel.fromJson(Map<String, dynamic> json) {
    return SponsorsResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SponsorsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SponsorsData {
  SponsorsData({required this.sponsors});

  final List<SponsorItem> sponsors;

  factory SponsorsData.fromJson(Map<String, dynamic> json) {
    final sponsorsJson = json['sponsors'];
    return SponsorsData(
      sponsors: sponsorsJson is List
          ? sponsorsJson
              .whereType<Map>()
              .map((item) => SponsorItem.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class SponsorItem {
  SponsorItem({
    this.id,
    this.name,
    this.image,
    this.imagePath,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? imagePath;

  factory SponsorItem.fromJson(Map<String, dynamic> json) {
    return SponsorItem(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      image: _parseString(json['image']),
      imagePath: _parseString(json['image_path']),
    );
  }
}

class MantrasResponseModel {
  MantrasResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final MantrasData? data;

  factory MantrasResponseModel.fromJson(Map<String, dynamic> json) {
    return MantrasResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? MantrasData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MantrasData {
  MantrasData({required this.mantras});

  final List<MantraItem> mantras;

  factory MantrasData.fromJson(Map<String, dynamic> json) {
    final mantrasJson = json['mantras'];
    return MantrasData(
      mantras: mantrasJson is List
          ? mantrasJson
              .whereType<Map>()
              .map((item) => MantraItem.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class MantraItem {
  MantraItem({
    this.id,
    this.name,
    this.audioFile,
    this.audioPath,
  });

  final int? id;
  final String? name;
  final String? audioFile;
  final String? audioPath;

  factory MantraItem.fromJson(Map<String, dynamic> json) {
    return MantraItem(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      audioFile: _parseString(json['audio_file']),
      audioPath: _parseString(json['audio_path']),
    );
  }
}

int? _parseInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

String? _parseString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
