import 'package:assesment/features/result/widgets/resultplace_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../result.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized.');
});

// Provider to fetch last response ID from SharedPreferences
final lastResponseIdProvider = FutureProvider<int?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('last_response_id');
});

class LastResultScreen extends ConsumerWidget {
  const LastResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider for the last response ID
    final responseIdAsyncValue = ref.watch(lastResponseIdProvider);

    return responseIdAsyncValue.when(
      data: (responseId) {
        if (responseId != null) {
          return ResultScreen(responseId: responseId);
        } else {
          return const ResultPlaceholderScreen();
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text("Error loading data")),
    );
  }
}
