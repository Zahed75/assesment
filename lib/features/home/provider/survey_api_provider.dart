// lib/features/survey/provider/survey_api_provider.dart
import 'package:assesment/core/network/dio_provider.dart';
import 'package:assesment/features/home/api/survey_api.dart';
import 'package:riverpod/riverpod.dart';

final surveyApiProvider = Provider<SurveyApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SurveyApi(dio);
});
