import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  AppInfoService._();

  static String _versionName = '';
  static String _buildNumber = '';

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _versionName = packageInfo.version.trim();
    _buildNumber = packageInfo.buildNumber.trim();
  }

  static String get versionLabel {
    if (_versionName.isEmpty) return '';
    if (_buildNumber.isEmpty) return _versionName;
    return '$_versionName';
  }
}
