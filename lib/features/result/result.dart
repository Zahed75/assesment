// lib/features/result/result_screen.dart
import 'package:assesment/features/result/widgets/all_question_tab.dart';
import 'package:assesment/features/result/widgets/result_header.dart';
import 'package:assesment/features/result/widgets/summary_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Providers
final resultLoadingProvider = StateProvider<bool>((ref) => true);
final resultDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.responseId});
  final int responseId;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchResult(ref));
  }

  Future<void> _fetchResult(WidgetRef ref) async {
    ref.read(resultLoadingProvider.notifier).state = true;

    // Simulate API
    await Future.delayed(const Duration(milliseconds: 700));

    // Build a bigger mock so you can see expand/collapse UX
    List<Map<String, dynamic>> makeQs(String cat, int n) =>
        List.generate(n, (i) {
          final yesNo = (i % 3 == 0) ? 'Yes' : 'No';
          return {
            'type': 'boolean',
            'text': '$cat • Question ${i + 1}',
            'answer': yesNo,
            'weight': 2, // optional, unused here but realistic
          };
        });

    final mock = {
      'overall': {'obtainedMarks': 80, 'totalMarks': 100, 'percentage': 80.0},
      'categories': [
        {
          'name': 'Storefront',
          'obtainedMarks': 40,
          'totalMarks': 50,
          'questions': [
            ...makeQs('Storefront', 14),
            {
              'type': 'remarks',
              'text': 'General Feedback',
              'answer': 'Store is improving overall.',
            },
          ],
        },
        {
          'name': 'Operations',
          'obtainedMarks': 40,
          'totalMarks': 50,
          'questions': makeQs('Operations', 27),
        },
      ],
      'siteCode': 'D011',
      'siteName': 'Demo Outlet',
      'timestamp': DateTime(2025, 8, 22).toIso8601String(),
    };

    ref.read(resultDataProvider.notifier).state = mock;
    ref.read(resultLoadingProvider.notifier).state = false;
  }

  // Helper methods
  static String _qType(dynamic q) {
    if (q is Map) return (q['type'] ?? '').toString();
    try {
      return (q.type ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static String _qText(dynamic q) {
    if (q is Map) return (q['text'] ?? '').toString();
    try {
      return (q.text ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static String _qAnswer(dynamic q) {
    if (q is Map) return (q['answer'] ?? '').toString();
    try {
      return (q.answer ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  static DateTime _safeParseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(resultLoadingProvider);
    final data = ref.watch(resultDataProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (loading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (data == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Result'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load survey result'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _fetchResult(ref),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final totalScore =
        (data['overall']?['obtainedMarks'] as num?)?.toDouble() ?? 0;
    final maxScore = (data['overall']?['totalMarks'] as num?)?.toDouble() ?? 0;
    final percent = maxScore == 0 ? 0.0 : totalScore / maxScore;
    final resultPercentLabel = '${(percent * 100).toStringAsFixed(1)}%';

    final String siteCode = (data['siteCode'] ?? 'N/A').toString();
    final String? siteName = data['siteName']?.toString();
    final DateTime timestamp = _safeParseDate(
      data['timestamp'] ?? data['submittedAt'],
    );

    // split categories/questions and remarks
    final List categoriesRaw = (data['categories'] as List?) ?? const [];
    final List<Map<String, dynamic>> categories = categoriesRaw
        .map<Map<String, dynamic>>((cat) {
          final name = (cat['name'] ?? '').toString();
          final score = (cat['obtainedMarks'] as num? ?? 0).toDouble();
          final tot = (cat['totalMarks'] as num? ?? 0).toDouble();
          final qs = (cat['questions'] as List?) ?? const [];
          final nonRemarks = qs.where((q) => _qType(q) != 'remarks').toList();
          return {
            'name': name,
            'score': score,
            'total': tot,
            'questions': nonRemarks,
          };
        })
        .toList();

    // feedback/remarks (first available)
    String feedback = 'No feedback submitted.';
    try {
      final r = categoriesRaw
          .expand((c) => (c['questions'] as List? ?? const []))
          .firstWhere(
            (q) => _qType(q) == 'remarks' && (_qAnswer(q)).isNotEmpty,
          );
      feedback = _qAnswer(r);
    } catch (_) {}

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Fixed Header
            ResultHeader(
              siteCode: siteCode,
              siteName: siteName,
              timestamp: timestamp,
              totalScore: totalScore.round(),
              maxScore: maxScore.round(),
              percent: percent,
              percentLabel: resultPercentLabel,
            ),

            // Fixed Tab Bar
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: TabBar(
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                  0.6,
                ),
                tabs: const [
                  Tab(text: 'Summary'),
                  Tab(text: 'All Questions'),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: TabBarView(
                  children: [
                    // SUMMARY TAB
                    SummaryTab(
                      isDark: isDark,
                      categories: categories,
                      feedback: feedback,
                      qType: _qType,
                      qText: _qText,
                      qAnswer: _qAnswer,
                    ),

                    // ALL QUESTIONS TAB
                    AllQuestionsTab(
                      categories: categories,
                      qType: _qType,
                      qText: _qText,
                      qAnswer: _qAnswer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
