// lib/features/profile/api/user_api_service.dart
import 'package:assesment/core/config/env.dart';
import 'package:assesment/core/network/dio_provider.dart';
import 'package:assesment/features/profile/model/user_info_model.dart';
import 'package:assesment/utils/constants/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

final userApiServiceProvider = Provider<UserApiService>((ref) {
  final dio = ref.read(dioProvider);
  return UserApiService(dio);
});

class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  Future<GetUserInfoModel> getUserProfile() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Authorization token is missing');
      }

      print(
        '🔄 Fetching user profile from: ${Env.centralAuthBaseUrl}/api/user/profile',
      );

      final response = await _dio.get(
        '${Env.centralAuthBaseUrl}/api/user/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('✅ User profile response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ User profile data received');
        return GetUserInfoModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioError in getUserProfile: ${e.message}');
      print('❌ Error Type: ${e.type}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');

      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error in getUserProfile: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
