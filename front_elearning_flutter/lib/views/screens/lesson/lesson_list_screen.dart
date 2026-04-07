import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class LessonListScreen extends ConsumerStatefulWidget {
  const LessonListScreen({required this.courseId, super.key});
  final String courseId;

  @override
  ConsumerState<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends ConsumerState<LessonListScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final result = await ref
        .read(lessonFeatureViewModelProvider)
        .lessonsByCourse(widget.courseId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson List')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data!;
          if (lessons.isEmpty) return const Center(child: Text('Khong co bai hoc'));
          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final item = lessons[index];
              final id = (item['lessonId'] ?? item['LessonId'] ?? '').toString();
              final title = (item['title'] ?? item['Title'] ?? 'Lesson').toString();
              return ListTile(
                title: Text(title),
                subtitle: Text('ID: $id'),
                onTap: () => context.push('${RoutePaths.lessonDetail}?lessonId=$id'),
              );
            },
          );
        },
      ),
    );
  }
}
