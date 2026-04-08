import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/teacher/teacher_info_list_tile.dart';

class TeacherCourseSubmissionsScreen extends ConsumerWidget {
  const TeacherCourseSubmissionsScreen({required this.essayId, super.key});
  final String essayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(teacherEssaySubmissionsDataProvider(essayId));
    return asyncItems.when(
      data: (items) => CatalunyaScaffold(
        appBar: AppBar(title: const Text('Bài nộp tự luận')),
        body: items.isEmpty
            ? const Center(
                child: EmptyStateView(
                  message: 'Chưa có bài nộp nào',
                  icon: Icons.assignment_outlined,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final s = items[index];
                  return TeacherInfoListTile(
                    title: s.studentName,
                    subtitle: 'Trạng thái: ${s.status} • Điểm: ${s.score}',
                    onTap: () => context.push(
                      '${RoutePaths.teacherSubmissionDetail}?submissionId=${s.submissionId}',
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
