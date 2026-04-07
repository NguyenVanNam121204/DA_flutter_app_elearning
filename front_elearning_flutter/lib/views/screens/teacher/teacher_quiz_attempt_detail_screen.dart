import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class TeacherQuizAttemptDetailScreen extends ConsumerWidget {
  const TeacherQuizAttemptDetailScreen({required this.attemptId, super.key});
  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<Map<String, dynamic>>>(
      future: ref.read(teacherFeatureViewModelProvider).quizAttemptDetail(attemptId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final map = (result as Success<Map<String, dynamic>>).value;
        final userName = (map['userName'] ?? map['UserName'] ?? 'Hoc vien').toString();
        final email = (map['email'] ?? map['Email'] ?? '').toString();
        final totalScore = (map['totalScore'] ?? map['TotalScore'] ?? '-').toString();
        final maxScore = (map['maxScore'] ?? map['MaxScore'] ?? '-').toString();
        final percentage = (map['percentage'] ?? map['Percentage'] ?? '-').toString();
        final timeSpent = (map['timeSpentSeconds'] ?? map['TimeSpentSeconds'] ?? 0).toString();
        final startedAt = (map['startedAt'] ?? map['StartedAt'] ?? '').toString();
        final submittedAt = (map['submittedAt'] ?? map['SubmittedAt'] ?? '').toString();
        final status = (map['status'] ?? map['Status'] ?? 'N/A').toString();
        final questions = ((map['questions'] ?? map['Questions']) as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            const <Map<String, dynamic>>[];
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
                    'Time: ${timeSpent}s • Status: $status',
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
                      'Nop bai: ${submittedAt.isEmpty ? 'N/A' : submittedAt}',
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text('Chi tiet cau hoi', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...questions.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                final questionText = (q['questionText'] ?? q['QuestionText'] ?? '').toString();
                final isCorrect = (q['isCorrect'] ?? q['IsCorrect'] ?? false) == true;
                final userAnswer = (q['userAnswerText'] ?? q['UserAnswerText'] ?? 'Chua tra loi').toString();
                final correctAnswer = (q['correctAnswerText'] ?? q['CorrectAnswerText'] ?? '').toString();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('Cau ${idx + 1}: $questionText')),
                            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Tra loi: $userAnswer'),
                        if (correctAnswer.isNotEmpty) Text('Dap an dung: $correctAnswer'),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
