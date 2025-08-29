// lib/features/auth/provider/auth_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assesment/utils/constants/token_storage.dart';

final authStateProvider = FutureProvider<bool>((ref) async {
  return await TokenStorage.isTokenValid();
});
