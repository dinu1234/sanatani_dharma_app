class LiveDarshanResponseModel {
  LiveDarshanResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final LiveDarshanData? data;

  factory LiveDarshanResponseModel.fromJson(Map<String, dynamic> json) {
    return LiveDarshanResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? LiveDarshanData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LiveDarshanData {
  LiveDarshanData({
    required this.liveDarshan,
    this.pagination,
  });

  final List<LiveDarshanItem> liveDarshan;
  final LiveDarshanPagination? pagination;

  factory LiveDarshanData.fromJson(Map<String, dynamic> json) {
    final items = json['live_darshan'];
    return LiveDarshanData(
      liveDarshan: items is List
          ? items
              .whereType<Map>()
              .map(
                (item) =>
                    LiveDarshanItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
          : const [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? LiveDarshanPagination.fromJson(
              json['pagination'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class LiveDarshanPagination {
  LiveDarshanPagination({
    this.page,
    this.limit,
    this.total,
  });

  final int? page;
  final int? limit;
  final int? total;

  factory LiveDarshanPagination.fromJson(Map<String, dynamic> json) {
    return LiveDarshanPagination(
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit']),
      total: _parseInt(json['total']),
    );
  }
}

class LiveDarshanItem {
  LiveDarshanItem({
    this.id,
    this.title,
    this.description,
    this.source,
    this.videoId,
    this.streamUrl,
    this.thumbnailImage,
    this.thumbnailImagePath,
    this.templeName,
    this.deityName,
    this.isLive = false,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String? title;
  final String? description;
  final String? source;
  final String? videoId;
  final String? streamUrl;
  final String? thumbnailImage;
  final String? thumbnailImagePath;
  final String? templeName;
  final String? deityName;
  final bool isLive;
  final int? sortOrder;
  final String? createdAt;
  final String? updatedAt;

  String get displayTitle =>
      title?.trim().isNotEmpty == true ? title!.trim() : 'Live Darshan';

  String get subtitle {
    final parts = <String>[
      if (templeName?.trim().isNotEmpty == true) templeName!.trim(),
      if (deityName?.trim().isNotEmpty == true) deityName!.trim(),
    ];
    return parts.isEmpty ? 'Temple stream' : parts.join(' | ');
  }

  String? get youtubeVideoId {
    final directId = videoId?.trim();
    if (directId != null && directId.isNotEmpty) {
      return directId;
    }
    return _extractYoutubeId(streamUrl);
  }

  bool get hasYoutubeSource =>
      source?.trim().toLowerCase() == 'youtube' && youtubeVideoId != null;

  factory LiveDarshanItem.fromJson(Map<String, dynamic> json) {
    return LiveDarshanItem(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      source: _parseString(json['source']),
      videoId: _parseString(json['video_id']),
      streamUrl: _parseString(json['stream_url']),
      thumbnailImage: _parseString(json['thumbnail_image']),
      thumbnailImagePath: _parseString(json['thumbnail_image_path']),
      templeName: _parseString(json['temple_name']),
      deityName: _parseString(json['deity_name']),
      isLive: _parseInt(json['is_live']) == 1,
      sortOrder: _parseInt(json['sort_order']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
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

String? _extractYoutubeId(String? url) {
  final value = url?.trim();
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  if (uri.host.contains('youtu.be')) {
    final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    return segment.isEmpty ? null : segment;
  }

  if (uri.host.contains('youtube.com')) {
    final watchId = uri.queryParameters['v']?.trim();
    if (watchId != null && watchId.isNotEmpty) return watchId;

    final embedIndex = uri.pathSegments.indexOf('embed');
    if (embedIndex != -1 && uri.pathSegments.length > embedIndex + 1) {
      final embedId = uri.pathSegments[embedIndex + 1].trim();
      if (embedId.isNotEmpty) return embedId;
    }

    final liveIndex = uri.pathSegments.indexOf('live');
    if (liveIndex != -1 && uri.pathSegments.length > liveIndex + 1) {
      final liveId = uri.pathSegments[liveIndex + 1].trim();
      if (liveId.isNotEmpty) return liveId;
    }
  }

  return null;
}
