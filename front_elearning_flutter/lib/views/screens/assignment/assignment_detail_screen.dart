import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_nav_tile.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';

class AssignmentDetailScreen extends ConsumerStatefulWidget {
  const AssignmentDetailScreen({
    required this.assessmentId,
    required this.moduleId,
    super.key,
  });
  final String assessmentId;
  final String moduleId;

  @override
  ConsumerState<AssignmentDetailScreen> createState() =>
      _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState
    extends ConsumerState<AssignmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final arg = '${widget.assessmentId}::${widget.moduleId}';
    final asyncData = ref.watch(assignmentDetailProvider(arg));
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Chi tiết bài tập')),
      body: asyncData.when(
        data: (data) {
          final quizzes = data.quizzes;
          final essays = data.essays;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Quiz', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...quizzes.map((q) {
                return CatalunyaNavTile(
                  title: q.title,
                  subtitle: 'Bắt đầu làm quiz',
                  onTap: () =>
                      context.push('${RoutePaths.quiz}?quizId=${q.quizId}'),
                );
              }),
              const SizedBox(height: 16),
              Text('Tự luận', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...essays.map((e) {
                return CatalunyaNavTile(
                  title: e.title,
                  subtitle: 'Viết và nộp bài tự luận',
                  onTap: () =>
                      context.push('${RoutePaths.essay}?essayId=${e.essayId}'),
                );
              }),
            ],
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) => ErrorStateView(message: '$error'),
      ),
    );
  }
}
