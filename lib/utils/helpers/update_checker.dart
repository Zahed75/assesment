// lib/utils/update_checker.dart

import 'package:flutter/src/widgets/framework.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateChecker {
  static Future<void> checkForUpdates({required BuildContext context}) async {
    try {
      // Get current app info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.parse(packageInfo.buildNumber);

      // Check for updates from your API
      final response = await http.get(
        Uri.parse('{{BaseURL}}/survey/api/app/download/'),
      );

      if (response.statusCode == 200) {
        final updateInfo = json.decode(response.body);
        final latestVersionCode = updateInfo['versionCode'];
        final apkUrl = updateInfo['apk_file_url'];
        final isMandatory = updateInfo['is_mandatory_update'] ?? false;

        // Check if update is needed
        if (latestVersionCode > currentVersionCode) {
          _showUpdateDialog(isMandatory, apkUrl);
        }
      }
    } catch (e) {
      print('Update check error: $e');
    }
  }

  static void _showUpdateDialog(bool isMandatory, String apkUrl) {
    // You'll need to use a navigator key or other method to show dialog
    // from anywhere in the app
    print('Update available: $apkUrl');
    // Implement your dialog logic here
  }
}
