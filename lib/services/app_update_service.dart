import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  AppUpdateService._();

  static bool _isChecking = false;

  static Future<bool> checkForForcedUpdate() async {
    if (_isChecking || kIsWeb || !Platform.isAndroid) {
      return true;
    }

    _isChecking = true;
    try {
      final info = await InAppUpdate.checkForUpdate();
      final updateAvailable =
          info.updateAvailability == UpdateAvailability.updateAvailable;

      if (!updateAvailable) {
        return true;
      }

      if (info.immediateUpdateAllowed) {
        try {
          await InAppUpdate.performImmediateUpdate();
        } catch (_) {
          return _showForceUpdateDialog();
        }

        final recheck = await InAppUpdate.checkForUpdate();
        return recheck.updateAvailability != UpdateAvailability.updateAvailable;
      }

      return _showForceUpdateDialog();
    } catch (_) {
      return true;
    } finally {
      _isChecking = false;
    }
  }

  static Future<bool> _showForceUpdateDialog() async {
    final shouldRetry = await Get.dialog<bool>(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('update_required'.tr),
          content: Text('update_required_message'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('exit_app'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text('update_now'.tr),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    if (shouldRetry == true) {
      return checkForForcedUpdate();
    }

    await SystemNavigator.pop();
    return false;
  }
}
