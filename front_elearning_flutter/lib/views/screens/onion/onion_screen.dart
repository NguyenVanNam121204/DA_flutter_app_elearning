import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/course/my_course_list_item.dart';

class OnionScreen extends ConsumerWidget {
  const OnionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourses = ref.watch(myCoursesListProvider);
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Khóa học của tôi')),
      body: asyncCourses.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const EmptyStateView(
              message: 'Bạn chưa đăng ký khóa học nào',
              icon: Icons.library_books_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myCoursesListProvider);
              await ref.read(myCoursesListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final c = courses[index];
                return MyCourseListItem(
                  item: c,
                  index: index,
                  onTap: () => context.push(
                    '${RoutePaths.courseDetail}?courseId=${c.courseId}',
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) => ErrorStateView(message: '$error'),
      ),
    );
  }
}
