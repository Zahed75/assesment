// lib/features/survey/provider/survey_submit_api_provider.dart
import 'package:assesment/core/network/dio_provider.dart';
import 'package:assesment/features/question/api/survey_submit_api.dart';
import 'package:riverpod/riverpod.dart';

final surveySubmitApiProvider = Provider<SurveySubmitApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SurveySubmitApi(dio);
});
