import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class TeacherQuizAttemptsScreen extends ConsumerWidget {
  const TeacherQuizAttemptsScreen({required this.quizId, super.key});
  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<List<Map<String, dynamic>>>>(
      future: ref.read(teacherFeatureViewModelProvider).quizAttempts(quizId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final items = (result as Success<List<Map<String, dynamic>>>).value;
        return Scaffold(
          appBar: AppBar(title: const Text('Quiz Attempts')),
          body: items.isEmpty
              ? const Center(child: Text('Chua co luot lam bai'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final a = items[index];
                    final id = (a['attemptId'] ?? a['AttemptId'] ?? '').toString();
                    final user = (a['studentName'] ?? a['StudentName'] ?? 'Hoc vien').toString();
                    final score = (a['totalScore'] ?? a['TotalScore'] ?? '-').toString();
                    final percent = (a['percentage'] ?? a['Percentage'] ?? '-').toString();
                    return Card(
                      child: ListTile(
                        title: Text(user),
                        subtitle: Text('Score: $score • $percent%'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('${RoutePaths.teacherQuizAttemptDetail}?attemptId=$id'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
