import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class ModuleLearningScreen extends ConsumerStatefulWidget {
  const ModuleLearningScreen({required this.moduleId, super.key});
  final String moduleId;

  @override
  ConsumerState<ModuleLearningScreen> createState() => _ModuleLearningScreenState();
}

class _ModuleLearningScreenState extends ConsumerState<ModuleLearningScreen> {
  Future<List<Map<String, dynamic>>> _loadLectures() async {
    final result = await ref
        .read(lessonFeatureViewModelProvider)
        .moduleLectures(widget.moduleId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Module Learning')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadLectures(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final lectures = snapshot.data!;
          if (lectures.isEmpty) {
            return const Center(child: Text('Khong co lecture, hoac module dang duoc cap nhat.'));
          }
          return ListView.builder(
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              final item = lectures[index];
              final id = (item['lectureId'] ?? item['LectureId'] ?? '').toString();
              final title = (item['title'] ?? item['Title'] ?? 'Lecture').toString();
              return ListTile(
                title: Text(title),
                onTap: () => context.push('${RoutePaths.lectureDetail}?lectureId=$id'),
              );
            },
          );
        },
      ),
    );
  }
}
