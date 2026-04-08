import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/teacher/teacher_info_list_tile.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourses = ref.watch(teacherMyCoursesDataProvider);
    return asyncCourses.when(
      data: (list) => CatalunyaScaffold(
        appBar: AppBar(
          title: const Text('Trang giáo viên'),
          actions: [
            IconButton(
              onPressed: () => context.push(RoutePaths.teacherCreateCourse),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
        body: list.isEmpty
            ? const Center(
                child: EmptyStateView(
                  message: 'Chưa có khóa học nào',
                  icon: Icons.school_outlined,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final c = list[index];
                  final id = c.courseId;
                  final title = c.title;
                  final desc = c.description;
                  final studentCount = c.studentCount;
                  return TeacherInfoListTile(
                    title: title,
                    subtitle: desc.isEmpty
                        ? 'Học viên: $studentCount'
                        : '$desc\nHọc viên: $studentCount',
                    onTap: () => context.push(
                      '${RoutePaths.teacherCourseDetail}?courseId=$id',
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
