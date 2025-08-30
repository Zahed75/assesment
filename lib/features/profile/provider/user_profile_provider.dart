// lib/features/profile/provider/user_profile_provider.dart
import 'package:assesment/features/profile/api/user_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user_info_model.dart';

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<GetUserInfoModel>>((
      ref,
    ) {
      return UserProfileNotifier(ref);
    });

class UserProfileNotifier extends StateNotifier<AsyncValue<GetUserInfoModel>> {
  final Ref ref;

  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    // Auto-fetch when provider is created
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    print('🔄 Starting to fetch user profile...');
    state = const AsyncValue.loading();

    try {
      final apiService = ref.read(userApiServiceProvider);
      print('🔍 Calling user API service...');
      final userProfile = await apiService.getUserProfile();

      if (userProfile == null) {
        print('❌ Received null response from API');
        throw Exception('Received null response from API');
      }

      print('✅ User profile fetched successfully');
      state = AsyncValue.data(userProfile);
    } catch (error, stackTrace) {
      print('❌ Error in fetchUserProfile: $error');
      print('❌ Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearProfile() {
    state = const AsyncValue.loading();
  }
}
