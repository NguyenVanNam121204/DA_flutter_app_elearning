import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<List<Map<String, dynamic>>>>(
      future: ref.read(teacherFeatureViewModelProvider).myCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final list = (result as Success<List<Map<String, dynamic>>>).value;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Teacher Home'),
            actions: [
              IconButton(
                onPressed: () => context.push(RoutePaths.teacherCreateCourse),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: list.isEmpty
              ? const Center(child: Text('Chua co khoa hoc nao'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final c = list[index];
                    final id = (c['courseId'] ?? c['CourseId'] ?? '').toString();
                    final title = (c['title'] ?? c['Title'] ?? 'Course').toString();
                    final desc = (c['description'] ?? c['Description'] ?? '').toString();
                    final studentCount = (c['studentCount'] ?? c['StudentCount'] ?? 0).toString();
                    return Card(
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(
                          desc.isEmpty ? 'Hoc vien: $studentCount' : '$desc\nHoc vien: $studentCount',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('${RoutePaths.teacherCourseDetail}?courseId=$id'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
