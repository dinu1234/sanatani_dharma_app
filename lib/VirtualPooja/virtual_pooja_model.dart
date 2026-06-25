import 'package:dharma_app/core/constants/api_constants.dart';

class VirtualPoojaDeity {
  const VirtualPoojaDeity({
    required this.id,
    required this.name,
    this.isPaid = false,
    this.image,
    this.imageUrl,
    this.imageWidth,
    this.imageHeight,
  });

  final int id;
  final String name;
  final bool isPaid;
  final String? image;
  final String? imageUrl;
  final int? imageWidth;
  final int? imageHeight;

  bool get isFree => !isPaid;

  String? get fullImageUrl {
    final value = imageUrl?.trim().isNotEmpty == true
        ? imageUrl!.trim()
        : image?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${ApiConstants.baseUrl}$value';
  }

  factory VirtualPoojaDeity.fromJson(Map<String, dynamic> json) {
    return VirtualPoojaDeity(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      isPaid: _parseInt(json['is_paid']) == 1 || json['is_paid'] == true,
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
      imageWidth: _parseInt(json['image_width']),
      imageHeight: _parseInt(json['image_height']),
    );
  }
}

class VirtualPoojaDeityListResponse {
  const VirtualPoojaDeityListResponse({
    required this.success,
    this.message = '',
    this.deities = const [],
  });

  final bool success;
  final String message;
  final List<VirtualPoojaDeity> deities;

  factory VirtualPoojaDeityListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final rawDeities = data['deities'] is List
        ? data['deities'] as List
        : const [];

    return VirtualPoojaDeityListResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      deities: rawDeities
          .whereType<Map>()
          .map(
            (item) =>
                VirtualPoojaDeity.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((deity) => deity.id > 0 && deity.name.trim().isNotEmpty)
          .toList(),
    );
  }
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
