// lib/services/update_service.dart
import 'package:app_installer_plus/app_installer_plus.dart';
import 'dart:async';

class UpdateService {
  static final StreamController<double> _progressController =
      StreamController<double>.broadcast();

  static Stream<double> get progressStream => _progressController.stream;

  static Future<void> downloadAndInstallUpdate(String apkUrl) async {
    try {
      await AppInstallerPlus().downloadAndInstallApk(
        downloadFileUrl: apkUrl,
        onError: (error) {
          print('Installation error: $error');
          _progressController.addError(error);
        },
        onProgress: (progress) {
          print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
          _progressController.add(progress);
        },
      );

      // Clean up after successful installation
      await AppInstallerPlus().removedDownloadedApk();
      _progressController.close();
    } catch (e) {
      print('Update failed: $e');
      _progressController.addError(e);
    }
  }
}
