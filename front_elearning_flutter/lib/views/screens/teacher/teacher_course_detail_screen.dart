import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';

class TeacherCourseDetailScreen extends ConsumerWidget {
  const TeacherCourseDetailScreen({required this.courseId, super.key});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourse = ref.watch(teacherCourseDetailDataProvider(courseId));
    return asyncCourse.when(
      data: (course) {
        final title = course.title;
        final desc = course.description;
        final imageUrl = course.imageUrl;
        final level = course.level;
        return CatalunyaScaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                onPressed: () => context.push(
                  '${RoutePaths.teacherClasses}?courseId=$courseId',
                ),
                icon: const Icon(Icons.group),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                ),
              if (imageUrl.isNotEmpty) const SizedBox(height: 12),
              CatalunyaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    if (level.isNotEmpty) Chip(label: Text('Level: $level')),
                    const SizedBox(height: 8),
                    Text(desc.isEmpty ? 'Chưa có mô tả' : desc),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(
                  '${RoutePaths.teacherClasses}?courseId=$courseId',
                ),
                icon: const Icon(Icons.group),
                label: const Text('Quản lý học viên'),
              ),
            ],
          ),
        );
      },
      loading: () => const CatalunyaScaffold(body: LoadingStateView()),
      error: (error, _) =>
          CatalunyaScaffold(body: ErrorStateView(message: '$error')),
    );
  }
}
