import 'dart:io';

import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SpiritualMediaDownloadService {
  SpiritualMediaDownloadService._();

  static const MethodChannel _channel =
      MethodChannel('dharma_app/spiritual_media_download');

  static Future<int?> _getAndroidSdkInt() async {
    if (!Platform.isAndroid) return null;
    final value = await _channel.invokeMethod<int>('getAndroidSdkInt');
    return value;
  }

  static Future<bool> ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final sdkInt = await _getAndroidSdkInt();
    if (sdkInt != null && sdkInt >= 29) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<String?> downloadImage({
    required String url,
    required String fileName,
    required String mimeType,
  }) async {
    final hasPermission = await ensureStoragePermission();
    if (!hasPermission) {
      ToastUtils.show('spiritual_media_storage_permission_required'.tr);
      return null;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      if (bytes.isEmpty) return null;

      final resolvedMimeType = response.headers.contentType?.mimeType ?? mimeType;
      final savedPath = await _channel.invokeMethod<String>(
        'saveImageToDownloads',
        <String, dynamic>{
          'bytes': bytes,
          'fileName': fileName,
          'mimeType': resolvedMimeType,
        },
      );
      return savedPath;
    } finally {
      client.close(force: true);
    }
  }

  static String sanitizeFileName(String rawName, {String extension = 'jpg'}) {
    final cleaned = rawName
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    final safe = cleaned.isEmpty ? 'spiritual_media' : cleaned;
    final lowerSafe = safe.toLowerCase();
    final normalizedExt = extension.replaceFirst('.', '').toLowerCase();
    if (lowerSafe.endsWith('.$normalizedExt')) {
      return safe;
    }
    return '$safe.$normalizedExt';
  }

  static String extensionFromMimeType(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      default:
        return 'jpg';
    }
  }
}
