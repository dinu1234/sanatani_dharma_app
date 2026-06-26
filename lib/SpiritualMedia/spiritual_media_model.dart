import 'package:get/get.dart';

class SpiritualMediaListResponse {
  SpiritualMediaListResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  final bool success;
  final String message;
  final SpiritualMediaListData? data;
  final int? statusCode;

  factory SpiritualMediaListResponse.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return SpiritualMediaListResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SpiritualMediaListData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      statusCode: statusCode,
    );
  }
}

class SpiritualMediaListData {
  SpiritualMediaListData({
    required this.media,
    this.pagination,
  });

  final List<SpiritualMediaItem> media;
  final SpiritualMediaPagination? pagination;

  factory SpiritualMediaListData.fromJson(Map<String, dynamic> json) {
    final items = json['media'];
    return SpiritualMediaListData(
      media: items is List
          ? items
              .whereType<Map>()
              .map(
                (item) =>
                    SpiritualMediaItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
          : const [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? SpiritualMediaPagination.fromJson(
              json['pagination'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class SpiritualMediaPagination {
  SpiritualMediaPagination({
    this.page,
    this.limit,
    this.total,
  });

  final int? page;
  final int? limit;
  final int? total;

  factory SpiritualMediaPagination.fromJson(Map<String, dynamic> json) {
    return SpiritualMediaPagination(
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit']),
      total: _parseInt(json['total']),
    );
  }
}

class SpiritualMediaDetailResponse {
  SpiritualMediaDetailResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  final bool success;
  final String message;
  final SpiritualMediaDetailData? data;
  final int? statusCode;

  factory SpiritualMediaDetailResponse.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return SpiritualMediaDetailResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SpiritualMediaDetailData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      statusCode: statusCode,
    );
  }
}

class SpiritualMediaDetailData {
  SpiritualMediaDetailData({
    this.media,
    this.download,
  });

  final SpiritualMediaDetailItem? media;
  final SpiritualMediaDownloadData? download;

  factory SpiritualMediaDetailData.fromJson(Map<String, dynamic> json) {
    return SpiritualMediaDetailData(
      media: json['media'] is Map<String, dynamic>
          ? SpiritualMediaDetailItem.fromJson(
              json['media'] as Map<String, dynamic>,
            )
          : null,
      download: json['download'] is Map<String, dynamic>
          ? SpiritualMediaDownloadData.fromJson(
              json['download'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class SpiritualMediaDownloadData {
  SpiritualMediaDownloadData({
    required this.isDownloadable,
    this.downloadPath,
  });

  final bool isDownloadable;
  final String? downloadPath;

  factory SpiritualMediaDownloadData.fromJson(Map<String, dynamic> json) {
    return SpiritualMediaDownloadData(
      isDownloadable: json['is_downloadable'] == true,
      downloadPath: _parseString(json['download_path']),
    );
  }
}

class SpiritualMediaItem {
  SpiritualMediaItem({
    this.id,
    this.title,
    this.description,
    this.mediaType,
    this.quoteText,
    this.teachingSource,
    this.imageDisplayPath,
    this.imageThumbPath,
    this.displayWidth,
    this.displayHeight,
    this.thumbWidth,
    this.thumbHeight,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String? title;
  final String? description;
  final String? mediaType;
  final String? quoteText;
  final String? teachingSource;
  final String? imageDisplayPath;
  final String? imageThumbPath;
  final int? displayWidth;
  final int? displayHeight;
  final int? thumbWidth;
  final int? thumbHeight;
  final int? sortOrder;
  final String? createdAt;
  final String? updatedAt;

  String get displayTitle =>
      title?.trim().isNotEmpty == true ? title!.trim() : 'spiritual_media'.tr;

  String get displaySubtitle {
    final source = teachingSource?.trim();
    if (source != null && source.isNotEmpty) return source;
    final quote = quoteText?.trim();
    if (quote != null && quote.isNotEmpty) return quote;
    final desc = description?.trim();
    if (desc != null && desc.isNotEmpty) return desc;
    return '';
  }

  factory SpiritualMediaItem.fromJson(Map<String, dynamic> json) {
    return SpiritualMediaItem(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      mediaType: _parseString(json['media_type']),
      quoteText: _parseString(json['quote_text']),
      teachingSource: _parseString(json['teaching_source']),
      imageDisplayPath: _parseString(json['image_display_path']),
      imageThumbPath: _parseString(json['image_thumb_path']),
      displayWidth: _parseInt(json['display_width']),
      displayHeight: _parseInt(json['display_height']),
      thumbWidth: _parseInt(json['thumb_width']),
      thumbHeight: _parseInt(json['thumb_height']),
      sortOrder: _parseInt(json['sort_order']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
    );
  }
}

class SpiritualMediaDetailItem extends SpiritualMediaItem {
  SpiritualMediaDetailItem({
    super.id,
    super.title,
    super.description,
    super.mediaType,
    super.quoteText,
    super.teachingSource,
    super.imageDisplayPath,
    super.imageThumbPath,
    super.displayWidth,
    super.displayHeight,
    super.thumbWidth,
    super.thumbHeight,
    super.sortOrder,
    super.createdAt,
    super.updatedAt,
    this.imageOriginalPath,
    this.imageType,
    this.originalWidth,
    this.originalHeight,
  });

  final String? imageOriginalPath;
  final String? imageType;
  final int? originalWidth;
  final int? originalHeight;

  factory SpiritualMediaDetailItem.fromJson(Map<String, dynamic> json) {
    return SpiritualMediaDetailItem(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      mediaType: _parseString(json['media_type']),
      quoteText: _parseString(json['quote_text']),
      teachingSource: _parseString(json['teaching_source']),
      imageDisplayPath: _parseString(json['image_display_path']),
      imageThumbPath: _parseString(json['image_thumb_path']),
      displayWidth: _parseInt(json['display_width']),
      displayHeight: _parseInt(json['display_height']),
      thumbWidth: _parseInt(json['thumb_width']),
      thumbHeight: _parseInt(json['thumb_height']),
      sortOrder: _parseInt(json['sort_order']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
      imageOriginalPath: _parseString(json['image_original_path']),
      imageType: _parseString(json['image_type']),
      originalWidth: _parseInt(json['original_width']),
      originalHeight: _parseInt(json['original_height']),
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
