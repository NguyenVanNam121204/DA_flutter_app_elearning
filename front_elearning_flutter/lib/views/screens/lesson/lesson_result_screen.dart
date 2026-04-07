import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class LessonResultScreen extends ConsumerWidget {
  const LessonResultScreen({required this.attemptId, super.key});
  final String attemptId;

  Future<Map<String, dynamic>> _load(WidgetRef ref) async {
    final result = await ref.read(lessonFeatureViewModelProvider).lessonResult(attemptId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Result')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final score = data['score'] ?? data['Score'] ?? '-';
          final correct = data['correctAnswers'] ?? data['CorrectAnswers'] ?? '-';
          final total = data['totalQuestions'] ?? data['TotalQuestions'] ?? '-';
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Diem: $score', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Dung $correct / $total cau'),
              ],
            ),
          );
        },
      ),
    );
  }
}
