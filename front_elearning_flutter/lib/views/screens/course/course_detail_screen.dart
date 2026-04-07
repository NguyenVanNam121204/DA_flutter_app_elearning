import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({required this.courseId, super.key});
  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<dynamic> _load() async {
    final result = await ref
        .read(lessonFeatureViewModelProvider)
        .courseDetail(widget.courseId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: FutureBuilder<dynamic>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(child: Text('Khong the tai khoa hoc: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final map = snapshot.data as Map<String, dynamic>;
          final title = (map['title'] ?? map['Title'] ?? 'Course').toString();
          final description = (map['description'] ?? map['Description'] ?? '').toString();
          final imageUrl = (map['imageUrl'] ?? map['ImageUrl'])?.toString();
          final courseId = (map['courseId'] ?? map['CourseId'] ?? widget.courseId).toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, height: 180, fit: BoxFit.cover),
                ),
              if (imageUrl != null && imageUrl.isNotEmpty) const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text(description),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.push('${RoutePaths.lessonList}?courseId=$courseId'),
                child: const Text('Vao danh sach bai hoc'),
              ),
            ],
          );
        },
      ),
    );
  }
}
