import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder shown when there's no response ID (unchanged UX)
class ResultPlaceholderScreen extends ConsumerWidget {
  const ResultPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Survey Result')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: const Text(
            "Submit a survey to view results here.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.5),
          ),
        ),
      ),
    );
  }
}
