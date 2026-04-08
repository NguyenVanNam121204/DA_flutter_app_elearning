import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({required this.courseId, super.key});
  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncCourse = ref.watch(courseDetailDataProvider(widget.courseId));
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Chi tiết khóa học')),
      body: asyncCourse.when(
        data: (course) {
          final title = course.title;
          final description = course.description;
          final imageUrl = course.imageUrl;
          final courseId = course.courseId.isEmpty
              ? widget.courseId
              : course.courseId;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              CatalunyaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imageUrl,
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (imageUrl.isNotEmpty) const SizedBox(height: 14),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(description),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () =>
                    context.push('${RoutePaths.lessonList}?courseId=$courseId'),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Vào danh sách bài học'),
              ),
            ],
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) =>
            ErrorStateView(message: 'Không thể tải khóa học: $error'),
      ),
    );
  }
}
