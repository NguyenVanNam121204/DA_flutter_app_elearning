import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({required this.lessonId, super.key});
  final String lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  Future<Map<String, dynamic>> _loadLesson() async {
    final result = await ref.read(lessonFeatureViewModelProvider).lessonDetailBundle(widget.lessonId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  int _contentType(Map<String, dynamic> m) {
    final raw = m['contentType'] ?? m['ContentType'] ?? 1;
    if (raw is int) return raw;
    return int.tryParse(raw.toString()) ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Detail')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadLesson(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final lesson = data['lesson'] as Map<String, dynamic>;
          final modules = data['modules'] as List<Map<String, dynamic>>;
          final title = (lesson['title'] ?? lesson['Title'] ?? 'Lesson').toString();
          final description = (lesson['description'] ?? lesson['Description'] ?? '').toString();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              if (description.isNotEmpty) Text(description),
              const SizedBox(height: 16),
              Text('Noi dung bai hoc', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...modules.map((m) {
                final moduleId = (m['moduleId'] ?? m['ModuleId'] ?? '').toString();
                final name = (m['name'] ?? m['Name'] ?? 'Module').toString();
                final type = _contentType(m);
                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('Type: $type'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (type == 3) {
                        context.push('${RoutePaths.assignmentDetail}?moduleId=$moduleId');
                      } else {
                        context.push('${RoutePaths.moduleLearning}?moduleId=$moduleId');
                      }
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
