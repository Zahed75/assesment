import 'package:assesment/features/result/widgets/category_score.dart';
import 'package:assesment/features/result/widgets/result_header.dart';
import 'package:assesment/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resultLoadingProvider = StateProvider<bool>((ref) => true);
final resultDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class ResultScreen extends ConsumerWidget {
  final int responseId;

  const ResultScreen({super.key, required this.responseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(resultLoadingProvider);
    final data = ref.watch(resultDataProvider);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load survey result'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                ref.read(resultLoadingProvider.notifier).state = true;
                await _fetchResult(ref);
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final totalScore = data['overall']['obtainedMarks'];
    final maxScore = data['overall']['totalMarks'];
    final String resultPercent =
        '${(data['overall']['percentage']).toStringAsFixed(1)}%';

    final List<Map<String, dynamic>> categoryScores = data['categories']
        .map((cat) {
          final questions = cat['questions']
              .where((q) => q['type'] != 'remarks')
              .toList();
          return {
            "name": cat['name'],
            "score": cat['obtainedMarks'],
            "total": cat['totalMarks'],
            "questions": questions,
          };
        })
        .where((cat) => (cat['questions'] as List).isNotEmpty)
        .toList();

    // 📝 Extract remarks
    String feedback = "No feedback submitted.";
    try {
      final remarks = data['categories']
          .expand((cat) => cat['questions'])
          .firstWhere((q) => q['type'] == 'remarks' && q['answer'] != null);
      feedback = remarks['answer'];
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(USizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurveyResultHeader(
            totalScore: totalScore.toInt(),
            maxScore: maxScore.toInt(),
            resultPercent: resultPercent,
            siteCode: data['siteCode'] ?? 'N/A',
            siteName: data['siteName'],
            timestamp: data['timestamp'] ?? data['submittedAt'],
          ),
          const SizedBox(height: USizes.spaceBtwSections),
          const Divider(),
          const SizedBox(height: USizes.spaceBtwSections),
          Text(
            "Category Scores",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: USizes.spaceBtwItems),
          SurveyCategoryScore(categoryScores: categoryScores, isDark: isDark),
          const SizedBox(height: USizes.spaceBtwSections),
          Text(
            "Submitted Feedback",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              feedback,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchResult(WidgetRef ref) async {
    // Simulating an API call and fetching the result
    await Future.delayed(const Duration(seconds: 2));

    final result = {
      'overall': {'obtainedMarks': 80, 'totalMarks': 100, 'percentage': 80.0},
      'categories': [
        {
          'name': 'Category 1',
          'obtainedMarks': 40,
          'totalMarks': 50,
          'questions': [],
        },
        {
          'name': 'Category 2',
          'obtainedMarks': 40,
          'totalMarks': 50,
          'questions': [],
        },
      ],
      'siteCode': 'Site123',
      'siteName': 'Site Name',
      'timestamp': '2025-08-21T12:00:00',
    };

    ref.read(resultDataProvider.notifier).state = result;
    ref.read(resultLoadingProvider.notifier).state = false;
  }
}
