import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Providers for loading & holding result
/// ─────────────────────────────────────────────────────────────────────────────
final resultLoadingProvider = StateProvider<bool>((ref) => true);
final resultDataProvider = StateProvider<Map<String, dynamic>?>( (ref) => null );

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.responseId});
  final int responseId;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchResult(ref));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchResult(WidgetRef ref) async {
    ref.read(resultLoadingProvider.notifier).state = true;

    // Simulate API
    await Future.delayed(const Duration(milliseconds: 700));

    // Build a bigger mock so you can see expand/collapse UX
    List<Map<String, dynamic>> makeQs(String cat, int n) => List.generate(n, (i) {
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
            {'type': 'remarks', 'text': 'General Feedback', 'answer': 'Store is improving overall.'},
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

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers for map/object-safe reads
  // ────────────────────────────────────────────────────────────────────────────
  static String _qType(dynamic q) {
    if (q is Map) return (q['type'] ?? '').toString();
    try { return (q.type ?? '').toString(); } catch (_) { return ''; }
  }
  static String _qText(dynamic q) {
    if (q is Map) return (q['text'] ?? '').toString();
    try { return (q.text ?? '').toString(); } catch (_) { return ''; }
  }
  static String _qAnswer(dynamic q) {
    if (q is Map) return (q['answer'] ?? '').toString();
    try { return (q.answer ?? '').toString(); } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(resultLoadingProvider);
    final data = ref.watch(resultDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
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

    final totalScore = (data['overall']?['obtainedMarks'] as num?)?.toDouble() ?? 0;
    final maxScore = (data['overall']?['totalMarks'] as num?)?.toDouble() ?? 0;
    final percent = maxScore == 0 ? 0.0 : totalScore / maxScore;
    final resultPercentLabel = '${(percent * 100).toStringAsFixed(1)}%';

    final String siteCode = (data['siteCode'] ?? 'N/A').toString();
    final String? siteName = data['siteName']?.toString();
    final DateTime timestamp = _safeParseDate(data['timestamp'] ?? data['submittedAt']);

    // split categories/questions and remarks
    final List categoriesRaw = (data['categories'] as List?) ?? const [];
    final List<Map<String, dynamic>> categories = categoriesRaw.map<Map<String, dynamic>>((cat) {
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
    }).toList();

    // feedback/remarks (first available)
    String feedback = 'No feedback submitted.';
    try {
      final r = categoriesRaw
          .expand((c) => (c['questions'] as List? ?? const []))
          .firstWhere((q) => _qType(q) == 'remarks' && (_qAnswer(q)).isNotEmpty);
      feedback = _qAnswer(r);
    } catch (_) {}

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 210,
              centerTitle: true,
              title: const Text('Result'),
              flexibleSpace: FlexibleSpaceBar(
                background: _ResultHeader(
                  siteCode: siteCode,
                  siteName: siteName,
                  timestamp: timestamp,
                  totalScore: totalScore.round(),
                  maxScore: maxScore.round(),
                  percent: percent,
                  percentLabel: resultPercentLabel,
                ),
              ),
              bottom: TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(text: 'Summary'),
                  Tab(text: 'All Questions'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              // SUMMARY TAB
              _SummaryTab(
                isDark: isDark,
                categories: categories,
                feedback: feedback,
                qType: _qType,
                qText: _qText,
                qAnswer: _qAnswer,
              ),

              // ALL QUESTIONS TAB
              _AllQuestionsTab(
                categories: categories,
                qType: _qType,
                qText: _qText,
                qAnswer: _qAnswer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static DateTime _safeParseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) {
      try { return DateTime.parse(v); } catch (_) {}
    }
    return DateTime.now();
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Header inside FlexibleSpace (responsive)
/// ─────────────────────────────────────────────────────────────────────────────
class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.siteCode,
    required this.siteName,
    required this.timestamp,
    required this.totalScore,
    required this.maxScore,
    required this.percent,
    required this.percentLabel,
  });

  final String siteCode;
  final String? siteName;
  final DateTime timestamp;
  final int totalScore;
  final int maxScore;
  final double percent;
  final String percentLabel;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMMM d, y').format(timestamp);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isCompact = w < 360;
        final pad = isCompact ? 12.0 : 16.0;
        final gaugeSize = isCompact ? 88.0 : 108.0;
        final stroke = isCompact ? 9.0 : 10.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(pad, 56, pad, pad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(siteCode, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(
                      siteName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(date, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Total Score: $totalScore / $maxScore',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Right gauge
              SizedBox(
                width: gaugeSize,
                height: gaugeSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: gaugeSize,
                      height: gaugeSize,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: stroke,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade300,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: gaugeSize,
                      height: gaugeSize,
                      child: CircularProgressIndicator(
                        value: percent.clamp(0.0, 1.0),
                        strokeWidth: stroke,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      percentLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// SUMMARY TAB (category cards with expandable questions & show more)
/// ─────────────────────────────────────────────────────────────────────────────
class _SummaryTab extends StatefulWidget {
  const _SummaryTab({
    required this.isDark,
    required this.categories,
    required this.feedback,
    required this.qType,
    required this.qText,
    required this.qAnswer,
  });

  final bool isDark;
  final List<Map<String, dynamic>> categories;
  final String feedback;

  final String Function(dynamic) qType;
  final String Function(dynamic) qText;
  final String Function(dynamic) qAnswer;

  @override
  State<_SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<_SummaryTab> {
  /// For each category index, how many items to show (progressive reveal)
  final Map<int, int> _visibleByCat = {};

  static const int _chunk = 5; // show 5, then +5

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Divider(),
        const SizedBox(height: 12),
        Text('Category Scores', style: textTheme.titleMedium),

        const SizedBox(height: 12),
        ...List.generate(widget.categories.length, (i) {
          final cat = widget.categories[i];
          final name = (cat['name'] ?? '').toString();
          final score = (cat['score'] as num? ?? 0).toDouble();
          final total = (cat['total'] as num? ?? 0).toDouble();
          final List qs = (cat['questions'] as List?) ?? const [];
          final percent = total == 0 ? 0.0 : (score / total);

          final visible = _visibleByCat[i] ?? min(_chunk, qs.length);
          final canShowMore = visible < qs.length;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white10 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.isDark
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              initiallyExpanded: true,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Text(
                      '${score.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} • ${(percent * 100).toStringAsFixed(0)}%',
                      style: textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8, right: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: widget.isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6, top: 2),
                    child: Text('Questions', style: textTheme.labelLarge),
                  ),
                ),
                ...qs.take(visible).map((q) {
                  final text = widget.qText(q);
                  final answer = widget.qAnswer(q);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(
                            answer.isEmpty ? text : '$text — $answer',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (canShowMore)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() {
                        _visibleByCat[i] = min(visible + _chunk, qs.length);
                      }),
                      child: Text('Show ${min(_chunk, qs.length - visible)} more'),
                    ),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 8),
        Text('Submitted Feedback', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white10 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(widget.feedback, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ALL QUESTIONS TAB (searchable, flat list across categories)
/// ─────────────────────────────────────────────────────────────────────────────
class _AllQuestionsTab extends StatefulWidget {
  const _AllQuestionsTab({
    required this.categories,
    required this.qType,
    required this.qText,
    required this.qAnswer,
  });

  final List<Map<String, dynamic>> categories;
  final String Function(dynamic) qType;
  final String Function(dynamic) qText;
  final String Function(dynamic) qAnswer;

  @override
  State<_AllQuestionsTab> createState() => _AllQuestionsTabState();
}

class _AllQuestionsTabState extends State<_AllQuestionsTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // flatten with category name
    final all = <Map<String, String>>[];
    for (final cat in widget.categories) {
      final name = (cat['name'] ?? '').toString();
      final List qs = (cat['questions'] as List?) ?? const [];
      for (final q in qs) {
        if (widget.qType(q) == 'remarks') continue;
        all.add({
          'category': name,
          'text': widget.qText(q),
          'answer': widget.qAnswer(q),
        });
      }
    }

    final filtered = _query.trim().isEmpty
        ? all
        : all.where((e) {
      final t = (e['text'] ?? '').toLowerCase();
      final a = (e['answer'] ?? '').toLowerCase();
      final q = _query.toLowerCase();
      return t.contains(q) || a.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search question or answer',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _query = ''),
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
            child: Text('No questions found', style: textTheme.bodyMedium),
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemBuilder: (_, i) {
              final item = filtered[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                title: Text(item['text'] ?? ''),
                subtitle: Text('Answer: ${item['answer'] ?? ''}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Text(item['category'] ?? '',
                      style: textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: filtered.length,
          ),
        ),
      ],
    );
  }
}
