// lib/features/result/widgets/category_score.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyCategoryScore extends ConsumerStatefulWidget {
  const SurveyCategoryScore({
    super.key,
    required this.categoryScores,
    required this.isDark,
  });

  /// Each item: {
  ///   'name': String,
  ///   'score': num,
  ///   'total': num,
  ///   'questions': List<dynamic>  // maps or objects
  /// }
  final List<Map<String, dynamic>> categoryScores;
  final bool isDark;

  @override
  ConsumerState<SurveyCategoryScore> createState() => _SurveyCategoryScoreState();
}

class _SurveyCategoryScoreState extends ConsumerState<SurveyCategoryScore> {
  // --- Safe getters that work for Map or Object with fields ---
  String _qType(dynamic q) {
    if (q is Map) return (q['type'] ?? '').toString();
    try {
      // ignore: avoid_dynamic_calls
      return (q.type ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  String _qText(dynamic q) {
    if (q is Map) return (q['text'] ?? '').toString();
    try {
      // ignore: avoid_dynamic_calls
      return (q.text ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  String _qAnswer(dynamic q) {
    if (q is Map) return (q['answer'] ?? '').toString();
    try {
      // ignore: avoid_dynamic_calls
      return (q.answer ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // If widget received any question models instead of maps, this still works.
    final items = widget.categoryScores.map<Map<String, dynamic>>((cat) {
      final name = (cat['name'] ?? '').toString();
      final score = (cat['score'] as num? ?? 0).toDouble();
      final total = (cat['total'] as num? ?? 0).toDouble();
      final rawQs = (cat['questions'] as List?) ?? const [];

      // Only non-remarks list for display under category
      final visibleQs = rawQs.where((q) => _qType(q) != 'remarks').toList();

      return <String, dynamic>{
        'name': name,
        'score': score,
        'total': total,
        'questions': visibleQs,
      };
    }).toList();

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No category scores available.',
          style: textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: items.map((cat) {
        final String name = cat['name'] as String;
        final double score = (cat['score'] as num).toDouble();
        final double total = (cat['total'] as num).toDouble();
        final List questions = (cat['questions'] as List);

        final percent = total == 0 ? 0.0 : (score / total);
        final percentLabel =
        total == 0 ? '0%' : '${(percent * 100).toStringAsFixed(0)}%';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white10 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isDark
                ? []
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + score chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Text(
                      '${score.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} • $percentLabel',
                      style: textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor:
                  widget.isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 10),

              // Questions preview (non-remarks)
              if (questions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Questions', style: textTheme.labelLarge),
                    const SizedBox(height: 6),
                    ...questions.take(4).map((q) {
                      final text = _qText(q);
                      final answer = _qAnswer(q);
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
                    if (questions.length > 4)
                      Text(
                        '+${questions.length - 4} more…',
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
