import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/teacher/teacher_info_list_tile.dart';

class TeacherQuizAttemptsScreen extends ConsumerWidget {
  const TeacherQuizAttemptsScreen({required this.quizId, super.key});
  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(teacherQuizAttemptsDataProvider(quizId));
    return asyncItems.when(
      data: (items) => CatalunyaScaffold(
        appBar: AppBar(title: const Text('Lượt làm bài quiz')),
        body: items.isEmpty
            ? const Center(
                child: EmptyStateView(
                  message: 'Chưa có lượt làm bài',
                  icon: Icons.fact_check_outlined,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final a = items[index];
                  return TeacherInfoListTile(
                    title: a.studentName,
                    subtitle: 'Điểm: ${a.totalScore} • ${a.percentage}%',
                    onTap: () => context.push(
                      '${RoutePaths.teacherQuizAttemptDetail}?attemptId=${a.attemptId}',
                    ),
                  );
                },
              ),
      ),
      loading: () => const CatalunyaScaffold(body: LoadingStateView()),
      error: (error, _) =>
          CatalunyaScaffold(body: ErrorStateView(message: '$error')),
    );
  }
}
