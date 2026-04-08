import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class TeacherQuizAttemptDetailScreen extends ConsumerWidget {
  const TeacherQuizAttemptDetailScreen({required this.attemptId, super.key});
  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(
      teacherQuizAttemptDetailDataProvider(attemptId),
    );
    return asyncDetail.when(
      data: (detail) {
        final userName = detail.userName;
        final email = detail.email;
        final totalScore = detail.totalScore;
        final maxScore = detail.maxScore;
        final percentage = detail.percentage;
        final timeSpent = detail.timeSpentSeconds;
        final startedAt = detail.startedAt;
        final submittedAt = detail.submittedAt;
        final status = detail.status;
        final questions = detail.questions;
        return Scaffold(
          appBar: AppBar(title: const Text('Teacher Quiz Attempt Detail')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text(userName),
                  subtitle: Text(
                    'Diem: $totalScore/$maxScore ($percentage%)\n'
                    '${email.isEmpty ? '' : '$email\n'}'
                    'Time: ${timeSpent}s â€¢ Status: $status',
                  ),
                  isThreeLine: true,
                ),
              ),
              const SizedBox(height: 8),
              if (startedAt.isNotEmpty || submittedAt.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Moc thoi gian'),
                    subtitle: Text(
                      'Bat dau: ${startedAt.isEmpty ? 'N/A' : startedAt}\n'
                      'Nộp bài: ${submittedAt.isEmpty ? 'N/A' : submittedAt}',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Chi tiet cau hoi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...questions.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                final questionText = q.questionText;
                final isCorrect = q.isCorrect;
                final userAnswer = q.userAnswerText;
                final correctAnswer = q.correctAnswerText;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Cau ${idx + 1}: $questionText'),
                            ),
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Tra loi: $userAnswer'),
                        if (correctAnswer.isNotEmpty)
                          Text('Dap an dung: $correctAnswer'),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
    );
  }
}

