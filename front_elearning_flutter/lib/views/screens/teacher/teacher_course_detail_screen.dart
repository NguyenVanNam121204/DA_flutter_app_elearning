import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class TeacherCourseDetailScreen extends ConsumerWidget {
  const TeacherCourseDetailScreen({required this.courseId, super.key});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<Map<String, dynamic>>>(
      future: ref.read(teacherFeatureViewModelProvider).courseDetail(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final map = (result as Success<Map<String, dynamic>>).value;
        final title = (map['title'] ?? map['Title'] ?? 'Course').toString();
        final desc = (map['description'] ?? map['Description'] ?? '').toString();
        final imageUrl = (map['imageUrl'] ?? map['ImageUrl'] ?? '').toString();
        final level = (map['level'] ?? map['Level'] ?? '').toString();
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                onPressed: () => context.push('${RoutePaths.teacherClasses}?courseId=$courseId'),
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
                  child: Image.network(imageUrl, height: 170, fit: BoxFit.cover),
                ),
              if (imageUrl.isNotEmpty) const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              if (level.isNotEmpty) Chip(label: Text('Level: $level')),
              const SizedBox(height: 8),
              Text(desc.isEmpty ? 'Chua co mo ta' : desc),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('${RoutePaths.teacherClasses}?courseId=$courseId'),
                icon: const Icon(Icons.group),
                label: const Text('Quan ly hoc vien'),
              ),
            ],
          ),
        );
      },
    );
  }
}
