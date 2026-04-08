import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';

class LessonResultScreen extends ConsumerWidget {
  const LessonResultScreen({required this.attemptId, super.key});
  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(lessonResultProvider(attemptId));
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Kết quả bài học')),
      body: asyncData.when(
        data: (data) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CatalunyaCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      'Điểm: ${data.score}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đúng ${data.correctAnswers} / ${data.totalQuestions} câu',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) => ErrorStateView(message: '$error'),
      ),
    );
  }
}
