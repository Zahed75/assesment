// lib/features/survey/api/survey_api.dart
import 'package:assesment/features/home/model/survey_list_model.dart';
import 'package:assesment/utils/constants/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:assesment/core/config/env.dart';

class SurveyApi {
  final Dio _dio;

  SurveyApi(this._dio);

  Future<SurveyListModel> getSurveysByUser() async {
    try {
      final token = await TokenStorage.getToken(); // Get the saved token
      if (token == null) {
        throw Exception('Authorization token is missing');
      }

      final response = await _dio.get(
        '${Env.surveyBaseUrl}/survey/api/survey_by_user/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Attach the token in header
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return SurveyListModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load surveys: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load surveys: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
