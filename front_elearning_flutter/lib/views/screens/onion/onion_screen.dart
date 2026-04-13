import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';
import '../../widgets/common/catalunya_reveal.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/catalunya_nav_tile.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/course/join_class_dialog.dart';
import '../../widgets/course/my_course_list_item.dart';

class OnionScreen extends ConsumerStatefulWidget {
  const OnionScreen({super.key});

  @override
  ConsumerState<OnionScreen> createState() => _OnionScreenState();
}

class _OnionScreenState extends ConsumerState<OnionScreen> {
  bool _isJoining = false;

  Future<void> _handleJoinClass() async {
    final classCode = await showDialog<String>(
      context: context,
      builder: (_) => const JoinClassDialog(),
    );

    if (classCode == null || classCode.trim().isEmpty) {
      return;
    }

    setState(() => _isJoining = true);
    final result = await ref
        .read(learningFeatureViewModelProvider)
        .joinByClassCode(classCode.trim());
    setState(() => _isJoining = false);

    if (!mounted) return;

    switch (result) {
      case Success<void>():
        ref.invalidate(myCoursesListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tham gia lớp học thành công')),
        );
      case Failure<void>(:final error):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourses = ref.watch(myCoursesListProvider);
    return CatalunyaScaffold(
      appBar: AppBar(
        title: const Text('Khóa học của tôi'),
        actions: [
          TextButton.icon(
            onPressed: _isJoining ? null : _handleJoinClass,
            icon: _isJoining
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Nhập mã lớp'),
          ),
        ],
      ),
      body: asyncCourses.when(
        data: (courses) {
          if (courses.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              children: [
                CatalunyaReveal(
                  child: CatalunyaNavTile(
                    title: 'Nhập mã lớp học',
                    subtitle: 'Tham gia khóa học bằng mã lớp như bản web',
                    leading: const Icon(Icons.group_add_rounded),
                    onTap: _isJoining ? null : _handleJoinClass,
                  ),
                ),
                const SizedBox(height: 28),
                const EmptyStateView(
                  message: 'Bạn chưa đăng ký khóa học nào',
                  icon: Icons.library_books_outlined,
                ),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myCoursesListProvider);
              await ref.read(myCoursesListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: courses.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CatalunyaReveal(
                    child: CatalunyaNavTile(
                      title: 'Nhập mã lớp học',
                      subtitle: 'Tham gia khóa học bằng mã lớp như bản web',
                      leading: const Icon(Icons.group_add_rounded),
                      onTap: _isJoining ? null : _handleJoinClass,
                    ),
                  );
                }

                final itemIndex = index - 1;
                final c = courses[itemIndex];
                return CatalunyaReveal(
                  delay: Duration(milliseconds: itemIndex * 40),
                  child: MyCourseListItem(
                    item: c,
                    index: itemIndex,
                    onTap: () => context.push(
                      '${RoutePaths.courseDetail}?courseId=${c.courseId}',
                    ),
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
