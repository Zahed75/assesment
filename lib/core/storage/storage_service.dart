// lib/core/storage/storage_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_keys.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Provide SharedPreferences in main() override');
});

class StorageService {
  StorageService(this.prefs);
  final SharedPreferences prefs;

  String? get token => prefs.getString(StorageKeys.token);
  Future<void> setToken(String value) =>
      prefs.setString(StorageKeys.token, value);

  bool get onboardingSeen => prefs.getBool(StorageKeys.onboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool v) =>
      prefs.setBool(StorageKeys.onboardingSeen, v);

  String? get lastResponseId => prefs.getString(StorageKeys.lastResponseId);
  Future<void> setLastResponseId(String v) =>
      prefs.setString(StorageKeys.lastResponseId, v);
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.read(sharedPrefsProvider));
});
